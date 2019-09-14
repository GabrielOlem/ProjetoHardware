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
	output logic AluOutWrite
);
	logic [4:0]state;
	logic [4:0]next_state;
	logic [4:0]call_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset)
			state = 0;
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 0) begin //Faz nada
			pcWrite = 0;
			pcSource = 0;
			regWrite = 0;
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
			pcSource = 0;
			Load_ir = 0;
			regWrite = 0;
			regAWrite = 1;
			regBWrite = 1;

			extensorSignal = 2;		
			MuxAlu1Sel = 0;
			Mux4Sel = 3;
			ALUOp = 1;
			AluOutWrite = 1;

			next_state = 1;
			if(Instruction[6:0] == 7'b0010011) begin //ADDI
				if(Instruction[14:12] == 3'b000) begin
					next_state = 3;
				end
			end
			if(Instruction[6:0] == 7'b0110011) begin //ADD
				if(Instruction[31:25] == 7'b0000000) begin
					next_state = 4;
				end
				if(Instruction[31:25] == 7'b0100000) begin //SUB
					next_state = 5;
				end
			end
			if(Instruction[6:0] == 7'b0000011) begin //LD
				if(Instruction[14:12] == 3'b011) begin
					next_state = 6;
				end
			end
			if(Instruction[6:0] == 7'b0100011) begin //SD
				if(Instruction[14:12] == 3'b111) begin	
					next_state = 9;
				end
			end
			if(Instruction[6:0] == 7'b1100011) begin //BEQ
				if(Instruction[14:12] == 3'b000) begin
					next_state = 11;
				end
			end
			if(Instruction[6:0] == 7'b1100011) begin //BNE
				if(Instruction[14:12] == 3'b001) begin
					next_state = 12;
				end
			end
			if(Instruction[6:0] == 7'b0110111) begin //LUI
				next_state = 13;
			end
		end
		if(state == 3) begin //addi
			extensorSignal = 0;
			pcSource = 0;
			Load_ir = 0;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;

			next_state = 30;
		end
		if(state == 4) begin //add
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 1;
			Load_ir = 0;
			pcSource = 0;
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;

			next_state = 30;
		end
		if(state == 5) begin //sub
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			Load_ir = 0;
			pcSource = 0;
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;

			next_state = 30;
		end
		if(state == 6) begin //ld
			regWrite = 0;
			extensorSignal = 0;
			pcSource = 0;
			Load_ir = 0;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			
			DMemRead = 0;
			call_state = 7;

			next_state = 30;
		end
		if(state == 7) begin
			regWrite = 0;
			LoadMDR = 1;
			Load_ir = 0;
			pcSource = 0;
			call_state = 8;

			next_state = 30;
		end
		if(state == 8) begin
			regWrite = 0;
			MuxDataSel = 1;
			regWrite = 1;
			Load_ir = 0;
			pcSource = 0;
			call_state = 1;

			next_state = 30;
		end
		if(state == 9) begin //sd
			extensorSignal = 1;

			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;

			next_state = 10;
		end
		if(state == 10) begin
			DMemRead = 1;
			call_state = 1;
			next_state = 30;
		end
		if(state == 11) begin //beq
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			PCWriteCond = 1;

			call_state = 1;

			next_state = 30;
		end
		if(state == 12) begin //bne ta errado
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			PCWriteCond = 1;

			call_state = 1;

			next_state = 30;
		end
		if(state == 13) begin //lui
			extensorSignal = 3;
			MuxDataSel = 2;
			regWrite = 1;
			
			call_state = 1;
			
			next_state = 30;
		end

		if(state == 30) begin
			PCWriteCond = 0;
			regWrite = 0;
			regAWrite = 0;
			regBWrite = 0;
			AluOutWrite = 0;
			MuxDataSel = 0;
			Load_ir = 0;
			pcSource = 0;
			LoadMDR = 0;
			DMemRead = 0;
			ALUOp = 0;
			extensorSignal = 0;
			IMemRead = 0;
			pcWrite = 0;

			next_state = call_state;
		end
	end

endmodule