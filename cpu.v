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
	wire MemRead, MemWrite, RegWrite, MemDest; 
	wire [1:0] RegDest;
	wire JumpDest;
	wire [1:0] Bcond;
	wire [1:0] ALUSrcA, ALUSrcB;
	wire [3:0] ALUOp;
	wire carry;

	wire [`SIZE_WORD - 1:0] inst;

	Datapath datapath(clk, data, inst, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry, num_inst, output_port, is_halted);
	ControlUnit controlUnit(clk, inst, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDest, RegDest, JumpDest, Bcond, ALUSrcA, ALUSrcB, ALUOp, carry);
endmodule
