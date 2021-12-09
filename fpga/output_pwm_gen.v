/* 
	=====    CHILD MODULE    =====
	output_pwm_gen.v
	buddeiw, winnam
	
	=====     I/O CONFIG     =====
	input clk			 					50MHz clock signal
	input [15:0]rpm_command				16-bit rpm command value
	output pwm								PWM output bus
	
	=====      FUNCTION      =====
	
	This module takes an RPM command and generates a 100 Hz PWM signal wherein duty-cycle varies 0 - 100% reflecting a command of 0 - 10,000 rpm.
	
*/

module output_pwm_gen(
	input clk,
	input [15:0]rpm_command,
	output pwm
);

// 50 MHz tick counter
reg [31:0]counter;


always @(posedge clk)
	begin
		if (counter < 500000)
			begin
				// Count up to 500,000 cycles (0.1 seconds)
				counter <= counter + 1;
			end
		else
			begin
				// Reset after 0.1 seconds
				counter <= 0;
			end
	end

// Determine pulse width of high-time, assign to output
assign pwm = (counter < (rpm_command * 50)) ? 1 : 0;

endmodule


