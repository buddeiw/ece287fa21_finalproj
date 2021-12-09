/* 
	=====    CHILD MODULE    =====
	seven_segment.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input en 								Display enable signal
	input [3:0]i							4-bit decimal input
	output reg [6:0]o						7-bit signal to 7-seg display
	
	=====      FUNCTION      =====
	
	This module drives a 7-segment display with a 4-bit decimal input dependent on a 1-bit enable signal
	
*/

module seven_segment (
	input en,
	input [3:0]i,
	output reg [6:0]o
);


always@(*)
	begin
		if (en)
			begin
				case (i)
					// Display decimal value
					4'b0000: o = 7'b0000001;
					4'b0001: o = 7'b1001111;
					4'b0010: o = 7'b0010010;
					4'b0011: o = 7'b0000110;
					4'b0100: o = 7'b1001100;
					4'b0101: o = 7'b0100100;
					4'b0110: o = 7'b0100000;
					4'b0111: o = 7'b0001111;
					4'b1000: o = 7'b0000000;
					4'b1001: o = 7'b0000100;
					
					
					default: o = 7'b1111111;
				endcase
			end
		else
			begin
				// Default off
				o = 7'b1111111;
			end
		
		
	end

endmodule 