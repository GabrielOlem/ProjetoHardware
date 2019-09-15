module mux4(output logic [63:0]f, input logic [63:0]a, logic [63:0]b, logic [63:0]c, logic [63:0]d, logic [63:0]e, logic [2:0] sel);
	always_comb begin
		if(sel == 0)begin
			f = a;
		end
		if(sel == 1)begin
			f = b;
		end
		if(sel == 2)begin
			f = c;
		end
		if(sel == 3)begin
			f = d;
		end
		if(sel == 4)begin
			f = e;
		end
	end
endmodule