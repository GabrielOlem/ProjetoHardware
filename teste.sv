`timescale 1ps/1ps

module teste;
	logic clk;
	logic reset;

	localparam clkperiod = 10000;
	localparam clkdelay = 5000;

	initial begin
		reset = 1'b1;
		clk = 1'b1;
		#(clkperiod)
		reset = 1'b0;
	end

	always #(clkdelay) clk = ~clk;
	cpu pczinho(.clk(clk), .reset(reset));

endmodule