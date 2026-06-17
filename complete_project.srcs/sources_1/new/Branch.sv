`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 03:21:08 PM
// Design Name: 
// Module Name: Branch
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


module Branch (
    input  logic       Branch,      // 1 = this instruction is a branch
    input  logic [2:0] funct3,      // instr[14:12]
    input  logic       zero,        // from ALU
    input  logic       lt,          // from ALU (signed)
    input  logic       ltu,         // from ALU (unsigned)
    output logic       take_branch  // final branch decision
);

    always_comb begin
        take_branch = 1'b0;         // default: don't branch

        if (Branch) begin
            case (funct3)
                3'b000: take_branch =  zero;   // BEQ
                3'b001: take_branch = ~zero;   // BNE
                3'b100: take_branch =  lt;     // BLT
                3'b101: take_branch = ~lt;     // BGE
                3'b110: take_branch =  ltu;    // BLTU
                3'b111: take_branch = ~ltu;    // BGEU
                default: take_branch = 1'b0;
            endcase
        end
    end

endmodule
