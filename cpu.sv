module cpu(input logic clk, input logic reset, output logic [63:0]pcOut);

	logic [63:0]Aluout;
	logic [2:0]selector;
    	logic [31:0]raddress;
    	logic [31:0]waddress;
    	logic [31:0]data;
    	logic [31:0]q;
	logic [4:0]saida1;
	logic [4:0]saida2;
	logic [4:0]saida3;
	logic [6:0]saida4;
	logic [31:0]saidaInstruction;

	register pc(.clk(clk), .reset(reset), .regWrite(pcWrite), .DadoIn(Aluout), .DadoOut(pcOut));
	
	Ula64 alu(.A(pcOut), .B(64'd4), .Seletor(selector), .S(Aluout));
	
	control controle(.clk(clk), .reset(reset), .pcWrite(pcWrite), .ALUOp(selector), .Load_ir(load_ir));

	Memoria32 meminst(.raddress(pcOut), .waddress(waddress), .Clk(clk), .Datain(data), .Dataout(q), .Wr(Wr));

	Instr_Reg_RISC_V reginst(.Clk(clk), .Reset(reset), .Load_ir(load_ir), .Entrada(q), .Instr19_15(saida1), .Instr24_20(saida2), .Instr11_7(saida3), .Instr6_0(saida4), .Instr31_0(saidaInstruction));
endmodule