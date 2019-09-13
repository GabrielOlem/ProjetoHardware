`timescale 1ps/1ps
module control (
	input logic [6:0]OpCode,
	input logic clk,    
	input logic reset,
	output logic pcWrite, logic PCWriteCond,  logic pcSource, 
	output logic MuxDataSel, [1:0]Mux4Sel,
	output logic MuxAlu1Sel, 
	output logic DMemRead, logic IMemRead, logic LoadMDR,
	output logic [2:0]ALUOp, logic Load_ir,
	output logic regWrite, logic regAWrite, logic regBWrite, 
	output logic memtoReg, logic wrMem,
	output logic AluOutWrite
);
	logic [2:0]state;
	logic [2:0]next_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset)
			state = 0;
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 3'b000) begin //Faz nada
			pcWrite = 0;
			next_state = 3'b001;
		end
		if(state == 3'b001) begin //PC = PC + 4 e carrega a instrução
			pcWrite = 1;
			pcSource = 0;
			Load_ir = 1;
			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b01;
			ALUOp = 3'd1;
			next_state = 3'b010;
		end
		if(state == 3'b010) begin //Carrega os dois registradores em A e B, faz PC = PC + imm
			pcWrite = 0;
			regAWrite = 1;
			regBWrite = 1;
			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b11;
			ALUOp = 3'd1;
			AluOutWrite = 1;
			if(OpCode == 7'b0110011) begin
				next_state = 3'b100;
			end
		end
	end

endmodule