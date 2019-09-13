module simulador;
	logic [5:0] count;
	logic muxOut;
	mux4 muxizadaa(.f(muxOut), .a(count[2]), .b(count[3]), .c(count[4]), .d(count[5]), .sel({count[1], count[0]}) );
	initial begin 
		$monitor($time, " a b c d sel = %b, muxOut = %b", count, muxOut);
		for(count = 0; count != 6'b111111; count++)
			#10;
		
		#10
		$stop;
	end
endmodule