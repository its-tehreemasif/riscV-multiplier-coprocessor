`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 03:01:40 PM
// Design Name: 
// Module Name: ALU_TB
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


module ALU_TB;
    logic [31:0] A, B;
    logic [1:0]  ALUOp;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic        Branch;
    logic [3:0]  ALUCtrl;
    logic [31:0] result;
    logic        zero, lt, ltu;
    logic        take_branch;
    // ALUcontrol
    AlUcontrol u_alu_ctrl (
        .ALUOp  (ALUOp),
        .funct3 (funct3),
        .funct7 (funct7),
        .ALUCtrl(ALUCtrl) );
    // ALU (no funct3 / Branch here)
    ALU u_alu (
        .A      (A),
        .B      (B),
        .ALUCtrl(ALUCtrl),
        .result (result),
        .zero   (zero),
        .lt     (lt),
        .ltu    (ltu));
    // Branch comparator 
    Branch u_branch (
        .Branch     (Branch),
        .funct3     (funct3),
        .zero       (zero),
        .lt         (lt),
        .ltu        (ltu),
        .take_branch(take_branch));
    initial begin
        // 1) Normal ADD (no branch)
        A      = 32'd10;
        B      = 32'd5;
        ALUOp  = 2'b10;          // R-type
        funct3 = 3'b000;
        funct7 = 7'b0000000;     // ADD
        Branch = 1'b0;
        #10;
        // 2) BEQ, equal ? should branch (take_branch = 1)
        A      = 32'd20;
        B      = 32'd20;
        ALUOp  = 2'b01;          // branch ? ALU does SUB
        funct3 = 3'b000;         // BEQ
        funct7 = 7'b0000000;     // ignored
        Branch = 1'b1;
        #10;

        // 3) BEQ, not equal ? no branch
        A      = 32'd20;
        B      = 32'd10;
        ALUOp  = 2'b01;
        funct3 = 3'b000;         // BEQ
        Branch = 1'b1;
        #10;

        // 4) BLT (signed), A < B ? branch
        A      = -5;
        B      = 10;
        ALUOp  = 2'b01;
        funct3 = 3'b100;         // BLT
        Branch = 1'b1;
        #10;

        $stop;
    end

endmodule

