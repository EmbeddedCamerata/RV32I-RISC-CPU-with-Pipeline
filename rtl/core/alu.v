`include "config.vh"

module alu(
	input		[31:0]	a,
	input		[31:0]	b,
	input		[ 2:0]	alucontrol,
	output reg	[31:0]	result,
	output wire			zero
);

	wire [31:0] condinvb, sum;
	wire v;						// overflow
	wire isAddSub;				// true when is add or subtract operation

	assign condinvb = alucontrol[0] ? ~b : b;
	assign sum = a + condinvb + alucontrol[0];
	assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
					~alucontrol[1] & alucontrol[0];

	always @(*) begin
		case (alucontrol)
			`ALU_CTRL_ADD:	result = sum;					// ADD/ADDI
			`ALU_CTRL_SUB:	result = sum;					// SUB/SUBI
			`ALU_CTRL_AND:	result = a & b;					// AND/ANDI
			`ALU_CTRL_OR:	result = a | b;					// OR/ORI
			`ALU_CTRL_XOR:	result = a ^ b;					// XOR/XORI
			`ALU_CTRL_SLT:	result = sum[31] ^ v;			// SLT/SLTI
			`ALU_CTRL_SLL:	result = a << b[4:0];			// SLL/SLLI
			`ALU_CTRL_SRL:	result = a >> b[4:0];			// SRL/SRLI
			default:		result = 32'bx;
		endcase
	end

	assign zero = (result == 32'b0);
	assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;

endmodule