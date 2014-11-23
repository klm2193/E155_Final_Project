

module finalProject(input logic clk, sck, sdo, reset,
						  output logic sdi);
	signal_processing sp(clk, reset);
	spi_slave ss(sck, sdo, sdi, reset, d, q)
endmodule

// signal processing code for FPGA
module signal_processing(input logic clk, reset,
								 input logic [9:0] voltage,
								 input logic [29:0] a, // FIR filter coefficients
								 output logic [9:0] filtered);
	
endmodule

module spi_slave(input logic sck, // from master 
					  input logic sdo, // from master
					  output logic sdi, // to master
					  input logic reset,
					  input logic [9:0] d, // data to send 
					  output logic [9:0] q, // data received
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
			q <= (cnt == 0) ? d : {q[8:0], sdo};
		end

	// align sdi to falling edge of sck // load d at the start
	always_ff @(negedge sck)
		qdelayed = q[9];

	assign sdi = (cnt == 0) ? d[9] : qdelayed;

endmodule