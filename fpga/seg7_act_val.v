/* 
	=====    CHILD MODULE    =====
	seg7_act_val.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input [11:0]val_p 					12-bit Kp value
	input [11:0]val_i						4-bit decimal input
	input [11:0]val_d						12-bit Kd value
	input [15:0]val_c						16-bit user command velocity value
	input [3:0]ui_select					Vector of SW[3:0] to select parameter to display
	output reg [6:0]k_active			Display character C, P, I, d on HEX5
	output reg [6:0]k_equals			Display character = on HEX4
	output [6:0]seg7_thousands			Display thousands place of active parameter on HEX3
	output [6:0]seg7_hundreds			Display hundreds place of active parameter on HEX2
	output [6:0]seg7_tens				Display tens place of active parameter on HEX1
	output [6:0]seg7_ones				Display ones place of active parameter on HEX0
	
	=====      FUNCTION      =====
	
	This module drives a set of 7-segment displays with a varied-width decimal input dependent on a 4-bit select signal
	
*/

module seg7_act_val (
	input [11:0]val_p,
	input [11:0]val_i,
	input [11:0]val_d,
	input [15:0]val_c,
	input [3:0]ui_select,
	output reg [6:0]k_active,
	output reg [6:0]k_equals,
	output [6:0]seg7_thousands,
	output [6:0]seg7_hundreds,
	output [6:0]seg7_tens,
	output [6:0]seg7_ones
);

// 4-bit registers to hold decimal values of place values
reg [3:0]res_thousands;
reg [3:0]res_hundreds;
reg [3:0]res_tens;
reg [3:0]res_ones;

// Register to signal if seven_segment.v output should be active
reg disp_vals;

always @(*)
	begin
		case (ui_select)
		
			4'b1000:
				begin
					// Case to display user control velocity
					res_thousands = val_c / 1000;
					res_hundreds = (val_c / 100) % 10;
					res_tens = (val_c / 10) % 10;
					res_ones = val_c % 10;
					k_active = 7'b0110001;
					k_equals = 7'b1110110;
					disp_vals = 1'b1;
				end
					
			
			4'b0100:
				begin
					// Case to display Kp value
					res_thousands = 4'd0;
					res_hundreds = val_p / 100;
					res_tens = (val_p / 10) % 10;
					res_ones = val_p % 10;
					k_active = 7'b0011000;
					k_equals = 7'b1110110;
					disp_vals = 1'b1;
				end
			4'b0010:
				begin
					// Case to display Ki value
					res_thousands = 4'd0;
					res_hundreds = val_i / 100;
					res_tens = (val_i / 10) % 10;
					res_ones = val_i % 10;
					k_active = 7'b1111001;
					k_equals = 7'b1110110;
					disp_vals = 1'b1;
				end
			4'b0001:
				begin
					// Case to display Kd value
					res_thousands = 4'd0;
					res_hundreds = val_d / 100;
					res_tens = (val_d / 10) % 10;
					res_ones = val_d % 10;
					k_active = 7'b1000010;
					k_equals = 7'b1110110;
					disp_vals = 1'b1;
				end
			default:
				begin
					// Case when SW[3:0] vector does not reflect valid value selection
					res_thousands = 4'd0;
					res_hundreds = 4'd0;
					res_tens = 4'd0;
					res_ones = 4'd0;
					k_active = 7'b1111111;
					k_equals = 7'b1111111;
					disp_vals = 1'b0;
				end
		endcase

	end

// Instantiate seven_segment to display values based on disp_vals signal
seven_segment thousands(disp_vals, res_thousands, seg7_thousands);
seven_segment hundreds(disp_vals, res_hundreds, seg7_hundreds);
seven_segment tens(disp_vals, res_tens, seg7_tens);
seven_segment ones(disp_vals, res_ones, seg7_ones);

endmodule 