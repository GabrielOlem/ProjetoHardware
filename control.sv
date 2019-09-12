`timescale 1ps/1ps
module control (
	input logic clk,    
	input logic reset,
	output logic pcWrite, [2:0]ALUOp, Wr, Load_ir,
	output logic regWrite, regAWrite, regBWrite, 
	output logic memtoReg, wrMem
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
			pcWrite = 1;
			ALUOp = 1;
			next_state = 3'b001;
			Wr = 0;
			Load_ir = 0;
			regAWrite = 0;
			regBWrite = 0;
			regWrite = 0;
		end
		if(state == 3'b001) begin
			pcWrite = 0;
			next_state = 3'b010;
			Wr = 0;
			Load_ir = 1;
		end
		if(state == 3'b010) begin
			regAWrite = 1;
			regBWrite = 1;
			next_state = 3'b000;
		end
	end

endmodule