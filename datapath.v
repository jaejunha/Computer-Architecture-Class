`include "header.v"

module Datapath(clk, data, inst, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDest, RegDest, JumpDest, Bcond, ALUSrcA, ALUSrcB, ALUOp, carry, num_inst, output_port, is_halted);
	input clk;

	inout [`SIZE_WORD - 1:0] data;

	output [`SIZE_WORD - 1:0] inst;
	assign data = inst;

	input PVSWriteEn;
	input jump, branch, WWD, HLT;
	input [1:0] MemToReg;
	input MemRead, MemWrite, RegWrite, MemDest; 
	input [1:0] RegDest;
	input JumpDest;
	input [1:0] Bcond;
	input [1:0] ALUSrcA, ALUSrcB;
	input [3:0] ALUOp;
	input carry;

	output reg[`SIZE_WORD - 1:0] num_inst;
	
	output reg [`SIZE_WORD - 1:0] output_port;
	reg [`SIZE_WORD - 1:0] output_port_next;
	
	output reg is_halted;
	reg is_halted_next;

	reg [`SIZE_WORD - 1:0] instruction;
	reg [`SIZE_WORD - 1:0] instruction_next;

	reg [`SIZE_WORD - 1:0] pc;
	reg [`SIZE_WORD - 1:0] pc_next;
	
	/* Init (Instead of reset_n) */
	initial begin
		pc_next <= 0;
		num_inst <= -1;
	end
	
	always @(pc) begin
		num_inst <= num_inst + 1;
	end
endmodule