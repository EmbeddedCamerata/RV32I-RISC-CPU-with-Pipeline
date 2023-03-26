module regfile(
	input  bit        	clk,
    input  logic        we3,
    input  logic [ 4:0] a1,	// rs1
	input  logic [ 4:0] a2,	// rs2
	input  logic [ 4:0] a3, // rd
    input  logic [31:0] wd3,
    output logic [31:0] rd1,
	output logic [31:0] rd2,
    output logic [31:0] sim_t3,
    output logic [31:0] sim_t4,
    output logic [31:0] sim_t5,
    output logic [31:0] sim_t6
);

  	logic [31:0] rf[31:0];

  	// Three ported register file
  	// Read two ports combinationally (A1/RD1, A2/RD2)
  	// Write third port on rising edge of clock (A3/WD3/WE3)
  	// Register #0 is hard-wired connected to GND

  	always_ff @(posedge clk) begin
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