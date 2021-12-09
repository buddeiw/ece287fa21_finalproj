/* 
	=====  TOP LEVEL MODULE  =====
	pid.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input clk 								50MHz input clock
	input res								Momentary reset signal (active low)
	input c_active							SW3 to select 7-seg display/edit of command velocity
	input kp_active						SW2 to select 7-seg display/edit of Kp value
	input ki_active						SW1 to select 7-seg display/edit of Ki value
	input kd_active						SW0 to select 7-seg display/edit of Kd value
	input inc_up							Momentary input to increment selected SW[3:0] parameter up
	input inc_dn							Momentary input to decrement selected SW[3:0] parameter down
	input motor_rot_pulse				Pulse input from motor encoder -- 60 pulses per revolution
	output disp_rs							LCD Command/Data select
	output disp_rw							LCD Read/Write seelct
	output disp_en							LCD Enable
	output display_on						LCD Power on
	output [7:0]disp_data				Data to display on LCD
	output [6:0]seg7_k					Display register to show active SW[3:0] parameter on HEX5
	output [6:0]seg7_eq					Display register to show equals sign on HEX4	
	output [6:0]seg7_thousands			Display register to show thousands digit of active SW[3:0] parameter on HEX3
	output [6:0]seg7_hundreds			Display register to show hundreds digit of active SW[3:0] parameter on HEX2
	output [6:0]seg7_tens				Display register to show tens digit of active SW[3:0] parameter on HEX1
	output [6:0]seg7_ones				Display register to show ones digit of active SW[3:0] parameter on HEX0
	output velocity_command_pulse		Pulse output to PWM-to-Analog conversion hardware, 0-100 % duty cycle @ 100 Hz -> 0 - 10,000 rpm @ 0 - 10 VDC
	
	=====      FUNCTION      =====
	
	This module implements the diffence-form equation of a Z-transform of a parallel PID controller such that:
	
		u(k) = u[k-1] + k1e[k] + k2e[k - 1] + k3e[k - 2]
		
	and:
	
		k1 = kp + ki + kd
		k2 = -kp - 2kd
		k3 = kd.
	
*/

module pid (
	input clk,
	input res,
	input c_active,
	input kp_active,
	input ki_active,
	input kd_active,
	input inc_up,
	input inc_dn,
	input motor_rot_pulse,
	output disp_rs,
	output disp_rw,
	output disp_en,
	output display_on,
	output [7:0]disp_data,
	output [6:0]seg7_k,
	output [6:0]seg7_eq,
	output [6:0]seg7_thousands,
	output [6:0]seg7_hundreds,
	output [6:0]seg7_tens,
	output [6:0]seg7_ones,
	output velocity_command_pulse
);




// Signed registers to store algorithm control parameters:
reg signed [15:0]command_speed;					// Controller output at k
reg signed [15:0]prev_command_speed; 			// Controller output at k - 1
reg signed [15:0]current_error;					// Calculated command/feedback error at k
reg signed [15:0]last_error;						// Calculated command/feedback error at k - 1
reg signed [15:0]prior_error;						// Calculated command/feedback error at k - 2
reg signed [15:0]user_control_speed;			// User-provided baseline control velocity
reg signed [15:0]feedback_speed;					// The current rotational speed of the motor as provided by encoder
wire [15:0]motor_rpm_return;						// Target for motor_rpm_count instance


// Register to store ASCII values of all digits of all K parameters
// for passing to LCD control instantiation: (3 parameters * 3 digits * 8 bits) = 72 bits
reg [71:0]kval_to_lcd;

// Register to store ASCII values of all digits of command/sense velocities
// for passing to LCD control instantiation: (2 velocities * 4 digits * 8 bits) = 64 bits
reg [63:0]velocity_to_lcd;

// Register to store current value of Kp, Ki, Kd as raw decimal numbers with sign
reg signed [11:0]k_p;
reg signed [11:0]k_i;
reg signed [11:0]k_d;

// Wires to conduct current ASCII values of each numerical place of each K parameter
wire [7:0]p100;
wire [7:0]p10;
wire [7:0]p1;
wire [7:0]i100;
wire [7:0]i10;
wire [7:0]i1;
wire [7:0]d100;
wire [7:0]d10;
wire [7:0]d1;

// Wires to conduct current ASCII values of each numerical place of each velocity value
wire [7:0]c1000;
wire [7:0]c100;
wire [7:0]c10;
wire [7:0]c1;
wire [7:0]s1000;
wire [7:0]s100;
wire [7:0]s10;
wire [7:0]s1;

