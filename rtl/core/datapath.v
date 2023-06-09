`include "config.vh"

`ifndef ENABLE_PIPELINE
module datapath(
	input				clk,
	input				reset,
	input		[1:0]	ResultSrc,
	input				PCSrc,
	input				ALUSrc,
	input				RegWrite,
	input		[1:0]	ImmSrc,
	input		[2:0]	ALUControl,
	input		[31:0]	Instr,
	input		[31:0]	ReadData,
	output				Zero,
	output reg	[31:0]	PC,
	output wire [31:0]	ALUResult,
	output wire [31:0]	WriteData,
	output wire [31:0]	sim_t3,
	output wire [31:0]	sim_t4,
	output wire [31:0]	sim_t5,
	output wire [31:0]	sim_t6
);

	wire [31:0] PCNext, PCPlus4, PCTarget;
	wire [31:0] ImmExt;
	wire [31:0] reg1, reg2; // from reg file.
	wire [31:0] SrcA, SrcB; // to alu.
	wire [31:0] Result;

	// 1. next PC update logic:
	assign PCPlus4 = PC + 32'd4;
	assign PCTarget = PC + ImmExt;
	assign PCNext = PCSrc ? PCTarget : PCPlus4;

	always @(posedge clk, posedge reset) begin
		if (reset)
			PC <= 0;
		else
			PC <= PCNext;
  	end

	// 2. register file logic:
	regfile rf(
		.clk	(clk			),
		.we3	(RegWrite		),	// rd write enable
		.a1		(Instr[19:15]	),	// rs1 index
		.a2		(Instr[24:20]	),	// rs2 index
		.a3		(Instr[11:7]	),	// rd  index
		.wd3	(Result			),	// rd write data
		.rd1	(reg1			),
		.rd2	(reg2			),
		.sim_t3	(sim_t3			),
		.sim_t4	(sim_t4			),
		.sim_t5	(sim_t5			),
		.sim_t6	(sim_t6			)
	);

	extend ext(
		.instr	(Instr[31:7]	),
		.immsrc (ImmSrc			),
		.immext (ImmExt			)
	);

	// 3. ALU logic:
	assign SrcA = reg1;
	assign SrcB = ALUSrc ? ImmExt : reg2;

	alu alu(
		.a			(SrcA		),
		.b			(SrcB		),
		.alucontrol (ALUControl ),
		.result		(ALUResult	),
		.zero		(Zero		)
	);

	// 4. Store logic:
	assign WriteData = reg2;
	// WriteAddr is ALUResult.

	// 5. Write back to Destination Register logic:
	assign Result = ResultSrc[1] ? PCPlus4 : (ResultSrc[0] ? ReadData: ALUResult);

endmodule

`else

module datapath(
	input				clk,
	input				reset,
	input				ResultSrcE0,
	input				PCSrcE,
	input				ALUSrcE,
	input				RegWriteM,
	input 		[1:0]	ResultSrcW,
	input				RegWriteW,
	input		[1:0]	ImmSrcD,
	input		[2:0]	ALUControlE,
	input		[31:0]	InstrF,
	input		[31:0]	ReadDataM,
	output				ZeroE,
	output				FlushE,
`ifdef ENABLE_MUL_DIV_SUPPORT
	output wire			div_stall,
`endif
	output wire	[31:0]	PCF,
	output wire [31:0]	InstrD,
	output wire [31:0]	ALUResultM,
	output wire [31:0]	WriteDataM,
	output wire [31:0]	sim_t3,
	output wire [31:0]	sim_t4,
	output wire [31:0]	sim_t5,
	output wire [31:0]	sim_t6
);

	wire [4:0] rs1D, rs2D, rs1E, rs2E, rdD, rdE, rdM, rdW;
	wire [1:0] forwardaE, forwardbE;
	wire StallF, StallD, FlushD;
	wire [31:0] PCNext, PCD, PCE, PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W, PCTargetE;
	wire [31:0] ImmExtD, ImmExtE;
	wire [31:0] RD1D, RD2D, RD1E, RD2E, SrcAE, SrcBE;
	wire [31:0] ALUResultE, ALUResultW, WriteDataE, ReadDataW, ResultW;

`ifdef ENABLE_MUL_DIV_SUPPORT
	wire DIV_flushE, DIV_busyE, DIV_validE, div_stallE;
	wire RtypedivE, div_i_startE;

	assign div_stall = div_stallE;
	assign RtypedivE = ALUME[0];
	assign div_i_startE = RtypedivE & ALUME[0];

