`ifndef __CONFIG_VH__
`define __CONFIG_VH__

// Define SIM_ON_IVERILOG to enable simulation on Iverilog
`ifndef SIM_ON_IVERILOG

// `define ENABLE_PIPELINE							// Uncomment it to enable pipeline implementation in RTL
// `define ENABLE_MUL_DIV_SUPPORT					// Uncomment it to enable multiplication & division support in RTL

// `define USE_ROTATING_LEDS_EXAMPLE				// Uncomment it to implement rotating leds example in Vivado
`define USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE	// Uncomment it to implement double-side rotating leds example in Vivado

`ifdef USE_ROTATING_LEDS_EXAMPLE
`undef USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE
`endif /* USE_ROTATING_LEDS_EXAMPLE */

`endif /* SIM_ON_IVERILOG */

`endif /* __CONFIG_VH__ */