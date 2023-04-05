`include "config.vh"

`ifndef ENABLE_PIPELINE
module core_top(
	input				clk,
	input				reset,
	input		[31:0]	Instr,
	output wire [31:0]	PC,
	output wire			MemWrite,
	output wire [31:0]	ALUResult,
	output wire [31:0]	WriteData,
	input  wire [31:0]	ReadData,
	output wire [31:0]	sim_t3,
	output wire [31:0]	sim_t4,
	output wire [31:0]	sim_t5,
	output wire [31:0]	sim_t6
);

	wire PCSrc, ALUSrc, RegWrite, Jump, Zero;
	wire [1:0] ResultSrc, ImmSrc;
	wire [2:0] ALUControl;

	controller c(
		.op			(Instr[6:0]		),
		.funct3		(Instr[14:12]	),
		.funct7b5	(Instr[30]		),
		.Zero		(Zero			),
		.ResultSrc	(ResultSrc		),
		.MemWrite	(MemWrite		),
		.PCSrc		(PCSrc			),
		.ALUSrc		(ALUSrc			),
		.RegWrite	(RegWrite		),
		.Jump		(Jump			),
		.ImmSrc		(ImmSrc			),
		.ALUControl (ALUControl		)
	);

	datapath dp(
		.clk		(clk		),
		.reset		(reset		),
		.ResultSrc	(ResultSrc	),
		.PCSrc		(PCSrc		),
		.ALUSrc		(ALUSrc		),
		.RegWrite	(RegWrite	),
		.ImmSrc		(ImmSrc		),
		.ALUControl (ALUControl	),
		.Instr		(Instr		),
		.Zero		(Zero		),
		.PC			(PC			),
		.ALUResult	(ALUResult	),
		.WriteData	(WriteData	),
		.ReadData	(ReadData	),
		.sim_t3		(sim_t3		),
		.sim_t4		(sim_t4		),
		.sim_t5		(sim_t5		),
		.sim_t6		(sim_t6		)
	);

endmodule

`else

module core_top(
	input				clk,
	input				reset,
	input		[31:0]	Instr,
	output wire [31:0]	PCF,
	output wire			MemWriteM,
	output wire [31:0]	ALUResultM,
	output wire [31:0]	WriteDataM,
	input  wire [31:0]	ReadDataM,
	output wire [31:0]	sim_t3,
	output wire [31:0]	sim_t4,
	output wire [31:0]	sim_t5,
	output wire [31:0]	sim_t6
);
	wire ZeroE, FlushE, ALUSrcE, PCSrcE;

`ifdef ENABLE_MUL_DIV_SUPPORT
	wire div_stallE;
	wire [1:0] ALUME;
`endif

	wire ResultSrcE0;
	wire RegWriteM;
	wire RegWriteW;
	wire [1:0] ImmSrcD;
	wire [1:0] ResultSrcW;
	wire [2:0] ALUControlE;
	wire [31:0] InstrF;
	wire [31:0] InstrD;

	assign InstrF = Instr;

	controller c(
		.clk		(clk			),
		.reset		(reset			),
		.op			(InstrD[6:0]	),
		.funct3		(InstrD[14:12]	),
		.funct7b5	(InstrD[30]		),
		.ZeroE		(ZeroE			),
		.FlushE		(FlushE			),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.funct7b0	(InstrD[25]		),
		.div_stallE	(div_stallE		),
		.ALUME		(ALUME			),
`endif
		.ResultSrcE0(ResultSrcE0	),
		.PCSrcE		(PCSrcE			),
		.ALUSrcE	(ALUSrcE		),
		.ALUControlE(ALUControlE	),
		.MemWriteM	(MemWriteM		),
		.RegWriteM	(RegWriteM		),
		.ImmSrcD	(ImmSrcD		),
		.ResultSrcW (ResultSrcW		),
		.RegWriteW	(RegWriteW		)
	);

	datapath dp(
		.clk		(clk		),
		.reset		(reset		),
		.ResultSrcE0(ResultSrcE0),
		.PCSrcE		(PCSrcE		),
		.ALUSrcE	(ALUSrcE	),
		.RegWriteM	(RegWriteM	),
		.ResultSrcW	(ResultSrcW	),
		.RegWriteW	(RegWriteW	),
		.ImmSrcD	(ImmSrcD	),
		.ALUControlE(ALUControlE),
		.InstrF		(InstrF		),
		.ReadDataM	(ReadDataM	),
		.ZeroE		(ZeroE		),
		.FlushE		(FlushE		),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.div_stall	(div_stallE	),
`endif
		.PCF		(PCF		),
		.InstrD		(InstrD		),
		.ALUResultM (ALUResultM ),
		.WriteDataM (WriteDataM	),
		.sim_t3		(sim_t3		),
		.sim_t4		(sim_t4		),
		.sim_t5		(sim_t5		),
		.sim_t6		(sim_t6		)
	);

endmodule
`endif