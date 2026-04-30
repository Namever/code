// ============================================================
//  HW18+19 - 四位數七段移位計數器
//
//  SW[16]=0 : 自動模式 — 每秒遞增 0~9，依移位方向推入顯示器
//  SW[16]=1 : 手動模式 — SW[3:0] 輸入數值，KEY[0] 下降緣觸發推入
//  SW[17]   : 移位方向 0=向左(新字由HEX0進) / 1=向右(新字由HEX3進)
//  KEY[3]   : 非同步 Reset（active-low，按下立即歸零）
// ============================================================

module Hw15 (
    input        CLK,        // 50 MHz 系統時脈
    input  [17:0] SW,       // 模式選擇：0=自動遞增，1=手動輸入
    input  [3:0] KEY,       // 手動觸發（active-low 下降緣）
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3
);
	wire SW16=SW[16];
	wire SW17=SW[17];
	wire KEY0=KEY[0];
	wire KEY3=KEY[3];
    // ----------------------------------------------------------
    // 1. 除頻：
    // ----------------------------------------------------------
		reg [0:0] div_cnt;
    reg        clk_1hz;

    always @(posedge CLK or negedge KEY3) begin
        if (!KEY3) begin
            div_cnt <= 1'd0;
            clk_1hz <= 1'b0;
        end else if (div_cnt == 1'd1) begin
            div_cnt <= 1'd0;
            clk_1hz <= ~clk_1hz;
        end else begin
            div_cnt <= div_cnt + 1'b1;
        end
    end

    // ----------------------------------------------------------
    // 2. 自動模式：EDG_TRIG（1 Hz 上升緣偵測）
    // ----------------------------------------------------------
    reg  auto_trig_d;
    wire auto_trig;

    always @(posedge CLK or negedge KEY3) begin
        if (!KEY3) auto_trig_d <= 1'b0;
        else       auto_trig_d <= clk_1hz;
    end

    assign auto_trig = clk_1hz & ~auto_trig_d;

    // ----------------------------------------------------------
    // 3. 自動模式：十進位計數器 0→9→0
    // ----------------------------------------------------------
    reg [3:0] digit;

    always @(posedge CLK or negedge KEY3) begin
        if (!KEY3) begin
            digit <= 4'd0;
        end else if (!SW16 && auto_trig) begin   // 自動模式才計數
            digit <= (digit == 4'd9) ? 4'd0 : digit + 1'b1;
        end
    end

    // ----------------------------------------------------------
    // 4. 手動模式：KEY[0] 下降緣偵測（EDG_TRIG）
    // ----------------------------------------------------------
    reg  key0_d0, key0_d1;
    wire manual_trig;

    always @(posedge CLK or negedge KEY3) begin
        if (!KEY3) begin
            key0_d0 <= 1'b1;
            key0_d1 <= 1'b1;
        end else begin
            key0_d0 <= KEY0;
            key0_d1 <= key0_d0;
        end
    end

    // 下降緣：前一拍高，現在低
    assign manual_trig = key0_d1 & ~key0_d0;

    // ----------------------------------------------------------
    // 5. 觸發訊號與輸入數值選擇
    //    SW16=0 → 自動模式；SW16=1 → 手動模式
    // ----------------------------------------------------------
    wire        load_trig = SW16 ? manual_trig : auto_trig;
    wire [3:0]  load_data = SW16 ? SW[3:0]     : digit;

    // ----------------------------------------------------------
    // 6. DLOAD 暫存器陣列（四個 4-bit 移位暫存器）
    //    SW17=0：d3←d2←d1←d0←load_data（向左，新字由HEX0進）
    //    SW17=1：d0←d1←d2←d3←load_data（向右，新字由HEX3進）
    // ----------------------------------------------------------
    reg [3:0] d0, d1, d2, d3;

    always @(posedge CLK or negedge KEY3) begin
        if (!KEY3) begin
            d0 <= 4'd0; d1 <= 4'd0;
            d2 <= 4'd0; d3 <= 4'd0;
        end else if (load_trig) begin
            if (SW17 == 1'b0) begin
                // 向左移位
                d3 <= d2;
                d2 <= d1;
                d1 <= d0;
                d0 <= load_data;
            end else begin
                // 向右移位
                d0 <= d1;
                d1 <= d2;
                d2 <= d3;
                d3 <= load_data;
            end
        end
    end

    // ----------------------------------------------------------
    // 7. seg7 解碼器（active-low）
    // ----------------------------------------------------------
    seg7 U0 (.D(d0), .Y(HEX0));
    seg7 U1 (.D(d1), .Y(HEX1));
    seg7 U2 (.D(d2), .Y(HEX2));
    seg7 U3 (.D(d3), .Y(HEX3));

endmodule


// ------------------------------------------------------------
// seg7：BCD → 7-segment (active-low, a=Y[0] ... g=Y[6])
// ------------------------------------------------------------
module seg7 (
    input      [3:0] D,
    output reg [6:0] Y
);
    always @(*) begin
        case (D)
        //          gfedcba
				    4'h0: Y = 7'h0; // 0
            4'h1: Y = 7'h1; // 1
            4'h2: Y = 7'h2; // 2
            4'h3: Y = 7'h3; // 3
            4'h4: Y = 7'h4; // 4
            4'h5: Y = 7'h5; // 5
            4'h6: Y = 7'h6; // 6
            4'h7: Y = 7'h7; // 7
            4'h8: Y = 7'h8; // 8
            4'h9: Y = 7'h9; // 9
            4'hA: Y = 7'hA; // A
            4'hB: Y = 7'hb; // b
            4'hC: Y = 7'hC; // C
            4'hD: Y = 7'hd; // d
            4'hE: Y = 7'hE; // E
            4'hF: Y = 7'hF; // F
        endcase
    end
endmodule