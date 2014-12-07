// Kristina Ming
// kming@g.hmc.edu
// E155 Lab 2
// September 22, 2014

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

/* module for a 2 input multiplexer (w/ 4-bit inputs) */
module mux24(input  logic [3:0] d0, d1,
			 input  logic s,
			 output logic [3:0] y);
				
	assign y = s ? d1 : d0;
endmodule

/* module to multiplex two seven segment displays based on
   a counter */
module multiplexDisplay(input  logic clk, reset,
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

/* wrapper module to sum two 4-bit numbers and display
   their sum on the LED array */
module ledSum(input  logic [3:0] a, b,
			  output logic [7:0] leds);
	
	// compute the sum
	logic [4:0] sum;
	assign sum = a + b;
	
	// write the sum to the LED array
	assign leds[7:3] = sum;
	assign leds[2:0] = 3'b000;
endmodule

/* main module to multiplex the two seven segment
   displays and display the sum of the two numbers */
module lab2_KM (input  logic clk, reset,
				input  logic [3:0] s1, s2,
				output logic [7:0] led,
				output logic [6:0] seg,
				output logic disp1, disp2);

	logic multiplex;
	logic [3:0] switches;
	logic [4:0] sum;
	
	multiplexDisplay chooseDisplay(clk, reset, multiplex, disp1, disp2);
	mux24 switchMux(s1, s2, multiplex, switches);
	sevenSeg sevenSegDisp(switches, seg);
	ledSum displaySum(s1, s2, led);
endmodule
