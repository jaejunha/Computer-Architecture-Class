`include "header.v"

module Datapath(clk, data, inst, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;

	inout [`SIZE_WORD - 1:0] data;

	output [`SIZE_WORD - 1:0] inst;
	assign data = inst;

	input PVSWriteEn;
	input [1:0] ALUSrcA, ALUSrcB;
	input [3:0] ALUOp;
	input carry;

	reg [`SIZE_WORD - 1:0] instruction;
	reg [`SIZE_WORD - 1:0] instruction_next;

	reg [`SIZE_WORD - 1:0] pc;
	reg [`SIZE_WORD - 1:0] pc_next;

endmodule