`include "header.v"

module Datapath(clk, reset_n, data, inst, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;
	input reset_n;

	inout [`SIZE_WORD - 1:0] data;

	output [`SIZE_WORD - 1:0] inst;
	assign data = inst;

	input PVSWriteEn;
	input [1:0] ALUSrcA, ALUSrcB;
	input [3:0] ALUOp;
	input carry;

endmodule