module mux4(output logic [63:0]fi, input logic [63:0]a, logic [63:0]b, logic [63:0]c, logic [63:0]d, logic [63:0]e, logic[63:0]f, logic [2:0] sel);
	always_comb begin
		if(sel == 0)begin
			fi = a;
		end
		if(sel == 1)begin
			fi = b;
		end
		if(sel == 2)begin
			fi = c;
		end
		if(sel == 3)begin
			fi = d;
		end
		if(sel == 4)begin
			fi = e;
		end
		if(sel == 5)begin
			fi = f;
		end
	end
endmodule