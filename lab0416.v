module lab(

	input CLOCK_50,
	input [2:0] SW,
	output reg [5:0] LEDR

);

	reg clk_div = 0;
	reg [28:0] div_cnt = 0;
	
	reg [1:0] right = 0;
	reg [1:0] left = 0;
	reg flash = 1;
	
	
always @(posedge CLOCK_50)begin
	if(div_cnt == 30000000)begin
		clk_div <= 1;
		div_cnt <= 0;
	end
	else begin
		clk_div <= 0;
		div_cnt <= div_cnt + 1;
	end
end

always@(posedge clk_div)begin
	if(SW[2])begin
		if(flash == 1)begin
			LEDR <= 6'b111111;
			flash <= 0;
		end
		else begin
			LEDR <= 6'b000000;
			flash <= 1;
		end
	end
	else if(SW[1:0] == 2'b10)begin
		case(left)
			2'b00:LEDR <= 6'b001000;
			2'b01:LEDR <= 6'b011000;
			2'b10:LEDR <= 6'b111000;
			2'b11:LEDR <= 6'b000000;
		endcase
		if(left == 2'b11)left <= 0;
		else left <= left + 1;
	end
	else if(SW[1:0] == 2'b01)begin
		case(right)
			2'b00:LEDR <= 6'b000100;
			2'b01:LEDR <= 6'b000110;
			2'b10:LEDR <= 6'b000111;
			2'b11:LEDR <= 6'b000000;
		endcase
		if(right == 2'b11)right <= 0;
		else right <= right + 1;
	end
	else begin
		LEDR <= 6'b000000;
		left <= 0;
		right <= 0;
	end
end
endmodule