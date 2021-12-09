module seg7_act_val (
input [11:0]val_p,
input [11:0]val_i,
input [11:0]val_d,
input [2:0]switch_k,
output [6:0]seg7_hundreds,
output [6:0]seg7_tens,
output [6:0]seg7_ones
);

reg [3:0]res_hundreds;
reg [3:0]res_tens;
reg [3:0]res_ones;


always @(*)
begin

	case (switch_k)
	3'b100:
		begin
			res_hundreds = val_p / 12'd100;
			res_tens = (val_p / 12'd10) % 12'd10;
			res_ones = val_p % 12'd10;
		end
	3'b010:
		begin
			res_hundreds = val_i / 12'd100;
			res_tens = (val_i / 12'd10) % 12'd10;
			res_ones = val_i % 12'd10;
		end
	3'b001:
		begin
			res_hundreds = val_d / 12'd100;
			res_tens = (val_d / 12'd10) % 12'd10;
			res_ones = val_d % 12'd10;		
		end
		
	endcase

end


seven_segment hundreds(res_hundreds, seg7_hundreds);
seven_segment tens(res_tens, seg7_tens);
seven_segment ones(res_ones, seg7_ones);

endmodule 