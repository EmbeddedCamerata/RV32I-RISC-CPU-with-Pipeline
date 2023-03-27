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
		.op        (Instr[6:0]  ),
  	    .funct3    (Instr[14:12]),
  	    .funct7b5  (Instr[30]   ),
  	    .Zero      (Zero        ),
  	    .ResultSrc (ResultSrc   ),
  	    .MemWrite  (MemWrite    ),
  	    .PCSrc     (PCSrc       ),
  	    .ALUSrc    (ALUSrc      ),
  	    .RegWrite  (RegWrite    ),
  	    .Jump      (Jump        ),
  	    .ImmSrc    (ImmSrc      ),
  	    .ALUControl(ALUControl  )
	);

  	datapath dp(
		.clk       (clk         ),
    	.reset     (reset       ),
    	.ResultSrc (ResultSrc   ), 
    	.PCSrc     (PCSrc       ), 
    	.ALUSrc    (ALUSrc      ),
    	.RegWrite  (RegWrite    ),
    	.ImmSrc    (ImmSrc      ),
    	.ALUControl(ALUControl  ),
    	.Zero      (Zero        ),
    	.PC        (PC          ),
    	.Instr     (Instr       ),
    	.ALUResult (ALUResult   ),
    	.WriteData (WriteData   ),
    	.ReadData  (ReadData    ),
    	.sim_t3    (sim_t3      ),
    	.sim_t4    (sim_t4      ),
    	.sim_t5    (sim_t5      ),
    	.sim_t6    (sim_t6      )
	);

endmodule