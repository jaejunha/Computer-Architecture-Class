`include "header.v"

module Register(clk, PVSWriteEn, readReg1, readReg2, readData1, readData2, RegWrite, writeReg, writeData);
	input clk;
	input PVSWriteEn;
	
	input [1:0] readReg1, readReg2, writeReg;
	input RegWrite;
	input [`SIZE_WORD - 1:0] writeData;
	output reg [`SIZE_WORD - 1:0] readData1, readData2;

	reg [`SIZE_WORD - 1:0] register[0:`SIZE_REG - 1];

	always @(*) begin
		readData1 <= register[readReg1];
		readData2 <= register[readReg2];
	end

	always @(posedge clk) begin
		if(PVSWriteEn == 1 && RegWrite == 1)
			register[writeReg] <= writeData;
	end

endmodule