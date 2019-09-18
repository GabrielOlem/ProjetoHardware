module historiador(input logic [63:0]entrada, output logic [63:0]saida, input logic [4:0]sel);
    always_comb begin
        if(sel == 0) begin
            if(entrada[7] == 0) begin
                saida = {56'd0, entrada[7:0]};
            end
            else begin
                saida = {56'b11111111111111111111111111111111111111111111111111111111, entrada[7:0]};
            end
        end
        if(sel == 1) begin
            if(entrada[15] == 0) begin
                saida = {48'd0, entrada[15:0]};
            end
            else begin
                saida = {48'b111111111111111111111111111111111111111111111111, entrada[15:0]};
            end
        end
        if(sel == 2) begin
            if(entrada[31] == 0) begin
                saida = {32'd0, entrada[31:0]};
            end
            else begin
                saida = {32'b11111111111111111111111111111111, entrada[31:0]};
            end
        end
        if(sel == 3) begin
            saida = {56'd0, entrada[7:0]};
        end
        if(sel == 4) begin
            saida = {48'd0, entrada[15:0]};
        end
        if(sel == 5) begin
            saida = {32'd0, entrada[31:0]};
        end
    end
endmodule