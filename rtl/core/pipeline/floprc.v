//r clear  flush  Decode/Eex
module floprc #(
	parameter WIDTH = 8
)(
	input					clk,
	input					reset,
	input					clear,
	input		[WIDTH-1:0]	d,
	output reg	[WIDTH-1:0]	q
);

	always @(posedge clk, posedge reset) begin
    	if (reset)
			q <= #1 0;
    	else if (clear)
			q <= #1 0;
    	else
			q <= #1 d;
	end

endmodule