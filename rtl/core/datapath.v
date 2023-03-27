module datapath(
	input				clk,
    input				reset,
    input		[1:0]	ResultSrc,
    input				PCSrc,
    input				ALUSrc,
    input				RegWrite,
    input		[1:0]	ImmSrc,
    input		[2:0]	ALUControl,
    output				Zero,
    output reg	[31:0]	PC,
    input  wire [31:0]	Instr,
    output wire [31:0]	ALUResult,
    output wire [31:0]	WriteData,
    input  wire [31:0]	ReadData,
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
		.clk 	(clk        	), 
        .we3 	(RegWrite   	),  // rd write enable
        .a1 	(Instr[19:15]	),  // rs1 index
        .a2 	(Instr[24:20]	),  // rs2 index 
        .a3 	(Instr[11:7] 	),  // rd  index
        .wd3 	(Result     	),  // rd write data
        .rd1 	(reg1       	),
        .rd2 	(reg2       	),
        .sim_t3 (sim_t3  		),
        .sim_t4 (sim_t4  		),
        .sim_t5 (sim_t5  		),
        .sim_t6 (sim_t6  		)
	);

  	extend ext(
		.instr (Instr[31:7]	),
		.immsrc(ImmSrc 		),
		.immext(ImmExt 		)
	);

  	// 3. ALU logic:
  	assign SrcA = reg1;
  	assign SrcB = ALUSrc ? ImmExt : reg2;
	
	alu alu(
		.a 			(SrcA 		),
		.b 			(SrcB 		),
		.alucontrol (ALUControl ),
		.result 	(ALUResult 	),
		.zero 		(Zero 		)
	);

  	// 4. Store logic:
  	assign WriteData = reg2;
  	// WriteAddr is ALUResult.
	
  	// 5. Write back to Destination Register logic:
  	assign Result = ResultSrc[1] ? PCPlus4 : (ResultSrc[0] ? ReadData: ALUResult);

endmodule
