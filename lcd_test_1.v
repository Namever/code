module	LCD_TEST (	//	Host Side
					CLK,iRST_N,
					in_trig,
					in_line,
					in_LCD,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS	);
		//	Host Side
		input			CLK,iRST_N;
		input in_trig;
		input in_line;
		input [0:8*16-1]in_LCD;
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
		wire		mLCD_Done;

		parameter	LCD_INTIAL	=	0;
		parameter	LCD_LINE1	=	6;
		parameter	LCD_CH_LINE	=	5;
		parameter	LUT_SIZE	=	LCD_LINE1+16+1;

always@(posedge CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
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
					if (LUT_INDEX == LCD_INTIAL+4)
						LUT_INDEX <= LUT_SIZE;   // 初始化完停住
					else
						LUT_INDEX <= LUT_INDEX+1;
					mLCD_ST	<=	0;
				end
			endcase
		end
		else if (in_trig)
		begin
			LUT_INDEX <= LCD_CH_LINE;
		end
	end
end

always @(*) begin
    case (LUT_INDEX)
        LCD_INTIAL+0: LUT_DATA = 9'h038;
        LCD_INTIAL+1: LUT_DATA = 9'h00C;
        LCD_INTIAL+2: LUT_DATA = 9'h001;
        LCD_INTIAL+3: LUT_DATA = 9'h006;
        LCD_INTIAL+4: LUT_DATA = 9'h080;

        LCD_CH_LINE : LUT_DATA = in_line ? 9'h0C0 : 9'h080;

        LCD_LINE1+0 : LUT_DATA = {1'b1, in_LCD[  0+:8]};
        LCD_LINE1+1 : LUT_DATA = {1'b1, in_LCD[  8+:8]};
        LCD_LINE1+2 : LUT_DATA = {1'b1, in_LCD[ 16+:8]};
        LCD_LINE1+3 : LUT_DATA = {1'b1, in_LCD[ 24+:8]};
        LCD_LINE1+4 : LUT_DATA = {1'b1, in_LCD[ 32+:8]};
        LCD_LINE1+5 : LUT_DATA = {1'b1, in_LCD[ 40+:8]};
        LCD_LINE1+6 : LUT_DATA = {1'b1, in_LCD[ 48+:8]};
        LCD_LINE1+7 : LUT_DATA = {1'b1, in_LCD[ 56+:8]};
        LCD_LINE1+8 : LUT_DATA = {1'b1, in_LCD[ 64+:8]};
        LCD_LINE1+9 : LUT_DATA = {1'b1, in_LCD[ 72+:8]};
        LCD_LINE1+10: LUT_DATA = {1'b1, in_LCD[ 80+:8]};
        LCD_LINE1+11: LUT_DATA = {1'b1, in_LCD[ 88+:8]};
        LCD_LINE1+12: LUT_DATA = {1'b1, in_LCD[ 96+:8]};
        LCD_LINE1+13: LUT_DATA = {1'b1, in_LCD[104+:8]};
        LCD_LINE1+14: LUT_DATA = {1'b1, in_LCD[112+:8]};
        LCD_LINE1+15: LUT_DATA = {1'b1, in_LCD[120+:8]};

        default:      LUT_DATA = 9'h120;
    endcase
end

LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(CLK),
							.iRST_N(iRST_N),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule