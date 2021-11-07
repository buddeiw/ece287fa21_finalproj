module pid (
output signed [15:0]u_out,
input signed [15:0]e_in,
input clk,
input res);

parameter k_1 = 1; //  Kp + Ki + Kd
parameter k_2 = 1; // -Kp - 2Kd
parameter k_3 = 1; //  Kd

reg signed [15:0]u_prev;
reg signed [15:0]e_prev1;
reg signed [15:0]e_prev2;

assign u_out = u_prev + (k_1 * e_in) - (k_2 * e_prev1) + (k_3 * e_prev2);

always @(posedge clk)
begin
	if (res == 1)
		begin
			u_prev <= 0;
			e_prev1 <= 0;
			e_prev2 <= 0;
		end
	else
		begin
			e_prev2 <= e_prev1;
			e_prev1 <= e_in;
			u_prev <= u_out;
		end
end
endmodule 