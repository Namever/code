module	EP4 (	//	Host Side
					iCLK,iRST_N,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS,KEY,SW	);
//	Host Side
input			iCLK,iRST_N;
input			[2:0]KEY;
input			[4:0]SW;
//	LCD Side
output	[7:0]	LCD_DATA;
output			LCD_RW,LCD_EN,LCD_RS;
//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
reg 		run = 0;
reg 		rst = 0;
wire		mLCD_Done;

parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	16+1;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N) begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else begin
		if(LUT_INDEX<LUT_SIZE || rst) begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY+1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mLCD_ST	<=	0;
				end
			endcase
		end
	end
end
always@(*)begin
if(!iRST_N) rst <= 1;
else if(!KEY[0]) run <= 1; 
if(rst)begin
case(LUT_INDEX)
			//	初始化設定 (RS=0，為指令，請勿更動)
			LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
			LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
			LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
			LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
			LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
			
			LCD_LINE1+0:	LUT_DATA	<=	{1'b1, "W"};
			LCD_LINE1+1:	LUT_DATA	<=	{1'b1, "e"};
			LCD_LINE1+2:	LUT_DATA	<=	{1'b1, "l"};
			LCD_LINE1+3:	LUT_DATA	<=	{1'b1, "c"};
			LCD_LINE1+4:	LUT_DATA	<=	{1'b1, "o"};
			LCD_LINE1+5:	LUT_DATA	<=	{1'b1, "m"};
			LCD_LINE1+6:	LUT_DATA	<=	{1'b1, "e"};
			LCD_LINE1+7:	LUT_DATA	<=	{1'b1, " "}; 
			LCD_LINE1+8:	LUT_DATA	<=	{1'b1, "t"};
			LCD_LINE1+9:	LUT_DATA	<=	{1'b1, "o"};
			LCD_LINE1+10:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE1+11:	LUT_DATA	<=	{1'b1, "F"};
			LCD_LINE1+12:	LUT_DATA	<=	{1'b1, "P"};
			LCD_LINE1+13:	LUT_DATA	<=	{1'b1, "G"};
			LCD_LINE1+14:	LUT_DATA	<=	{1'b1, "A"};
			LCD_LINE1+15:	LUT_DATA	<=	{1'b1, "!"};
			
			LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
			
			LCD_LINE2+0:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+1:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+2:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+3:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+4:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+5:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+6:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+7:	LUT_DATA	<=	{1'b1, " "}; 
			LCD_LINE2+8:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+9:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+10:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+11:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+12:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+13:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+14:	LUT_DATA	<=	{1'b1, " "};
			LCD_LINE2+15:	begin
				LUT_DATA	<=	{1'b1, " "};
				rst <=0;
			end
endcase
end
else if(run) begin
	if(SW[4])begin
		case(SW[1:0])
		2'b00:begin
			case(LUT_INDEX)
			//	初始化設定 (RS=0，為指令，請勿更動)

			0:	LUT_DATA	<=	9'h080;

			
			1+0:	LUT_DATA	<=	{1'b1, "W"};
			1+1:	LUT_DATA	<=	{1'b1, "e"};
			1+2:	LUT_DATA	<=	{1'b1, "l"};
			1+3:	LUT_DATA	<=	{1'b1, "c"};
			1+4:	LUT_DATA	<=	{1'b1, "o"};
			1+5:	LUT_DATA	<=	{1'b1, "m"};
			1+6:	LUT_DATA	<=	{1'b1, "e"};
			1+7:	LUT_DATA	<=	{1'b1, " "}; // 空格
			1+8:	LUT_DATA	<=	{1'b1, "t"};
			1+9:	LUT_DATA	<=	{1'b1, "o"};
			1+10:	LUT_DATA	<=	{1'b1, " "};
			1+11:	LUT_DATA	<=	{1'b1, "F"};
			1+12:	LUT_DATA	<=	{1'b1, "P"};
			1+13:	LUT_DATA	<=	{1'b1, "G"};
			1+14:	LUT_DATA	<=	{1'b1, "A"};
			1+15:	begin
				LUT_DATA	<=	{1'b1, "!"};
				run <= 0;
			end
			endcase
		end
		2'b01:begin
			case(LUT_INDEX)
			//	初始化設定 (RS=0，為指令，請勿更動)

			0:	LUT_DATA	<=	9'h080;

			//	Line 1 (第一行，共 16 個字元)
			//  格式： {1'b1, "你想要的英文字母、數字或符號"}
			1+0:	LUT_DATA	<=	{1'b1, "N"};
			1+1:	LUT_DATA	<=	{1'b1, "T"};
			1+2:	LUT_DATA	<=	{1'b1, "U"};
			1+3:	LUT_DATA	<=	{1'b1, "T"};
			1+4:	LUT_DATA	<=	{1'b1, " "};
			1+5:	LUT_DATA	<=	{1'b1, "N"};
			1+6:	LUT_DATA	<=	{1'b1, "T"};
			1+7:	LUT_DATA	<=	{1'b1, "U"}; // 空格
			1+8:	LUT_DATA	<=	{1'b1, "T"};
			1+9:	LUT_DATA	<=	{1'b1, " "};
			1+10:	LUT_DATA	<=	{1'b1, "N"};
			1+11:	LUT_DATA	<=	{1'b1, "T"};
			1+12:	LUT_DATA	<=	{1'b1, "U"};
			1+13:	LUT_DATA	<=	{1'b1, "T"};
			1+14:	LUT_DATA	<=	{1'b1, " "};
			1+15:	begin
				LUT_DATA	<=	{1'b1, " "};
				run <= 0;
			end
			endcase
		end
		2'b10:begin

		end
		2'b11:begin

		end
		endcase
	end
	else begin
		case(SW[1:0])
		2'b00:begin
			case(LUT_INDEX)


			0:	LUT_DATA	<=	9'h0C0;
			1+0:	LUT_DATA	<=	{1'b1, "W"};
			1+1:	LUT_DATA	<=	{1'b1, "e"};
			1+2:	LUT_DATA	<=	{1'b1, "l"};
			1+3:	LUT_DATA	<=	{1'b1, "c"};
			1+4:	LUT_DATA	<=	{1'b1, "o"};
			1+5:	LUT_DATA	<=	{1'b1, "m"};
			1+6:	LUT_DATA	<=	{1'b1, "e"};
			1+7:	LUT_DATA	<=	{1'b1, " "}; // 空格
			1+8:	LUT_DATA	<=	{1'b1, "t"};
			1+9:	LUT_DATA	<=	{1'b1, "o"};
			1+10:	LUT_DATA	<=	{1'b1, " "};
			1+11:	LUT_DATA	<=	{1'b1, "F"};
			1+12:	LUT_DATA	<=	{1'b1, "P"};
			1+13:	LUT_DATA	<=	{1'b1, "G"};
			1+14:	LUT_DATA	<=	{1'b1, "A"};
			1+15:	begin
				LUT_DATA	<=	{1'b1, "!"};
				run <= 0;
			end
			endcase
		end
		2'b01:begin
			case(LUT_INDEX)


			0:	LUT_DATA	<=	9'h0C0;
			1+0:	LUT_DATA	<=	{1'b1, "N"};
			1+1:	LUT_DATA	<=	{1'b1, "T"};
			1+2:	LUT_DATA	<=	{1'b1, "U"};
			1+3:	LUT_DATA	<=	{1'b1, "T"};
			1+4:	LUT_DATA	<=	{1'b1, " "};
			1+5:	LUT_DATA	<=	{1'b1, "N"};
			1+6:	LUT_DATA	<=	{1'b1, "T"};
			1+7:	LUT_DATA	<=	{1'b1, "U"}; // 空格
			1+8:	LUT_DATA	<=	{1'b1, "T"};
			1+9:	LUT_DATA	<=	{1'b1, " "};
			1+10:	LUT_DATA	<=	{1'b1, "N"};
			1+11:	LUT_DATA	<=	{1'b1, "T"};
			1+12:	LUT_DATA	<=	{1'b1, "U"};
			1+13:	LUT_DATA	<=	{1'b1, "T"};
			1+14:	LUT_DATA	<=	{1'b1, " "};
			1+15:	begin
				LUT_DATA	<=	{1'b1, " "};
				run <= 0;
			end
			endcase
		end
		2'b10:begin

		end
		2'b11:begin

		end
		endcase
	end				
end				
end
LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.iRST_N(iRST_N),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule
