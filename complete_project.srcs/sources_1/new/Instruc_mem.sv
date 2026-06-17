`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 02:20:31 PM
// Design Name: 
// Module Name: Instruc_mem
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


module Instruc_mem#(
    parameter length = 32, width = 32
)(
    input  logic [width-1:0] addr,
    output logic [width-1:0] dataR
);
    logic [width-1:0] InsMem [0:length-1];

    // Fill all words with RISC-V NOP (0x00000013), then overlay file
    initial begin
        for (int i = 0; i < length; i++) InsMem[i] = 32'h00000013; // NOP
        $display("[Instruc_mem] Loading midd.mem ...");             // <- name matches project
        $readmemh("midd.mem", InsMem);
        $display("[Instruc_mem] W0=%h W1=%h W2=%h W3=%h",
                 InsMem[0], InsMem[1], InsMem[2], InsMem[3]);
    end

    // PC is byte address; use word index
    assign dataR = InsMem[addr[6:2]];
endmodule

