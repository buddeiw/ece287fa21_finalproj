/* 
	=====    CHILD MODULE    =====
	lcd.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input clk 								50MHz input clock
	input res								Momentary reset signal (active low)
	input [71:0]k_params					SW3 to select 7-seg display/edit of command velocity
	input [63:0]v_params					SW2 to select 7-seg display/edit of Kp value
	output reg lcd_rs						LCD Command/Data select			
	output lcd_rw							LCD Read/Write select				
	output reg [7:0]lcd_data			8-bit width data connection to HD44870 module
	
	=====      FUNCTION      =====
	
	This module displays 256 bits of data in a 2x16 array on the HD44870-driven LCD on the DE2-115 board.
	
*/

module lcd(
	input clk,
	input res,
	input [71:0]k_params,
	input [63:0]v_params,
	output reg lcd_rs,
	output lcd_rw,
	output lcd_en,
	output reg [7:0]lcd_data
);


// FSM Parameters
parameter	INIT = 3'd0,
				LOAD = 3'd1,
				PUSH = 3'd2,
				IDLE = 3'd3;

// Display position index register
reg [5:0] index;

// State transition list
reg [2:0]S;

// Display update logic
always @(posedge clk or negedge res) 
	begin
		// If reset, zero-state index and state
		if (!res) 
			begin
				index <= 0;
				S <= INIT;
			end
		else 
			begin
				case (S)
					INIT: 
						begin
							// If at INIT, zero-state index and move to LOAD
							index <= 0;
							S <= LOAD;
						end	
					LOAD: 
						begin
							if (index > 36)
								begin
									// If at LOAD and finished writing, move to IDLE
									S <= IDLE;
								end
							else
								begin
									// If at LOAD and not finished writing, move to PUSH
									S <= PUSH;
								end							
						end
					PUSH: 
						begin
							// If at PUSH, increment index and move to LOAD
							index <= index + 1;
							S <= LOAD;
						end
					IDLE: 
						begin
							// If at IDLE, remain IDLE
							S <= IDLE;
						end
					default: 
						begin
							// Default back to zero-index and initial state
							index <= 0;
							S <= INIT;
						end
				endcase
		end
	end

// Configure HD44870 connection to push data.
assign lcd_en = (S == PUSH);
assign lcd_rw = 0;
	
always @(*)
	begin
		case (index)
			0: {lcd_rs, lcd_data} = {1'b0, 8'b0011_1000};		// Function set: 8-bit datapath, 2-line display, 5x8 dot character font
			1: {lcd_rs, lcd_data} = {1'b0, 8'b0000_0110};		// Entry mode set: Move cursor RT on each character write
			2: {lcd_rs, lcd_data} = {1'b0, 8'b0000_0001};		// Clear display on each iteration
										
			3: {lcd_rs, lcd_data} = {1'b1,  "K"};
			4: {lcd_rs, lcd_data} = {1'b1,  "p"};
			5: {lcd_rs, lcd_data} = {1'b1,  " "};
			6: {lcd_rs, lcd_data} = {1'b1,  " "};
			7: {lcd_rs, lcd_data} = {1'b1,  "K"};
			8: {lcd_rs, lcd_data} = {1'b1,  "i"};
			9: {lcd_rs, lcd_data} = {1'b1,  " "};
			10: {lcd_rs, lcd_data} = {1'b1,  " "};
			11: {lcd_rs, lcd_data} = {1'b1,  "K"};
			12: {lcd_rs, lcd_data} = {1'b1,  "d"};
			13: {lcd_rs, lcd_data} = {1'b1,  " "};
			14: {lcd_rs, lcd_data} = {1'b1,  " "};
			15: {lcd_rs, lcd_data} = {1'b1,  v_params[63:56]};
			16: {lcd_rs, lcd_data} = {1'b1,  v_params[55:48]};
			17: {lcd_rs, lcd_data} = {1'b1,  v_params[47:40]};
			18: {lcd_rs, lcd_data} = {1'b1,  v_params[39:32]};
	 
			19: {lcd_rs, lcd_data} = {1'b0, 8'b1100_0000};		// Set DDRAM address: Move cursor to the beginning of second line
		
			20: {lcd_rs, lcd_data} = {1'b1,  k_params[71:64]};
			21: {lcd_rs, lcd_data} = {1'b1,  k_params[63:56]};
			22: {lcd_rs, lcd_data} = {1'b1,  k_params[55:48]};
			23: {lcd_rs, lcd_data} = {1'b1,  " "};
			24: {lcd_rs, lcd_data} = {1'b1,  k_params[47:40]};
			25: {lcd_rs, lcd_data} = {1'b1,  k_params[39:32]};
			26: {lcd_rs, lcd_data} = {1'b1,  k_params[31:24]};
			27: {lcd_rs, lcd_data} = {1'b1,  " "};
			28: {lcd_rs, lcd_data} = {1'b1,  k_params[23:16]};
			29: {lcd_rs, lcd_data} = {1'b1,  k_params[15:8]};
			30: {lcd_rs, lcd_data} = {1'b1,  k_params[7:0]};
			31: {lcd_rs, lcd_data} = {1'b1,  " "};
			32: {lcd_rs, lcd_data} = {1'b1,  v_params[31:24]};
			33: {lcd_rs, lcd_data} = {1'b1,  v_params[23:16]};
			34: {lcd_rs, lcd_data} = {1'b1,  v_params[15:8]};
			35: {lcd_rs, lcd_data} = {1'b1,  v_params[7:0]};

			default: {lcd_rs, lcd_data} = {1'b0, 8'b1000_0000};		// Set DDRAM address: Move cursor to the beginning of first line
		endcase 
	end
endmodule 