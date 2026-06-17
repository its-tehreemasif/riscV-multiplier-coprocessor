`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/23/2025 12:52:44 PM
// Design Name: 
// Module Name: tb_Multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
// tb_mul32_iterative_sv.sv
module tb_Multiplier;
    logic clk;
    logic rst;
    logic start;
    logic [1:0] op_sel;
    logic [31:0] A, B;
    logic [63:0] result;
    logic busy, done;

    Multiplier uut (
        .clk(clk), .rst(rst), .start(start),
        .op_sel(op_sel), .A(A), .B(B),
        .result(result), .busy(busy), .done(done)
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz-ish for sim scale

    initial begin
        rst = 1; start = 0; op_sel = 2'b00; A = 0; B = 0;
        #20 rst = 0;
        // Test 1: unsigned * unsigned
        A = 32'd15; B = 32'd10; op_sel = 2'b00; // unsigned*unsigned
        #10 start = 1; #10 start = 0;
        wait(done); #10;
        $display("T1: %0d * %0d = %0d (expected %0d)", $signed(A), $signed(B), result, 64'd150);
        #20;

        // Test 2: signed * unsigned  (-7)*3 = -21
        A = -32'sd7; B = 32'd3; op_sel = 2'b01;
        #10 start = 1; #10 start = 0;
        wait(done); #10;
        $display("T2: %0d * %0d = %0d (expected %0d)", $signed(A), $signed(B), $signed(result), -64'sd21);
        #20;

        // Test 3: unsigned * signed  4 * (-8) = -32
        A = 32'd4; B = -32'sd8; op_sel = 2'b10;
        #10 start = 1; #10 start = 0;
        wait(done); #10;
        $display("T3: %0d * %0d = %0d (expected %0d)", $signed(A), $signed(B), $signed(result), -64'sd32);
        #20;

        // Test 4: signed * signed (-9)*(-9) = 81
        A = -32'sd9; B = -32'sd9; op_sel = 2'b11;
        #10 start = 1; #10 start = 0;
        wait(done); #10;
        $display("T4: %0d * %0d = %0d (expected %0d)", $signed(A), $signed(B), $signed(result), 64'd81);
        #20;

        // Test 5: zero * anything
        A = 32'd0; B = -32'sd12345; op_sel = 2'b10;
        #10 start = 1; #10 start = 0;
        wait(done); #10;
        $display("T5: %0d * %0d  %0d (expected 0)", $signed(A), $signed(B), $signed(result));
        #20;

        // Test 6: max * max (unsigned)
        A = 32'hFFFF_FFFF; B = 32'hFFFF_FFFF; op_sel = 2'b00;
        #10 start = 1; #10 start = 0;
        wait(done); #10;
        $display("T6: 0x%h * 0x%h = 0x%h", A, B, result);
        #50;

        $display("All tests completed.");
        $finish;
    end
endmodule