module lab(
	input        CLOCK_50,
	input  [3:0] KEY,
	input  [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output reg [17:0] LEDR,
	output reg [7:0] LEDG
);
	reg [1:0] pass0;
	reg [1:0] pass1;
	reg [1:0] pass2;
	reg [1:0] pass3;
	reg [1:0] show0;
	reg [1:0] show1;
	reg [1:0] show2;
	reg [1:0] show3;
	
	reg [3:0] pb;
	reg [3:0] key_count[3:0];
	
	reg [2:0] count = 0;
	reg [1:0] enter0;
	reg [1:0] enter1;
	reg [1:0] enter2;
	reg [1:0] enter3;
	
	reg [26:0] div_cnt = 0;
	reg clk_div = 0;

seven_segment u_hex0(
	.digit(show0),
	.seg(HEX0)
);
seven_segment u_hex1(
	.digit(show1),
	.seg(HEX1)
);
seven_segment u_hex2(
	.digit(show2),
	.seg(HEX2)
);
seven_segment u_hex3(
	.digit(show3),
	.seg(HEX3)
);
seven_segment u_hex4(
	.digit(pass0),
	.seg(HEX4)
);
seven_segment u_hex5(
	.digit(pass1),
	.seg(HEX5)
);
seven_segment u_hex6(
	.digit(pass2),
	.seg(HEX6)
);
seven_segment u_hex7(
	.digit(pass3),
	.seg(HEX7)
);

always @(posedge CLOCK_50) begin
	key_count[0] <= {key_count[0][2:0],KEY[0]};
	key_count[1] <= {key_count[1][2:0],KEY[1]};
	key_count[2] <= {key_count[2][2:0],KEY[2]};
	key_count[3] <= {key_count[3][2:0],KEY[3]};
	
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
	if(div_cnt == 10000000)begin
		div_cnt <= 0;
		clk_div <= ~clk_div;
	end
	else begin
		div_cnt <= div_cnt + 1;
	end
end

always@(posedge clk_div)begin
	if(SW[0] == 0)begin
		pass0 <= 0;
		pass1 <= 0;
		pass2 <= 0;
		pass3 <= 0;
		LEDR[17] <= 0;
		LEDR[16] <= 0;
		LEDR[15] <= 0;
		LEDR[14] <= 0;
		LEDR[13] <= 0;
		LEDR[12] <= 0;
		LEDR[11] <= 0;
		LEDR[10] <= 0;
	end
	else begin
		pass0 <= {SW[11],SW[10]};
		pass1 <= {SW[13],SW[12]};
		pass2 <= {SW[15],SW[14]};
		pass3 <= {SW[17],SW[16]};
		LEDR[17] <= SW[17];
		LEDR[16] <= SW[16];
		LEDR[15] <= SW[15];
		LEDR[14] <= SW[14];
		LEDR[13] <= SW[13];
		LEDR[12] <= SW[12];
		LEDR[11] <= SW[11];
		LEDR[10] <= SW[10];
	end
end

always @(posedge CLOCK_50)begin
	if(SW[0] == 0)begin
		count <= 0;
		enter0 <= 0;
		enter1 <= 0;
		enter2 <= 0;
		enter3 <= 0;
		show0 <= 0;
		show1 <= 0;
		show2 <= 0;
		show3 <= 0;
	end
	else begin
		case(count)
			3'b000:begin
				if(pb[0])enter3 <= 2'b00;
				else if(pb[1])enter3 <= 2'b01;
				else if(pb[2])enter3 <= 2'b10;
				else if(pb[3])enter3 <= 2'b11;
				if(pb!=4'b0000)count <= count + 1;
			end
			3'b001:begin
				show0 <= enter3;
				if(pb[0])enter2 <= 2'b00;
				else if(pb[1])enter2 <= 2'b01;
				else if(pb[2])enter2 <= 2'b10;
				else if(pb[3])enter2 <= 2'b11;
				if(pb!=4'b0000)count <= count + 1;
			end
			3'b010:begin
				show1 <= enter3;
				show0 <= enter2;
				if(pb[0])enter1 <= 2'b00;
				else if(pb[1])enter1 <= 2'b01;
				else if(pb[2])enter1 <= 2'b10;
				else if(pb[3])enter1 <= 2'b11;
				if(pb!=4'b0000)count <= count + 1;
			end
			3'b011:begin
				show2 <= enter3;
				show1 <= enter2;
				show0 <= enter1;
				if(pb[0])enter0 <= 2'b00;
				else if(pb[1])enter0 <= 2'b01;
				else if(pb[2])enter0 <= 2'b10;
				else if(pb[3])enter0 <= 2'b11;
				if(pb!=4'b0000)count <= count + 1;
			end
			3'b100:begin
				show3 <= enter3;
				show2 <= enter2;
				show1 <= enter1;
				show0 <= enter0;
			end
			default:count <= 3'b100;
		endcase
	end
end
always@(posedge clk_div)begin
	if(SW[0]==1)begin
		if(count == 3'b100)begin
			if(pass0==enter0 && pass1==enter1 && pass2==enter2 && pass3==enter3)begin
				if(LEDG == 0)LEDG <= 8'b00000001;
				else LEDG <= {LEDG[6:0], LEDG[7]};
			end
			else LEDG <= ~LEDG;
		end
	end
	else begin
		LEDG <= 8'b0;
	end
end
endmodule