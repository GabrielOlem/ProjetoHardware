module cpu(input logic clk, input logic reset);
	logic [63:0]PC;
	logic [63:0]Alu;
	logic [63:0]registradorA;
	logic [63:0]WriteDataMem;
	logic [63:0]regAIn;
	logic [63:0]regBIn;
	logic [63:0]AluOut;
	logic [63:0]MDR;
	logic [63:0]WriteDataReg;
	logic [63:0]Entrada1Alu;
	logic [63:0]Entrada2Alu;
	logic [2:0]Mux4Sel;
	logic [2:0]MuxDataSel;

	logic [63:0]saidaMuxPc;
	logic [63:0]entradaShift;
	logic [63:0]DeslocValue;
	logic [2:0]selector;
	logic [31:0]raddress;
	logic [31:0]waddress;
	logic [31:0]data;
	logic [31:0]MemOutInst;
	logic [4:0]saida1;
	logic [4:0]saida2;
	logic [4:0]WriteRegister;
	logic [6:0]opCode;
	logic [31:0]saidaInstruction;
	logic [63:0]saidaMemoria;
	logic [3:0]extensorSignal;
	logic [1:0]SeletorShift;
	logic [63:0]saidaShift2;
	logic [63:0]Historiado;
	logic [4:0]HistSel;

	control controle(.HistSel(HistSel), .pcWriteCondBge(pcWriteCondBge), .pcWriteCondBlt(pcWriteCondBlt), .SeletorShift(SeletorShift), .pcWriteCondBne(pcWriteCondBne), .extensorSignal(extensorSignal), .PCWriteCond(PCWriteCond), .Instruction(saidaInstruction), .AluOutWrite(AluOutWrite), .clk(clk), .reset(reset), .pcWrite(pcWrite), .pcSource(PcSource), .MuxDataSel(MuxDataSel), .Mux4Sel(Mux4Sel), .ALUOp(selector), .MuxAlu1Sel(MuxAlu1Sel), .Load_ir(IRWrite), .regWrite(RegWrite), .regAWrite(regAWrite), .regBWrite(regBWrite), .DMemRead(wrDataMem), .IMemRead(wrInstMem), .LoadMDR(LoadMDR) );

	register pcz(.clk(clk), .reset(reset), .regWrite(f2), .DadoIn(saidaMuxPc), .DadoOut(PC));
	register A(.clk(clk), .reset(reset), .regWrite(regAWrite), .DadoIn(regAIn), .DadoOut(registradorA));
	register B(.clk(clk), .reset(reset), .regWrite(regBWrite), .DadoIn(regBIn), .DadoOut(WriteDataMem));
	register SaidaAlu(.clk(clk), .reset(reset), .regWrite(AluOutWrite), .DadoIn(Alu), .DadoOut(AluOut));
	register memdataregister(.clk(clk), .reset(reset), .regWrite(LoadMDR), .DadoIn(saidaMemoria), .DadoOut(MDR));
	
	mux4 escreveData(.fi(WriteDataReg), .a(Alu), .b(MDR), .c(entradaShift), .d({63'b0, Alu[31]}), .e(saidaShift2), .f(Historiado), .sel(MuxDataSel));
	mux MuxAlu1(.f(Entrada1Alu), .a(PC), .b(registradorA), .sel(MuxAlu1Sel));
	mux4 MuxAlu2(.fi(Entrada2Alu), .a(WriteDataMem), .b(64'd4), .c(entradaShift), .d(DeslocValue), .sel(Mux4Sel));
	mux MuxPC(.f(saidaMuxPc), .a(Alu), .b(AluOut), .sel(PcSource));
	and and1(f1, zero, PCWriteCond);
	and and2(f3, ~zero, pcWriteCondBne);
	and and3(f4, ~Alu[31], pcWriteCondBge);
	and and4(f5, Alu[31], pcWriteCondBlt);

	or or2(f2, f1, f3, f4, f5, pcWrite);

	Ula64 alu(.A(Entrada1Alu), .B(Entrada2Alu), .Seletor(selector), .S(Alu), .z(zero));

	historiador historia(.entrada(MDR), .saida(Historiado), .sel(HistSel));
	extensor estende(.entrada(saidaInstruction), .saida(entradaShift), .sel(extensorSignal));
	Deslocamento shift(.Shift(2'b00), .Entrada(entradaShift), .N(6'd1), .Saida(DeslocValue));
	Deslocamento shift2(.Shift(SeletorShift), .Entrada(Alu), .N(saidaInstruction[25:20]), .Saida(saidaShift2));
	Memoria32 meminst(.raddress(PC), .waddress(waddress), .Clk(clk), .Datain(data), .Dataout(MemOutInst), .Wr(wrInstMem));
	Memoria64 memdata(.Clk(clk), .raddress(Alu), .waddress(Alu), .Datain(WriteDataMem), .Dataout(saidaMemoria), .Wr(wrDataMem));

	Instr_Reg_RISC_V reginst(.Clk(clk), .Reset(reset), .Load_ir(IRWrite), .Entrada(MemOutInst), .Instr19_15(saida1), .Instr24_20(saida2), .Instr11_7(WriteRegister), .Instr6_0(opCode), .Instr31_0(saidaInstruction));

	bancoReg bancoRegister(.clock(clk), .reset(reset), .regreader1(saida1), .regreader2(saida2), .regwriteaddress(WriteRegister), .write(RegWrite), .dataout1(regAIn), .dataout2(regBIn), .datain(WriteDataReg));
endmodule