`include "config.vh"

module top(
`ifndef SIM_ON_IVERILOG
	input				clk_in1_n,
	input				clk_in1_p,
`else
	input				clk,
`endif
	input				reset,
	output wire [7:0]	led
);

`ifndef SIM_ON_IVERILOG
	wire clk;
`endif

	wire MemWrite;
	wire [31:0] PC, Instr, ReadData, WriteData, DataAdr;
	wire [31:0] sim_t3, sim_t4, sim_t5, sim_t6;

	// instantiate processor and memories
`ifndef ENABLE_PIPELINE
	core_top rvsingle(
		.clk		(clk		),
		.reset		(reset		),
		.PC			(PC			),
		.Instr		(Instr		),
		.MemWrite	(MemWrite	),
		.ALUResult	(DataAdr	),	// Mem addr
		.WriteData	(WriteData	),
		.ReadData	(ReadData	),
		.sim_t3		(sim_t3		),
		.sim_t4		(sim_t4		),
		.sim_t5		(sim_t5		),
		.sim_t6		(sim_t6		)
	);
`else
	core_top rvsingle_with_pipeline(
		.clk		(clk		),
		.reset		(reset		),
		.PCF		(PC			),
		.Instr		(Instr		),
		.MemWriteM	(MemWrite	),
		.ALUResultM	(DataAdr	),	// Mem addr
		.WriteDataM	(WriteData	),
		.ReadDataM	(ReadData	),
		.sim_t3		(sim_t3		),
		.sim_t4		(sim_t4		),
		.sim_t5		(sim_t5		),
		.sim_t6		(sim_t6		)
	);
`endif

	imem imem(
		.a	(PC		),
		.rd (Instr	)
	);

	dmem dmem(
		.clk(clk		),
		.we (MemWrite	),
		.a	(DataAdr	),
		.wd (WriteData	),
		.rd (ReadData	)
	);

`ifndef SIM_ON_IVERILOG
	clk_wiz_0 u_clk_wiz(
		// Clock out ports
		.clk_out1	(clk		),	// output clk_out1
		// Clock in ports
		.clk_in1_p	(clk_in1_p	),	// input clk_in1_p
		.clk_in1_n	(clk_in1_n	)	// input clk_in1_n
	);
`endif

	assign led[7:0] = sim_t4[7:0];

endmodule