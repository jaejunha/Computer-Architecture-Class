`include "header.v"

module ControlUnit(clk, reset_n, inst, PVSWriteEn, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] inst;

	output reg PVSWriteEn;

	reg [`OP_SIZE-1:0] op;
	reg [`FUNC_SIZE-1:0] func;

	output reg [1:0] ALUSrcA, ALUSrcB;
	output reg [3:0] ALUOp;
	output reg carry;

	parameter IF = 0, ID = 1, EX = 2, MEM = 3, WB = 4;

	initial
		begin
			op = inst[15:12];
			func = inst[15:12];
		end

	always @(op or func)
		begin
			if(op == 4'd15)
				begin
					carry = 0;
					case(func)
						0: ALUOp = 4'b0000;	// ADD
						1: ALUOp = 4'b0001;	// SUB
						2: ALUOp = 4'b1101;	// AND
						3: ALUOp = 4'b1110;	// OR
						4: ALUOp = 4'b1100;	// NOT
						5:			// TCP
							begin
								ALUOp = 4'b1100;
								carry = 1;
							end
						6: ALUOp = 4'b0101;	// ALS
						7: ALUOp = 4'b0100;	// ARS
					endcase
				end
		end
endmodule