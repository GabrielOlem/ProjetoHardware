`timescale 1ps/1ps
module control (
	input logic [31:0]Instruction,
	input logic clk,    
	input logic reset,
	output logic [3:0]extensorSignal,
	output logic pcWrite, logic PCWriteCond,  logic [2:0]pcSource, 
	output logic [2:0]MuxDataSel, logic [2:0]Mux4Sel,
	output logic MuxAlu1Sel, 
	output logic DMemRead, logic IMemRead, logic LoadMDR,
	output logic [2:0]ALUOp, logic Load_ir,
	output logic regWrite, logic regAWrite, logic regBWrite,
	output logic AluOutWrite, logic pcWriteCondBne,
	output logic [1:0]SeletorShift,
	output logic pcWriteCondBge, logic pcWriteCondBlt,
	output logic [4:0]HistSel, logic [1:0]selDataMem, logic [2:0]selMuxMem,
	output logic noOpcode, logic [2:0]MuxAddress, logic [3:0]memSel, 
	input logic Overflow
);
	logic [6:0]state;
	logic [6:0]next_state;
	logic [6:0]call_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset) begin
			state = 32;
		end
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 45) begin //OPCODE inexistente
			MuxAlu1Sel = 0;
			Mux4Sel = 1;
			ALUOp = 2;
			noOpcode = 1;

			MuxAddress = 1;
			DMemRead = 0;
			
			next_state = 46;
		end
		if(state == 46) begin
			pcSource = 2;
			pcWrite = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 47) begin //Overflow
			MuxAlu1Sel = 0;
			Mux4Sel = 1;
			ALUOp = 2;
			noOpcode = 1;

			MuxAddress = 2;
			DMemRead = 0;

			next_state = 46;
		end
		if(state == 40) begin //break OK
			next_state = 40;
		end
		if(state == 32) begin
			call_state = 1;
			next_state = 0;
		end
		if(state == 0) begin //Faz nada
			noOpcode = 0;
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
			MuxAddress = 0;
			DMemRead = 0;
			IMemRead = 0;

			ALUOp = 0;

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

			call_state = 2;
			
			next_state = 0;
		end
		if(state == 2) begin //Carrega os dois registradores em A e B, faz PC = PC + imm
			regAWrite = 1;
			regBWrite = 1;

			extensorSignal = 2;		
			MuxAlu1Sel = 0;
			Mux4Sel = 3;
			ALUOp = 1;
			AluOutWrite = 1;
			
			call_state = 1;

			next_state = 45;
			if(Instruction[31:0] == 32'b00000000000100000000000001110011) begin //break
				next_state = 40;
			end
			else if(Instruction[31:0] == 32'b00000000000000000000000000010011) begin //nop OK
				next_state = 1;
			end
			else if(Instruction[6:0] == 7'b1101111) begin //JAL
				next_state = 22;
			end
			else if(Instruction[6:0] == 7'b0010011) begin 
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
			else if(Instruction[6:0] == 7'b0110011) begin //Tipo R
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
			else if(Instruction[6:0] == 7'b0000011) begin //Load
				next_state = 6;
			end
			else if(Instruction[6:0] == 7'b0100011) begin //Store
				next_state = 33;
				if(Instruction[14:12] == 3'b111) begin //SD
					next_state = 9;
				end
			end
			else if(Instruction[6:0] == 7'b1100011) begin //BEQ
				if(Instruction[14:12] == 3'b000) begin
					next_state = 11;
				end
			end
			else if(Instruction[6:0] == 7'b1100111) begin //BNE
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
			else if(Instruction[6:0] == 7'b0110111) begin //LUI
				next_state = 13;
			end
		end
		if(state == 3) begin //addi OK
			extensorSignal = 0;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			AluOutWrite = 1;

			

			next_state = 48;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 48) begin
			MuxDataSel = 0;
			regWrite = 1;
			call_state = 1;
			next_state = 0;
		end
		if(state == 4) begin //add OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 1;
			AluOutWrite = 1;

			

			next_state = 48;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 5) begin //sub OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			AluOutWrite = 1;

			

			next_state = 48;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 6) begin //load
			extensorSignal = 0;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			AluOutWrite = 1;
			
			

			next_state = 51;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 51) begin
			MuxAddress = 0;
			DMemRead = 0;
			next_state = 7;
		end
		if(state == 7) begin
			LoadMDR = 1;
			if(Instruction[14:12] == 3'b000) begin //lb
				next_state = 26;
			end
			if(Instruction[14:12] == 3'b001) begin //lh
				next_state = 27;
			end
			if(Instruction[14:12] == 3'b010) begin //lw
				next_state = 28;
			end
			if(Instruction[14:12] == 3'b100) begin //lbu
				next_state = 29;
			end
			if(Instruction[14:12] == 3'b101) begin //lhu
				next_state = 30;
			end
			if(Instruction[14:12] == 3'b110) begin //lwu
				next_state = 31;
			end
			if(Instruction[14:12] == 3'b011) begin //ld
				next_state = 8;
			end
		end
		if(state == 8) begin//ld OK
			MuxDataSel = 1;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 9) begin //sd OK
			extensorSignal = 1;
			selMuxMem = 1;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			ALUOp = 1;
			AluOutWrite = 1;

			next_state = 10;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 10) begin
			MuxAddress = 0;
			DMemRead = 1;
			call_state = 1;
			next_state = 0;
		end
		if(state == 11) begin //beq OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			pcSource = 1;

			ALUOp = 2;
			PCWriteCond = 1;
			pcWrite = 0;
			call_state = 1;
			next_state = 0;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 12) begin //bne OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			pcSource = 1;
			
			ALUOp = 2;
			pcWriteCondBne = 1;
			call_state = 1;
			next_state = 0;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 13) begin //lui OK
			extensorSignal = 3;
			MuxDataSel = 2;
			regWrite = 1;
			
			call_state = 1;

			next_state = 0;
		end
		if(state == 14) begin //and OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			
			ALUOp = 3;
			AluOutWrite = 1;

			next_state = 48;
		end
		if(state == 15) begin //slt OK
			ALUOp = 2;
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			MuxDataSel = 3;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 16) begin //slti OK
			extensorSignal = 0;
			ALUOp = 2;
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			MuxDataSel = 3;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 17) begin //jalr OK
			MuxAlu1Sel = 0;
			ALUOp = 0;
			MuxDataSel = 6;
			regWrite = 1;

			call_state = 18;
			
			next_state = 0;
		end
		if(state == 18) begin
			extensorSignal = 0;
			Mux4Sel = 2;
			MuxAlu1Sel = 1;
			ALUOp = 1;
			AluOutWrite = 1;

			next_state = 58;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 58) begin
			pcSource = 0;
			pcWrite = 1;
			
			call_state = 1;

			next_state = 0;
		end
		if(state == 19) begin //srli OK
			MuxAlu1Sel = 1;
			ALUOp = 0;
			SeletorShift = 1;
			MuxDataSel = 4;
			regWrite = 1;

			call_state = 1;
			
			next_state = 0;
		end
		if(state == 20) begin //srai OK
			MuxAlu1Sel = 1;
			ALUOp = 0;
			SeletorShift = 2;
			MuxDataSel = 4;
			regWrite = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 21) begin //slli OK
			MuxAlu1Sel = 1;
			ALUOp = 0;
			SeletorShift = 0;
			MuxDataSel = 4;
			regWrite = 1;

			call_state = 1;
			
			next_state = 0;
		end
		if(state == 22) begin //jal OK
			MuxAlu1Sel = 0;
			ALUOp = 0;
			MuxDataSel = 6;
			regWrite = 1;

			next_state = 23;
		end
		if(state == 23) begin
			MuxAlu1Sel = 0;
			extensorSignal = 4;
			Mux4Sel = 3;
			ALUOp = 1;
			AluOutWrite = 1;
			regWrite = 0;
			
			next_state = 65;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 65) begin
			pcSource = 1;
			pcWrite = 1;

			call_state = 1;
			
			next_state = 0;
		end
		if(state == 24) begin //bge OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			
			pcWriteCondBge = 1;
			pcSource = 1;

			call_state = 1;

			next_state = 0;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 25) begin //blt OK
			MuxAlu1Sel = 1;
			Mux4Sel = 0;
			ALUOp = 2;
			pcSource = 1;
			
			pcWriteCondBlt = 1;

			call_state = 1;

			next_state = 0;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 26) begin //lb OK
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 0;

			call_state = 1;

			next_state = 0;
		end
		if(state == 27) begin //lh OK
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 1;

			call_state = 1;

			next_state = 0;
		end
		if(state == 28) begin //lw OK
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 2;

			call_state = 1;

			next_state = 0;
		end
		if(state == 29) begin //lbu OK
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 3;

			call_state = 1;

			next_state = 0;
		end
		if(state == 30) begin //lhu OK
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 4;

			call_state = 1;

			next_state = 0;
		end
		if(state == 31) begin //lwu OK
			MuxDataSel = 5;
			regWrite = 1;
			HistSel = 5;

			call_state = 1;

			next_state = 0;
		end
		if(state == 33) begin //SW/SH/SB
			MuxAlu1Sel = 1;
			Mux4Sel = 2;
			extensorSignal = 1;
			ALUOp = 1;
			AluOutWrite = 1;

			next_state = 64;
			if(Overflow) begin
				next_state = 47;
			end
		end
		if(state == 64) begin
			DMemRead = 0;
			MuxAddress = 0;
			next_state = 34;
		end
		if(state == 34) begin
			LoadMDR = 1;
			if(Instruction[14:12] == 3'b010) begin
				next_state = 35;
			end
			if(Instruction[14:12] == 3'b001) begin
				next_state = 36;
			end
			if(Instruction[14:12] == 3'b000) begin
				next_state = 37;
			end
		end
		if(state == 35) begin //SW OK
			selDataMem = 0;
			selMuxMem = 0;
			DMemRead = 1;
			MuxAddress = 0;
			call_state = 1;

			next_state = 0;
		end
		if(state == 36) begin //SH OK
			selDataMem = 1;
			selMuxMem = 0;
			DMemRead = 1;
			MuxAddress = 0;
			call_state = 1;
			
			next_state = 0;
		end
		if(state == 37) begin //SB OK
			selDataMem = 2;
			selMuxMem = 0;
			DMemRead = 1;
			MuxAddress = 0;
			call_state = 1;
			
			next_state = 0;
		end
	end

endmodule