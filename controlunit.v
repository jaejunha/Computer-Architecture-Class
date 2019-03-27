`include "header.v"

module ControlUnit(clk, reset_n, inst);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] inst;

	reg [`OP_SIZE-1:0] op;
	reg [`FUNC_SIZE-1:0] func;
	initial
		begin
			op = inst[15:12];
			func = inst[15:12];
		end
endmodule