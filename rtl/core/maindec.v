`include "defines.vh"

module maindec(
	input		[6:0]	op,
	output wire [1:0]	ResultSrc,
	output wire			MemWrite,
	output wire			Branch,
	output wire			ALUSrc,
	output wire			RegWrite,
	output wire			Jump,
	output wire [1:0]	ImmSrc,
	output wire [1:0]	ALUOp
);

	reg [10:0] controls;

	always @(*) begin
		case (op)
			`OP_LW:		controls = {1'b1, 2'b00, 1'b1, 1'b0, 2'b01, 1'b0, 2'b00, 1'b0};
			`OP_SW:		controls = {1'b0, 2'b01, 1'b1, 1'b1, 2'b00, 1'b0, 2'b00, 1'b0};
			`OP_R_TYPE:	controls = {1'b1, 2'b00, 1'b0, 1'b0, 2'b00, 1'b0, 2'b10, 1'b0};
			`OP_BEQ:	controls = {1'b0, 2'b10, 1'b0, 1'b0, 2'b00, 1'b1, 2'b01, 1'b0};
			`OP_I_TYPE:	controls = {1'b1, 2'b00, 1'b1, 1'b0, 2'b00, 1'b0, 2'b10, 1'b0};
			`OP_JAL:	controls = {1'b1, 2'b11, 1'b0, 1'b0, 2'b10, 1'b0, 2'b00, 1'b1};
			default:	controls = 11'b0;
		endcase
	end

	assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

endmodule