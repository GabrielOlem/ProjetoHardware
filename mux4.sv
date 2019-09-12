module mux4(output logic f, input logic a, b, c, d, [1:0] sel);
	not not1(n_sel1, sel[1]), not2(n_sel0, sel[0]);
	
	and and1(f1, a, n_sel0, n_sel1),
	    and2(f2, b, sel[0], n_sel1),
	    and3(f3, c, sel[1], n_sel0),
	    and4(f4, d, sel[1], sel[0]);
	or or4(f, f1, f2, f3, f4);

endmodule