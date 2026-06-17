`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 03:11:08 PM
// Design Name: 
// Module Name: AlUcontrol
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


module AlUcontrol(
    input  logic [1:0] ALUOp,   // from main Control
    input  logic [2:0] funct3,  // from instruction[14:12]
    input  logic [6:0] funct7,  // from instruction[31:25]
    output logic [3:0] ALUCtrl   );
    parameter [3:0]
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
        unique case (ALUOp)
            // LW, SW, JALR: just ADD
            2'b00: ALUCtrl = ALU_ADD;
            // Branches: ALU does SUB (Zero, lt, ltu used outside)
            2'b01: ALUCtrl = ALU_SUB;
            // R-type (opcode = 0110011)
            2'b10: begin
                unique case (funct3)
                    3'b000: ALUCtrl =
         (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD; // SUB/ADD
                    3'b111: ALUCtrl = ALU_AND;
                    3'b110: ALUCtrl = ALU_OR;
                    3'b100: ALUCtrl = ALU_XOR;
                    3'b010: ALUCtrl = ALU_SLT;   // SLT
                    3'b011: ALUCtrl = ALU_SLTU;  // SLTU
                    3'b001: ALUCtrl = ALU_SLL;   // SLL
                    3'b101: ALUCtrl =
                                (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL; // SRA/SRL
                    default: ALUCtrl = ALU_ADD;  // safe default
                endcase
            end
            // I-type (opcode = 0010011)
            2'b11: begin
                unique case (funct3)
                    3'b000: ALUCtrl = ALU_ADD;   // ADDI
                    3'b111: ALUCtrl = ALU_AND;   // ANDI
                    3'b110: ALUCtrl = ALU_OR;    // ORI
                    3'b100: ALUCtrl = ALU_XOR;   // XORI
                    3'b010: ALUCtrl = ALU_SLT;   // SLTI
                    3'b011: ALUCtrl = ALU_SLTU;  // SLTIU
                    3'b001: ALUCtrl = ALU_SLL;   // SLLI
                    3'b101: ALUCtrl =
                                (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    default: ALUCtrl = ALU_ADD;
                endcase
            end

            default: ALUCtrl = ALU_ADD;
        endcase
    end
endmodule

