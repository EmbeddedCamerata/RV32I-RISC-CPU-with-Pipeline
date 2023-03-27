`include "config.vh"
`define PERIOD 100

module top_tb;
	logic       clk;
    logic       reset;
    logic [7:0] led;
	
	top u_top(.*);

	initial begin
`ifdef SIM_VALUE25
        $dumpfile("./test/value25_sim_wave.fst");
`endif
`ifdef SIM_ROTATING_LEDS
		$dumpfile("./test/rotating_leds_sim_wave.fst");
`endif
`ifdef SIM_DB_ROTATING_LEDS
		$dumpfile("./test/db_rotating_leds_sim_wave.fst");
`endif
        $dumpvars(0, u_top);
    end

	initial begin
        clk = 0;
        // display time in nanoseconds
        $timeformat(-9, 1, " ns", 12);
        sys_reset;
        test;
`ifdef SIM_VALUE25
        #5000;
`else
        #100000;
`endif
        $finish;
    end

	task sys_reset;
        begin
            reset = 0;
            #(`PERIOD*0.7) reset = 1;
            #(1.5*`PERIOD) reset = 0;
        end
    endtask

    task test;
        begin
`ifdef SIM_VALUE25
            $readmemh("./test/value25_sim_imem.mem", u_top.imem.RAM);
`endif
`ifdef SIM_ROTATING_LEDS
			$readmemh("./test/rotating_leds_sim_imem.mem", u_top.imem.RAM);
`endif
`ifdef SIM_DB_ROTATING_LEDS
			$readmemh("./test/db_rotating_leds_sim_imem.mem", u_top.imem.RAM);
`endif
            $display("imem loaded successfully!");
        end
    endtask

`ifdef SIM_VALUE25
    always @(posedge clk) begin
        if (u_top.PC == 'h4c) begin
            // When PC == 76, the next data & address to write should be 25 & 100
            if (u_top.DataAdr == 100 && u_top.WriteData == 25)
                $display("Simulation OK: DataAdr=0x%02x, WriteData=0x%02x",
                    u_top.DataAdr, u_top.WriteData);
            else
                $display("Simlulation failed: DataAdr=0x%02x, WriteData=0x%02x",
                    u_top.DataAdr, u_top.WriteData);
        end
    end
`endif /* SIM_VALUE25 */

	always #(`PERIOD/2) clk = ~clk;

endmodule