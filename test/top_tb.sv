`include "config.vh"

`ifndef SIMULATION
`define SIMULATION
`endif /* SIMULATION */

`define PERIOD 100

module top_tb;
	logic clk;
    logic reset;
    logic [7:0] led;
	
	top u_top(.*);

`ifdef SIM_ON_IVERILOG
	initial begin
        $dumpfile("./test/value25_sim_wave.fst");
        $dumpvars(0, u_top);
    end
`endif

	initial begin
        clk = 0;
        // display time in nanoseconds
        $timeformat(-9, 1, " ns", 12);
        sys_reset;
        value25_simulation;
        #5000;
        $finish;
    end

	task sys_reset;
        begin
            reset = 0;
            #(`PERIOD*0.7) reset = 1;
            #(1.5*`PERIOD) reset = 0;
        end
    endtask

    task value25_simulation;
        begin
`ifdef SIM_ON_IVERILOG
            $readmemh("./test/value25_sim_imem.txt", u_top.imem.RAM, 0, 20);
`else
            $readmemh("./value25_sim_imem.txt", u_top.imem.RAM, 0, 20);
`endif
            $display("imem loaded successfully!");
        end
    endtask

	always #(`PERIOD/2) clk = ~clk;

endmodule