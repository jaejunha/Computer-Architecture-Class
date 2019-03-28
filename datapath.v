`include "header.v"

module Datapath(clk, reset_n, data, op, func, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;
	input reset_n;

	inout [`WORD_SIZE-1:0] data;

	output [`OP_SIZE-1:0] op;
	output [`FUNC_SIZE-1:0] func;
	assign op = data[15:12];
	assign func = data[5:0];


	input PVSWriteEn;
	input [1:0] ALUSrcA, ALUSrcB;
	input [3:0] ALUOp;
	input carry;

endmodule