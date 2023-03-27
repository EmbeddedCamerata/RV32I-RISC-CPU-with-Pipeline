`ifndef __CONFIG_VH__
`define __CONFIG_VH__

`define LW		(7'b000_0011)
`define SW		(7'b010_0011)

`define R_TYPE 	(7'b011_0011)
`ifdef R_TYPE
`define ADD 	(7'b011_0011)
`define SUB 	(7'b011_0011)
`define AND 	(7'b011_0011)
`define OR 		(7'b011_0011)
`define SLT 	(7'b011_0011)
`endif /* R_TYPE */

`define BEQ		(7'b110_0011)

`define I_TYPE 	(7'b001_0011)
`ifdef I_TYPE
`define ADDI 	(7'b001_0011)
`define ANDI 	(7'b001_0011)
`define ORI 	(7'b001_0011)
`define SLTI 	(7'b001_0011)
`endif /* I_TYPE */

`define JAL		(7'b110_1111)

// Define SIM_ON_IVERILOG to enable simulation on Iverilog
`ifndef SIM_ON_IVERILOG

//`define USE_ROTATING_LEDS_EXAMPLE 				// Uncomment it to implement rotating leds example on Vivado
`define USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE 	// Uncomment it to implement double-side rotating leds example on Vivado

`ifdef USE_ROTATING_LEDS_EXAMPLE
`undef USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE
`endif /* USE_ROTATING_LEDS_EXAMPLE */

`endif /* SIM_ON_IVERILOG */

`endif /* __CONFIG_VH__ */