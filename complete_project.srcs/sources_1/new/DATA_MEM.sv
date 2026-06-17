`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 11:23:00 PM
// Design Name: 
// Module Name: DATA_MEM
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


    module DATA_MEM#(
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH = 16
   )(
    input logic clk,
    input logic mem_read,
    input logic mem_write,
    input logic [5:0] addr,
    input logic [DATA_WIDTH-1:0] write_data,
    input logic [2:0] func3,
    output logic [DATA_WIDTH-1:0] read_data);
    logic [7:0] memory [0:(MEM_DEPTH*4)-1];  
    always_comb begin
        read_data = 32'd0;
        if (mem_read) begin
            case (func3)
                3'b000: read_data = $signed({{24{memory[addr][7]}}, memory[addr]});
                3'b001: read_data = $signed({{16{memory[addr+1][7]}}, memory[addr+1], memory[addr]});
                3'b010: read_data = {memory[addr+3], memory[addr+2], memory[addr+1],
                 memory[addr]};
                3'b100: read_data = {24'd0, memory[addr]};
                3'b101: read_data = {16'd0, memory[addr+1], memory[addr]};
                default: read_data = 32'd0;
            endcase
        end
    end
 always_ff @(posedge clk) begin
        if (mem_write) begin
            case (func3)
                3'b000: memory[addr] <= write_data[7:0];
                3'b001: begin
                    memory[addr] <= write_data[7:0];
                    memory[addr+1] <= write_data[15:8];
                end
                3'b010: begin
                    memory[addr]   <= write_data[7:0];
                    memory[addr+1] <= write_data[15:8];
                    memory[addr+2] <= write_data[23:16];
                    memory[addr+3] <= write_data[31:24];
                end
            endcase
        end
    end
endmodule
