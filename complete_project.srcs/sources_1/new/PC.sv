`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 02:14:17 PM
// Design Name: 
// Module Name: PC
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


module PC (
    input  logic clk,
    input  logic reset,
    input  logic enable,        //  added
    input  logic [31:0] next_addr,
    input  logic PCSrc,
    output logic [31:0] PC
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 0;
        else if (enable) begin   //  added
            if (PCSrc)
                PC <= next_addr;
            else
                PC <= PC + 4;
        end
    end
endmodule