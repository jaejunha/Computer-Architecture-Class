`include "header.v"

module ControlUnit(clk, inst, PVSWriteEn, jump, branch, WWD, HLT, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;
	input [`SIZE_WORD - 1:0] inst;

	wire [`SIZE_OP - 1:0] op;
	wire [`SIZE_FUNC - 1:0] func;
	assign op = inst[15:12];
	assign func = inst[5:0];

	output reg PVSWriteEn;
	output reg jump, branch, WWD, HLT; 
	output reg [1:0] ALUSrcA, ALUSrcB;
	output reg [3:0] ALUOp;
	output reg carry;

	reg [2:0] stage;
	reg [2:0] stage_next;

	/* Init (Instead of reset_n) */
	initial begin
		stage_next <= `STAGE_IF;
		PVSWriteEn <= 1;
	end
	
	/* New start clock edge: change stage */
	always @(posedge clk) begin
		stage <= stage_next;
	end

	always @(inst) begin

		if(opcode==`OP_JMP || opcode==`OP_JAL || func==`FUNC_JPR || func==`FUNC_JRL)
			jump <= 1;
		else
			jump <= 0;
		if(opcode==`OP_BNE || opcode==`OP_BEQ || opcode==`OP_BGZ || opcode==`OP_BLZ)
			branch <= 1;
		else
			branch <= 0;
		if(funct==`FUNC_WWD)
			WWD <= 1;
		else
			WWD <= 0;
		if(opcode==`OP_R && func==`FUNC_HLT)
			HLT <= 1;
		else
			HLT <= 0;

		if(op == `OP_R) begin
			carry <= 0;
			case(func)
				0: ALUOp <= `ALU_ADD;	// ADD
				1: ALUOp <= `ALU_SUB;	// SUB
				2: ALUOp <= `ALU_AND;	// AND
				3: ALUOp <= `ALU_OR;	// OR
				4: ALUOp <= `ALU_NOT;	// NOT
				5:			// TCP
					begin
						ALUOp <= `ALU_NOT;
						carry <= 1;
					end
				6: ALUOp <= `ALU_ALS;	// ALS
				7: ALUOp <= `ALU_ARS;	// ARS
			endcase
		end
	end
endmodule