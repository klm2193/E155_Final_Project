// Kaitlin Kimberling and Kristina Ming
// E155 Final Project: Non-Invasive Heart Rate Monitor

/* signal processing code for FPGA */
module signal_processing(input logic clk, reset, 
								 input  logic sck, sdo, sdi,
								 //input logic [9:0] voltage,
								 output logic peakLED);//numPeaks, numTroughs);
	//filter f1(clk, reset, voltage, filtered);
	logic foundPeak;
	logic peak;
	logic [9:0] filtered;
	logic [31:0] voltageOutput;
	spi_slave ss(sck, sdo, sdi, reset, d, q, voltageOutput);//voltage);
	filter f1(reset, sck, voltageOutput[9:0], filtered);
	findPeaks peakFinder(clk, reset, sck, voltageOutput[9:0], foundPeak, peak);
	assign peakLED = foundPeak;
endmodule

/* module to apply a digital FIR filter to an input signal */
module filter(input logic reset, sck,
			  input logic [9:0] voltage,
			  output logic [9:0] filteredSignal);
			  
	logic [4:0] count; // count to 32 (it takes 32 cycles to have all
					   // of the SPI data
			  
	// filter coefficients
	logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10;
	logic [31:0] a11, a12, a13, a14, a15;
	
	// delayed voltage values
	logic [9:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10;
	logic [9:0] v11, v12, v13, v14, v15, v16, v17, v18, v19, v20;
	logic [9:0] v21, v22, v23, v24, v25, v26, v27, v28, v29, v30;	
	
	logic [31:0] intermediateFiltered;
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			count <= 0;
		else count <= count + 5'b1;
	
	// assign FIR filter coefficients
	always_comb
		begin
	
			/*a0 = 0.0032;
			a1 = 0.0039;
			a2 = 0.0055;
			a3 = 0.0081;
			a4 = 0.0119;
			a5 = 0.0166;
			a6 = 0.0222;
			a7 = 0.0285;
			a8 = 0.0351;
			a9 = 0.0419;
			a10 = 0.0484;
			a11 = 0.0542;
			a12 = 0.0592;
			a13 = 0.0630;
			a14 = 0.0653;
			a15 = 0.0661;*/
			
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
	
/* SPI slave module */
module spi_slave(input logic sck, // from master 
				 input logic sdo, // from master
				 output logic sdi, // to master
				 input logic reset,
				 input logic [31:0] d, // data to send 
				 output logic [31:0] q, // data received
				 output logic [31:0] voltage); // discrete output signal

	logic [4:0] cnt; 
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
			q <= (cnt == 0) ? d : {q[30:0], sdo};
			voltage <= (cnt == 0) ? q[30:0] : voltage;
		end

	// align sdi to falling edge of sck
	// load d at the start
	always_ff @(negedge sck)
		qdelayed = q[31];

	assign sdi = (cnt == 0) ? d[31] : qdelayed;
	
endmodule

/* module for DAC */
module DAC(input logic clk, reset,
		   input logic [9:0] filteredSignal,
		   output logic DACserial,
		   output logic load, LDAC, DACclk);
		  
	always_comb
		begin
			LDAC = '0;
			DACclk = clk;
		end
	
	always_ff @(posedge clk)
		begin
			
		end
	
endmodule
		   

/* module to find the peaks of a signal */
/* We need to add a counter or something to tell it when to turn the
   foundPeak bit off. */
module findPeaks(input  logic clk, reset, sck,
				 input  logic[9:0] newSample,
				 output logic foundPeak,
				 output logic peak);
				 
	logic [4:0] sckcount;
	logic [9:0] oldSample, newDifference;
	logic [127:0] s; // shift register (buffer) to track slope change
	logic [9:0] leftSum, rightSum; // sum of left and right half of buffer
	logic [6:0] count; // 7-bit counter to keep track of how long findPeak should stay high.
	
	// 5-bit counter tracks when 32-bits is transmitted and new d should be sent
	always_ff @(negedge sck, posedge reset)
		if (reset)
			sckcount <= 0;
		else sckcount <= sckcount + 5'b1;
	
	// keep track of if the slope is increasing or decreasing
	always_ff @(posedge sck, posedge reset)
		
		if (reset)
			begin
				count <= '0;
				leftSum <= '0;
				rightSum <= '0;
				peak <= '0;
				foundPeak <= '0;
				s <= {50'h3FFFFFFFFFFFF, 50'h000000000000};
			end
		/*		
		else if(count == 24'd13000000)
			begin
				foundPeak <= 1'b0;
				count <= '0;
			end
		else*/
		else if (sckcount == 0)
			begin
				oldSample <= newSample;
				
				// if the new value is greater than the old value, the
				// slope is increasing
				if ((newSample - oldSample) > 0)
					newDifference <= 0;
				
				// if the new value is less than the old value, the slope
				// is decreasing
				else
					newDifference <= 1;
					
				// shift in the new indicator bit
				s <= {s[126:0], newDifference};
				
				// keep track of the sum of the left and right sides of
				// the shift register
				rightSum <= rightSum + newDifference - s[63];
				leftSum <= leftSum + s[64] - s[127];
				
				// if 4/5 of the left half are positive slopes
				// and 4/5 of the right half are negative slopes,
				// we have a peak  Erg, this is super sketchy!!
				if ((leftSum <= 20)&& (rightSum >= 40))// && !foundPeak)
					begin
						foundPeak <= 1'b1;
						count <= '0;
						peak <= 1'b1;
					end
					
				// increment the counter if peak has been foundPeak
				if(foundPeak)// && count != 0)
					count <= count + '1;
					
				else if(count == 20)
					peak <= 1'b0;
					
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

/* module for a 3 input multiplexer (w/ 4-bit inputs and
   2 bit selector) */
module mux24(input  logic [3:0] d0, d1, d2,
			 input  logic s[1:0],
			 output logic [3:0] y);
				
	always_comb
		case(s)
			2'b00: y = d0;
			2'b01: y = d1;
			2'b10: y = d2;
			default y = d0;
		endcase
endmodule

/* module to multiplex three seven segment displays based on
   a counter */
module multiplexDisplay(input  logic clk, reset,
						output logic disp1, disp2, disp3);

	logic [27:0] counter = '0;
	logic [27:0] thresh = 28'd250000;
	logic state1, state2, state3;
	
	// the human eye can only see ~40 fps, so we toggle our display
	// at a rate above that
	always_ff @(posedge clk, posedge reset)
		if (reset)
			begin
				counter <= '0;
				state1 <= '0;
				state2 <= '0;
				state3 <= '0;
			end
			
		else if (counter <= thresh)
			begin
				state1 <= '1;
				state2 <= '0;
				state3 <= '0;
				counter <= counter + 1'b1;
			end
			
		else if (counter > thresh && counter <= 2*thresh)
			begin
				state1 <= '0;
				state2 <= '1;
				state3 <= '0;
				counter <= counter + 1'b1;
			end
			
		else
			begin
				state1 <= '0;
				state2 <= '0;
				state3 <= '1;
				counter <= '0;
			end
		
	// choose which 7-segment display to use
	assign disp1 = state1;
	assign disp2 = state2;
	assign disp3 = state3;

endmodule

/* module to count the number of peaks over a certain time period 
   and output the heart rate */
module countPeaks(input logic clk, reset, foundPeak,
				  output logic [7:0] heartRate);
	logic [28:0] count;
	logic [28:0] thresh = 29'd400000000; // Count up to 10s
	logic [3:0] periods = 4'd6; // Multiply by this to get BPM
	logic [7:0] numPeaks; 

	always_ff @(posedge clk, posedge reset)
		begin
			if (reset)
				begin
					numPeaks <= '0;
					count <= '0;
				end
			
			else if (count < thresh)
				begin
					count <= count + 1'b1;
					/*always_ff @(posedge foundPeak)
						begin
							numPeaks <= numPeaks + 1'b1;
						end*/
				end
				
			else
				begin
					heartRate <= numPeaks * periods;
					numPeaks <= '0;
					count <= '0;
				end
		end
endmodule
				
/* module to get decimal digits from 3-digit decimal number */
module getDigits(input logic [7:0] heartRate,
				 output logic [3:0] digit1, digit2, digit3);
				 // digit1 is LSB
				 
				 logic [5:0] sum1, sum2;
				 logic [4:0] overflow100, overflow30, overflow20, overflow10;
				 
	always_comb
		begin
			// Add ones digits and account for overflow
			assign sum1 = 1'd1*heartRate[0] + 2'd2*heartRate[1] + 3'd4*heartRate[2] + 3'd8*heartRate[3]
			+ 3'd6*heartRate[4] + 2'd2*heartRate[5] + 3'd4*heartRate[6] + 3'd8*heartRate[7];
			assign overflow30 = sum1 > 5'd29;
			assign overflow20 = sum1 > 5'd19 & sum1 < 5'd30;
			assign overflow10 = sum1 > 4'd9 & sum1 < 5'd20;
			assign digit1 = overflow30*(sum1 - 5'd30) + overflow20*(sum1 - 5'd20) + overflow10*(sum1 - 4'd10)
			+ ~(overflow10 + overflow20 + overflow30)*sum1;
			
			// Add tens digits and account for overflow
			assign sum2= 1'd1*heartRate[4] + 2'd3*heartRate[5] + 3'd6*heartRate[6] + 2'd2*heartRate[6]
			+ overflow10 + 2'd2*overflow20 + 2'd3*overflow30;
			assign overflow100 = sum2 > 7'd99;
			assign digit2 = overflow100*(sum2 - 7'd100) + !overflow100*sum2;
			
			// Hundreds digit
			assign digit3 = heartRate[7] + overflow100;
		end
endmodule
			
	
// module to find the peaks and troughs of a signal
module findPeaksAndTroughs(input  logic clk, reset,
						   input  logic [9:0] inputSignal,
						   output logic [9:0] numPeaks, numTroughs);
						   
	logic [9:0] pastPast, past, present;
	
	always_ff @(posedge clk, posedge reset)
		begin
			pastPast <= past;
			past <= present;
			
			if (reset)
				begin
					numPeaks <= 0;
					numTroughs <= 0;
				end
			
			else if ((pastPast < past) && (present < past))
				numPeaks <= numPeaks + 1;
				
			else if ((pastPast > past) && (past < present))
				numTroughs <= numTroughs + 1;
			else
				begin
					numPeaks <= numPeaks;
					numTroughs <= numTroughs;
				end
		end
endmodule
