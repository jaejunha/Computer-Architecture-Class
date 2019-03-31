`include "header.v"

module ControlUnit(clk, inst, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDest, RegDest, JumpDest, Bcond, ALUSrcA, ALUSrcB, ALUOp, carry);
	input clk;
	input [`SIZE_WORD - 1:0] inst;

	wire [`SIZE_OP - 1:0] op;
	wire [`SIZE_FUNC - 1:0] func;
	assign op = inst[15:12];
	assign func = inst[5:0];

	output reg PVSWriteEn;
	output reg jump, branch, WWD, HLT;
	output reg [1:0] MemToReg;
	output reg MemRead, MemWrite, RegWrite, MemDest; 
	output reg [1:0] RegDest;
	output reg JumpDest;
	output reg [1:0] Bcond;
	output reg [1:0] ALUSrcA, ALUSrcB;
	output reg [3:0] ALUOp;
	output reg carry;

	reg [2:0] state;
	reg [2:0] state_next;

	/* Init (Instead of reset_n) */
	initial begin
		state_next <= `STATE_IF;
		PVSWriteEn <= 1;
	end
	
	/* Start new clock edge: change state */
	always @(posedge clk) begin
		state <= state_next;
	end

	/* Analyze op code (part of decoding) */
	always @(inst) begin

		if(op == `OP_JMP || op == `OP_JAL || func == `FUNC_JPR || func == `FUNC_JRL)
			jump <= 1;
		else
			jump <= 0;
		if(op == `OP_BNE || op == `OP_BEQ || op == `OP_BGZ || op == `OP_BLZ)
			branch <= 1;
		else
			branch <= 0;
		if(func == `FUNC_WWD)
			WWD <= 1;
		else
			WWD <= 0;
		if(op == `OP_R && func == `FUNC_HLT)
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

	/* Manage state */
	always @(*) begin
		case(state)
			`STATE_IF: begin
				/* Read instruction */
				PVSWriteEn <= 0;
				jump <= 0;
				branch <= 0;
				WWD <= 0;
				HLT <= 0;
				MemDest <= 0;
				MemRead <= 1;
				MemWrite <= 0;
				RegWrite <= 0;
				state_next <= `STATE_ID;
			end
			`STATE_ID: begin
				if(op == `OP_R || op == `OP_ADI || op == `OP_ORI || op == `OP_LHI || op == `OP_LWD || op == `OP_SWD) begin
					PVSWriteEn <= 0;
					MemRead <= 0;
					MemWrite <= 0;
					RegWrite <= 0;
					state_next <= `STATE_EX;
				end
				/* Print result */
				if(WWD == 1) begin
					PVSWriteEn <= 1;
					MemRead <= 0;
					MemWrite <= 0;
					RegWrite <= 0;
					state_next <= `STATE_IF;
				end
				/* Branch occurs */
				if(branch == 1) begin
					PVSWriteEn <= 1;	
					Bcond <= op[1:0];
					MemRead <= 0;
					MemWrite <= 0;
					RegWrite <= 0;
					state_next <= `STATE_IF;
				end
				if(jump == 1) begin
					PVSWriteEn <= 1;
					if(op == `OP_JAL || op == `OP_JMP)
						JumpDest <= 0;
					else
						JumpDest <= 1;
					MemRead <= 0;
					MemWrite <= 0;
					MemToReg <= 2;
					if(op == `OP_JAL || func == `FUNC_JRL)
						RegWrite <= 1;
					else
						RegWrite <= 0;
					RegDest <= 2;
					state_next <= `STATE_IF;
				end
				if(HLT == 1) begin
					PVSWriteEn <= 1;
					MemRead <= 0;
					MemWrite <= 0;
					RegWrite <= 0;
					state_next <= `STATE_IF;
				end
			end
			`STATE_EX: begin
				PVSWriteEn <= 0;
				MemRead <= 0;
				MemWrite <= 0;
				RegWrite <= 0;
				if(op == `OP_R) begin
					ALUSrcA <= 0;
					case(func)
						`FUNC_SHL: ALUSrcB <= 3;
						`FUNC_SHR: ALUSrcB <= 3;
						default: ALUSrcB <= 0;
					endcase
					state_next <= `STATE_WB;
				end
				if(op == `OP_ADI || op == `OP_ORI || op == `OP_LHI) begin
					if(op == `OP_ADI || op == `OP_ORI) begin
						ALUSrcA <= 0;
						ALUSrcB <= 1;
					end
					else begin
						ALUSrcA <= 1;
						ALUSrcB <= 2;
					end
					case(op)
						`OP_ADI: ALUOp <= `ALU_ADD;
						`OP_ORI: ALUOp <= `ALU_OR;
						`OP_LHI: ALUOp <= `ALU_LRS;
					endcase
					carry <= 0;
					state_next <= `STATE_WB;
				end
				if(op == `OP_LWD || op == `OP_SWD) begin
					ALUSrcA <= 0;
					ALUSrcB <= 1;
					ALUOp <= `ALU_ADD;
					carry <= 0;
					state_next <= `STATE_MEM;
				end	
			end
			`STATE_MEM: begin
				MemDest <= 1;
				RegWrite <= 0;
				case(op)
					`OP_LWD: begin
						PVSWriteEn <= 0;
						MemRead <= 1;
						MemWrite <= 0;
						state_next <= `STATE_WB;
					end
					`OP_SWD: begin
						PVSWriteEn <= 1;
						MemRead <= 0;
						MemWrite <= 1;
						state_next <= `STATE_IF;
					end
				endcase
			end
			`STATE_WB: begin
				PVSWriteEn <= 1;
				MemRead <= 0;
				MemWrite <= 0;
				if(op == `OP_R) begin
					MemToReg <= 1;
					RegWrite <= 1;
					RegDest <= 1;
				end
				if(op == `OP_ADI || op == `OP_ORI || op == `OP_LHI) begin
					MemToReg <= 1;
					RegWrite <= 1;
					RegDest <= 0;
				end
				if(op == `OP_LWD) begin
					MemToReg <= 0;
					RegWrite <= 1;
					RegDest <= 0;
				end
				state_next <= `STATE_IF;
			end
		endcase
	end
endmodule