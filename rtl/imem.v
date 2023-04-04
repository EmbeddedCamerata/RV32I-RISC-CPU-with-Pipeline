`include "config.vh"

module imem(
	input		[31:0]	a,
	output wire [31:0]	rd
);

	reg [31:0] RAM[63:0];

	assign rd = RAM[a[31:2]]; // word aligned

`ifndef SIM_ON_IVERILOG
	always @(*) begin
`ifdef USE_ROTATING_LEDS_EXAMPLE
		RAM[0]  = 32'h7FF00F13;
		RAM[1]  = 32'h01EF0F33;
		RAM[2]  = 32'h01EF0F33;
		RAM[3]  = 32'h01EF0F33;
		RAM[4]  = 32'h01EF0F33;
		RAM[5]  = 32'h01EF0F33;
		RAM[6]  = 32'h01EF0F33;
		RAM[7]  = 32'h01EF0F33;
		RAM[8]  = 32'h01EF0F33;
		RAM[9]  = 32'h01EF0F33;
		RAM[10] = 32'h01EF0F33;
		RAM[11] = 32'h01EF0F33;
		RAM[12] = 32'h01EF0F33;
		RAM[13] = 32'h01EF0F33;
		RAM[14] = 32'h10000f93;
		RAM[15] = 32'h00100e93;
		RAM[16] = 32'h00000e13;
		RAM[17] = 32'h001E0E13;
		RAM[18] = 32'h01EE0463;
		RAM[19] = 32'hFF9FF06F;
		RAM[20] = 32'h01DE8EB3;
		RAM[21] = 32'hFFFE84E3;
		RAM[22] = 32'hFE9FF06F;
`else /* Use USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE */
		RAM[0]  = 32'h7FF00F13;
		RAM[1]  = 32'h00D00E13;
		RAM[2]  = 32'h00000293;
		RAM[3]  = 32'h00128293;
		RAM[4]  = 32'h001F3F13;
		RAM[5]  = 32'h005E0463;
		RAM[6]  = 32'hFF5FF06F;
		RAM[7]  = 32'h10000F93;
		RAM[8]  = 32'h00100093;
		RAM[9]  = 32'h00100E93;
		RAM[10] = 32'h00000E13;
		RAM[11] = 32'h001E0E13;
		RAM[12] = 32'h01EE0463;
		RAM[13] = 32'hFF9FF06F;
		RAM[14] = 32'h001EBE93;
		RAM[15] = 32'h01FE8C63;
		RAM[16] = 32'hFE9FF06F;
		RAM[17] = 32'h00000E13;
		RAM[18] = 32'h001E0E13;
		RAM[19] = 32'h01EE0663;
		RAM[20] = 32'hFF9FF06F;
		RAM[21] = 32'h001ECE93;
		RAM[22] = 32'h001ECE93;
		RAM[23] = 32'hFC1E84E3;
		RAM[24] = 32'hFE5FF06F;
`endif /* USE_ROTATING_LEDS_EXAMPLE */
	end
`endif /* SIM_ON_IVERILOG */

endmodule