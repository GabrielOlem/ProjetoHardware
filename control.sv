`timescale 1ps/1ps
module control (
	input logic clk,    
	input logic reset,
	output logic pcWrite, [2:0]ALUOp, Wr, Load_ir
);
	logic [1:0]state;
	logic [1:0]next_state;
	always_ff @(posedge clk, posedge reset)begin
		if(reset)
			state = 0;
		else 
			state = next_state;
	end
	always_comb begin
		if(state == 2'b00) begin
			pcWrite = 1;
			ALUOp = 1;
			next_state = 2'b01;
			Wr = 0;
			Load_ir = 0;
		end
		if(state == 2'b01) begin
			pcWrite = 0;
			next_state = 2'b00;
			Wr = 0;
			Load_ir = 1;
		end
	end

endmodule