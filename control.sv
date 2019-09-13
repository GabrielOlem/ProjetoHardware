`timescale 1ps/1ps
module control (
	input logic [31:0]Instruction,
	input logic clk,    
	input logic reset,
	output logic [3:0]extensorSignal,
	output logic pcWrite, logic PCWriteCond,  logic pcSource, 
	output logic MuxDataSel, logic [1:0]Mux4Sel,
	output logic MuxAlu1Sel, 
	output logic DMemRead, logic IMemRead, logic LoadMDR,
	output logic [2:0]ALUOp, logic Load_ir,
	output logic regWrite, logic regAWrite, logic regBWrite, 
	output logic memtoReg, logic wrMem,
	output logic AluOutWrite
);
	logic [4:0]state;
	logic [4:0]next_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset)
			state = 0;
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 0) begin //Faz nada
			pcWrite = 0;
			next_state = 1;
		end
		if(state == 1) begin //PC = PC + 4 e carrega a instrução
			regWrite = 0;
			pcWrite = 1;
			pcSource = 0;
			Load_ir = 1;
			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b01;
			ALUOp = 3'd1;
			next_state = 2;
		end
		if(state == 2) begin //Carrega os dois registradores em A e B, faz PC = PC + imm
			pcWrite = 0;

			regWrite = 0;
			regAWrite = 1;
			regBWrite = 1;

			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b11;
			ALUOp = 3'd1;
			AluOutWrite = 1;
			next_state = 1;
			if(Instruction[6:0] == 7'b0010011) begin
				if(Instruction[14:12] == 3'b000) begin
					next_state = 3;
				end
			end
			if(Instruction[6:0] == 7'b0110011) begin
				if(Instruction[31:25] == 7'b0000000) begin
					next_state = 4;
				end
				if(Instruction[31:25] == 7'b0100000) begin
					next_state = 5;
				end
			end
			if(Instruction[6:0] == 7'b0000011) begin
				if(Instruction[14:12] == 3'b011) begin
					next_state = 6;
				end
			end
		end
		if(state == 3) begin //addi
			extensorSignal = 0;

			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			
			MuxDataSel = 0;
			regWrite = 1;

			next_state = 1;
		end
		if(state == 4) begin //add
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 1;

			MuxDataSel = 0;
			regWrite = 1;

			next_state = 1;
		end
		if(state == 5) begin //sub
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;

			MuxDataSel = 0;
			regWrite = 1;

			next_state = 1;
		end
		if(state == 6) begin //ld
			extensorSignal = 0;

			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			
			DMemRead = 0;

			next_state = 7;
		end
		if(state == 7) begin
			LoadMDR = 1;

			next_state = 8;
		end
		if(state == 8) begin
			MuxDataSel = 1;
			regWrite = 1;

			next_state = 1;
		end
	end

endmodule