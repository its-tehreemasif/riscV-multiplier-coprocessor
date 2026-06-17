`timescale 1ns/1ps
///////////////////////////////////

module tb_TOP_MODULE;

  // Inputs
  logic clk;
  logic reset;

  // Outputs
  logic [31:0] pc_o;
  logic [31:0] instruction_o;
  logic [31:0] alu_result_o;
  logic [31:0] write_back_o;
  logic        RegWrite_o;
  logic        MemRead_o;
  logic        MemWrite_o;

  logic        Branch_o;
  logic        ALUSrc_o;
  logic [1:0]  ALUOp_o;
  logic [1:0]  MemtoReg_o;
  logic [31:0] rs1_data_o;
  logic [31:0] rs2_data_o;
  logic [31:0] imm_out_o;
  logic [3:0]  alu_ctrl_o;
  logic        alu_zero_o;
  logic        alu_lt_o;
  logic        alu_ltu_o;
  logic        take_branch_o;
  logic [31:0] branch_target_o;
  logic [31:0] jal_target_o;
  logic [31:0] jalr_target_o;
  logic        PCSrc_o;

  // DUT
  TOP_MODULE dut (
    .clk(clk),
    .reset(reset),

    .pc_o(pc_o),
    .instruction_o(instruction_o),
    .alu_result_o(alu_result_o),
    .write_back_o(write_back_o),
    .RegWrite_o(RegWrite_o),
    .MemRead_o(MemRead_o),
    .MemWrite_o(MemWrite_o),

    .Branch_o(Branch_o),
    .ALUSrc_o(ALUSrc_o),
    .ALUOp_o(ALUOp_o),
    .MemtoReg_o(MemtoReg_o),
    .rs1_data_o(rs1_data_o),
    .rs2_data_o(rs2_data_o),
    .imm_out_o(imm_out_o),
    .alu_ctrl_o(alu_ctrl_o),
    .alu_zero_o(alu_zero_o),
    .alu_lt_o(alu_lt_o),
    .alu_ltu_o(alu_ltu_o),
    .take_branch_o(take_branch_o),
    .branch_target_o(branch_target_o),
    .jal_target_o(jal_target_o),
    .jalr_target_o(jalr_target_o),
    .PCSrc_o(PCSrc_o)
  );

  // Clock: 10ns period
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Reset: hold for a few cycles
  initial begin
    reset = 1'b1;
    repeat (4) @(posedge clk);
    reset = 1'b0;
  end

  // Wave dump (for GTKWave / Icarus / Verilator)
  initial begin
    $dumpfile("tb_TOP_MODULE.vcd");
    $dumpvars(0, tb_TOP_MODULE);

    // Optional: also dump inside DUT hierarchy (more visibility)
    $dumpvars(0, dut);
  end

  // Optional memory init (only if your memories expose arrays)
  // Fix the hierarchical array names to match your modules.
  /*
  initial begin
    wait(reset == 1'b0);
    $readmemh("midd.mem",   dut.imem.mem);
    $readmemh("rfdata.mem", dut.rf.regs);
    $readmemh("dmem.mem",   dut.data_mem.mem);
  end
  */

  // End simulation after N cycles
  initial begin
    wait(reset == 1'b0);
    repeat (300) @(posedge clk);
    $finish;
  end

endmodule
