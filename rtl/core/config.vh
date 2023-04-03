`ifndef __CONFIG_VH__
`define __CONFIG_VH__

`define OP_LW		(7'b000_0011)
`define OP_SW		(7'b010_0011)

`define OP_R_TYPE 	(7'b011_0011)
`ifdef OP_R_TYPE
`define ALU_CTRL_ADD 	(3'b000)
`define ALU_CTRL_SUB 	(3'b001)
`define ALU_CTRL_AND 	(3'b010)
`define ALU_CTRL_OR 	(3'b011)
`define ALU_CTRL_XOR	(3'b100)
`define ALU_CTRL_SLT 	(3'b101)
`define ALU_CTRL_SLL 	(3'b110)
`define ALU_CTRL_SRL 	(3'b111)
`endif /* OP_R_TYPE */

`define OP_BEQ		(7'b110_0011)

`define OP_I_TYPE 	(7'b001_0011)
`ifdef OP_I_TYPE
`define ALU_CTRL_ADDI	`ALU_CTRL_ADD
`define ALU_CTRL_ANDI	`ALU_CTRL_AND
`define ALU_CTRL_ORI 	`ALU_CTRL_OR
`define ALU_CTRL_XORI	`ALU_CTRL_XOR
`define ALU_CTRL_SLTI	`ALU_CTRL_SLT
`define ALU_CTRL_SLLI	`ALU_CTRL_SLL
`define ALU_CTRL_SRLI	`ALU_CTRL_SRL
`endif /* OP_I_TYPE */

`define OP_JAL		(7'b110_1111)

// Define SIM_ON_IVERILOG to enable simulation on Iverilog
`ifndef SIM_ON_IVERILOG

// `define USE_ROTATING_LEDS_EXAMPLE 				// Uncomment it to implement rotating leds example on Vivado
`define USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE 	// Uncomment it to implement double-side rotating leds example on Vivado

`ifdef USE_ROTATING_LEDS_EXAMPLE
`undef USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE
`endif /* USE_ROTATING_LEDS_EXAMPLE */

`endif /* SIM_ON_IVERILOG */

`endif /* __CONFIG_VH__ */