`endif

	// Hazard detection
	hazard h(
		.rs1D		(rs1D		),
		.rs2D		(rs2D		),
		.rs1E		(rs1E		),
		.rs2E		(rs2E		),
		.rdE		(rdE		),
		.rdM		(rdM		),
		.rdW		(rdW		),
		.RegWriteM	(RegWriteM	),
		.RegWriteW	(RegWriteW	),
		.ResultSrcE0(ResultSrcE0),
		.PCSrcE		(PCSrcE		),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.RtypedivE	(RtypedivE	),
		.DIV_validE	(DIV_validE	),
		.div_stallE	(div_stallE	),
`endif
		.forwardaE	(forwardaE	),
		.forwardbE	(forwardbE	),
		.stallF		(StallF		),
		.stallD		(StallD		),
		.flushD		(FlushD		),
		.flushE		(FlushE		)
	);

	// Next PC logic
	mux2 #(32) pcbrmux(.d0(PCPlus4F), .d1(PCTargetE), .s(PCSrcE), .y(PCNext));

	// Fetch stage logic
	flopenr #(32) pcreg(.clk(clk), .reset(reset), .en(
`ifdef ENABLE_MUL_DIV_SUPPORT
			~(StallD | div_stallE)
`else
			~StallF // TODO check this format
`endif
		), .d(PCNext), .q(PCF));

	adder pcadd4(.a(PCF), .b(32'd4), .y(PCPlus4F));

	// Decode stage
	flopenrc #(32) pcd(.clk(clk), .reset(reset),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.en(~(StallD | div_stallE)),
`else
		.en(~StallD),
`endif
		.clear(FlushD), .d(PCF), .q(PCD));

	flopenrc #(32) PC4D(.clk(clk), .reset(reset),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.en(~(StallD | div_stallE)),
`else
		.en(~StallD),
`endif
		.clear(FlushD), .d(PCPlus4F), .q(PCPlus4D));

	flopenrc #(
		.WIDTH	(32			),
		.VALUE_0(32'b0010011)
	) INSTD(.clk(clk), .reset(reset),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.en(~(StallD | div_stallE)),
`else
		.en(~StallD),
`endif
		.clear(FlushD), .d(InstrF), .q(InstrD));

	assign rs1D = InstrD[19:15];
	assign rs2D = InstrD[24:20];
	assign rdD = InstrD[11:7];

	// Register file logic
	regfile rf(
		.clk	(clk		),
		.we3	(RegWriteW	),
		.a1		(rs1D		),
		.a2		(rs2D		),
		.a3		(rdW		),
		.wd3	(ResultW	),
		.rd1	(RD1D		),
		.rd2	(RD2D		),
		.sim_t3	(sim_t3		),
		.sim_t4	(sim_t4		),
		.sim_t5	(sim_t5		),
		.sim_t6	(sim_t6		)
	);

	extend ext(
		.instr	(InstrD[31:7]	),
		.immsrc (ImmSrcD		),
		.immext (ImmExtD		)
	);

	// Execute stage
`ifdef ENABLE_MUL_DIV_SUPPORT
	flopenrc #(32) rdata1E	(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(RD1D),		.q(RD1E));
	flopenrc #(32) rdata2E	(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(RD2D),		.q(RD2E));
	flopenrc #(32) immE		(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(ImmExtD),	.q(ImmExtE));
	flopenrc #(32) pcplus4E (.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(PCPlus4D),	.q(PCPlus4E));
	flopenrc #(32) pcE		(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(PCD),		.q(PCE));
	flopenrc #(5)  rs11E	(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(rs1D),		.q(rs1E));
	flopenrc #(5)  rs22E	(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(rs2D),		.q(rs2E));
	flopenrc #(5)  rddE		(.clk(clk), .reset(reset), .en(~div_stallE), .clear(FlushE), .d(rdD),		.q(rdE));
