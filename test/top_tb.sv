`include "config.vh"
`define PERIOD 100

module top_tb;
	logic		clk;
	logic		reset;
	logic [7:0] led;

	top u_top(.*);

	string test_base_dir = "./test";
	string fst_name;
	string mem_base_dir = {test_base_dir, "/mem"};
	string mem_name;
	string temp;

	initial begin
`ifndef USE_PIPELINE
		fst_name = {test_base_dir, "/simple/"};
`else
		fst_name = {test_base_dir, "/pipeline/"};
`endif

`ifdef SIM_RANDOM_INS
		fst_name = {fst_name, "SIM_RANDOM_INS"};
`endif /* SIM_RANDOM_INS */

`ifdef SIM_VALUE25
		fst_name = {fst_name, "SIM_VALUE25"};
`endif /* SIM_VALUE25 */

`ifdef SIM_ROTATING_LEDS
		fst_name = {fst_name, "SIM_ROTATING_LEDS"};
`endif /* SIM_ROTATING_LEDS */

`ifdef SIM_DB_ROTATING_LEDS
		fst_name = {fst_name, "SIM_DB_ROTATING_LEDS"};
`endif /* SIM_DB_ROTATING_LEDS */

		fst_name = {fst_name, "_wave.fst"};
		$display("Wave file will output in %s", fst_name);

		$dumpfile(fst_name);
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
`endif /* SIM_VALUE25 */
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
			mem_name = "/value25_sim_imem.mem";
`endif
`ifdef SIM_ROTATING_LEDS
			mem_name = "/rotating_leds_sim_imem.mem";
`endif
`ifdef SIM_DB_ROTATING_LEDS
			mem_name = "/db_rotating_leds_sim_imem.mem";
`endif
`ifdef SIM_RANDOM_INS
			mem_name = "/random_ins.mem";
`endif
			mem_name = {mem_base_dir, mem_name};

			$readmemh(mem_name, u_top.imem.RAM);
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