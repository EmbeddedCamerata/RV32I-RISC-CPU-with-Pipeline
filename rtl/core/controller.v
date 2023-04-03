`include "config.vh"

`ifndef USE_PIPELINE
module controller(
	input		[6:0]	op,
	input		[2:0]	funct3,
	input				funct7b5,
	input				Zero,
	output wire [1:0]	ResultSrc,
	output wire			MemWrite,
	output wire			PCSrc,
	output wire			ALUSrc,
	output wire			RegWrite,
	output wire			Jump,
	output wire [1:0]	ImmSrc,
	output wire [2:0]	ALUControl
);

  	wire [1:0] ALUOp;
  	wire Branch;

	maindec md(
		.op			(op			),
		.ResultSrc	(ResultSrc	),
		.MemWrite	(MemWrite	),
		.Branch		(Branch		),
		.ALUSrc		(ALUSrc		),
		.RegWrite	(RegWrite	),
		.Jump		(Jump		),
		.ImmSrc		(ImmSrc		),
		.ALUOp		(ALUOp		)
	);

	aludec ad(
		.opb5		(op[5]		),
		.funct3		(funct3		),
		.funct7b5	(funct7b5	),
		.ALUOp		(ALUOp		),
		.ALUControl (ALUControl )
	);

	assign PCSrc = Branch & Zero | Jump;

endmodule

`else

module controller(
	input				clk,
	input				reset,
	input		[6:0]	op,
	input		[2:0]	funct3,
	input				funct7b5,
	input				ZeroE,
	input				FlushE,
	output wire [1:0]	ResultSrcE0,
	output wire			PCSrcE,
	output wire			ALUSrcE,
	output wire [2:0]	ALUControlE,
	output wire			MemWriteM,
	output wire			RegWriteM,
	output wire [1:0]	ImmSrcD,
	output wire [1:0]	ResultSrcW,
	output wire			RegWriteW
);

	wire [1:0] ALUOpD, ResultSrcD;
	wire [2:0] ALUControlD;
	wire MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD;

	wire [1:0] ResultSrcE;
	wire MemWriteE, BranchE, RegWriteE, JumpE;

	wire [1:0] ResultSrcM;

	maindec md(
		.op			(op			),
		.ResultSrc	(ResultSrcD ),
		.MemWrite	(MemWriteD	),
		.Branch		(BranchD	),
		.ALUSrc		(ALUSrcD	),
		.RegWrite	(RegWriteD	),
		.Jump		(JumpD		),
		.ImmSrc		(ImmSrcD	),
		.ALUOp		(ALUOpD		)
	);

	aludec ad(
		.opb5		(op[5]		),
		.funct3		(funct3		),
		.funct7b5	(funct7b5	),
		.ALUOp		(ALUOpD		),
		.ALUControl (ALUControlD)
	);

	// Pipeline registers
	floprc #(
		.WIDTH(10)
	) regE(
		.clk	(clk 	),
		.reset	(reset 	),
		.clear	(FlushE ),
		.d		({ResultSrcD, ALUControlD, MemWriteD, BranchD,
					ALUSrcD, RegWriteD, JumpD}),
		.q		({ResultSrcE, ALUControlE, MemWriteE, BranchE,
					ALUSrcE, RegWriteE, JumpE})
	);

	flopr #(4) regM(.clk(clk), .reset(reset), .d({ResultSrcE, MemWriteE, RegWriteE}), .q({ResultSrcM, MemWriteM, RegWriteM}));
	flopr #(3) regW(.clk(clk), .reset(reset), .d({ResultSrcM, RegWriteM}), .q({ResultSrcW, RegWriteW}));

	assign PCSrcE = BranchE & ZeroE | JumpE;
	assign ResultSrcE0 = ResultSrcE[0];

endmodule
`endif