// Registers to store differential values of K parameters following Z-transform of
// parallel-form PID equation
reg signed [15:0]k_1;
reg signed [15:0]k_2;
reg signed [15:0]k_3;

// Register to store current selected user-adjustable parameter based on manipulation of SW[3:0]
reg [3:0]active_ui_control;

// Register to store UI clock cycle status
reg [23:0]ui_clock_counter;

// Register to store LCD clock cycle status
reg [15:0]lcd_clock_counter;

// Register to store LCD reset cycle status
reg [31:0]lcd_reset_counter;

// Register to invert on UI clock count achieved
reg ui_clock_pulse;

// Register to invert on LCD clock count achieved
reg lcd_clock_pulse;

// Register to invert on LCD reset count achieved
reg lcd_reset_pulse;

// Initial block to handle zero-state intialization of PID controller at set values
initial
	begin
	 	k_p = 12'd0;
	 	k_i = 12'd0;
	 	k_d = 12'd0;
		user_control_speed = 16'd1000;
	 end 

 // Enable LCD display
 assign display_on = 1'b1;

 // Sequential logic block to update values of differential K parameters (post-Z-transform)
 always @(posedge clk)
 	begin
 		k_1 <= k_p + k_i + k_d;
 		k_2 <= -k_p - (2 * k_d);
 		k_3 <= k_d; 
 	end

