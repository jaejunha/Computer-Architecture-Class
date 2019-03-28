
module Datapath(clk, reset_n, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;
	input reset_n;

	input PVSWriteEn;
	input [1:0] ALUSrcA, ALUSrcB;
	input [3:0] ALUOp;
	input carry;

endmodule