`define SIZE_WORD	16
`define SIZE_OP		4
`define SIZE_FUNC	6
`define SIZE_REG	4

`define ON		1
`define OFF		0

`define SRC_RS		0
`define SRC_IMM		1
`define SRC_RT		0
`define SRC_LHI		2
`define SRC_SHFT	3

`define DST_TARGET	0
`define DST_RS		1
`define DST_PC		0
`define DST_ALU		1
`define DST_RT		0
`define DST_RD		1
`define DST_JMP		2

`define TRANS_LWD	0
`define TRANS_ALU	1
`define TRANS_PC	2

`define BXX_BNE		0
`define BXX_BEQ		1
`define BXX_BGZ		2
`define BXX_BLZ		3

`define STATE_IF	0
`define STATE_ID	1
`define STATE_EX	2
`define STATE_MEM	3
`define STATE_WB	4

`define	ALU_ADD		0
`define	ALU_SUB		1
`define	ALU_AND		2
`define	ALU_OR		3
`define	ALU_NOT		4
`define	ALU_TCP		5
`define	ALU_SHL		6
`define	ALU_SHR		7

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
