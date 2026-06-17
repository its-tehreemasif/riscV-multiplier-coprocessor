`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 02:54:27 PM
// Design Name: 
// Module Name: ALU
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


module ALU #(
    parameter WIDTH = 32
)(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic [3:0]       ALUCtrl,   // from ALUcontrol

    output logic [WIDTH-1:0] result,
    output logic             zero,      // result == 0
    output logic             lt,        // signed A < B
    output logic             ltu        // unsigned A < B
);

    // ALUCtrl encoding
    localparam [3:0]
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLT  = 4'b0101,
        ALU_SLTU = 4'b0110,
        ALU_SLL  = 4'b0111,
        ALU_SRL  = 4'b1000,
        ALU_SRA  = 4'b1001;
    always_comb begin
        result = '0;
        unique case (ALUCtrl)
            ALU_ADD : result = A + B;
            ALU_SUB : result = A - B;
            ALU_AND : result = A & B;
            ALU_OR  : result = A | B;
            ALU_XOR : result = A ^ B;
            ALU_SLT : result = ($signed(A) < $signed(B))
                               ? {{(WIDTH-1){1'b0}},1'b1} : '0;
            ALU_SLTU: result = (A < B)
                               ? {{(WIDTH-1){1'b0}},1'b1} : '0;
            ALU_SLL : result = A <<  B[4:0];
            ALU_SRL : result = A >>  B[4:0];
            ALU_SRA : result = $signed(A) >>> B[4:0];
            default : result = '0;
        endcase
        // flags - used by branch logic
        zero = (result == '0);
        lt   = ($signed(A) < $signed(B));
        ltu  = (A < B);
    end
endmodule