// Kaitlin Kimberling and Kristina Ming
// E155 Final Project: Non-Invasive Heart Rate Monitor

/* signal processing code for FPGA */
module signal_processing(input logic clk, reset, 
								 input  logic sck, sdo, sdi,
								 //input logic [9:0] voltage,
								 output logic peakLED, DACserial, load, LDAC, DACclk,
								 output logic [7:0] leds,
								 //output logic [2:0] disp,
								 output logic disp1, disp2, disp3,
								 output logic [6:0] seven13, seven2);//numPeaks, numTroughs);
	//filter f1(clk, reset, voltage, filtered);
	logic foundPeak;
	logic peak;
	logic [9:0] filtered;
	logic [15:0] voltageOutput;
	logic [11:0] heartRate;
	logic [3:0] digit1, digit2, digit3;
	logic multiplex;
	logic [3:0] sevenIn;
	logic [7:0] numPeaks;
	logic [7:0] dummyLEDs;
	logic [28:0] count;
	
	spi_slave ss(sck, sdo, sdi, reset, d, q, voltageOutput);//voltage);
	filter f1(reset, sck, voltageOutput[9:0], filtered);
	findPeaks peakFinder(clk, reset, sck, filtered[9:0], foundPeak, leds[7:0], numPeaks, peakLED);
	DAC d1(sck, reset, filtered[9:0], DACserial, load, LDAC, DACclk);
	//getDigits gd(heartRate, digit1, digit2, digit3);
	//multiplexDisplay md(clk, reset, disp, multiplex);
	//mux34 m34(digit1, digit2, digit3, multiplex, sevenIn);
	multiplex2Displays chooseDisplay(clk, reset, multiplex, disp1, disp3);
	mux24 dispMux(digit1, digit3, multiplex, sevenIn);
	sevenSeg s13(sevenIn, seven13);
	sevenSeg s2(digit2, seven2);
	countPeaks64 cp(clk, reset, foundPeak, heartRate, numPeaks, count);
	
	assign digit1 = heartRate[3:0];
	assign digit2 = heartRate[7:4];
	assign digit3 = heartRate[11:8];
	
	//assign leds[4:0] = 5'b11111;
	
	//assign leds[7:5] = multiplex;
	//assign heartRate = 123;
	//assign leds[7:0] = count[28:21];
endmodule

