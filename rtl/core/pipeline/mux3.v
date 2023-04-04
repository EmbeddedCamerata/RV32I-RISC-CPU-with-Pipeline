module mux3 #(
	parameter WIDTH = 8
)(
	input		[WIDTH-1:0] d0,
	input		[WIDTH-1:0] d1,
	input		[WIDTH-1:0] d2,
    input		[1:0]		s,
    output wire [WIDTH-1:0] y
);

	// 01: d1  1X: d2  00:d0    s?a:b  | s=1:a  s=0:b
  	assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule