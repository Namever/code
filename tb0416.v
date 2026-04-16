`timescale 10 ns/10 ns
module tb;
	reg a;
	reg b;
	wire f;

	EP4 UUT(.a(a),.b(b),.f(f));
	
	initial begin
			a=0;
			b=0;
	end
	
	always #20 a = ~a;
	always #10 b = ~b;

endmodule
