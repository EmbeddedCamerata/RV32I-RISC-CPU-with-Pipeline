module wallace_tree_17 #(
	parameter WIDTH = 64
)(
	input		[WIDTH-1:0] in[16:0],
	output wire [WIDTH-1:0] out[1:0]
);

	wire [WIDTH-1:0] s_row1[4:0];
	wire [WIDTH-1:0] c_row1[4:0];
	wire [WIDTH-1:0] c_row1_shift[4:0];
	wire [WIDTH-1:0] s_row2[3:0];
	wire [WIDTH-1:0] c_row2[3:0];
	wire [WIDTH-1:0] c_row2_shift[3:0];
	wire [WIDTH-1:0] s_row3[1:0];
	wire [WIDTH-1:0] c_row3[1:0];
	wire [WIDTH-1:0] c_row3_shift[1:0];
	wire [WIDTH-1:0] s_row4[1:0];
	wire [WIDTH-1:0] c_row4[1:0];
	wire [WIDTH-1:0] c_row4_shift[1:0];
	wire [WIDTH-1:0] s_row5;
	wire [WIDTH-1:0] c_row5;
	wire [WIDTH-1:0] c_row5_shift;
	wire [WIDTH-1:0] s_row6, c_row6, c_row6_shift;

	// 1. first level, 5 csa, 17p -> 2x5+2=12p://////////////////////////////////////////////////////////////
	// left in15 in16
	genvar i;
	for (i = 0; i < 5; i = i+1) begin: csa_row1
		csa_nbit #(
			.N(WIDTH		)
		) csa_row1(
			.i_a(in[3*i]	),
			.i_b(in[3*i+1]	),
			.i_c(in[3*i+2]	),
			.o_s(s_row1[i]	),
			.o_c(c_row1[i]	)
		);
		assign c_row1_shift[i] = {c_row1[i][WIDTH-2:0], 1'b0};
	end

	// 2. second level, 4 csa, 12p -> 8p
	// add in15 in16;
	csa_nbit #(WIDTH) csa_row2_0(.i_a(s_row1[0]),		.i_b(c_row1_shift[0]),	.i_c(s_row1[1]),		.o_s(s_row2[0]),  .o_c(c_row2[0]));
	csa_nbit #(WIDTH) csa_row2_1(.i_a(c_row1_shift[1]),	.i_b(s_row1[2]),		.i_c(c_row1_shift[2]),	.o_s(s_row2[1]),  .o_c(c_row2[1]));
	csa_nbit #(WIDTH) csa_row2_2(.i_a(s_row1[3]),		.i_b(c_row1_shift[3]),	.i_c(s_row1[4]), 		.o_s(s_row2[2]),  .o_c(c_row2[2]));
	csa_nbit #(WIDTH) csa_row2_3(.i_a(c_row1_shift[4]),	.i_b(in[15]),			.i_c(in[16]),			.o_s(s_row2[3]),  .o_c(c_row2[3]));

	for (i = 0; i < 4; i = i+1) begin: csa_row2_shift
		assign c_row2_shift[i] = {c_row2[i][WIDTH-2:0], 1'b0};
  	end

	// 3. third level, 2 csa, 8p -> 6p
	// left s_row2[3], c_row2_shift[3]
	csa_nbit #(WIDTH) csa_row3_0(.i_a(s_row2[0]), .i_b(s_row2[1]),		.i_c(c_row2_shift[0]), .o_s(s_row3[0]), .o_c(c_row3[0]));
	csa_nbit #(WIDTH) csa_row3_1(.i_a(s_row2[2]), .i_b(c_row2_shift[1]),.i_c(c_row2_shift[2]), .o_s(s_row3[1]), .o_c(c_row3[1]));

	for (i = 0; i < 2; i = i+1) begin: csa_row3_shift
		assign c_row3_shift[i] = {c_row3[i][WIDTH-2:0], 1'b0};
	end

	// 4. fourth level, 2csa, 6p -> 4p
	csa_nbit #(WIDTH) csa_row4_0(.i_a(s_row3[0]),		.i_b(s_row3[1]),		.i_c(s_row2[3]),		.o_s(s_row4[0]), .o_c(c_row4[0]));
	csa_nbit #(WIDTH) csa_row4_1(.i_a(c_row2_shift[3]),	.i_b(c_row3_shift[0]),	.i_c(c_row3_shift[1]),	.o_s(s_row4[1]), .o_c(c_row4[1]));

	for (i = 0; i < 2; i = i+1) begin: csa_row4_shift
		assign c_row4_shift[i] = {c_row4[i][WIDTH-2:0], 1'b0};
	end

	// 5. fifth level, 1 csa, 4p -> 3p (2+1)
	csa_nbit #(WIDTH) csa_row5_0(.i_a(c_row4_shift[0]),	.i_b(s_row4[0]), .i_c(s_row4[1]), .o_s(s_row5), .o_c(c_row5));

	assign c_row5_shift = {c_row5[WIDTH-2:0], 1'b0};

	// 6. sixth level, 1 csa, 3p -> 2p
	csa_nbit #(WIDTH) csa_row6_0(.i_a(c_row4_shift[1]), .i_b(s_row5), .i_c(c_row5_shift), .o_s(s_row6), .o_c(c_row6));

	assign c_row6_shift = {c_row6[WIDTH-2:0], 1'b0};

	// 7. output 2p
	assign out[1] = c_row6_shift;
	assign out[0] = s_row6;

endmodule