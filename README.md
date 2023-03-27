# Simple RISC CPU

简单的**基于部分RV32I指令集**的CPU，并在Genesys2上验证并部署（双向）流水灯。

## ⛓ Prerequisites

1. 编译工具：[iverilog](https://github.com/gtkwave/gtkwave)
2. 仿真波形查看：[gtkwave](https://github.com/gtkwave/gtkwave)
3. 工程示例部署：Vivado 2022.2，如果使用Genesys2，可直接使用约束文件

## 📜 Directory

1. `./rtl` 下为RTL源码
2. `./test` 下为仿真测试所需文件，其中 `.mem` 为三个仿真程序放置在 `imem` 的指令；`./test/test.sh` 包含使用iverilog仿真的简单命令
3. 三个应用示例及仿真程序在 `./rtl/imem.v` 内注释处有详细说明
4. Vivado工程位于 `./proj` 下，需要Vivado 2022.2及更高版本，或自行部署

## 🛠️ Usages

1. 运行RV32I指令测试仿真程序

   ```shell
   bash test/test.sh SIM_VALUE25
   ```

   若成功运行且RTL正确，将输出仿真正确信息，仿真的最后 `dmem` 地址100处将写入25。
2. 运行单向流水灯仿真程序

   ```shell
   bash test/test.sh SIM_ROTATING_LEDS
   ```

   若在Vivado上部署此工程，则在 `./rtl/core/config.vh` 下开启此宏定义：

   ```verilog
   `define USE_ROTATING_LEDS_EXAMPLE
   ```

   部署在Genesys2的现象：8个LED将从LED0\~LED7间隔~0.5s依次闪烁。
3. 运行双向流水灯仿真程序

   ```shell
   bash test/test.sh SIM_ROTATING_LEDS
   ```

   若在Vivado上部署此工程，则在 `./rtl/core/config.vh` 下开启此宏定义，同时注释上一宏定义：

   ```verilog
   // `define USE_ROTATING_LEDS_EXAMPLE 
   `define USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE
   ```

   部署在Genesys2的现象：8个LED将从LED\~LED7\~LED0间隔~0.5s双向依次闪烁。

## 📚 应用示例简介

1. RV32I指令测试：测试所设计的所有指令，最终将25写入 `dmem` 地址100处

   ```assembly
   #       RISC-V Assembly         Description               Address   Machine Code
   main:   addi x2, x0, 5          # x2 = 5                  00        0x00500113
           addi x3, x0, 12         # x3 = 12                 04        0x00C00193
           addi x7, x3, -9         # x7 = (12 - 9) = 3       08        0xFF718393
           or   x4, x7, x2         # x4 = (3 OR 5) = 7       0C        0x0023E233
           and  x5, x3, x4         # x5 = (12 AND 7) = 4     10        0x0041F2B3
           add  x5, x5, x4         # x5 = (4 + 7) = 11       14        0x004282B3
           beq  x5, x7, end        # shouldn't be taken      18        0x02728863
           slt  x4, x3, x4         # x4 = (12 < 7) = 0       1C        0x0041A233
           beq  x4, x0, around     # should be taken         20        0x00020463
           addi x5, x0, 0          # shouldn't happen        24        0x00000293
   around: slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28        0x0023A233
           add  x7, x4, x5         # x7 = (1 + 11) = 12      2C        0x005203B3
           sub  x7, x7, x2         # x7 = (12 - 5) = 7       30        0x402383B3
           sw   x7, 84(x3)         # [96] = 7                34        0x0471AA23
           lw   x2, 96(x0)         # x2 = [96] = 7           38        0x06002103
           add  x9, x2, x5         # x9 = (7 + 11) = 18      3C        0x005104B3
           jal  x3, end            # jump to end, x3 = 0x44  40        0x008001EF
           addi x2, x0, 1          # shouldn't happen        44        0x00100113
   end:    add  x2, x2, x9         # x2 = (7 + 18)  = 25     48        0x00910133
           sw   x2, 0x20(x3)       # mem[100] = 25           4C        0x0221A023
   done:   beq  x2, x2, done       # infinite loop           50        0x00210063
   ```
   指令主要包括：

   | Instruction |   opcode   |  funct3  |   funct7   |
   | :---------: | :--------: | :-------: | :--------: |
   |     ADD     | 7'b0110011 |  3'b000  | 7'b0000000 |
   |     SUB     | 7'b0110011 |  3'b000  | 7'b0100000 |
   |     AND     | 7'b0110011 |  3'b111  | 7'b0000000 |
   |     OR     | 7'b0110011 |  3'b110  | 7'b0000000 |
   |     SLT     | 7'b0110011 |  3'b010  | 7'b0000000 |
   |    ADDI    | 7'b0010011 |  3'b000  | immediate |
   |    ANDI    | 7'b0010011 |  3'b111  | immediate |
   |     ORI     | 7'b0010011 |  3'b110  | immediate |
   |    SLTI    | 7'b0010011 |  3'b010  | immediate |
   |     BEQ     | 7'b1100011 |  3'b000  | immediate |
   |     LW     | 7'b0000011 |  3'b010  | immediate |
   |     SW     | 7'b0100011 |  3'b010  | immediate |
   |     JAL     | 7'b1101111 | immediate | immediate |
2. 单向流水灯。板上时钟频率100MHz，借助 `t5` 寄存器及循环计数，达到

   $$
   100\text{M}/(2047\times 8192\times 3)\approx 2\text{Hz}
   $$

   分频，实现间隔~0.5秒闪烁效果。在Genesys2上，`t4` 寄存器低八位对应8个LED。

   ```assembly
   #           RISC-V Assembly         Description                     Address  Machine Code
   init:       addi t5, x0, 2047       # count_max, t5 = 2047          00       0x7FF00F13
               add  t5, t5, t5         # count_max, t5 = 2047*2        04       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*4        08       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*8        0C       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*16       10       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*32       14       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*64       18       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*128      1C       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*256      20       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*512      24       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*1024     28       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*2048     2C       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*4096     30       0x01EF0F33
               add  t5, t5, t5         # count_max, t5 = 2047*8192     34       0x01EF0F33
               addi t6, x0, 256        # led_max, t6 = 256             38       0x10000F93
               addi t4, x0, 1          # init led value, t4 = 1        3C       0x00100E93
   clean_cnt:  addi t3, x0, 0          # clear count(t3).              40       0x00000E13
   count:      addi t3, t3, 1          # count++                       44       0x001E0E13
               beq  t3, t5, mov_led    # if count==max, jump mov_led   48       0x01EE0463
               jal count               #                               4C       0xFF9FF06F
   mov_led:    add t4, t4, t4          # led << 1.                     50       0x01DE8EB3
               beq t4, t6, clean_led   #                               54       0xFFFE84E3
               jal clean_cnt           #                               58       0xFE9FF06F
   ```
   其中，各寄存器含义如下表所列：

   | Register | Address |      Meaning      |
   | :------: | :------: | :---------------: |
   |  `t3`  | 5'b11100 | Counter of `t5` |
   |  `t4`  | 5'b11101 |    LED result    |
   |  `t5`  | 5'b11110 |  0.5s time count  |
   |  `t6`  | 5'b11111 |   Led max count   |
3. 双向流水灯，在上述示例基础上实现双向闪烁，仅多用几个寄存器。

   ```assembly
   #           RISC-V Assembly         Description                   Address  Machine Code
   init:       addi t5, x0, 2047       # count_max, t5 = 2047        00       0x7FF00F13
               addi t3, x0, 13         # loop_cnt = 13               04       0x00D00E13
               addi x5, x0, 0          # x5 = 0                      08       0x00000293
   init_loop:  addi x5, x5, 1          # x5 += 1                     0C       0x00128293
               add  t5, t5, t5         # t5 *= 2                     10       0x01EF0F33
               beq  x5, t3, start      # if x5 == t3, jump start     14       0x005E0463
               jal  init_loop          #                             18       0xFF5FF06F
   start:      addi t6, x0, 8          # pow_max, t6 = 8             1C       0x00800F93
               addi x2, x0, 0          # init pow count, x2 = 0      20       0x00000113
               addi x4, x0, 0          # x4 = 0                      24       0x00000213
               addi t4, x0, 0          # t4 = 0                      28       0x00000E93
   clean_cnt:  addi t3, x0, 0          # clear count(t3).            2C       0x00000E13
   count_add:  addi t3, t3, 1          # count++                     30       0x001E0E13
               beq  t3, t5, judge      # if count==max, jump judge   34       0x01EE0463
               jal  count_add          #                             38       0xFF9FF06F
   judge:      beq  x2, t6, dec_pow    # if x2 == 8, jump dec_pow    3C       0x002F8463
               beq  x4, x0, add_pow    # if x4 == 0, jump add_pow    40       0x00400A63
   dec_pow:    addi x4, x0, 1          # x4 = 1                      44       0x00100213
               beq  x2, x4, add_pow    # if x2 == x4, jump add_pow   48       0x00220663
               sub  x2, x2, x4         # x2 -= 1                     4C       0x40410133
               jal  get_led            #                             50       0x00C0006F
   add_pow:    addi x4, x0, 0          # x4 = 0                      54       0x00000213
               addi x2, x2, 1          # x2 += 1                     58       0x00110113
   get_led:    addi x5, x0, 1          # x5 = 1                      5C       0x00100293
               addi x3, x0, 1          # x3 = 1                      60       0x00100193
   led_loop:   beq  x5, x2, show_led   # if x5 == x2, jump show_led  64       0x00228863
               addi x5, x5, 1          # x5 += 1                     68       0x00128293
               add  x3, x3, x3         # x3 *= 2                     6C       0x003181B3
               jal  led_loop           #                             70       0xFF5FF06F
   show_led:   addi t4, x3, 0          # t4 = x3                     74       0x00018E93
               jal  clean_cnt          #                             78       0xFB5FF06F
   ```
   其中，各寄存器含义如下表所列：

   | Register | Address |                Meaning                |
   | :------: | :------: | :------------------------------------: |
   |  `x2`  | 5'b00010 |           Counter of `t6`           |
   |  `x3`  | 5'b00011 |       Shadow register of `t4`       |
   |  `x4`  | 5'b00100 | Indicate to increase(0) or decrease(1) |
   |  `x5`  | 5'b00101 |           Temporary register           |
   |  `t3`  | 5'b11100 |           Counter of `t5`           |
   |  `t4`  | 5'b11101 |               LED result               |
   |  `t5`  | 5'b11110 |            0.5s time count            |
   |  `t6`  | 5'b11111 |            Pow of LED count            |
