// signal processing code for FPGA
module signal_processing(input logic clk, reset, sck, sdo,
								 input logic [9:0] voltage,
								 input logic [29:0] a, // FIR filter coefficients
								 output logic, sdi,
								 output logic [9:0] filtered);
	spi_slave ss(sck,sdo,sdi,reset,d,q,voltage);
endmodule

module filter(input logic clk, reset,
			  input logic [9:0] voltage,
			  output logic [9:0] filtered);
	logic [31:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10,
	all, a12, a13, a14, a15, a16, a17, a18, a19, a20,
	a21, a22, a23, a24, a25, a26, a27, a28, a29, a30;
	
	logic [4:0] multiplierSelect, multiplier;
	logic [31:0] filteredSignal;
	
	// set multiplier value (selector for a multiplexer)
	always_ff(@posedge clk)
		begin
			multiplierSelect <= multiplierSelect + 1;
		end
	
	// multiplexer to choose multiplier values
	always_comb
		case(multiplierSelect)
			32'd0:		multiplier = a0;
			32'd1:		multiplier = a1;
			
		endcase
		
	assign filteredSignal = filteredSignal + multiplier * voltage;
	
endmodule
	

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