// Sequential logic block to update values of previous commanded speed and calculated error
always @(posedge clk)
	begin
		if (res == 1'b0)
			begin
				// Zero-state initialization of parameters under active reset
				prev_command_speed <= 16'd0;
				current_error <= 16'd0;
				last_error <= 16'd0;
				prior_error <= 16'd0;
			end
		else
			begin
				// Update [k + n] values of difference equation
				prev_command_speed <= command_speed;
				prior_error <= last_error;
				last_error <= current_error;
			end
		// Update current e[k] and u(k) values
		current_error <= command_speed - feedback_speed;
		command_speed <= prev_command_speed + (((k_1 * current_error) - (k_2 * last_error) + (k_3 * prior_error)) / 10000);

	end
	



// Create logic to change user-adjustable parameters including selection of 7-seg display and clock to debounce inputs
always @(posedge ui_clock_pulse)
	begin
		// Concatenate values of SW2, SW1, SW0 to pass to instantiation of seg7_act_val.v
		active_ui_control<= {c_active, kp_active, ki_active, kd_active};

		// Case statement to execute increment/decrement and display based on selected K* value
		case (active_ui_control)
		
		// Case for command velocity active
		4'b1000:
			begin
				if (~inc_up && inc_dn && user_control_speed < 16'd9999)
					begin
						// Call to increment, no call to decrement, current value less than max
						user_control_speed <= user_control_speed + 1'b1;
					end
				else if (~inc_up && inc_dn && user_control_speed == 16'd9999)
					begin
						// Call to increment, no call to decrement, current value at max
						user_control_speed <= 16'd0;
					end
				else if (inc_up && ~inc_dn && user_control_speed > 16'd0)
					begin
						// Call to decrement, no call to increment, current value greater than min
						user_control_speed <= user_control_speed - 1'b1;
					end
				else if (inc_up && ~inc_dn && user_control_speed == 16'd0)
					begin
						// Call tod ecrement, no call to increment, current value at min
						user_control_speed <= 16'd9999;
					end
				else
					begin
						// No call to change, retain value.
						user_control_speed <= user_control_speed;
					end
			end

		// Case for Kp active
		4'b0100:
			begin
				if (~inc_up && inc_dn && k_p < 12'd999)
					begin
						// Call to increment, no call to decrement, current value less than max
						k_p <= k_p + 1'b1;
					end
				else if (~inc_up && inc_dn && k_p == 12'd999)
					begin
						// Call to increment, no call to decrement, current value at max
						k_p <= 12'd0;
					end
				else if (inc_up && ~inc_dn && k_p > 12'd0)
					begin
						// Call to decrement, no call to increment, current value greater than min
						k_p <= k_p - 1'b1;
					end
				else if (inc_up && ~inc_dn && k_p == 12'd0)
					begin
						// Call to decrement, no call to increment, current value at min
						k_p <= 12'd999;
					end
				else
					begin
						// No call to change, retain value.
						k_p <= k_p;
					end
			end

		// Case for Ki active
		4'b0010:
			begin
				if (~inc_up && inc_dn && k_i < 12'd999)
					begin
						// Call to increment, no call to decrement, current value less than max
						k_i <= k_i + 1'b1;
					end
				else if (~inc_up && inc_dn && k_i == 12'd999)
					begin
						// Call to increment, no call to decrement, current value at max
						k_i <= 12'd0;
					end
				else if (inc_up && ~inc_dn && k_i > 12'd0)
					begin
						// Call to decrement, no call to increment, current value greater than min
						k_i <= k_i - 1'b1;
					end
				else if (inc_up && ~inc_dn && k_i == 12'd0)
					begin
						// Call to decrement, no call to increment, current value at min
						k_i <= 12'd999;
					end
				else
					begin
						// No call to change, retain value
						k_i <= k_i;
					end
			end

		// Case for Kd active
		4'b0001:
			begin
				if (~inc_up && inc_dn && k_d < 12'd999)
					begin
						// Call to increment, no call to decrement, current value less than max
						k_d <= k_d + 1'b1;
					end
				else if (~inc_up && inc_dn && k_d == 12'd999)
					begin
						// Call to increment, no call to decrement, current value at max
						k_d <= 12'd0;
					end
				else if (inc_up && ~inc_dn && k_d > 12'd0)
					begin
						// Call to decrement, no call to increment, current value greater than min
						k_d <= k_d - 1'b1;
					end
				else if (inc_up && ~inc_dn && k_d == 12'd0)
					begin
						// Call to decrement, no call to increment, current value at min
						k_d <= 12'd999;
					end
				else
					begin
						// No call to change, retain value
						k_d <= k_d;
					end
			end

		default:
			begin
				// Retain parameter values
				k_p <= k_p;
				k_i <= k_i;
				k_d <= k_d;
				user_control_speed <= user_control_speed;
			end

		endcase

		// Update concatenated array of values to send to LCD instantiation
		kval_to_lcd <= {p100, p10, p1, i100, i10, i1, d100, d10, d1};
		velocity_to_lcd <= {c1000, c100, c10, c1, s1000, s100, s10, s1};


		
	end

// Instantiate decimal_val to determine ASCII values of each K parameter
decimal_val kp_ascii(k_p, p100, p10, p1);
decimal_val ki_ascii(k_i, i100, i10, i1);
decimal_val kd_ascii(k_d, d100, d10, d1);

// Instantiate velocity_decimal_val to determine ASCII values of each velocity parameter
velocity_decimal_val comm_ascii(command_speed, c1000, c100, c10, c1);
velocity_decimal_val sens_ascii(feedback_speed, s1000, s100, s10, s1);

// Create clock counter for UI clock pulse
always @(posedge clk)
	begin
		ui_clock_counter <= ui_clock_counter + 1'b1;
		
		if (ui_clock_counter == 24'b0011_1111_1111_1111_1111_1111)
			begin
				ui_clock_counter <= 24'd0;
				ui_clock_pulse <= ~ui_clock_pulse;
			end
	end

// Create clock counter for LCD clock pulse
always @(posedge clk)
	begin
		lcd_clock_counter <= lcd_clock_counter + 1'b1;

		if (lcd_clock_counter == 16'd32_768)
			begin
				lcd_clock_counter <= 0;
				lcd_clock_pulse <= ~lcd_clock_pulse;
			end
	end

// Create clock counter for LCD reset pulse
always @(posedge clk)
	begin
		if (lcd_reset_counter == 32'd0)
			begin
				lcd_reset_counter <= 32'd20_000_000;
				lcd_reset_pulse <= ~lcd_reset_pulse;
			end
		else 
			begin
				lcd_reset_counter <= lcd_reset_counter - 1'b1;
			end
	end
	
// Instantiate motor_rpm_count to count the number of pulses over interval
motor_rpm_count count_pulse(clk, motor_rot_pulse, motor_rpm_return);
	
// Pass quantity in wire motor_rpm_return to reg feedback_speed for calculation
always @(*)
	begin
		feedback_speed <= motor_rpm_return;
	end
	
	
// Instantiate output_pwm_gen to send command velocity to control hardware
output_pwm_gen out_pulse(clk, command_speed, velocity_command_pulse);
			
// Instantiate 7-segment module to display active K-values 
seg7_act_val kval_disp(k_p, k_i, k_d, user_control_speed, active_ui_control, seg7_k, seg7_eq, seg7_thousands, seg7_hundreds, seg7_tens, seg7_ones);
lcd lcd(lcd_clock_pulse, lcd_reset_pulse, kval_to_lcd, velocity_to_lcd, disp_rs, disp_rw, disp_en, disp_data);


endmodule 