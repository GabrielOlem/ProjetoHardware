`timescale 1ps/1ps
module control (
	input logic [31:0]Instruction,
	input logic clk,    
	input logic reset,
	output logic [3:0]extensorSignal,
	output logic pcWrite, logic PCWriteCond,  logic pcSource, 
	output logic [2:0]MuxDataSel, logic [2:0]Mux4Sel,
	output logic MuxAlu1Sel, 
	output logic DMemRead, logic IMemRead, logic LoadMDR,
	output logic [2:0]ALUOp, logic Load_ir,
	output logic regWrite, logic regAWrite, logic regBWrite,
	output logic AluOutWrite, pcWriteCondBne,
	output logic [1:0]SeletorShift,
	output logic pcWriteCondBge, logic pcWriteCondBlt,
	output logic [4:0]HistSel
);
	logic [5:0]state;
	logic [5:0]next_state;
	logic [5:0]call_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset) begin
			state = 32;
		end
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 32) begin
			call_state = 1;
			next_state = 0;
		end
		if(state == 0) begin //Faz nada
			PCWriteCond = 0;
			pcWriteCondBne = 0;
			pcWriteCondBge = 0;
			pcWriteCondBlt = 0;
			pcWrite = 0;
			pcSource = 0;

			regWrite = 0;
			regAWrite = 0;
			regBWrite = 0;

			AluOutWrite = 0;

			MuxDataSel = 0;

			Load_ir = 0;
			
			LoadMDR = 0;
			DMemRead = 0;
			IMemRead = 0;

			ALUOp = 0;
			AluOutWrite = 0;

			extensorSignal = 0;
			
			next_state = call_state;
		end
		if(state == 1) begin //PC = PC + 4 e carrega a instrução
			pcWrite = 1;
			pcSource = 0;
			Load_ir = 1;
			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b01;
			ALUOp = 3'd1;
			next_state = 2;
		end
		if(state == 2) begin //Carrega os dois registradores em A e B, faz PC = PC + imm
			regAWrite = 1;
			regBWrite = 1;

			extensorSignal = 2;		
			MuxAlu1Sel = 0;
			Mux4Sel = 3;
			ALUOp = 1;
			AluOutWrite = 1;

			next_state = 1;
			if(Instruction[6:0] == 7'b1101111) begin //JAL
				next_state = 22;
			end
			if(Instruction[6:0] == 7'b0010011) begin 
				if(Instruction[14:12] == 3'b000) begin //ADDI
					next_state = 3;
				end
				if(Instruction[14:12] == 3'b010) begin //SLTI
					next_state = 16;
				end
				if(Instruction[14:12] == 3'b101 && Instruction[31:26] == 6'd0) begin //SRLI
					next_state = 19;
				end
				if(Instruction[14:12] == 3'b101 && Instruction[31:26] == 6'b010000) begin //SRAI
					next_state = 20;
				end
				if(Instruction[14:12] == 3'b001) begin //SLLI
					next_state = 21;
				end
			end
			if(Instruction[6:0] == 7'b0110011) begin //Tipo R
				if(Instruction[31:25] == 7'b0000000 && Instruction[14:12] == 3'b000) begin //ADD
					next_state = 4;
				end
				if(Instruction[31:25] == 7'b0100000) begin //SUB
					next_state = 5;
				end
				if(Instruction[31:25] == 7'b0000000 && Instruction[14:12] == 3'b111) begin //AND
					next_state = 14;
				end
				if(Instruction[31:25] == 7'b0000000 && Instruction[14:12] == 3'b010) begin //SLT
					next_state = 15;
				end
			end
			if(Instruction[6:0] == 7'b0000011) begin //LD
				next_state = 6;
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
			if(Instruction[6:0] == 7'b1100111) begin //BNE
				if(Instruction[14:12] == 3'b100) begin //BLT
					next_state = 25;
				end
				if(Instruction[14:12] == 3'b101) begin //BGE
					next_state = 24;
				end
				if(Instruction[14:12] == 3'b001) begin
					next_state = 12;
				end
				if(Instruction[14:12] == 3'b000) begin //JALR
					next_state = 17;
				end
			end
			if(Instruction[6:0] == 7'b0110111) begin //LUI
				next_state = 13;
			end
		end
		if(state == 3) begin //addi
			extensorSignal = 0;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;

			next_state = 0;
		end
		if(state == 4) begin //add
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 1;
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;

			next_state = 0;
		end
		if(state == 5) begin //sub
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;

			next_state = 0;
		end
		if(state == 6) begin //load
			extensorSignal = 0;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			
			DMemRead = 0;
			call_state = 7;

			next_state = 0;
		end
		if(state == 7) begin
			LoadMDR = 1;
			if(Instruction[14:12] == 3'b000) begin //lb
				call_state = 26;
			end
			if(Instruction[14:12] == 3'b001) begin //lh
				call_state = 27;
			end
			if(Instruction[14:12] == 3'b010) begin //lw
				call_state = 28;
			end
			if(Instruction[14:12] == 3'b100) begin //lbu
				call_state = 29;
			end
			if(Instruction[14:12] == 3'b101) begin //lhu
				call_state = 30;
			end
			if(Instruction[14:12] == 3'b110) begin //lwu
				call_state = 31;
			end
			if(Instruction[14:12] == 3'b011) begin //ld
				call_state = 8;
			end

			next_state = 0;
		end
		if(state == 8) begin
			MuxDataSel = 1;
			regWrite = 1;
			Load_ir = 0;
			pcSource = 0;
			call_state = 1;

			next_state = 0;
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
			next_state = 0;
		end
		if(state == 11) begin //beq
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			pcSource = 1;

			ALUOp = 2;
			PCWriteCond = 1;
			pcWrite = 0;

			call_state = 1;

			next_state = 0;
		end
		if(state == 12) begin //bne
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			pcSource = 1;
			
			ALUOp = 2;
			pcWriteCondBne = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 13) begin //lui
			extensorSignal = 3;
			MuxDataSel = 2;
			regWrite = 1;
			
			call_state = 1;

			next_state = 0;
		end
		if(state == 14) begin //and
			ALUOp = 3;
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			MuxDataSel = 0;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 15) begin //slt
			ALUOp = 2;
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			MuxDataSel = 3;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 16) begin //slti a alu ta retornando a flag errada
			extensorSignal = 0;
			ALUOp = 2;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			MuxDataSel = 3;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
		end 
		if(state == 17) begin //jalr
			MuxAlu1Sel = 0;
			ALUOp = 0;
			MuxDataSel = 0;
			regWrite = 1;
			extensorSignal = 0;

			call_state = 18;
			
			next_state = 0;
		end
		if(state == 18) begin
			Mux4Sel = 2;
			MuxAlu1Sel = 0;
			ALUOp = 1;
			pcSource = 0;
			pcWrite = 1;
			
			call_state = 1;

			next_state = 0;
		end
		if(state == 19) begin //srli
			MuxAlu1Sel = 1;
			ALUOp = 0;
			SeletorShift = 1;
			MuxDataSel = 4;
			regWrite = 1;

			call_state = 1;
			
			next_state = 0;
		end
		if(state == 20) begin //srai
			MuxAlu1Sel = 1;
			ALUOp = 0;
			SeletorShift = 2;
			MuxDataSel = 4;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 21) begin //slli
			MuxAlu1Sel = 1;
			ALUOp = 0;
			SeletorShift = 0;
			MuxDataSel = 4;
			regWrite = 1;

			call_state = 1;
			
			next_state = 0;
		end
		if(state == 22) begin //jal
			MuxAlu1Sel = 0;
			ALUOp = 0;
			MuxDataSel = 0;
			regWrite = 1;

			call_state = 23;

			next_state = 0;
		end
		if(state == 23) begin
			MuxAlu1Sel = 0;
			extensorSignal = 4;
			Mux4Sel = 3;
			ALUOp = 1;
			pcSource = 0;
			pcWrite = 1;

			call_state = 1;
			
			next_state = 0;
		end
		if(state == 24) begin //bge
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			pcWriteCondBge = 1;
			pcSource = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 25) begin //blt
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			pcSource = 1;
			
			pcWriteCondBlt = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 26) begin //lb
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 0;

			call_state = 1;

			next_state = 0;
		end
		if(state == 27) begin //lh
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 28) begin //lw
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 2;

			call_state = 1;

			next_state = 0;
		end
		if(state == 29) begin //lbu
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 3;

			call_state = 1;

			next_state = 0;
		end
		if(state == 30) begin //lhu
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 4;

			call_state = 1;

			next_state = 0;
		end
		if(state == 31) begin //lwu
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 5;

			call_state = 1;

			next_state = 0;
		end
	end

endmodule