// Single-cycle implementation of RISC-V (RV32I)
// User-level Instruction Set Architecture V2.2 (May 7, 2017)
// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt, 
//    addi, andi, ori, slti
//    beq
//    jal
// Exceptions, traps, and interrupts not implemented
// little-endian memory

// 31 32-bit registers x1-x31, x0 hardwired to 0
// R-Type instructions
//   add, sub, and, or, slt
//   INSTR rd, rs1, rs2
//   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// I-Type Instructions
//   lw, I-type ALU (addi, andi, ori, slti)
//   lw:         INSTR rd, imm(rs1)
//   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
//   Instr[31:20] = imm[11:0]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// S-Type Instruction
//   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
//   Instr[31:25] = imm[11:5] (offset[11:5])
//   Instr[24:20] = rs2 (src)
//   Instr[19:15] = rs1 (base)
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:0]  (offset[4:0])
//   Instr[6:0]   = opcode
// B-Type Instruction
//   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
//   Instr[31:25] = imm[12], imm[10:5]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:1], imm[11]
//   Instr[6:0]   = opcode
// J-Type Instruction
//   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
//   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode

/*
	Instruction  opcode    funct3    funct7
	add          0110011   000       0000000
	sub          0110011   000       0100000
	and          0110011   111       0000000
	or           0110011   110       0000000
	slt          0110011   010       0000000
	addi         0010011   000       immediate
	andi         0010011   111       immediate
	ori          0010011   110       immediate
	slti         0010011   010       immediate
	beq          1100011   000       immediate
	lw	          0000011   010       immediate
	sw           0100011   010       immediate
	jal          1101111   immediate immediate
*/

module aludec(
	input				opb5,
    input		[2:0]	funct3,
    input				funct7b5,
    input		[1:0]	ALUOp,
    output reg	[2:0]	ALUControl
);

	wire RtypeSub;
	assign RtypeSub = funct7b5 & opb5;  // TRUE for R-type subtract instruction

	always @(*) begin
		case (ALUOp)
			2'b00: ALUControl = 3'b0;
			2'b01: ALUControl = 3'b1;
			2'b10: begin
				case (funct3)
					3'b0: if (RtypeSub) ALUControl = 3'b1; else ALUControl = 3'b0;
					3'b010: ALUControl = 3'b101;
					3'b110: ALUControl = 3'b011;
					3'b111: ALUControl = 3'b010;
					default: ALUControl = 3'b0;
				endcase
			end
			default: ALUControl = 3'b0;
		endcase
	end

endmodule