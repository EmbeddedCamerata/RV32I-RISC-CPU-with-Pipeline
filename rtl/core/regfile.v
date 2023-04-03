module regfile(
	input				clk,
	input				we3,
	input		[ 4:0]	a1,	// rs1
	input		[ 4:0]	a2,	// rs2
	input		[ 4:0]	a3,	// rd
	input		[31:0]	wd3,
	output wire [31:0]	rd1,
	output wire [31:0]	rd2,
	output wire [31:0]	sim_t3,
	output wire [31:0]	sim_t4,
	output wire [31:0]	sim_t5,
	output wire [31:0]	sim_t6
);

	reg [31:0] rf[31:0];	
	// Three ported register file
	// Read two ports combinationally (A1/RD1, A2/RD2)
	// Write third port on rising edge of clock (A3/WD3/WE3)
	// Register #0 is hard-wired connected to GND	
	
	always @(posedge clk) begin
		if (we3)
			rf[a3] <= wd3;
	end	
	
	assign rd1 = (a1 != 0) ? rf[a1] : 0;
	assign rd2 = (a2 != 0) ? rf[a2] : 0;	
	
	// Used for simulation
	assign sim_t3 = rf[28];
	assign sim_t4 = rf[29];
	assign sim_t5 = rf[30];
	assign sim_t6 = rf[31];

endmodule