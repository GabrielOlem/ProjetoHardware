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
		if(sel == 2) begin
			if(entrada[31] == 0)begin
				saida = {52'd0, entrada[31], entrada[7], entrada[30:25], entrada[11:8], 1'b0};
			end
			else begin
				saida = {52'hFFFFFFFFFFFFF, entrada[31], entrada[7], entrada[30:25], entrada[11:8], 1'b0};
			end
		end
		if(sel == 3) begin
			if(entrada[31] == 0)begin
				saida = {32'b0, entrada[31:12], 12'b0};
			end
			else begin
				saida = {32'b11111111111111111111111111111111, entrada[31:12], 12'b0};
			end
		end
	end
endmodule
