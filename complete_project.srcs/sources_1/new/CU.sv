`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 03:20:10 PM
// Design Name: 
// Module Name: CU
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


module CU#(
  parameter logic [6:0] OP_ITYPE  = 7'b0010011, // I-type (ADDI, ANDI, ORI, ...)
  parameter logic [6:0] OP_LOAD   = 7'b0000011, // LW
  parameter logic [6:0] OP_STORE  = 7'b0100011, // SW
  parameter logic [6:0] OP_RTYPE  = 7'b0110011, // R-type (ADD, SUB, AND, OR, ...)
  parameter logic [6:0] OP_JAL    = 7'b1101111, // JAL
  parameter logic [6:0] OP_JALR   = 7'b1100111, // JALR
  parameter logic [6:0] OP_BRANCH = 7'b1100011, // BEQ/BNE/...
  parameter logic [1:0] ALUOP_ITYPE  = 2'b11,
  parameter logic [1:0] ALUOP_LOAD   = 2'b00,
  parameter logic [1:0] ALUOP_STORE  = 2'b00,
  parameter logic [1:0] ALUOP_RTYPE  = 2'b10,
  parameter logic [1:0] ALUOP_JUMP   = 2'b00,  // ADD
  parameter logic [1:0] ALUOP_BRANCH = 2'b01
)(
  input  logic [6:0] opcode,
  output logic       Branch,
  output logic       MemRead,
  output logic [1:0] MemtoReg,
  output logic [1:0] ALUOp,
  output logic       MemWrite,
  output logic       ALUSrc,
  output logic       RegWrite);
  always_comb begin
    // Default values
    Branch   = 1'b0;
    MemRead  = 1'b0;
    MemtoReg = 2'b00;
    ALUOp    = 2'b00;
    MemWrite = 1'b0;
    ALUSrc   = 1'b0;
    RegWrite = 1'b0;

    unique case (opcode)

      // I-type: ADDI, ANDI, ORI, XORI, SLTI, ...
      OP_ITYPE: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;          // rs1 + imm
        ALUOp    = ALUOP_ITYPE;
      end

      // LOAD: LW
      OP_LOAD: begin
        RegWrite = 1'b1;
        MemRead  = 1'b1;
        MemtoReg = 2'b01;         // from data memory
        ALUSrc   = 1'b1;          // base + imm
        ALUOp    = ALUOP_LOAD;    // ADD
      end

      // STORE: SW
      OP_STORE: begin
        MemWrite = 1'b1;
        ALUSrc   = 1'b1;          // base + imm
        ALUOp    = ALUOP_STORE;   // ADD
      end

      // R-type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
      OP_RTYPE: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;          // rs1, rs2
        ALUOp    = ALUOP_RTYPE;   // use funct3/funct7 in ALUcontrol
      end

      // JAL: rd = PC+4, PC = PC + imm
      OP_JAL: begin
        RegWrite = 1'b1;
        MemtoReg = 2'b10;         // write PC+4 to rd
        // PC target done in TOP, ALU not needed
      end

      // JALR: rd = PC+4, PC = (rs1 + imm) & ~1
      OP_JALR: begin
        RegWrite = 1'b1;
        MemtoReg = 2'b10;         // write PC+4 to rd
        ALUSrc   = 1'b1;          // rs1 + imm if you want ALU to compute it
        ALUOp    = ALUOP_JUMP;    // ADD
      end

      // BRANCH: BEQ, BNE, BLT, BGE, BLTU, BGEU
      OP_BRANCH: begin
        Branch   = 1'b1;
        ALUSrc   = 1'b0;          // rs1 vs rs2
        ALUOp    = ALUOP_BRANCH;  // SUB + flags
      end

      default: ; // keep defaults
    endcase
  end

endmodule