module extensor(input logic [31:0]entrada, output logic [63:0]saida, input logic [3:0]sel);
	always_comb begin
		if(sel == 0) begin
			if(entrada[31] == 0)begin
				saida = {52'd0, entrada[31:20]};
			end
			else begin
				saida = {52'hFFFFFFFFFFFFF, entrada[31:20]};
			end
		end
		if(sel == 1) begin
			if(entrada[31] == 0)begin
				saida = {52'd0,entrada[31:25], entrada[11:7]};
			end
			else begin
				saida = {52'hFFFFFFFFFFFFF, entrada[31:25], entrada[11:7]};
			end
		end
	end
endmodule
