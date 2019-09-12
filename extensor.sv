module extensor(input logic [31:0]entrada, output logic [63:0]saida);
	always_comb begin
		if(entrada[31] == 0)begin
			saida = {32'd0, entrada};
		end
		else begin
			saida = {32'd4294967295, entrada};
		end
	end
endmodule
