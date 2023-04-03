module hazard(
	input		[4:0]	rs1D,
	input		[4:0]	rs2D,
	input		[4:0]	rs1E,
	input		[4:0]	rs2E,
	input		[4:0]	rdE,
	input		[4:0]	rdM,
	input		[4:0]	rdW,
	input				RegWriteM,
	input				RegWriteW,
	input				ResultSrcE0,
	input				PCSrcE,
	output reg	[1:0]	forwardaE,
	output reg	[1:0]	forwardbE,
	output wire			stallF,
	output wire			stallD,
	output wire			flushD,
	output wire			flushE
);

	// forwarding src to E stage(ALU)
	always @(*) begin
		if (rs1E != 0)
			if (rs1E == rdM & RegWriteM)
				forwardaE = 2'b10;
			else if (rs1E == rdW & RegWriteW)
				forwardaE = 2'b01;
			else
				forwardaE = 2'b00;
		else
			forwardaE = 2'b00;
		
		if (rs2E != 0)
			if (rs2E == rdM & RegWriteM)
				forwardbE = 2'b10;
			else if (rs2E == rdW & RegWriteW)
				forwardbE = 2'b01;
			else
				forwardbE = 2'b00;
		else
			forwardbE = 2'b00;
	end

	wire lwstall;

	// stalls load word stall logic
	assign #1 lwstall = ResultSrcE0 & (rdE == rs1D | rdE == rs2D);
	
	assign #1 stallD = lwstall;
	assign #1 stallF = stallD;

	// contorl hazard flush
	assign #1 flushD = PCSrcE;
	assign #1 flushE = lwstall | PCSrcE;

endmodule