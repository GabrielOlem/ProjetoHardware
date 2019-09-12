`timescale 1ps/1ps
module control (
	input logic clk,    
	input logic reset,
	output logic pcWrite, pcSource, 
	output logic MuxDataSel, [1:0]Mux4Sel,
	output logic MuxAlu1Sel, 
	output logic DMemRead, IMemRead, LoadMDR,
	output logic [2:0]ALUOp, Load_ir,
	output logic regWrite, regAWrite, regBWrite, 
	output logic memtoReg, wrMem,
	output logic AluOutWrite
);
	logic [2:0]state;
	logic [1:0]next_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset)
			state = 0;
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 3'b000) begin
			pcWrite = 0;

			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b01;
			ALUOp = 3'd1;
			next_state = 3'b001;
		end
		if(state == 3'b001) begin
			pcWrite = 1;
			pcSource = 0;

			regAWrite = 1;
			regBWrite = 1;
			MuxAlu1Sel = 1'b0;
			Mux4Sel = 2'b11;
			ALUOp = 3'd1;
			AluOutWrite = 1;
			next_state = 3'b000;
		end
	end

endmodule