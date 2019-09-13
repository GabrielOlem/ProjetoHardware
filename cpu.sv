module cpu(input logic clk, input logic reset);
	logic [63:0]pcOut;
	logic [63:0]AluResult;
	logic [63:0]registradorA;
	logic [63:0]registradorB;
	logic [63:0]regAIn;
	logic [63:0]regBIn;
	logic [63:0]AluOut;
	logic [63:0]RegMemoria;
	logic [63:0]saidaMuxData;
	logic [63:0]Entrada1Alu;
	logic [63:0]Entrada2Alu;
	logic [1:0]Mux4Sel;

	logic [63:0]saidaMuxPc;
	logic [63:0]entradaShift;
	logic [63:0]saidaShift;
	logic [2:0]selector;
	logic [31:0]raddress;
	logic [31:0]waddress;
	logic [31:0]data;
	logic [31:0]q;
	logic [4:0]saida1;
	logic [4:0]saida2;
	logic [4:0]saida3;
	logic [6:0]opCode;
	logic [31:0]saidaInstruction;
	logic [63:0]saidaMemoria;
	logic [3:0]extensorSignal;

	control controle(.extensorSignal(extensorSignal), .PCWriteCond(PCWriteCond), .Instruction(saidaInstruction), .AluOutWrite(AluOutWrite), .clk(clk), .reset(reset), .pcWrite(pcWrite), .pcSource(PcSource), .MuxDataSel(MuxDataSel), .Mux4Sel(Mux4Sel), .ALUOp(selector), .MuxAlu1Sel(MuxAlu1Sel), .Load_ir(load_ir), .regWrite(regWrite), .regAWrite(regAWrite), .regBWrite(regBWrite), .DMemRead(DMemRead), .IMemRead(IMemRead), .LoadMDR(LoadMDR) );

	register pc(.clk(clk), .reset(reset), .regWrite(f2), .DadoIn(saidaMuxPc), .DadoOut(pcOut));
	register A(.clk(clk), .reset(reset), .regWrite(regAWrite), .DadoIn(regAIn), .DadoOut(registradorA));
	register B(.clk(clk), .reset(reset), .regWrite(regBWrite), .DadoIn(regBIn), .DadoOut(registradorB));
	register SaidaAlu(.clk(clk), .reset(reset), .regWrite(AluOutWrite), .DadoIn(AluResult), .DadoOut(AluOut));
	register memdataregister(.clk(clk), .reset(reset), .regWrite(LoadMDR), .DadoIn(saidaMemoria), .DadoOut(RegMemoria));
	
	mux escreveData(.f(saidaMuxData), .a(AluResult), .b(RegMemoria), .sel(MuxDataSel));
	mux MuxAlu1(.f(Entrada1Alu), .a(pcOut), .b(registradorA), .sel(MuxAlu1Sel));
	mux4 MuxAlu2(.f(Entrada2Alu), .a(registradorB), .b(64'd4), .c(entradaShift), .d(saidaShift), .sel(Mux4Sel));
	mux MuxPC(.f(saidaMuxPc), .a(AluResult), .b(AluOut), .sel(PcSource));
	and and1(f1, zero, PCWriteCond);
	or or2(f2, f1, pcWrite);
	Ula64 alu(.A(Entrada1Alu), .B(Entrada2Alu), .Seletor(selector), .S(AluResult), .z(zero));
	
	extensor estende(.entrada(saidaInstruction), .saida(entradaShift), .sel(extensorSignal));
	Deslocamento shift(.Shift(2'b00), .Entrada(entradaShift), .N(6'd1), .Saida(saidaShift));
	
	Memoria32 meminst(.raddress(pcOut), .waddress(waddress), .Clk(clk), .Datain(data), .Dataout(q), .Wr(IMemRead));
	Memoria64 memdata(.Clk(clk), .raddress(AluOut), .waddress(AluOut), .Datain(registradorB), .Dataout(saidaMemoria), .Wr(DMemRead));

	Instr_Reg_RISC_V reginst(.Clk(clk), .Reset(reset), .Load_ir(load_ir), .Entrada(q), .Instr19_15(saida1), .Instr24_20(saida2), .Instr11_7(saida3), .Instr6_0(opCode), .Instr31_0(saidaInstruction));

	bancoReg bancoRegister(.clock(clk), .reset(reset), .regreader1(saida1), .regreader2(saida2), .regwriteaddress(saida3), .write(regWrite), .dataout1(regAIn), .dataout2(regBIn), .datain(saidaMuxData));
endmodule