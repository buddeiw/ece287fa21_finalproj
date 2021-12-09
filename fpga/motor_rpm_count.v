/* 
	=====    CHILD MODULE    =====
	motor_rpm_count.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input clk 								50 MHz input clock
	input motor_rot_pulse				Motor rotation pulse (60 pulses per revolution)
	output wire [15:0]rpm_output		16-bit output of active rpm value
	
	=====      FUNCTION      =====
	
	This module counts motor rotation pulses in one second and returns a numeric representation
	
*/

module motor_rpm_count(
	input clk,
	input motor_rot_pulse,
	output wire [15:0]rpm_output
);

// Clock pulse count register
reg [31:0]pulse_count;

// Clock pulse count counter
always @(posedge clk)
	begin
		if (pulse_count == 31'd0)
			begin
				pulse_count <= 31'd50_000_000 - 1;
			end
		else
			begin
				pulse_count <= pulse_count - 1;
			end
	end

// Register to hold last value of motor_rot_pulse
reg last_scan_value;

// Update last value on each clock cycle
always @(posedge clk)
	begin
		last_scan_value <= motor_rot_pulse;
	end

// Registers to count quantity of pulses and pass to output
reg [15:0]pulse_count_qty;
reg [15:0]output_count_qty;

always @(posedge clk)
	begin
		if (pulse_count == 0)
			begin
				// Reinitialization state
				output_count_qty <= pulse_count_qty;
				pulse_count_qty <= 0;
			end
		else if (~last_scan_value && motor_rot_pulse)
			begin
				// If an inversion on motor_rot_pulse is detected on a clock cycle transition, increment pulse count
				pulse_count_qty <= pulse_count_qty + 1;
			end
	end
	
// Assign number of pulses counted to rpm_output value.
assign rpm_output = output_count_qty;
	
endmodule 