# 3. Double-side rotating leds.
# If successful, 8 Leds will rotating back and forth all the time.
# Register	Address 	Meaning
# t3 		11100 		counter of t5
# t4 		11101 		LED result
# t5 		11110 		0.5s time count
# t6 		11111 		LED max value
# x1		00001 		temporary register

#           RISC-V Assembly         Description                     Address     Machine Code
init:       addi t5, x0, 2047       # count_max, t5 = 2047          00			0x7FF00F13	# 0111_1111_1111_00000_000_11110_0010011
			addi t3, x0, 13			# loop_cnt = 13 				04			0x00D00E13	# 0000_0000_1101_00000_000_11100_0010011
			addi x1, x0, 0 			# x1 = 0 						08			0x00000293	# 0000_0000_0000_00000_000_00001_0010011
init_loop:  addi x1, x1, 1 			# x1 += 1 						0C			0x00128293	# 0000_0000_0001_00001_000_00001_0010011
			slli t5, t5, 1 			# t5 << 1 						10			0x001F3F13	# 0000_0000_0001_11110_011_11110_0010011
			beq  x1, t3, start		# if x1 == t3, jump start 		14			0x005E0463	# 0000000_00001_11100_000_01000_1100011
			jal  init_loop 			# 								18			0xFF5FF06F	# 1111_1111_0101_1111_1111_00000_1101111
start: 		addi t6, x0, 256        # led_max = 256					1C			0x10000F93	# 0001_0000_0000_00000_000_11111_0010011
			addi x1, x0, 1			# x1 = 1 						20 			0x00100093	# 0000_0000_0001_00000_000_00001_0010011
new_cycle:	addi t4, x0, 1          # init led value, t4 = 1        24			0x00100E93	# 0000_0000_0001_00000_000_11101_0010011

inc_clr_cnt:addi t3, x0, 0          # clear count(t3)				28			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
inc_count:	addi t3, t3, 1          # count++						2C			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
			beq  t3, t5, inc_led    # if count == max, jump inc_led 30			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
			jal  inc_count          # 								34			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
inc_led:	slli t4, t4, 1         	# led << 1						38			0x001EBE93	# 0000_0000_0001_11101_011_11101_0010011
			beq  t4, t6, jump256   	# if led = 256, jump jump256	3C			0x01FE8C63	# 0000000_11111_11101_000_11000_1100011
			jal  inc_clr_cnt		# 								40			0xFE9FF06F	# 1111_1110_1001_1111_1111_00000_1101111

dec_clr_cnt:addi t3, x0, 0          # clear count(t3)				44			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
dec_count:	addi t3, t3, 1          # count++						48			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
			beq  t3, t5, dec_led    # if count == max, jump dec_led 4C			0x01EE0663	# 0000000_11110_11100_000_01100_1100011
			jal  dec_count          # 								50			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
jump256:	srli t4, t4, 1 			# led >> 1 = 128				54 			0x001ECE93	# 0000_0000_0001_11101_100_11101_0010011
dec_led:	srli t4, t4, 1 			# led >> 1 						58 			0x001ECE93	# 0000_0000_0001_11101_100_11101_0010011
			beq  t4, x1, new_cycle  # if led = 1, jump new_cycle	5C			0xFC1E84E3	# 1111110_00001_11101_000_01001_1100011
			jal  dec_clr_cnt 		# 								60 			0xFE5FF06F	# 1111_1110_0101_1111_1111_00000_1101111

# For simulation, t5 = 8:
# 			RISC-V Assembly         Description                     Address     Machine Code
init:       addi t5, x0, 8       	# count_max, t5 = 8          	00			0x00800F13	# 0000_0000_1000_00000_000_11110_0010011
start: 		addi t6, x0, 256        # led_max = 256					04			0x10000F93	# 0001_0000_0000_00000_000_11111_0010011
			addi x1, x0, 1			# x1 = 1 						08 			0x00100093	# 0000_0000_0001_00000_000_00001_0010011
new_cycle:	addi t4, x0, 1          # init led value, t4 = 1        0C			0x00100E93	# 0000_0000_0001_00000_000_11101_0010011

inc_clr_cnt:addi t3, x0, 0          # clear count(t3)				10			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
inc_count:	addi t3, t3, 1          # count++						14			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
			beq  t3, t5, inc_led    # if count == max, jump inc_led 18			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
			jal  inc_count          # 								1C			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
inc_led:	slli t4, t4, 1         	# led << 1						20			0x001EBE93	# 0000_0000_0001_11101_011_11101_0010011
			beq  t4, t6, jump256   	# if led = 256, jump jump256	24			0x01FE8C63	# 0000000_11111_11101_000_11000_1100011
			jal  inc_clr_cnt		# 								28			0xFE9FF06F	# 1111_1110_1001_1111_1111_00000_1101111

dec_clr_cnt:addi t3, x0, 0          # clear count(t3)				2C			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
dec_count:	addi t3, t3, 1          # count++						30			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
			beq  t3, t5, dec_led    # if count == max, jump dec_led 34			0x01EE0663	# 0000000_11110_11100_000_01100_1100011
			jal  dec_count          # 								38			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
jump256:	srli t4, t4, 1 			# led >> 1 = 128				3C 			0x001ECE93	# 0000_0000_0001_11101_100_11101_0010011
dec_led:	srli t4, t4, 1 			# led >> 1 						40 			0x001ECE93	# 0000_0000_0001_11101_100_11101_0010011
			beq  t4, x1, new_cycle  # if led = 1, jump new_cycle	44			0xFC1E84E3	# 1111110_00001_11101_000_01001_1100011
			jal  dec_clr_cnt 		# 								48 			0xFE5FF06F	# 1111_1110_0101_1111_1111_00000_1101111