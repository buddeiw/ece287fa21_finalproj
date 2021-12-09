/* 
	=====    CHILD MODULE    =====
	velocity_decimal_val.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input [15:0]val 						16-bit input number
	output reg [7:0]ascii_thousands	8-bit thousands representation
	output reg [7:0]ascii_hundreds	8-bit hundreds representation	
	output reg [7:0]ascii_tens			8-bit tens representation
	output reg [7:0]ascii_ones			8-bit ones representation
	
	=====      FUNCTION      =====
	
	This module converts a 16-bit input number into four, 8-bit ASCII values for LCD display. The module assumes all positive integers, i.e. twos-complement
	is not handled.
	
*/

module velocity_decimal_val(
	input signed [15:0]val,
	output reg [7:0]ascii_thousands,
	output reg [7:0]ascii_hundreds,
	output reg [7:0]ascii_tens,
	output reg [7:0]ascii_ones
);

// 4-bit registers to hold decimal values of each place
reg [3:0]dec_thousands;
reg [3:0]dec_hundreds;
reg [3:0]dec_tens;
reg [3:0]dec_ones;

// Begin displaying all zeroes
initial
	begin
		ascii_thousands = 8'd48;
		ascii_hundreds = 8'd48;
		ascii_tens = 8'd48;
		ascii_ones = 8'd48;
	end

always @(*)
	begin
		// Determine decimal value of each place
		dec_thousands = val / 1000;
		dec_hundreds = (val / 100) % 10;
		dec_tens = (val / 10) % 10;
		dec_ones = val % 10;

		// Determine ascii_thousands
		case (dec_thousands)
	
			4'd0:
				begin
					ascii_thousands = 8'd48;
				end
			4'd1:
				begin
					ascii_thousands = 8'd49;
				end
			4'd2:
				begin
					ascii_thousands = 8'd50;
				end
			4'd3:
				begin
					ascii_thousands = 8'd51;
				end
			4'd4:
				begin
					ascii_thousands = 8'd52;
				end
			4'd5:
				begin
					ascii_thousands = 8'd53;
				end
			4'd6:
				begin
					ascii_thousands = 8'd54;
				end
			4'd7:
				begin
					ascii_thousands = 8'd55;
				end
			4'd8:
				begin
					ascii_thousands = 8'd56;
				end
			4'd9:
				begin
					ascii_thousands = 8'd57;
				end
			default:
				begin
					ascii_thousands = 8'd3;
				end
				
		endcase
		
		// Determine ascii_hundreds
		case (dec_hundreds)
	
			4'd0:
				begin
					ascii_hundreds = 8'd48;
				end
			4'd1:
				begin
					ascii_hundreds = 8'd49;
				end
			4'd2:
				begin
					ascii_hundreds = 8'd50;
				end
			4'd3:
				begin
					ascii_hundreds = 8'd51;
				end
			4'd4:
				begin
					ascii_hundreds = 8'd52;
				end
			4'd5:
				begin
					ascii_hundreds = 8'd53;
				end
			4'd6:
				begin
					ascii_hundreds = 8'd54;
				end
			4'd7:
				begin
					ascii_hundreds = 8'd55;
				end
			4'd8:
				begin
					ascii_hundreds = 8'd56;
				end
			4'd9:
				begin
					ascii_hundreds = 8'd57;
				end
			default:
				begin
					ascii_hundreds = 8'd3;
				end

		endcase
	
		// Determine ascii_tens
		case (dec_tens)
	
			4'd0:
				begin
					ascii_tens = 8'd48;
				end
			4'd1:
				begin
					ascii_tens = 8'd49;
				end
			4'd2:
				begin
					ascii_tens = 8'd50;
				end
			4'd3:
				begin
					ascii_tens = 8'd51;
				end
			4'd4:
				begin
					ascii_tens = 8'd52;
				end
			4'd5:
				begin
					ascii_tens = 8'd53;
				end
			4'd6:
				begin
					ascii_tens = 8'd54;
				end
			4'd7:
				begin
					ascii_tens = 8'd55;
				end
			4'd8:
				begin
					ascii_tens = 8'd56;
				end
			4'd9:
				begin
					ascii_tens = 8'd57;
				end
			default:
				begin
					ascii_tens = 8'd3;
				end
		endcase
	
	
		// Determine ascii_ones
		case (dec_ones)
	
			4'd0:
				begin
					ascii_ones = 8'd48;
				end
			4'd1:
				begin
					ascii_ones = 8'd49;
				end
			4'd2:
				begin
					ascii_ones = 8'd50;
				end
			4'd3:
				begin
					ascii_ones = 8'd51;
				end
			4'd4:
				begin
					ascii_ones = 8'd52;
				end
			4'd5:
				begin
					ascii_ones = 8'd53;
				end
			4'd6:
				begin
					ascii_ones = 8'd54;
				end
			4'd7:
				begin
					ascii_ones = 8'd55;
				end
			4'd8:
				begin
					ascii_ones = 8'd56;
				end
			4'd9:
				begin
					ascii_ones = 8'd57;
				end
			default:
				begin
					ascii_ones = 8'd3;
				end
			
		endcase
	end
	
endmodule 