`include "header.v"

module Datapath(clk, data, inst, address, readM, writeM, PVSWriteEn, jump, branch, WWD, HLT, MemToReg, MemRead, MemWrite, RegWrite, MemDst, RegDst, JumpDst, Bcond, ALUSrcA, ALUSrcB, ALUOp, num_inst, output_port, is_halted);
	input clk;
	inout [`SIZE_WORD - 1:0] data;
	output [`SIZE_WORD - 1:0] inst;
	output reg [`SIZE_WORD-1:0] address;
	output reg readM, writeM;
	input PVSWriteEn;
	input jump, branch, WWD, HLT;
	input [1:0] MemToReg;
	input MemRead, MemWrite, RegWrite, MemDst; 
	input [1:0] RegDst;
	input JumpDst;
	input [1:0] Bcond;
	input ALUSrcA;
	input [1:0] ALUSrcB;
	input [3:0] ALUOp;

	output reg[`SIZE_WORD - 1:0] num_inst;
	
	output reg [`SIZE_WORD - 1:0] output_port;
	reg [`SIZE_WORD - 1:0] output_port_next;
	
	output reg is_halted;
	reg is_halted_next;

	reg [`SIZE_WORD - 1:0] instruction, instruction_next;
	assign inst = instruction;

	reg [`SIZE_WORD - 1:0] pc, pc_next;

	reg [`SIZE_WORD - 1:0] data_lwd;

	wire [1:0] readReg1, readReg2;
	assign readReg1 = instruction[11:10];
	assign readReg2 = instruction[9:8];

	reg [1:0] writeReg;
	reg [`SIZE_WORD - 1:0] writeData;

	wire [`SIZE_WORD - 1:0] readData1, readData2;
	assign data = (MemWrite == 1) ? readData2 : 16'hzzzz;

	Register register(clk, PVSWriteEn, readReg1, readReg2, readData1, readData2, RegWrite, writeReg, writeData);
	
	reg [`SIZE_WORD - 1:0] A;
	reg [`SIZE_WORD - 1:0] B;
	wire [`SIZE_WORD - 1:0] C;
	ALU alu(A, B, ALUOp, C);

	/* Init (Instead of reset_n) */
	initial begin
		pc_next <= 0;
		num_inst <= -1;
	end
	

	/* Prepare for IF */
	always @(posedge clk) begin
		if(PVSWriteEn == `ON) begin
			pc <= pc_next;
			output_port <= output_port_next;
			is_halted <= is_halted_next;
		end
		instruction <= instruction_next;
	end

	always @(pc) begin
		num_inst <= num_inst + 1;
	end

	always @(data) begin
		/* Read instruction */
		if(MemRead == `ON && MemDst == `DST_PC)
			instruction_next <= data;
		/* For LWD */
		else
			data_lwd <= data;
	end
	
	always @(HLT) begin
		is_halted_next <= HLT;
	end

	always @(WWD) begin
		if(WWD == `ON)
			output_port_next <= readData1;
		else
			output_port_next <= `SIZE_WORD'hzzzz;
	end

	always @(PVSWriteEn, jump, branch, MemDst, MemRead, MemWrite, MemToReg, RegWrite, RegDst, ALUSrcA, ALUSrcB) begin

		/* Normal case */
		if(jump == `OFF) begin	
			pc_next = pc + 1;
			if(branch == `ON) begin
				case(Bcond)
					`BXX_BNE: begin
						if(readData1 != readData2)
							pc_next = pc_next + { { 8{instruction[7]} } ,instruction[7:0] };
					end
					`BXX_BEQ: begin
						if(readData1 == readData2)
							pc_next = pc_next + { { 8{instruction[7]} } ,instruction[7:0] };
					end
					`BXX_BGZ: begin
						if($signed(readData1) > 0)
							pc_next = pc_next + { { 8{instruction[7]} } ,instruction[7:0] };
					end
					`BXX_BLZ: begin
						if($signed(readData1) < 0)
							pc_next = pc_next + { { 8{instruction[7]} } ,instruction[7:0] };
							
					end
				endcase
			end
		end

		/* Jump */
		else if(jump == `ON) begin
			case(JumpDst)
				`DST_TARGET: pc_next <= {pc[15:12],instruction[11:0]};
				`DST_RS: pc_next <= readData1;
			endcase
		end

		if(MemRead == `OFF)
			readM <= `OFF;
		else begin
			readM <= `ON;
			case(MemDst)
				`DST_PC: address <= pc;
				`DST_ALU: address <= C;
			endcase
		end
		
		if(MemWrite == `OFF)
			writeM <= `OFF;
		else begin
			writeM <= `ON;
			case(MemDst)
				`DST_PC: address <= pc;
				`DST_ALU: address <= C;
			endcase
		end

		case(MemToReg)
			`TRANS_LWD: writeData <= data_lwd;
			`TRANS_ALU: writeData <= C;
			`TRANS_PC: writeData <= pc + 1;
		endcase

		case(RegDst)
			`DST_RT: writeReg <= instruction[9:8];
			`DST_RD: writeReg <= instruction[7:6];
			`DST_JMP: writeReg <= 2;
		endcase
		
		case(ALUSrcA)
			`SRC_RS: A <= readData1;
			`SRC_IMM: A <= { { 8{instruction[7]} } ,instruction[7:0] };
		endcase
		
		case(ALUSrcB)
			`SRC_RT: B <= readData2;
			`SRC_IMM: B <= { { 8{instruction[7]} } ,instruction[7:0] };
			`SRC_LHI: B <= 8;
			`SRC_SHFT: B <= 1;
		endcase
	end
endmodule