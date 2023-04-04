//en r clear  flush/stall/   Fetch/Decode
module flopenrc #(
	parameter WIDTH = 8,
	parameter VALUE_0 = 32'b0
)(
	input					clk,
	input					reset,
	input					en,
	input					clear,
	input		[WIDTH-1:0] d,
	output reg	[WIDTH-1:0] q
);
 
	always @(posedge clk, posedge reset) begin
		if (reset)
			q <= #1 VALUE_0;
		else if (clear)
			q <= #1 VALUE_0;
		else if (en)
			q <= #1 d;
	end
	
endmodule