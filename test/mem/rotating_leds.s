@ 2. rotating leds.
@ If successful, 8 Leds will rotating orderly all the time.

@        	RISC-V Assembly 		Description  					Address		Machine Code
init:       addi t5, x0, 2047       # count_max, t5 = 2047          00			0x7FF00F13	# 0111_1111_1111_00000_000_11110_0010011
			add  t5, t5, t5         # count_max, t5 = 2047*2        04			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*4        08			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*8        0C			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*16       10			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*32       14			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*64       18			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*128      1C			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*256      20			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*512      24			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*1024     28			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*2048     2C			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*4096     30			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			add  t5, t5, t5         # count_max, t5 = 2047*8192     34			0x01EF0F33	# 0000_000_11110_11110_000_11110_0110011
			addi t6, x0, 256        # led_max, t6 = 256             38			0x10000F93	# 0001_0000_0000_00000_000_11111_0010011
clean_led:  addi t4, x0, 1          # init led value, t4 = 1        3C			0x00100E93	# 0000_0000_0001_00000_000_11101_0010011
clean_cnt:  addi t3, x0, 0          # clear count(t3).              40			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
count:      addi t3, t3, 1          # count++  						44			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
			beq  t3, t5, mov_led    # if count==max, jump mov_led   48			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
			jal count               # 								4C			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
mov_led:    add t4, t4, t4          # led << 1.						50			0x01DE8EB3	# 0000_000_11101_11101_000_11101_0110011
			beq t4, t6, clean_led   # 								54			0xFFFE84E3	# 1111111_11111_11101_000_01001_1100011
			jal clean_cnt           # 								58			0xFE9FF06F	# 1111_1110_1001_1111_1111_00000_1101111

@ For simulation, t5 = 8(short enough):
@        	RISC-V Assembly 		Description  					Address		Machine Code
init:       addi t5, x0, 8       	# count_max, t5 = 8 			00			0x00800F13	# 0000_0000_1000_00000_000_11110_0010011
			addi t6, x0, 256        # led_max, t6 = 256             04			0x10000F93	# 0001_0000_0000_00000_000_11111_0010011
clean_led:  addi t4, x0, 1          # init led value, t4 = 1        08			0x00100E93	# 0000_0000_0001_00000_000_11101_0010011
clean_cnt:  addi t3, x0, 0          # clear count(t3).              0C			0x00000E13	# 0000_0000_0000_00000_000_11100_0010011
count:      addi t3, t3, 1          # count++  						10			0x001E0E13	# 0000_0000_0001_11100_000_11100_0010011
			beq  t3, t5, mov_led    # if count==max, jump mov_led   14			0x01EE0463	# 0000000_11110_11100_000_01000_1100011
			jal count               # 								18			0xFF9FF06F	# 1111_1111_1001_1111_1111_00000_1101111
mov_led:    add t4, t4, t4          # led << 1.						1C			0x01DE8EB3	# 0000_000_11101_11101_000_11101_0110011
			beq t4, t6, clean_led   # 								20			0xFFFE84E3	# 1111111_11111_11101_000_01001_1100011
			jal clean_cnt           # 								24			0xFE9FF06F	# 1111_1110_1001_1111_1111_00000_1101111