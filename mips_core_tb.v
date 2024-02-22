`timescale 1 ns/10 ps
`include "mips_core.v"


module mips_core_tb;

	reg clk;
	reg rst;

	mips_core uut (
		.clk(clk), 
		.rst(rst)
	);

	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 1;
		#7;
		rst = 0;
	end
endmodule