/* module to apply a digital FIR filter to an input signal */
module filter(input logic reset, sck,
			  input logic [9:0] voltage,
			  output logic [9:0] filteredSignal);
			  
	logic [3:0] count; // count to 32 (it takes 32 cycles to have all
					   // of the SPI data
			  
	// filter coefficients
	logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10;
	logic [31:0] a11, a12, a13, a14, a15;
	
	// delayed voltage values
	logic [9:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10;
	logic [9:0] v11, v12, v13, v14, v15, v16, v17, v18, v19, v20;
	logic [9:0] v21, v22, v23, v24, v25, v26, v27, v28, v29, v30;	
	
	logic [15:0] intermediateFiltered;
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			count <= 0;
		else count <= count + 5'b1;
	
	// assign FIR filter coefficients
	always_comb
		begin
	
			
			// Multiplying by 1024 = 2^10
			a0 = 3;
			a1 = 4;
			a2 = 6;
			a3 = 8;
			a4 = 12;
			a5 = 17;
			a6 = 23;
			a7 = 29;
			a8 = 36;
			a9 = 43;
			a10 = 50;
			a11 = 56;
			a12 = 61;
			a13 = 65;
			a14 = 67;
			a15 = 68;
		end
	
	// shift register to delay the voltage signal
	always_ff @(posedge sck)
		if (count == 0)
			begin
				v0 <= v1;
				v1 <= v2;
				v2 <= v3;
				v3 <= v4;
				v4 <= v5;
				v5 <= v6;
				v6 <= v7;
				v7 <= v8;
				v8 <= v9;
				v9 <= v10;
				v10 <= v11;
				v11 <= v12;
				v12 <= v13;
				v13 <= v14;
				v14 <= v15;
				v15 <= v16;
				v16 <= v17;
				v17 <= v18;
				v18 <= v19;
				v19 <= v20;
				v20 <= v21;
				v21 <= v22;
				v22 <= v23;
				v23 <= v24;
				v24 <= v25;
				v25 <= v26;
				v26 <= v27;
				v27 <= v28;
				v28 <= v29;
				v29 <= v30;
				v30 <= voltage;
				
				// calculate the filtered signal
				intermediateFiltered <= a0*(v0+v30) + a1*(v1+v29) + a2*(v2+v28) + a3*(v3+v27) + 
								  a4*(v4+v26) + a5*(v5+v25) + a6*(v6+v24) + a7*(v7+v23) + 
								  a8*(v8+v22) + a9*(v9+v21) + a10*(v10+v20) + a11*(v11+v19) +
								  a12*(v12+v18) + a13*(v13+v17) + a14*(v14+v16) + a15*v15;
				filteredSignal <= intermediateFiltered >> 10;				  
			end
endmodule

/* module to apply a digital FIR filter to an input signal */
module filter50(input logic reset, sck,
			  input logic [9:0] voltage,
			  output logic [9:0] filteredSignal);
			  
	logic [3:0] count; // count to 32 (it takes 32 cycles to have all
					   // of the SPI data
			  
	// filter coefficients
	logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10;
	logic [31:0] a11, a12, a13, a14, a15, a16, a17, a18, a19, a20;
	logic [31:0] a21, a22, a23, a24, a25;
	
	// delayed voltage values
	logic [9:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10;
	logic [9:0] v11, v12, v13, v14, v15, v16, v17, v18, v19, v20;
	logic [9:0] v21, v22, v23, v24, v25, v26, v27, v28, v29, v30;
	logic [9:0] v31, v32, v33, v34, v35, v36, v37, v38, v39, v40;
	logic [9:0] v41, v42, v43, v44, v45, v46, v47, v48, v49, v50;
	
	logic [15:0] intermediateFiltered;
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			count <= 0;
		else count <= count + 5'b1;
	
	// assign FIR filter coefficients
	always_comb
		begin
	
			
			// Multiplying by 2048 = 2^11
			a0 = 1;
			a1 = 1;
			a2 = 2;
			a3 = 3;
			a4 = 4;
			a5 = 6;
			a6 = 8;
			a7 = 11;
			a8 = 14;
			a9 = 18;
			a10 = 22;
			a11 = 27;
			a12 = 33;
			a13 = 38;
			a14 = 44;
			a15 = 51;
			a16 = 57;
			a17 = 63;
			a18 = 69;
			a19 = 75;
			a20 = 80;
			a21 = 84;
			a22 = 87;
			a23 = 90;
			a24 = 91;
			a25 = 92;
		end
	
	// shift register to delay the voltage signal
	always_ff @(posedge sck)
		if (count == 0)
			begin
				v0 <= v1;
				v1 <= v2;
				v2 <= v3;
				v3 <= v4;
				v4 <= v5;
				v5 <= v6;
				v6 <= v7;
				v7 <= v8;
				v8 <= v9;
				v9 <= v10;
				v10 <= v11;
				v11 <= v12;
				v12 <= v13;
				v13 <= v14;
				v14 <= v15;
				v15 <= v16;
				v16 <= v17;
				v17 <= v18;
				v18 <= v19;
				v19 <= v20;
				v20 <= v21;
				v21 <= v22;
				v22 <= v23;
				v23 <= v24;
				v24 <= v25;
				v26 <= v27;
				v27 <= v28;
				v28 <= v29;
				v29 <= v30;
				v30 <= v31;
				v31 <= v32;
				v32 <= v33;
				v33 <= v34;
				v34 <= v35;
				v35 <= v36;
				v36 <= v37;
				v37 <= v38;
				v38 <= v39;
				v39 <= v40;
				v40 <= v41;
				v41 <= v42;
				v42 <= v43;
				v43 <= v44;
				v44 <= v45;
				v45 <= v46;
				v46 <= v47;
				v47 <= v48;
				v48 <= v49;
				v49 <= v50;
				v50 <= voltage;
				
				// calculate the filtered signal
				intermediateFiltered <= a0*(v0+v50) + a1*(v1+v49) + a2*(v2+v48) + a3*(v3+v47) + 
								  a4*(v4+v46) + a5*(v5+v45) + a6*(v6+v44) + a7*(v7+v43) + 
								  a8*(v8+v42) + a9*(v9+v41) + a10*(v10+v40) + a11*(v11+v39) +
								  a12*(v12+v38) + a13*(v13+v37) + a14*(v14+v36) + a15*(v15+v35)
								  + a16*(v16+v34) + a17*(v17+v33) + a18*(v18+v32) + a19*(v19+v31)
								  + a20*(v20+v30) + a21*(v21+v29) +a22*(v22+v28) + a23*(v23+v27)
								  + a24*(v24+v26) + a25*v25;
				filteredSignal <= intermediateFiltered >> 11;				  
			end
endmodule
	
/* SPI slave module */
module spi_slave(input logic sck, // from master 
				 input logic sdo, // from master
				 output logic sdi, // to master
				 input logic reset,
				 input logic [15:0] d, // data to send 
				 output logic [15:0] q, // data received
				 output logic [15:0] voltage); // discrete output signal

	logic [3:0] cnt; 
	logic qdelayed;

	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset) 
		if (reset)
			cnt = 0;
		else cnt = cnt + 5'b1;

	// loadable shift register
	// loads d at the start, shifts sdo into bottom position on subsequent step 
	always_ff @(posedge sck)
		begin
			q <= (cnt == 0) ? d : {q[14:0], sdo};
			voltage <= (cnt == 0) ? q[14:0] : voltage;
		end

	// align sdi to falling edge of sck
	// load d at the start
	always_ff @(negedge sck)
		qdelayed = q[15];

	assign sdi = (cnt == 0) ? d[15] : qdelayed;
	
endmodule

/* module for DAC */
module DAC(input logic sck, reset,
		   input logic [9:0] filteredSignal,
		   output logic DACserial,
		   output logic load, LDAC, DACclk);
		   
	logic [1:0] A = 2'b00;
	logic RNG = 1'b0;
	logic [10:0] buffer;
	logic [3:0] count;
	logic [9:0] newSignal;
		  
	always_comb
		begin
			LDAC = 1'b0;
			DACclk = sck;
		end
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			begin
				count <= 1'b0;
				//load <= 1'b1;
			end
		else count <= count + 5'b1;
		
	always_ff @(posedge sck)
		if(count == 0)
			begin
				//newSignal <= filteredSignal;
				buffer <= {A,RNG,filteredSignal[7:0]};
				load <= 1'b1;
			end
			
		else if (count > 0 && count < 4'd12)
			begin
				DACserial <= buffer[10];
				buffer[10:0] <= {buffer[9:0], 1'b0};
			end
			
		else if (count == 4'd12)
			load <= 1'b0;
			
		else if (count == 4'd13)
			load <= 1'b1;
	
endmodule
		   

/* module to find the peaks of a signal */
/* We need to add a counter or something to tell it when to turn the
   foundPeak bit off. */
module findPeaks(input  logic clk, reset, sck,
				 input  logic[9:0] newSample,
				 output logic foundPeak,
				 output logic [7:0] leftSumLEDS, numPeaks,
				 output logic newDiff);
				 
	logic [3:0] sckcount;
	logic [9:0] oldSample, newDifference;
	logic [63:0] s; // shift register (buffer) to track slope change
	logic [9:0] leftSum, rightSum; // sum of left and right half of buffer
	logic [5:0] count; // 7-bit counter to keep track of how long findPeak should stay high.
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			sckcount <= 0;
		else sckcount <= sckcount + 5'b1;
	
	// keep track of if the slope is increasing or decreasing
	always_ff @(posedge sck)
		
		if (reset)
			begin
				count <= '0;
				leftSum <= 32;
				rightSum <= 32;
				foundPeak <= '0;
				numPeaks <= 0;
				s <= {64{1'b1}};//128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;//'0;
			end
			
		else if (sckcount == 0)
			begin
				oldSample <= newSample;
				
				// if the new value is greater than the old value, the
				// slope is increasing
				// if the new value is less than the old value, the slope
				// is decreasing
				
				newDifference <= ~((newSample - oldSample) > 0);
				
				// shift in the new indicator bit
				//s[127:0] <= {s[126:0], newDifference};
				s <= s << 1;
				s[0] <= newDifference;
				
				// keep track of the sum of the left and right sides of
				// the shift register
				rightSum <= rightSum + newDifference - s[31];
				leftSum <= leftSum + s[31] - s[63];
				
				// LED output (for debugging)
				leftSumLEDS[7:0] <= s[7:0];
				newDiff <= foundPeak;

				if ((leftSum <= 20) && (rightSum >= 16) && (count == 0) && (foundPeak == 0))// && !foundPeak)
					begin
						foundPeak <= 1'b1;
						count <= 7'b1;
						numPeaks <= numPeaks + 1;
					end
					
				// increment the counter if peak has been foundPeak
				else if(foundPeak && (count != 0))// && count != 0)
					count <= count + 1'b1;
					
				else
					foundPeak <= 1'b0;
			end
			//end
endmodule

/* module to find the peaks of a signal */
/* We need to add a counter or something to tell it when to turn the
   foundPeak bit off. */
module findPeaks128(input  logic clk, reset, sck,
				 input  logic[9:0] newSample,
				 output logic foundPeak,
				 output logic [7:0] leftSumLEDS, numPeaks,
				 output logic newDiff);
				 
	logic [3:0] sckcount;
	logic [9:0] oldSample, newDifference;
	logic [127:0] s; // shift register (buffer) to track slope change
	logic [6:0] leftSum, rightSum; // sum of left and right half of buffer
	logic [6:0] count; // 7-bit counter to keep track of how long findPeak should stay high.
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			sckcount <= 0;
		else sckcount <= sckcount + 5'b1;
	
	// keep track of if the slope is increasing or decreasing
	always_ff @(posedge sck)
		
		if (reset)
			begin
				count <= '0;
				leftSum <= 64;
				rightSum <= 64;
				foundPeak <= '0;
				numPeaks <= 0;
				s <= {128{1'b1}};
			end
			
		else if (sckcount == 0)
			begin
				oldSample <= newSample;
				
				// if the new value is greater than the old value, the
				// slope is increasing
				// if the new value is less than the old value, the slope
				// is decreasing
				
				newDifference <= ~((newSample - oldSample) > 0);
				
				// shift in the new indicator bit
				//s[127:0] <= {s[126:0], newDifference};
				s <= s << 1;
				s[0] <= newDifference;
				
				// keep track of the sum of the left and right sides of
				// the shift register
				rightSum <= rightSum + newDifference - s[63];
				leftSum <= leftSum + s[63] - s[127];
				
				// LED output (for debugging)
				leftSumLEDS[7:0] <= count[6:0];
				newDiff <= foundPeak;

				//if ((leftSum <= 40) && (rightSum >= 40) && (count == 0) && (foundPeak == 0))// && !foundPeak)
				if ((leftSum <= 40) && (rightSum >= 38) && (foundPeak == 0))
					begin
						foundPeak <= 1;
						numPeaks <= numPeaks + 1;
						count <= 1;
					end
					
				// increment the counter if peak has been foundPeak
				else if(foundPeak && (count != 0))// && count != 0)
					count <= count + 1;
					
				else if (foundPeak && (count == 0))
					begin
						foundPeak <= 0;
						count <= 0;
					end
				
				else
					foundPeak <= 0;
			end
			//end
endmodule

/* module to find the peaks of a signal */
/* We need to add a counter or something to tell it when to turn the
   foundPeak bit off. */
module findPeaks128_23(input  logic clk, reset, sck,
				 input  logic[9:0] newSample,
				 output logic foundPeak,
				 output logic [7:0] leftSumLEDS, numPeaks,
				 output logic newDiff);
				 
	logic [3:0] sckcount;
	logic [9:0] oldSample, newDifference;
	logic [255:0] s; // shift register (buffer) to track slope change
	logic [7:0] leftSum, rightSum; // sum of left and right half of buffer
	logic [7:0] count; // 7-bit counter to keep track of how long findPeak should stay high.
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			sckcount <= 0;
		else sckcount <= sckcount + 5'b1;
	
	// keep track of if the slope is increasing or decreasing
	always_ff @(posedge sck)
		
		if (reset)
			begin
				count <= '0;
				leftSum <= 128;
				rightSum <= 128;
				foundPeak <= '0;
				numPeaks <= 0;
				s <= {256{1'b1}};
			end
			
		else if (sckcount == 0)
			begin
				oldSample <= newSample;
				
				// if the new value is greater than the old value, the
				// slope is increasing
				// if the new value is less than the old value, the slope
				// is decreasing
				
				newDifference <= ~((newSample - oldSample) > 0);
				
				// shift in the new indicator bit
				//s[127:0] <= {s[126:0], newDifference};
				s <= s << 1;
				s[0] <= newDifference;
				
				// keep track of the sum of the left and right sides of
				// the shift register
				rightSum <= rightSum + newDifference - s[127];
				leftSum <= leftSum + s[127] - s[255];
				
				// LED output (for debugging)
				leftSumLEDS[7:0] <= count[6:0];
				newDiff <= foundPeak;

				//if ((leftSum <= 40) && (rightSum >= 40) && (count == 0) && (foundPeak == 0))// && !foundPeak)
				if ((leftSum <= 60) && (rightSum >= 60) && (foundPeak == 0))
					begin
						foundPeak <= 1;
						numPeaks <= numPeaks + 1;
						count <= 1;
					end
					
				// increment the counter if peak has been foundPeak
				else if(foundPeak && (count != 0))// && count != 0)
					count <= count + 1;
					
				else if (foundPeak && (count == 0))
					begin
						foundPeak <= 0;
						count <= 0;
					end
				
				else
					foundPeak <= 0;
			end
			//end
endmodule

/* module to find the peaks of a signal */
module findPeaks2(input  logic clk, reset, sck,
				 input  logic[9:0] newSample,
				 output logic foundPeak,
				 output logic [7:0] leftSumLEDS,
				 output logic newDiff);
				 
	logic [3:0] sckcount;
	logic [9:0] oldSample;
	logic [9:0] newDifference;
	logic [639:0] s; // shift register (buffer) to track slope change
	logic [31:0] leftSum, rightSum; // sum of left and right half of buffer
	logic [5:0] count; // 6-bit counter to keep track of how long findPeak should stay high.
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			sckcount <= 0;
		else sckcount <= sckcount + 5'b1;
	
	// keep track of if the slope is increasing or decreasing
	always_ff @(posedge sck)
		
		if (reset)
			begin
				count <= '0;
				leftSum <= 0;
				rightSum <= 0;
				foundPeak <= '0;
				s <= {640{1'b0}};//128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;//'0;
			end
			
		else if (sckcount == 0)
			begin
				oldSample <= newSample;
				
				// calculate the y difference between the new and old
				// samples
				
				newDifference <= newSample - oldSample;
				
				// shift in the new indicator bit
				s <= s << 10;
				s[9:0] <= newDifference;
				
				// keep track of the sum of the left and right sides of
				// the shift register
				rightSum <= rightSum + newDifference[9:0] - s[319:310];
				leftSum <= leftSum + s[319:310] - s[639:630];
				
				// LED output (for debugging)
				leftSumLEDS[7:0] <= leftSum[7:0];
				newDiff <= foundPeak;

				if ((leftSum > 200) && (rightSum < 15) && (count == 0) && (foundPeak == 0))// && !foundPeak)
					begin
						foundPeak <= 1'b1;
						count <= 7'b1;
					end
					
				// increment the counter if peak has been foundPeak
				else if(foundPeak && (count != 0))// && count != 0)
					count <= count + 1'b1;
					
				else
					foundPeak <= 1'b0;
			end
			//end
endmodule

/* decoder for the seven segment display
   to display a single hexadecimal digit
   specified by an input s */
module sevenSeg(input  logic [3:0] s,
                output logic [6:0] seg);
                
    always_comb
        case(s)
            4'b0000: seg = 7'b100_0000; // 0
            4'b0001: seg = 7'b111_1001; // 1
            4'b0010: seg = 7'b010_0100; // 2
            4'b0011: seg = 7'b011_0000; // 3
            4'b0100: seg = 7'b001_1001; // 4
            4'b0101: seg = 7'b001_0010; // 5
            4'b0110: seg = 7'b000_0010; // 6
            4'b0111: seg = 7'b111_1000; // 7
            4'b1000: seg = 7'b000_0000; // 8
            4'b1001: seg = 7'b001_1000; // 9
            4'b1010: seg = 7'b000_1000; // A
            4'b1011: seg = 7'b000_0011; // B
            4'b1100: seg = 7'b010_0111; // C
            4'b1101: seg = 7'b010_0001; // D
            4'b1110: seg = 7'b000_0110; // E
            4'b1111: seg = 7'b000_1110; // F
            default: seg = 7'b000_0000;
        endcase
endmodule

/* decoder for the seven segment display
   to display a single hexadecimal digit
   specified by an input s */
module sevenSeg2(input  logic [3:0] s,
                output logic [6:0] seg);
                
    always_comb
        case(s)
            4'b0000: seg = 7'b100_0000; // 0
            4'b0001: seg = 7'b111_1001; // 1
            4'b0010: seg = 7'b010_0100; // 2
            4'b0011: seg = 7'b011_0000; // 3
            4'b0100: seg = 7'b001_1001; // 4
            4'b0101: seg = 7'b001_0010; // 5
            4'b0110: seg = 7'b000_0010; // 6
            4'b0111: seg = 7'b111_1000; // 7
            4'b1000: seg = 7'b000_0000; // 8
            4'b1001: seg = 7'b001_1000; // 9
            4'b1010: seg = 7'b000_1000; // A
            4'b1011: seg = 7'b000_0011; // B
            4'b1100: seg = 7'b010_0111; // C
            4'b1101: seg = 7'b010_0001; // D
            4'b1110: seg = 7'b000_0110; // E
            4'b1111: seg = 7'b000_1110; // F
            default: seg = 7'b000_0000;
        endcase
endmodule

/* module for a 3 input multiplexer (w/ 4-bit inputs and
   2 bit selector) */
module mux34(input  logic [3:0] d0, d1, d2,
			 input  logic [2:0] s,
			 output logic [3:0] y);
				
	always_comb
		case(s)
			3'b001: y = d0;
			3'b010: y = d1;
			3'b100: y = d2;
			default y = d0;
		endcase
endmodule

/* module for a 2 input multiplexer (w/ 4-bit inputs) */
module mux24(input  logic [3:0] d0, d1,
			 input  logic s,
			 output logic [3:0] y);
				
	assign y = s ? d1 : d0;
endmodule

/* module to multiplex three seven segment displays based on
   a counter */
module multiplexDisplay(input  logic clk, reset,
						output logic [2:0] disp, multiplex);

	logic [28:0] counter = '0;
	logic [28:0] thresh = 28'd300000;
	
	// the human eye can only see ~40 fps, so we toggle our display
	// at a rate above that
	always_ff @(posedge clk, posedge reset)
		if (reset)
			begin
				counter <= '0;
				multiplex <= 3'b001;
			end
			
		else if (counter <= thresh)
			begin
				multiplex <= 3'b001;
				counter <= counter + 1'b1;
			end
			
		else if (counter > thresh && counter <= 2*thresh)
			begin
				multiplex <= 3'b010;
				counter <= counter + 1'b1;
			end
			
		else if (counter > 2*thresh && counter <= 3*thresh)
			begin
				multiplex <= 3'b100;
				counter <= counter + 1'b1;
			end
		
		else if (counter > 3*thresh)
			counter <= '0;
		
	// choose which 7-segment display to use
	assign disp = ~multiplex;

endmodule

/* module to multiplex two seven segment displays based on
   a counter */
module multiplex2Displays(input  logic clk, reset,
						output logic multiplex, disp1, disp2);

	logic [27:0] counter = '0;
	logic [27:0] thresh = 28'd250000;
	
	// the human eye can only see ~40 fps, so we toggle our display
	// at a rate above that
	always_ff @(posedge clk, posedge reset)
		if (reset)
			begin
				counter <= '0;
				multiplex <= '0;
			end
			
		else if (counter >= thresh)
			begin
				counter <='0;
				multiplex <= ~multiplex;
			end
			
		else
			begin
				multiplex <= multiplex;
				counter <= counter + 1'b1;
			end
		
	// choose which 7-segment display to use
	assign disp1 = multiplex;
	assign disp2 = ~multiplex;

endmodule

/* module to count the number of peaks over a certain time period 
   and output the heart rate */
module countPeaks(input logic clk, reset, foundPeak,
						output logic [11:0] heartRate,
						input logic [7:0] numPeaks,
						output logic [28:0] count);
	//logic [23:0] count;
	logic [28:0] thresh = 400000000; // Count up to 10s
	logic [3:0] periods = 6; // Multiply by this to get BPM
	//logic [7:0] numPeaks; 

	always_ff @(posedge clk, posedge reset)
		begin
			if (reset)
				begin
					//numPeaks <= '0;
					count <= '0;
				end
			
			else if(numPeaks > 2 && count < thresh)
				begin
					//if(~prevFP && foundPeak)
						//numPeaks <= numPeaks + 1;
					count <= count + 1'b1;
				end
				
			else if (count == thresh)
				begin
					heartRate <= (numPeaks - 3) * periods;
					count <= count + 1'b1;
					//numPeaks <= '0;
					//count <= '0;
				end
		end
endmodule

/* module to count the number of peaks over a certain time period 
   and output the heart rate */
module countPeaks64(input logic clk, reset, foundPeak,
						output logic [11:0] heartRate,
						input logic [7:0] numPeaks,
						output logic [28:0] count);
	//logic [23:0] count;
	logic [28:0] thresh = 400000000; // Count up to 10s
	logic [3:0] periods = 6; // Multiply by this to get BPM
	//logic [7:0] numPeaks; 

	always_ff @(posedge clk, posedge reset)
		begin
			if (reset)
				begin
					//numPeaks <= '0;
					count <= '0;
				end
			
			else if(numPeaks > 3 && count < thresh)
				begin
					//if(~prevFP && foundPeak)
						//numPeaks <= numPeaks + 1;
					count <= count + 1'b1;
				end
				
			else if (count == thresh)
				begin
					heartRate <= ((numPeaks - 3) >> 2)* periods;
					count <= count + 1'b1;
					//numPeaks <= '0;
					//count <= '0;
				end
		end
endmodule
				
/* module to get decimal digits from 3-digit decimal number */
module getDigits(input logic [7:0] heartRate,
				 output logic [3:0] digit1, digit2, digit3);
				 // digit1 is LSB
				 
				 logic [5:0] sum1, sum2;
				 logic overflow100, overflow30, overflow20, overflow10;
				 
	always_comb
		begin
			// Add ones digits and account for overflow
			sum1 = heartRate[0] + 2*heartRate[1] + 4*heartRate[2] + 8*heartRate[3]
			+ 6*heartRate[4] + 2*heartRate[5] + 4*heartRate[6] + 8*heartRate[7];
			overflow30 = sum1 > 29;
			overflow20 = (sum1 > 19) & (sum1 < 30);
			overflow10 = (sum1 > 9) & (sum1 < 20);
			digit1 = overflow30*(sum1 - 30) + overflow20*(sum1 - 20) + overflow10*(sum1 - 10)
			+ ~(overflow10 | overflow20 | overflow30)*sum1;
			
			// Add tens digits and account for overflow
			sum2= heartRate[4] + 3*heartRate[5] + 6*heartRate[6] + 2*heartRate[6]
			+ overflow10 + 2*overflow20 + 3*overflow30;
			overflow100 = sum2 > 99;
			digit2 = overflow100*(sum2 - 100) + (~overflow100)*sum2;
			
			// Hundreds digit
			digit3 = heartRate[7] + overflow100;
		end
endmodule
