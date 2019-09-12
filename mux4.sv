module mux4(output logic [63:0]f, input logic [63:0]a, [63:0]b, [63:0]c, [63:0]d, [1:0] sel);
	always_comb begin
		if(sel == 2'b00)begin
			f = a;
		end
		if(sel == 2'b01)begin
			f = b;
		end
		if(sel == 2'b10)begin
			f = c;
		end
		if(sel == 2'b11)begin
			f = d;
		end
	end
endmodule