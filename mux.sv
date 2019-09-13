module mux(output logic [63:0]f, input logic [63:0]a, logic [63:0]b, logic sel);
	always_comb begin
		if(sel == 1'b0) f = a;
		else f = b;
	end

endmodule