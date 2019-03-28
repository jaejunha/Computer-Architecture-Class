`include "header.v"

module cpu(clk, reset_n, readM, writeM, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output readM;
	output writeM;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;

	wire PVSWriteEn;

	wire [1:0] ALUSrcA, ALUSrcB;
	wire [3:0] ALUOp;
	wire carry;

	Datapath datapath(clk, reset_n, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
	ControlUnit controlUnit(clk, reset_n, inst, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
endmodule