`else
	floprc #(32) rdata1E	(.clk(clk), .reset(reset), .clear(FlushE), .d(RD1D),	.q(RD1E));
	floprc #(32) rdata2E	(.clk(clk), .reset(reset), .clear(FlushE), .d(RD2D),	.q(RD2E));
	floprc #(32) immE		(.clk(clk), .reset(reset), .clear(FlushE), .d(ImmExtD),	.q(ImmExtE));
	floprc #(32) pcplus4E	(.clk(clk), .reset(reset), .clear(FlushE), .d(PCPlus4D),.q(PCPlus4E));
	floprc #(32) pcE		(.clk(clk), .reset(reset), .clear(FlushE), .d(PCD),		.q(PCE));
	floprc #(5)  rs11E		(.clk(clk), .reset(reset), .clear(FlushE), .d(rs1D),	.q(rs1E));
	floprc #(5)  rs22E		(.clk(clk), .reset(reset), .clear(FlushE), .d(rs2D),	.q(rs2E));
	floprc #(5)  rddE		(.clk(clk), .reset(reset), .clear(FlushE), .d(rdD),		.q(rdE));
`endif

	mux3 #(32) forwardaemux(.d0(RD1E), .d1(ResultW), .d2(ALUResultM), .s(forwardaE), .y(SrcAE));
	mux3 #(32) forwardbemux(.d0(RD2E), .d1(ResultW), .d2(ALUResultM), .s(forwardbE), .y(WriteDataE));
	mux2 #(32) srcbmux(.d0(WriteDataE), .d1(ImmExtE), .s(ALUSrcE), .y(SrcBE));

	// ALU logic
	alu alu(
`ifdef ENABLE_MUL_DIV_SUPPORT
		.clk		(clk		),
		.reset		(reset		),
`endif
		.a			(SrcAE		),
		.b			(SrcBE		),
		.alucontrol (ALUControlE),
`ifdef ENABLE_MUL_DIV_SUPPORT
		.alu_m		(ALUME 		),
		.i_div_flush(FlushE 	),
		.o_div_busy (DIV_busyE 	),
		.o_div_valid(DIV_validE ),
`endif
		.result		(ALUResultE	),
		.zero		(ZeroE		)
	);

	adder pcaddJAL(.a(PCE), .b(ImmExtE), .y(PCTargetE));

	// Memory stage
`ifdef ENABLE_MUL_DIV_SUPPORT
	flopenr #(32) r1M		(.clk(clk), .reset(reset), .en(~div_stallE), .d(WriteDataE),.q(WriteDataM));
	flopenr #(32) r2M		(.clk(clk), .reset(reset), .en(~div_stallE), .d(ALUResultE),.q(ALUResultM));
	flopenr #(32) pcplus4M	(.clk(clk), .reset(reset), .en(~div_stallE), .d(PCPlus4E),	.q(PCPlus4M));
	flopenr #(5)  rdm		(.clk(clk), .reset(reset), .en(~div_stallE), .d(rdE),		.q(rdM));

	// Writeback stage
	flopenr #(32) aluM		(.clk(clk), .reset(reset), .en(~div_stallE), .d(ALUResultM),.q(ALUResultW));
	flopenr #(32) pcplus4w	(.clk(clk), .reset(reset), .en(~div_stallE), .d(PCPlus4M),	.q(PCPlus4W));
	flopenr #(32) resultW	(.clk(clk), .reset(reset), .en(~div_stallE), .d(ReadDataM),	.q(ReadDataW));
	flopenr #(5)  rdw		(.clk(clk), .reset(reset), .en(~div_stallE), .d(rdM),		.q(rdW));
`else
	flopr #(32) r1M		(.clk(clk), .reset(reset), .d(WriteDataE),	.q(WriteDataM));
	flopr #(32) r2M		(.clk(clk), .reset(reset), .d(ALUResultE),	.q(ALUResultM));
	flopr #(32) pcplus4M(.clk(clk), .reset(reset), .d(PCPlus4E),	.q(PCPlus4M));
	flopr #(5)  rdm		(.clk(clk), .reset(reset), .d(rdE),			.q(rdM));

	// Writeback stage
	flopr #(32) aluM	(.clk(clk), .reset(reset), .d(ALUResultM),	.q(ALUResultW));
	flopr #(32) pcplus4w(.clk(clk), .reset(reset), .d(PCPlus4M),	.q(PCPlus4W));
	flopr #(32) resultW (.clk(clk), .reset(reset), .d(ReadDataM),	.q(ReadDataW));
	flopr #(5)  rdw		(.clk(clk), .reset(reset), .d(rdM),			.q(rdW));
`endif

	mux3 #(32) resultmux(.d0(ALUResultW), .d1(ReadDataW), .d2(PCPlus4W), .s(ResultSrcW), .y(ResultW));

endmodule
`endif