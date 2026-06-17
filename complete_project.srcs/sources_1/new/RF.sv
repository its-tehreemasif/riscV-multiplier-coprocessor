`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 02:37:37 PM
// Design Name: 
// Module Name: RF
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


module RF#(
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS   = 32,
    parameter e = 5               )(
    input  logic clk,
    input  logic we,
    input  logic [e-1:0] rs1,
    input  logic [e-1:0] rs2,
    input  logic [e-1:0] rsw,
    input  logic [DATA_WIDTH-1:0] dataw,
    output logic [DATA_WIDTH-1:0] data1,
    output logic [DATA_WIDTH-1:0] data2);
    logic [DATA_WIDTH-1:0] regfile [0:NUM_REGS-1];
    initial begin
        for (int i = 0; i < NUM_REGS; i++) regfile[i] = '0;
        $readmemh("rfdata.mem", regfile); end
    always_ff @(posedge clk) begin
        if (we && rsw != '0) regfile[rsw] <= dataw;
        regfile[0] <= '0; // x0 = 0
    end
    assign data1 = regfile[rs1];
    assign data2 = regfile[rs2];
endmodule