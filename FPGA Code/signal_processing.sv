// signal processing code for FPGA
module signal_processing(input logic clk);

endmodule

module spi_slave(input logic sck, // from master 
					  input logic sdo, // from master
					  output logic sdi, // to master
					  input logic reset,
					  input logic [31:0] d, // data to send 
					  output logic [31:0] q, // data received
					  output logic [15:0] xCoor, yCoor); // cursor x and y coordinates

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
			xCoor <= (cnt == 0) ? q[31:16] : xCoor;
			yCoor <= (cnt == 0) ? q[15:0] : yCoor;
		end

	// align sdi to falling edge of sck // load d at the start
	always_ff @(negedge sck)
		qdelayed = q[31];

	assign sdi = (cnt == 0) ? d[31] : qdelayed;

endmodule