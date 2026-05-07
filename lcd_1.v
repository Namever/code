module Hw18(
    CLK,PB,SW,LEDG,LEDR,SEG0,SEG1,SEG2,SEG3,SEG4,SEG5,SEG6,SEG7,
    LCD_BLON,LCD_DATA,LCD_EN,LCD_ON,LCD_RS,LCD_RW
);

input  wire        CLK;
input  wire [3:0]  PB;
input  wire [17:0] SW;
output wire [8:0]  LEDG;
output wire [17:0] LEDR;
output wire [6:0]  SEG0,SEG1,SEG2,SEG3,SEG4,SEG5,SEG6,SEG7;
output wire        LCD_BLON;
output wire [7:0]  LCD_DATA;
output wire        LCD_EN;
output wire        LCD_ON;
output wire        LCD_RS;
output wire        LCD_RW;

parameter [0:8*16-1] text1 = {
 8'h20, 8'h57, 8'h65, 8'h6C, 8'h63, 8'h6F, 8'h6D, 8'h65,
 8'h20, 8'h74, 8'h6F, 8'h20, 8'h74, 8'h68, 8'h65, 8'h20
}; 
parameter [0:8*16-1] text2 = {8'h20, 8'h41, 8'h6C, 8'h74, 8'h65, 8'h72, 8'h61, 8'h20,
 8'h44, 8'h45, 8'h32, 8'hB0, 8'h31, 8'h31, 8'h35, 8'h20};
parameter [0:8*16-1] text3 = {8'h53, 8'h54, 8'h20, 8'h49, 8'h44, 8'h3A, 8'h31, 8'h31,
 8'h32, 8'h33, 8'h36, 8'h30, 8'h31, 8'h31, 8'h38, 8'h20};
parameter [0:8*16-1] text4 = {8'h4E, 8'h61, 8'h74, 8'h69, 8'h6F, 8'h6E, 8'h61, 8'h6C,
 8'h20, 8'h54, 8'h61, 8'h69, 8'h70, 8'h65, 8'h69, 8'h20};

assign LCD_ON   = 1'b1;
assign LCD_BLON = 1'b1;

assign LEDG = 9'd0;
assign LEDR = 18'd0;
assign SEG0 = 7'h7F;
assign SEG1 = 7'h7F;
assign SEG2 = 7'h7F;
assign SEG3 = 7'h7F;
assign SEG4 = 7'h7F;
assign SEG5 = 7'h7F;
assign SEG6 = 7'h7F;
assign SEG7 = 7'h7F;

wire [0:8*16-1] in_text;
assign in_text = (SW[1:0] == 0) ? text1 : 
									((SW[1:0] == 1) ? text2 : ((SW[1:0] == 2) ? text3 : text4));

LCD_TEST u_lcd (
    .CLK(CLK),
    .iRST_N(PB[3]),
    .in_trig(!PB[0]),
    .in_line(SW[4]),
    .in_LCD(in_text),
    .LCD_DATA(LCD_DATA),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_RS(LCD_RS)
);

endmodule