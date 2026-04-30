`timescale 1ns/1ns

module Hw15_tb;

    // Inputs
    reg        CLK;
    reg [17:0] SW;
    reg [3:0]  KEY;

    // Outputs
    wire [6:0] HEX0, HEX1, HEX2, HEX3;

    // Instantiate the Unit Under Test (UUT)
    Hw15 uut (
        .CLK(CLK),
        .SW(SW),
        .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    // 50MHz Clock Generation (20ns period)
    always #10 CLK = ~CLK;

    initial begin
        // --- Initialize Inputs ---
        CLK = 0;
        SW = 18'd0;
        KEY = 4'b1111; // Active-low, so 1 is idle

        // --- 1. Reset System ---
        $display("Applying Reset...");
        KEY[3] = 0;    // Assert Reset [cite: 4, 11]
        #100;
        KEY[3] = 1;    // Release Reset
        #100;

        // --- 2. Auto Mode, Shift Left (SW16=0, SW17=0) ---
        // New values enter from HEX0 and move toward HEX3 
        $display("Testing Auto Mode: Shift Left...");
        SW[16] = 0; 
        SW[17] = 0;
        #1200; // Wait for several clk_1hz cycles to see digits move

        // --- 3. Auto Mode, Shift Right (SW16=0, SW17=1) ---
        // New values enter from HEX3 and move toward HEX0 
        $display("Testing Auto Mode: Shift Right...");
        SW[16] = 0;
        SW[17] = 1;
        #1200;

        // --- 4. Manual Mode, Shift Left (SW16=1, SW17=0) ---
        $display("Testing Manual Mode: Shift Left...");
        SW[16] = 1;
        SW[17] = 0;
        
        // Load value 4'hA into HEX0
        SW[3:0] = 4'hA; 
        #200; KEY[0] = 0;
        #100; KEY[0] = 1; // Pulse KEY0 [cite: 16, 17]
        
        // Load value 4'hB into HEX0
        SW[3:0] = 4'hB;
        #200; KEY[0] = 0;
        #100; KEY[0] = 1;

        // --- 5. Manual Mode, Shift Right (SW16=1, SW17=1) ---
        $display("Testing Manual Mode: Shift Right...");
        SW[16] = 1;
        SW[17] = 1;
        
        // Load value 4'hC into HEX3 
        SW[3:0] = 4'hC;
        #200; KEY[0] = 0;
        #100; KEY[0] = 1;
        
        SW[3:0] = 4'hD;
        #200; KEY[0] = 0;
        #100; KEY[0] = 1;
        
        #1000;

        $display("Simulation Finished.");
        $stop;
    end

endmodule