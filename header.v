`define SIZE_WORD	16
`define SIZE_OP		4
`define SIZE_FUNC	6
`define SIZE_REG	4

`define STATE_IF	0
`define STATE_ID	1
`define STATE_EX	2
`define STATE_MEM	3
`define STATE_WB	4

`define	ALU_ADD		4'b0000
`define	ALU_SUB		4'b0001
`define	ALU_LRS		4'b0010
`define	ALU_ARS		4'b0100
`define	ALU_ALS		4'b0101
`define	ALU_NOT		4'b1100
`define	ALU_AND		4'b1101
`define	ALU_OR		4'b1110

`define OP_BNE		4'd0
`define OP_BEQ		4'd1
`define OP_BGZ		4'd2
`define OP_BLZ		4'd3
`define OP_ADI		4'd4
`define OP_ORI		4'd5
`define OP_LHI		4'd6
`define OP_LWD		4'd7
`define OP_SWD		4'd8
`define OP_R		4'd15
`define OP_JMP		4'd9
`define OP_JAL		4'd10

`define FUNC_SHL	6'd6
`define FUNC_SHR	6'd7
`define FUNC_JPR	6'd25
`define FUNC_JRL	6'd26
`define FUNC_WWD	6'd28
`define FUNC_HLT	6'd29