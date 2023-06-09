module mult #(
	parameter W = 32	// width should not be changed, only support 64 now.
)(
	input				i_x_sign,
	input				i_y_sign,
	input		[W-1:0] i_x,
	input		[W-1:0] i_y,
	output wire [W-1:0] o_hi_res,
	output wire [W-1:0] o_lw_res
);

	localparam TOTAL_W = W + 2 ; // 2 for signed extension, 34 totally.
	localparam PNUM = TOTAL_W/2; // 17
	
	wire [TOTAL_W-1:0] x; 		// 34bit
	wire [TOTAL_W-1:0] y; 		// 34bit
	wire [2*TOTAL_W-1:0] res;	// 68bit
	
	assign x = {i_x_sign ? {2{i_x[W-1]}} : 2'b0, i_x[W-1:0]}; // 34bit 扩展两位符号数
	assign y = {i_y_sign ? {2{i_y[W-1]}} : 2'b0, i_y[W-1:0]};
	
	// 1. generate partial product://///////////////////////////////////////////////////////////
	wire [TOTAL_W:0] p[PNUM-1:0];	// 17个 34bit部分积
	wire c[PNUM-1:0];             	// 扩展位
	
	booth #(
		.WIDTH(TOTAL_W)
	) B_0(.x(x), .s({y[1:0], 1'b0}), .p(p[0]), .c(c[0]));	// p[0] 34bit
	
	genvar i;
	for (i = 1; i < PNUM; i = i+1) begin: Booths
		booth #(
			.WIDTH(TOTAL_W)
		) B_(.x(x), .s(y[2*i+1 : 2*i-1]), .p(p[i]), .c(c[i]));
	end
	
	// 2. use wallace tree to generate result://////////////////////////////////////////////////
	wire [2*TOTAL_W-1:0] tree_in [PNUM-1:0];	// with modified sign extension  扩展成68bit
	wire [2*TOTAL_W-1:0] tree_out [1:0];      //压缩成两个68bit相加
	
	assign tree_in[0] = {{(TOTAL_W-1){c[0]}}, p[0]};
	
	for(i = 1; i < PNUM; i = i+1) begin: gen_tree_in
		assign tree_in[i] = {{(TOTAL_W-1-2*i){c[i]}}, p[i], 1'b0, c[i-1], {(2*i-2){1'b0}}};
	end
	
	wallace_tree_17 #(
		.WIDTH(2*TOTAL_W)
	) wallace_tree (
		.in (tree_in	),
		.out(tree_out	)
	);
	
	// 3. full connect adder://///////////////////////////////////////////////////////////////////
	wire carry;
	
	rca_nbit #(
		.N(2*TOTAL_W	)
	) u_rca_nbit(
		.i_a(tree_out[1]),
		.i_b(tree_out[0]),
		.i_c(1'b0		),
		.o_s(res		),
		.o_c(carry		)
	);
	
	assign {o_hi_res, o_lw_res} = res[2*W-1:0];

endmodule