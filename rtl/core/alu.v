`include "defines.vh"
`include "config.vh"

module alu(
`ifdef ENABLE_MUL_DIV_SUPPORT
	input				clk,
	input				reset,
`endif
	input		[31:0]	a,
	input		[31:0]	b,
	input		[ 2:0]	alucontrol,
`ifdef ENABLE_MUL_DIV_SUPPORT
	input		[ 1:0]	alu_m,
	input				i_div_flush,
	output				o_div_busy,
	output				o_div_valid,
`endif
	output reg	[31:0]	result,
	output wire			zero
);

	wire [1:0] alum;
	wire [31:0] condinvb, sum;
	wire v;								// overflow
	wire isAddSub;						// true when is add or subtract operation

	assign condinvb = alucontrol[0] ? ~b : b;
	assign sum = a + condinvb + alucontrol[0];
	assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
					~alucontrol[1] & alucontrol[0];

`ifdef ENABLE_MUL_DIV_SUPPORT
	assign alum = alu_m;

	wire [31:0] quotient, remainder;
	wire [31:0] mult_high, mult_low;

	// serdiv
	serdiv #(
		.WIDTH		(32)
	) div1 (
		.i_clk		(clk					),
		.i_rst		(reset					),
		.i_flush 	(i_div_flush			),
		.i_start	(alucontrol[1] & alum[0]),
		.i_signed	(alucontrol[2]			),
		.i_dividend (a						),
		.i_divisor	(b						),
		.o_busy		(o_div_busy				),
		.o_end_valid(o_div_valid			),
		.o_quotient	(quotient				),
		.o_remainder(remainder				)
	);

	// mul
	mult #(
		.W(32)
	) mult1 (
		.i_x_sign	(alucontrol[2]	),
		.i_y_sign	(alucontrol[1]	),
		.i_x		(a				),
		.i_y		(b				),
		.o_hi_res	(mult_high		),
		.o_lw_res	(mult_low		)
	);
`else
	assign alum = 2'b0;
`endif

	always @(*) begin
		casez ({alum, alucontrol})
			{2'b00, `ALU_CTRL_ADD}:	result = sum;			// ADD/ADDI
			{2'b00, `ALU_CTRL_SUB}:	result = sum;			// SUB/SUBI
			{2'b00, `ALU_CTRL_AND}:	result = a & b;			// AND/ANDI
			{2'b00, `ALU_CTRL_OR}:	result = a | b;			// OR/ORI
			{2'b00, `ALU_CTRL_XOR}:	result = a ^ b;			// XOR/XORI
			{2'b00, `ALU_CTRL_SLT}:	result = sum[31] ^ v;	// SLT/SLTI
			{2'b00, `ALU_CTRL_SLL}:	result = a << b[4:0];	// SLL/SLLI
			{2'b00, `ALU_CTRL_SRL}:	result = a >> b[4:0];	// SRL/SRLI
`ifdef ENABLE_MUL_DIV_SUPPORT
			{2'b11, 2'b??, 1'b0}:	result = quotient;
			{2'b11, 2'b??, 1'b1}:	result = remainder;
			{2'b10, 2'b??, 1'b0}:	result = mult_high;
			{2'b10, 2'b??, 1'b1}:	result = mult_low;
`endif
			default:				result = 32'bx;
		endcase
	end

	assign zero = (result == 32'b0);
	assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;

endmodule