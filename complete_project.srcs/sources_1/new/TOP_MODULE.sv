`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 03:17:23 PM
// Design Name: 
// Module Name: TOP_MODULE
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


module TOP_MODULE(

    input  logic clk,
    input  logic reset,

    // CORE OUTPUTS
    output logic [31:0] pc_o,
    output logic [31:0] instruction_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] write_back_o,
    output logic        RegWrite_o,
    output logic        MemRead_o,
    output logic        MemWrite_o,

    // DEBUG OUTPUTS
    output logic        Branch_o,
    output logic        ALUSrc_o,
    output logic [1:0]  ALUOp_o,
    output logic [1:0]  MemtoReg_o,
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o,
    output logic [31:0] imm_out_o,
    output logic [3:0]  alu_ctrl_o,
    output logic        alu_zero_o,
    output logic        alu_lt_o,
    output logic        alu_ltu_o,
    output logic        take_branch_o,
    output logic [31:0] branch_target_o,
    output logic [31:0] jal_target_o,
    output logic [31:0] jalr_target_o,
    output logic        PCSrc_o
);

    // INTERNAL SIGNALS
    logic [31:0] pc, instruction;
    logic [31:0] rd1, rd2;
    logic [31:0] imm_out;
    logic [31:0] alu_result;
    logic [31:0] read_data;
    logic [31:0] write_back;

    logic Branch, MemRead, MemWrite, ALUSrc, RegWrite;
    logic zero, lt, ltu;
    logic take_branch;

    logic [1:0] ALUOp;
    logic [3:0] ALUCtrl;
    logic [1:0] MemtoReg;

    logic [31:0] pc_plus_4;
    logic [31:0] imm_shift;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    logic [31:0] next_addr;
    logic PCSrc;

    // JUMP OPCODES
    localparam logic [6:0] OP_JAL  = 7'b1101111;
    localparam logic [6:0] OP_JALR = 7'b1100111;

    logic is_jal, is_jalr;

    // MULTIPLIER SIGNALS
    logic is_mul;
    logic mul_start;
    logic mul_busy;
    logic mul_done;
    logic [63:0] mul_result;

    // MUL DETECT (RISC-V M)
    assign is_mul =
        (instruction[6:0]   == 7'b0110011) &&
        (instruction[31:25] == 7'b0000001) &&
        (instruction[14:12] == 3'b000);

    // PC STALL DURING MUL
    logic pc_enable;
    assign pc_enable = ~mul_busy;

    // PC
    PC pc_inst (
        .clk      (clk),
        .reset    (reset),
        .enable   (pc_enable),
        .next_addr(next_addr),
        .PCSrc    (PCSrc),
        .PC       (pc)
    );

    // INSTRUCTION MEMORY
    Instruc_mem imem (
        .addr (pc),
        .dataR(instruction)
    );

    // CONTROL UNIT
    CU cu (
        .opcode  (instruction[6:0]),
        .Branch  (Branch),
        .MemRead (MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp   (ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc  (ALUSrc),
        .RegWrite(RegWrite)
    );

    // REGISTER FILE
    RF rf (
        .clk   (clk),
        .we    (is_mul ? mul_done : RegWrite),
        .rs1   (instruction[19:15]),
        .rs2   (instruction[24:20]),
        .rsw   (instruction[11:7]),
        .dataw (write_back),
        .data1 (rd1),
        .data2 (rd2)
    );

    // IMMEDIATE GENERATOR
    Imme_gen imm_gen (
        .instruction(instruction),
        .imm_out    (imm_out)
    );

    // ALU CONTROL 
    AlUcontrol alu_ctrl (
        .ALUOp  (ALUOp),
        .funct3 (instruction[14:12]),
        .funct7 (instruction[31:25]),
        .ALUCtrl(ALUCtrl)
    );

    // ALU
    ALU alu (
        .A      (rd1),
        .B      (ALUSrc ? imm_out : rd2),
        .ALUCtrl(ALUCtrl),
        .result (alu_result),
        .zero   (zero),
        .lt     (lt),
        .ltu    (ltu)
    );

    // BRANCH UNIT
    Branch branch_unit (
        .Branch (Branch),
        .funct3 (instruction[14:12]),
        .zero   (zero),
        .lt     (lt),
        .ltu    (ltu),
        .take_branch(take_branch)
    );

    // DATA MEMORY
    DATA_MEM data_mem (
        .clk       (clk),
        .mem_read  (mul_busy ? 1'b0 : MemRead),
        .mem_write (mul_busy ? 1'b0 : MemWrite),
        .addr      (alu_result[5:0]),
        .write_data(rd2),
        .read_data (read_data)
    );

    // PC TARGET LOGIC
    assign pc_plus_4     = pc + 32'd4;
    assign imm_shift     = imm_out << 1;
    assign branch_target = pc_plus_4 + imm_shift;
    assign jal_target    = pc + imm_shift;
    assign jalr_target   = (rd1 + imm_out) & 32'hFFFF_FFFE;

    assign is_jal  = (instruction[6:0] == OP_JAL);
    assign is_jalr = (instruction[6:0] == OP_JALR);

    always_comb begin
        if (is_jalr)      next_addr = jalr_target;
        else if (is_jal)  next_addr = jal_target;
        else              next_addr = branch_target;
    end

    assign PCSrc = is_jal | is_jalr | take_branch;

    // MULTIPLIER
    assign mul_start = is_mul & ~mul_busy;

    Multiplier mul (
        .clk    (clk),
        .rst    (reset),
        .start  (mul_start),
        .op_sel (2'b11),
        .A      (rd1),
        .B      (rd2),
        .result (mul_result),
        .busy   (mul_busy),
        .done   (mul_done)
    );

    // WRITE BACK
    always_comb begin
        if (mul_done)
            write_back = mul_result[31:0];
        else begin
            case (MemtoReg)
                2'b00: write_back = alu_result;
                2'b01: write_back = read_data;
                2'b10: write_back = pc_plus_4;
                default: write_back = alu_result;
            endcase
        end
    end

    // OUTPUT ASSIGNMENTS
    assign pc_o            = pc;
    assign instruction_o   = instruction;
    assign alu_result_o    = alu_result;
    assign write_back_o    = write_back;

    assign RegWrite_o      = (is_mul ? mul_done : RegWrite);
    assign MemRead_o       = MemRead;
    assign MemWrite_o      = MemWrite;

    assign Branch_o        = Branch;
    assign ALUSrc_o        = ALUSrc;
    assign ALUOp_o         = ALUOp;
    assign MemtoReg_o      = MemtoReg;
    assign rs1_data_o      = rd1;
    assign rs2_data_o      = rd2;
    assign imm_out_o       = imm_out;
    assign alu_ctrl_o      = ALUCtrl;
    assign alu_zero_o      = zero;
    assign alu_lt_o        = lt;
    assign alu_ltu_o       = ltu;
    assign take_branch_o   = take_branch;
    assign branch_target_o = branch_target;
    assign jal_target_o    = jal_target;
    assign jalr_target_o   = jalr_target;
    assign PCSrc_o         = PCSrc;

endmodule