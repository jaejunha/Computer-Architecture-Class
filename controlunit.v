`include "header.v"

module ControlUnit(clk, reset_n, inst, PVSWriteEn);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] inst;

	output reg PVSWriteEn;

	reg [`OP_SIZE-1:0] op;
	reg [`FUNC_SIZE-1:0] func;

	parameter IF=0, ID=1, EX=2, MEM=3, WB=4;

	initial
		begin
			op = inst[15:12];
			func = inst[15:12];
		end
endmodule