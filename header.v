`define SIZE_WORD 16
`define SIZE_OP 4
`define SIZE_FUNC 6
`define SIZE_REG 4

`define STAGE_IF 0
`define STAGE_ID 1
`define STAGE_EX 2
`define STAGE_MEM 3
`define STAGE_WB 4

`define	ALU_ADD	4'b0000
`define	ALU_SUB	4'b0001
`define	ALU_NOT	4'b1100
`define	ALU_AND	4'b1101
`define	ALU_OR	4'b1110
`define	ALU_ARS	4'b0100
`define	ALU_ALS 4'b0101

`define OP_R 4'd15