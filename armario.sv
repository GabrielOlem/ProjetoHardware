module armario(input logic [63:0]rs2, input logic [63:0]MemData, output logic [63:0]guardado, input logic [1:0]sel);
    always_comb begin
        if(sel == 0) begin
            guardado = {MemData[63:32], rs2[31:0]};
        end
        if(sel == 1) begin
            guardado = {MemData[63:16], rs2[15:0]};
        end
        if(sel == 2) begin
            guardado = {MemData[63:8], rs2[7:0]};
        end
    end
endmodule