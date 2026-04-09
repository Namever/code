module lab(
	input        CLOCK_50,
	input  [3:0] KEY,
	input  [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output reg [17:0] LEDR,
	output reg [7:0] LEDG
);
	
	reg [3:0] show0 = 0;
	reg [3:0] show1 = 0;
	reg [3:0] show2 = 0;
	reg [3:0] show3 = 0;
	
	reg [3:0] pb;
	reg [3:0] key_count[3:0];
	
	reg [26:0] div_cnt = 0;
	reg clk_div = 0;

seg7 u_hex0(
	.BCDIN(show0),
	.SEGOUT(HEX0)
);
seg7 u_hex1(
	.BCDIN(show1),
	.SEGOUT(HEX1)
);
seg7 u_hex2(
	.BCDIN(show2),
	.SEGOUT(HEX2)
);
seg7 u_hex3(
	.BCDIN(show3),
	.SEGOUT(HEX3)
);


always @(posedge CLOCK_50) begin
	key_count[0] <= {key_count[0][2:0],~KEY[0]};
	key_count[1] <= {key_count[1][2:0],~KEY[1]};
	key_count[2] <= {key_count[2][2:0],~KEY[2]};
	key_count[3] <= {key_count[3][2:0],~KEY[3]};
	
	if(key_count[0]==4'b0001) pb[0] <= 1;
	else pb[0] <= 0;
	if(key_count[1]==4'b0001) pb[1] <= 1;
	else pb[1] <= 0;
	if(key_count[2]==4'b0001) pb[2] <= 1;
	else pb[2] <= 0;
	if(key_count[3]==4'b0001) pb[3] <= 1;
	else pb[3] <= 0;
end

always@(posedge CLOCK_50)begin
	if(div_cnt == 50000000)begin
		div_cnt <= 0;
		clk_div <= 1;
	end
	else begin
		div_cnt <= div_cnt + 1;
		clk_div <= 0;
	end
end

always@(posedge CLOCK_50)begin
	if(pb[3])begin
		show0 <= 0;
		show1 <= 0;
		show2 <= 0;
		show3 <= 0;
	end
	
	if(SW[16])begin
		if(clk_div)begin
			if(SW[17])begin
				if(show0 ==4'b1001) show0 <=4'b0000;
				else show0 <= show0 + 1;
				show1 <= show0;
				show2 <= show1;
				show3 <= show2;
			end
			else begin
				if(show3 ==4'b1001) show3 <=4'b0000;
				else show3 <= show3 + 1;
				show0 <= show1;
				show1 <= show2;
				show2 <= show3;
			end
		end
	end
	else begin
		if(pb[0])begin
			if(SW[17])begin
				show0 <= SW[3:0];
				show1 <= show0;
				show2 <= show1;
				show3 <= show2;
			end
			else begin
				show3 <= SW[3:0];
				show0 <= show1;
				show1 <= show2;
				show2 <= show3;
			end
		end
	end
end
endmodule