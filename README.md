<div align="center">

# Single-cycle RISC CPU with Five-stage Pipeline

</div>

**基于RV32I指令集**的单周期CPU，实现了部分指令集，包含五级流水线实现；并在Genesys2上验证并部署（双向）流水灯。

## ⛓ Prerequisites

1. 编译工具：[iverilog](https://github.com/gtkwave/gtkwave)
2. 仿真波形查看：[gtkwave](https://github.com/gtkwave/gtkwave)
3. 可选：Vivado、Genesys2开发板

## 📜 Directory

1. `./rtl` 下为RTL源码，其中 `./rtl/core/pipeline` 包含使用五级流水线实现所需的模块
2. `./test/mem` 下为仿真测试所需文件，其中 `.s` 为测试的汇编程序（包括可部署至FPGA及便于仿真的简化程序），`.mem` 为对应的机器码；`./test/test.sh` 包含使用iverilog编译、仿真、查看波形等简单命令

## 🛠️ Usages

- 使用iverilog进行仿真，通过 `-s <example_name>` 指定所仿真的示例，从而选择不同的 `.mem` 指令至 `imem` 中。具体选项参见下方示例或 `./test/test.sh`。所生成的 `.vvp` 及 `.fst` 波形文件位于 `./test/simple` 或 `./test/pipeline` （若使用五级流水线实现）下。

    1. RV32I指令测试仿真程序

        ```shell
        bash test/test.sh -s SIM_VALUE25
        ```

        若成功运行且RTL正确，将输出仿真正确信息，仿真的最后 `dmem` 地址100处将写入25。

    2. 单向流水灯仿真程序

        ```shell
        bash test/test.sh -s SIM_ROTATING_LEDS
        ```

        `t4` 寄存器将等时间间隔地（对应实际间隔0.5s）从 `32'h1`、`32'h2` 左移至 `32'h80`，再**置** `32'h01`，以此往复，从而对应实际8个LED的单向依次闪烁。

    3. 双向流水灯仿真程序

        ```shell
        bash test/test.sh -s SIM_DB_ROTATING_LEDS
        ```

        `t4` 寄存器将等时间间隔地（对应实际间隔0.5s）从 `32'h1`、`32'h2` 左移至 `32'h80`，再**右移至** `32'h01`，以此往复，从而对应实际8个LED的双向依次闪烁。

    4. 五级流水线部署实现。通过 `-p` 选项编译五级流水线实现的CPU：

        ```shell
        bash test/test.sh -s SIM_ROTATING_LEDS -p
        # Also works
        bash test/test.sh -p -s SIM_VALUE25
        ```

- 使用Vivado进行上板部署：需例化Clock Wizard IP，并根据FPGA实际时钟（单端/差分）修改例化部分的RTL代码。在Genesys2开发板上，需例化一双端差分转单端、无复位、100MHz输出的Clock Wizard IP。

    1. 单向流水灯。若在Vivado上部署此工程，则在 `./rtl/core/config.vh` 下开启此宏定义：

        ```verilog
        `define USE_ROTATING_LEDS_EXAMPLE
        ```

        部署在Genesys2的现象：8个LED将从LED0\~LED7间隔~0.5s依次闪烁。

    2. 双向流水灯。若在Vivado上部署此工程，则在 `./rtl/core/config.vh` 下开启此宏定义，同时注释前一宏定义：

        ```verilog
        // `define USE_ROTATING_LEDS_EXAMPLE    // This macro definition will mask the next one.
        `define USE_DOUBLE_SIDE_ROTATING_LEDS_EXAMPLE
        ```

       部署在Genesys2的现象：8个LED将从LED\~LED7\~LED0间隔~0.5s双向依次闪烁。

    3. 五级流水线部署实现。若在Vivado上实现五级流水线部署，则在 `./rtl/core/config.vh` 下开启此宏定义：

        ```verilog
        `define USE_PIPELINE
        ```

## 📚 Introduction of Examples

1. 所实现的RV32I指令包括：

   | Instruction |   opcode   |  funct3  |   funct7   |
   | :---------: | :--------: | :-------: | :--------: |
   |     ADD     | 7'b0110011 |  3'b000  |     0     |
   |     SUB     | 7'b0110011 |  3'b000  | 7'b0100000 |
   |     AND     | 7'b0110011 |  3'b111  |     0     |
   |     XOR     | 7'b0110011 |  3'b101  |     0     |
   |     OR     | 7'b0110011 |  3'b110  |     0     |
   |     SLT     | 7'b0110011 |  3'b010  |     0     |
   |     SLL     | 7'b0110011 |  3'b011  |     0     |
   |     SRL     | 7'b0110011 |  3'b100  |     0     |
   |    ADDI    | 7'b0010011 |  3'b000  | immediate |
   |    ANDI    | 7'b0010011 |  3'b111  | immediate |
   |    XORI    | 7'b0010011 |  3'b101  | immediate |
   |     ORI     | 7'b0010011 |  3'b110  | immediate |
   |    SLTI    | 7'b0010011 |  3'b010  | immediate |
   |    SLLI    | 7'b0010011 |  3'b011  | immediate |
   |    SRLI    | 7'b0010011 |  3'b100  | immediate |
   |     BEQ     | 7'b1100011 |  3'b000  | immediate |
   |     LW     | 7'b0000011 |  3'b010  | immediate |
   |     SW     | 7'b0100011 |  3'b010  | immediate |
   |     JAL     | 7'b1101111 | immediate | immediate |

2. RV32I指令测试：测试所设计的所有指令，最终将25写入 `dmem` 地址100处

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

3. 单向流水灯。板上时钟频率100MHz，借助 `t5` 寄存器及循环计数，达到

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
               jal  count              #                               4C       0xFF9FF06F
   mov_led:    add  t4, t4, t4         # led << 1.                     50       0x01DE8EB3
               beq  t4, t6, clean_led  #                               54       0xFFFE84E3
               jal  clean_cnt          #                               58       0xFE9FF06F
   ```

   其中，各寄存器含义如下表所列：

   | Register | Address |      Meaning      |
   | :------: | :------: | :---------------: |
   |  `t3`  | 5'b11100 | Counter of `t5` |
   |  `t4`  | 5'b11101 |    LED result    |
   |  `t5`  | 5'b11110 |  0.5s time count  |
   |  `t6`  | 5'b11111 |   Led max value   |

4. 双向流水灯。在上述示例基础上实现双向闪烁，主要利用左移（ `SLLI` ）、右移（ `SRLI` ）。

   ```assembly
    #           RISC-V Assembly         Description                     Address Machine Code
    init:       addi t5, x0, 2047       # count_max, t5 = 2047          00      0x7FF00F13
                addi t3, x0, 13         # loop_cnt = 13                 04      0x00D00E13
                addi x1, x0, 0          # x1 = 0                        08      0x00000293
    init_loop:  addi x1, x1, 1          # x1 += 1                       0C      0x00128293
                slli t5, t5, 1          # t5 << 1                       10      0x001F3F13
                beq  x1, t3, start      # if x1 == t3, jump start       14      0x005E0463
                jal  init_loop          #                               18      0xFF5FF06F
    start:      addi t6, x0, 256        # led_max = 256                 1C      0x10000F93
                addi x1, x0, 1C         # x1 = 1                        20      0x00100093
    new_cycle:  addi t4, x0, 1          # init led value, t4 = 1        24      0x00100E93
    inc_clr_cnt:addi t3, x0, 0          # clear count(t3)               28      0x00000E13
    inc_count:  addi t3, t3, 1          # count++                       2C      0x001E0E13
                beq  t3, t5, inc_led    # if count == max, jump inc_led 30      0x01EE0463
                jal  inc_count          #                               34      0xFF9FF06F
    inc_led:    slli t4, t4, 1          # led << 1                      38      0x001EBE93
                beq  t4, t6, jump256    # if led = 256, jump jump256    3C      0x01FE8C63
                jal  inc_clr_cnt        #                               40      0xFE9FF06F
    dec_clr_cnt:addi t3, x0, 0          # clear count(t3)               44      0x00000E13
    dec_count:  addi t3, t3, 1          # count++                       48      0x001E0E13
                beq  t3, t5, dec_led    # if count == max, jump dec_led 4C      0x01EE0663
                jal  dec_count          #                               50      0xFF9FF06F
    jump256:    srli t4, t4, 1          # led >> 1 = 128                54      0x001ECE93
    dec_led:    srli t4, t4, 1          # led >> 1                      58      0x001ECE93
                beq  t4, x1, new_cycle  # if led = 1, jump new_cycle    5C      0xFC1E84E3
                jal  dec_clr_cnt        #                               60      0xFE5FF06F
   ```

   其中，各寄存器含义如下表所列：

   | Register | Address |                Meaning                |
   | :------: | :------: | :------------------------------------: |
   |  `x1`  | 5'b00001 |          Temporary register          |
   |  `t3`  | 5'b11100 |           Counter of `t5`           |
   |  `t4`  | 5'b11101 |               LED result               |
   |  `t5`  | 5'b11110 |            0.5s time count            |
   |  `t6`  | 5'b11111 |            LED max value            |
