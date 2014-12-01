// signal processing code for FPGA
module signal_processing(input logic clk, reset, sck, sdo,
								 input logic [9:0] voltage,
								 input logic [29:0] a, // FIR filter coefficients
								 output logic sdi,
								 output logic [9:0] filtered);
	spi_slave ss(sck,sdo,sdi,reset,d,q,voltage);
endmodule

// module to apply a digital FIR filter to an input signal
module filter(input logic clk, reset,
			  input logic [9:0] voltage,
			  output logic [9:0] filtered);
	logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10;
	logic [31:0] a11, a12, a13, a14, a15;
	
	logic [9:0] v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10;
	logic [9:0] v11, v12, v13, v14, v15, v16, v17, v18, v19, v20;
	logic [9:0] v21, v22, v23, v24, v25, v26, v27, v28, v29, v30;	
	
	logic [9:0] filteredSignal;
	
	always_comb
		begin
			a0 = 0.0032;
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
			a15 = 0.0661;
		end
	
	always_ff @(posedge clk)
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
			
			filteredSignal <= a0*(v0+v30) + a1*(v1+v29) + a2*(v2+v28) + a3*(v3+v27) + a4*(v4+v26) + a5*(v5+v25) +
							  a6*(v6+v24) + a7*(v7+v23) + a8*(v8+v22) + a9*(v9+v21) + a10*(v10+v20) + a11*(v11+v19) +
							  a12*(v12+v18) + a13*(v13+v17) + a14*(v14+v16) + a15*v15;
		end
		
endmodule
	
// SPI slave module
module spi_slave(input logic sck, // from master 
					  input logic sdo, // from master
					  output logic sdi, // to master
					  input logic reset,
					  input logic [31:0] d, // data to send 
					  output logic [31:0] q, // data received
					  output logic [9:0] voltage); // discrete output signal

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
			voltage <= (cnt == 0) ? q[9:0] : voltage;
		end

	// align sdi to falling edge of sck // load d at the start
	always_ff @(negedge sck)
		qdelayed = q[31];

	assign sdi = (cnt == 0) ? d[31] : qdelayed;
	
	endmodule

// module to find the peaks and troughs of a signal
module findPeaksAndTroughs(input  logic clk, reset,
						   input  logic[9:0] inputSignal,
						   output logic [9:0] numPeaks, numTroughs);
						   
	logic[9:0] pastPast, past, present;
	
	always_ff @(posedge clk, posedge reset)
		begin
			pastPast <= past;
			past <= present
			
			if (reset)
				begin
					numPeaks <= 0;
					numTroughs <= 0;
				end
			
			if ((pastPast < past) && (present < past))
				numPeaks <= numPeaks + 1;
				
			if ((pastPast > past) && (past < present))
				numTroughs <= numTroughs +1;
		end

endmodule