`include "header.v"

module ControlUnit(clk, inst, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDst, RegDst, JumpDst, Bcond, ALUSrcA, ALUSrcB, ALUOp);
	input clk;
	input [`SIZE_WORD - 1:0] inst;

	wire [`SIZE_OP - 1:0] op;
	wire [`SIZE_FUNC - 1:0] func;
	assign op = inst[15:12];
	assign func = inst[5:0];

	output reg PVSWriteEn;
	output reg jump, branch, WWD, HLT;
	output reg [1:0] MemToReg;
	output reg MemRead, MemWrite, RegWrite, MemDst; 
	output reg [1:0] RegDst;
	output reg JumpDst;
	output reg [1:0] Bcond;
	output reg ALUSrcA;
	output reg [1:0] ALUSrcB;
	output reg [3:0] ALUOp;

	reg [2:0] state;
	reg [2:0] state_next;

	/* Init (Instead of reset_n) */
	initial begin
		state_next <= `STATE_IF;
		PVSWriteEn <= `ON;
	end
	
	/* Start new clock edge: change state */
	always @(posedge clk) begin
		state <= state_next;
	end

	/* Analyze op code (part of decoding) */
	always @(inst) begin

		if(op == `OP_JMP || op == `OP_JAL || func == `FUNC_JPR || func == `FUNC_JRL)
			jump <= `ON;
		else
			jump <= `OFF;
		if(op == `OP_BNE || op == `OP_BEQ || op == `OP_BGZ || op == `OP_BLZ)
			branch <= `ON;
		else
			branch <= `OFF;
		if(func == `FUNC_WWD)
			WWD <= `ON;
		else
			WWD <= `OFF;
		if(op == `OP_R && func == `FUNC_HLT)
			HLT <= `ON;
		else
			HLT <= `OFF;

		if(op == `OP_R)
			ALUOp <= func;
	end

	/* Manage state */
	always @(*) begin
		case(state)
			`STATE_IF: begin
				/* Read instruction */
				PVSWriteEn <= `OFF;
				jump <= `OFF;
				branch <= `OFF;
				WWD <= `OFF;
				HLT <= `OFF;
				MemDst <= `DST_PC;
				MemRead <= `ON;
				MemWrite <= `OFF;
				RegWrite <= `OFF;
				state_next <= `STATE_ID;
			end
			`STATE_ID: begin
				if(op == `OP_R || op == `OP_ADI || op == `OP_ORI || op == `OP_LHI || op == `OP_LWD || op == `OP_SWD) begin
					PVSWriteEn <= `OFF;
					MemRead <= `OFF;
					MemWrite <= `OFF;
					RegWrite <= `OFF;
					state_next <= `STATE_EX;
				end
				/* Print result */
				if(WWD == `ON) begin
					PVSWriteEn <= `ON;
					MemRead <= `OFF;
					MemWrite <= `OFF;
					RegWrite <= `OFF;
					state_next <= `STATE_IF;
				end
				/* Branch occurs */
				if(branch == `ON) begin
					PVSWriteEn <= `ON;	
					Bcond <= op[1:0];
					MemRead <= `OFF;
					MemWrite <= `OFF;
					RegWrite <= `OFF;
					state_next <= `STATE_IF;
				end
				if(jump == `ON) begin
					PVSWriteEn <= `ON;
					if(op == `OP_JAL || op == `OP_JMP)
						JumpDst <= `DST_TARGET;
					else
						JumpDst <= `DST_RS;
					MemRead <= `OFF;
					MemWrite <= `OFF;
					MemToReg <= `TRANS_PC;
					if(op == `OP_JAL || func == `FUNC_JRL)
						RegWrite <= `ON;
					else
						RegWrite <= `OFF;
					RegDst <= `DST_JMP;
					state_next <= `STATE_IF;
				end
				if(HLT == `ON) begin
					PVSWriteEn <= `ON;
					MemRead <= `OFF;
					MemWrite <= `OFF;
					RegWrite <= `OFF;
					state_next <= `STATE_IF;
				end
			end
			`STATE_EX: begin
				PVSWriteEn <= `OFF;
				MemRead <= `OFF;
				MemWrite <= `OFF;
				RegWrite <= `OFF;
				if(op == `OP_R) begin
					ALUSrcA <= `SRC_RS;
					case(func)
						`FUNC_SHL: ALUSrcB <= `SRC_SHFT;
						`FUNC_SHR: ALUSrcB <= `SRC_SHFT;
						default: ALUSrcB <= `SRC_RT;
					endcase
					state_next <= `STATE_WB;
				end
				if(op == `OP_ADI || op == `OP_ORI || op == `OP_LHI) begin
					if(op == `OP_ADI || op == `OP_ORI) begin
						ALUSrcA <= `SRC_RS;
						ALUSrcB <= `SRC_IMM;
					end
					/* LHI */
					else begin
						ALUSrcA <= `SRC_IMM;
						ALUSrcB <= `SRC_LHI;
					end
					case(op)
						`OP_ADI: ALUOp <= `ALU_ADD;
						`OP_ORI: ALUOp <= `ALU_OR;
						`OP_LHI: ALUOp <= `ALU_SHL;
					endcase
					state_next <= `STATE_WB;
				end
				if(op == `OP_LWD || op == `OP_SWD) begin
					ALUSrcA <= `SRC_RS;
					ALUSrcB <= `SRC_IMM;
					ALUOp <= `ALU_ADD;
					state_next <= `STATE_MEM;
				end	
			end
			`STATE_MEM: begin
				MemDst <= `DST_ALU;
				RegWrite <= `OFF;
				case(op)
					`OP_LWD: begin
						PVSWriteEn <= `OFF;
						MemRead <= `ON;
						MemWrite <= `OFF;
						state_next <= `STATE_WB;
					end
					`OP_SWD: begin
						PVSWriteEn <= `ON;
						MemRead <= `OFF;
						MemWrite <= `ON;
						state_next <= `STATE_IF;
					end
				endcase
			end
			`STATE_WB: begin
				PVSWriteEn <= `ON;
				MemRead <= `OFF;
				MemWrite <= `OFF;
				if(op == `OP_R) begin
					MemToReg <= `TRANS_ALU;
					RegWrite <= `ON;
					RegDst <= `DST_RD;
				end
				if(op == `OP_ADI || op == `OP_ORI || op == `OP_LHI) begin
					MemToReg <= `TRANS_ALU;
					RegWrite <= `ON;
					RegDst <= `DST_RT;
				end
				if(op == `OP_LWD) begin
					MemToReg <= `TRANS_LWD;
					RegWrite <= `ON;
					RegDst <= `DST_RT;
				end
				state_next <= `STATE_IF;
			end
		endcase
	end
endmodule