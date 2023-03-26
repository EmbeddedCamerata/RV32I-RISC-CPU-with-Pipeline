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

// `define SIMULATION 		// Uncommit the micro to enbale simulation for test "Value 25"

`ifdef SIMULATION
	// `define SIM_ON_IVERILOG	// Uncommit it if you launch a simulation on Iverilog
	`define SIM_ON_VIVADO	// Uncommit it if you launch a simulation on Vivado

`ifdef SIM_ON_IVERILOG
	`undef SIM_ON_VIVADO
`endif /* SIM_ON_IVERILOG */

`else
	`undef SIM_ON_IVERILOG
	`undef SIM_ON_VIVADO
`endif /* SIMULATION */

`endif /* __CONFIG_VH__ */