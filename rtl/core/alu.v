`include "config.vh"

module alu(
	input		[31:0]	a,
	input		[31:0]	b,
	input		[ 2:0]	alucontrol,
	output reg	[31:0]	result,
	output wire			zero
);

	wire [31:0] subtract = a - b;

	always @(*) begin
		case (alucontrol)
			`ALU_CTRL_ADD:	result = a + b;					// ADD/ADDI
			`ALU_CTRL_SUB:	result = subtract;				// SUB/SUBI
			`ALU_CTRL_AND:	result = a & b;					// AND/ANDI
			`ALU_CTRL_OR:	result = a | b;					// OR/ORI
			`ALU_CTRL_XOR:	result = a ^ b;					// XOR/XORI
			`ALU_CTRL_SLT:	result = {31'b0, subtract[31]};	// SLT/SLTI
			`ALU_CTRL_SLL:	result = a << b[4:0];			// SLL/SLLI
			`ALU_CTRL_SRL:	result = a >> b[4:0];			// SRL/SRLI
			default:		result = 32'b0;
		endcase
	end

	assign zero = (result == 32'b0);

endmodule