`include "header.v"

module cpu(clk, reset_n, readM, writeM, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output readM;
	output writeM;
	output [`SIZE_WORD - 1:0] address;

	inout [`SIZE_WORD - 1:0] data;

	output [`SIZE_WORD - 1:0] num_inst;
	output [`SIZE_WORD - 1:0] output_port;
	output is_halted;

	wire PVSWriteEn;

	wire jump, branch, WWD, HLT;
	wire [1:0] MemToReg;
	wire MemRead, MemWrite, RegWrite, MemDst; 
	wire [1:0] RegDst;
	wire JumpDst;
	wire [1:0] Bcond;
	wire ALUSrcA;
	wire [1:0] ALUSrcB;
	wire [3:0] ALUOp;

	wire [`SIZE_WORD - 1:0] inst;

	Datapath datapath(clk, data, inst, address, readM, writeM, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDst, RegDst, JumpDst, Bcond, ALUSrcA, ALUSrcB, ALUOp, num_inst, output_port, is_halted);
	ControlUnit controlUnit(clk, inst, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDst, RegDst, JumpDst, Bcond, ALUSrcA, ALUSrcB, ALUOp);
endmodule
