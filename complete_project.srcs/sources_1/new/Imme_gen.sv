`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 03:06:09 PM
// Design Name: 
// Module Name: Imme_gen
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


    module Imme_gen(
    input  logic [31:0] instruction,
    output logic [31:0] imm_out
);
    logic [6:0] opcode;
    assign opcode = instruction[6:0];
    always_comb begin
        case (opcode)
            // I-type: ADDI, ANDI, ORI, XORI, SLTI, SLTIU, LW, JALR
            7'b0010011,
            7'b0000011,
            7'b1100111:
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            // S-type: SW, SH, SB
            7'b0100011:
                imm_out = {{20{instruction[31]}},
                           instruction[31:25],
                           instruction[11:7]};
            // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011:
                imm_out = {{19{instruction[31]}},
                           instruction[31],      // imm[12]
                           instruction[7],       // imm[11]
                           instruction[30:25],   // imm[10:5]
                           instruction[11:8]};   // imm[4:1]
            // TOP will do << 1

            // J-type: JAL
            7'b1101111:
                imm_out = {{11{instruction[31]}},
                           instruction[31],      // imm[20]
                           instruction[19:12],   // imm[19:12]
                           instruction[20],      // imm[11]
                           instruction[30:21]};  // imm[10:1]
            // TOP will do << 1

            default:
                imm_out = 32'b0;
        endcase
    end
endmodule
