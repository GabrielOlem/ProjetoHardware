module mux(output logic [63:0]f, input logic [63:0]a, [63:0]b, sel);
	always_comb begin
		if(sel == 1'b0) f = a;
		else f = b;
	end

endmodule