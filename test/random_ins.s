@       RISC-V Assembly         Description     Address   	Machine Code
main:   addi x2, x0, 8          # x2 = 8        00			0x00500113	# 0000000_00101_00000_000_00010_0010011
		addi x3, x0, 5 			# x3 = 5		04
		slli x2, x2, 1 			# x2 << 1		08
		srli x2, x2, 2			# x2 >> 2 		0C
		sll  x2, x2, x3 		# x2 << 5(x3)  	10
		srl  x2, x2, x3 		# x2 >> 5(x3)  	14
		xori x2, x2, 7 			# x2 = x2^7 	18
		ori  x2, x2, 15 		# x2 = x2|15 	1C
		xor  x2, x2, x3 		# x2 = x2^5(x3) 20
		or 	 x2, x2, 