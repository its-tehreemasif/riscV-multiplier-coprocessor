`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 09:40:52 AM
// Design Name: 
// Module Name: Multiplier
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


// 32x32 -> 64 iterative multiplier with signed/unsigned support and handshake interface.
// op_sel defines signed/unsigned mode for operands:
// 2'b00 = unsigned * unsigned
// 2'b01 = signed   * unsigned (A signed, B unsigned)
// 2'b10 = unsigned * signed   (A unsigned, B signed)
// 2'b11 = signed   * signed

module Multiplier (
    input  logic         clk,        // clock signal
    input  logic         rst,        // synchronous active-high reset
    input  logic         start,      // pulse to start operation when !busy
    input  logic [1:0]   op_sel,     // operation mode (signed/unsigned)
    input  logic [31:0]  A,          // operand A
    input  logic [31:0]  B,          // operand B
    output logic [63:0]  result,     // 64-bit multiplication result
    output logic         busy,       // busy signal while running
    output logic         done        // done signal when result ready
);

    // FSM states
    typedef enum logic [1:0] {IDLE=2'b00, RUN=2'b01, DONE=2'b10} state_t;
    // FSM state definition using enum:
    // - Creates a 2-bit state type (logic [1:0]) for the FSM
    // - IDLE  = 2'b00 ? waiting for start signal
    // - RUN   = 2'b01 ? multiplication in progress
    // - DONE  = 2'b10 ? multiplication completed, result ready
    // Using enum improves readability and avoids using raw binary values
    state_t state, next_state;  // current and next FSM states

    // Internal registers
    logic [31:0] a_reg, b_reg;      // working copies of operands
    logic [63:0] acc;               // accumulator for partial products
    logic [5:0]  cnt;               // iteration counter (0-31 for 32-bit multiplication)
    logic        sign_a, sign_b;    // flags for negative operands
    logic        result_negative;   // flag for final result sign
    logic [31:0] abs_a, abs_b;      // absolute values of operands

    // Combinational logic: Determine signs and absolute values
    always_comb begin
        // Determine if A and B are negative depending on op_sel
        sign_a = op_sel[1] ? A[31] : 1'b0; // if A is signed, use MSB
        sign_b = op_sel[0] ? B[31] : 1'b0; // if B is signed, use MSB

        // Compute absolute values using two's complement if negative
        abs_a = (op_sel[1] && A[31]) ? (~A + 32'd1) : A; // |A|
        abs_b = (op_sel[0] && B[31]) ? (~B + 32'd1) : B; // |B|
    end

    // FSM state register (sequential)
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;          // reset FSM to IDLE
        else
            state <= next_state;    // update to next state
    end

    // Next-state logic and handshake outputs
    always_comb begin
        // Default assignments
        next_state = state;  // stay in current state by default
        busy       = 1'b0;   // not busy by default
        done       = 1'b0;   // done low by default

        case (state)
            IDLE: begin
                busy = 1'b0; // multiplier is idle
                done = 1'b0; // result not ready
                if (start)   // wait for start pulse
                    next_state = RUN;
            end

            RUN: begin
                busy = 1'b1; // multiplier is working
                // After 32 iterations, multiplication is complete
                if (cnt == 6'd31)
                    next_state = DONE;
            end

            DONE: begin
                done = 1'b1;  // result is ready
                // Wait for start to go low to acknowledge completion
                if (!start)
                    next_state = IDLE;
            end

            default: next_state = IDLE; // safety: default to IDLE
        endcase
    end

    // Datapath sequential logic
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset all registers
            a_reg           <= 32'd0;
            b_reg           <= 32'd0;
            acc             <= 64'd0;
            cnt             <= 6'd0;
            result          <= 64'd0;
            result_negative <= 1'b0;
        end
        else begin
            case (state)
                // IDLE state
                IDLE: begin
                    if (start) begin
                        a_reg <= abs_a;        // load absolute A
                        b_reg <= abs_b;        // load absolute B
                        acc   <= 64'd0;        // clear accumulator
                        cnt   <= 6'd0;         // reset counter
                        // final result sign = A_sign XOR B_sign
                        result_negative <= sign_a ^ sign_b;
                    end
                end

                // RUN state (iterative multiplication)
                RUN: begin
                    // If LSB of b_reg is 1, add shifted a_reg to accumulator
                    if (b_reg[0])
                        acc <= acc + {32'd0, a_reg}; // extend a_reg to 64-bit

                    // Shift for next iteration
                    a_reg <= a_reg << 1; // shift A left
                    b_reg <= b_reg >> 1; // shift B right

                    cnt <= cnt + 6'd1;   // increment counter
                end

                // DONE state
                DONE: begin
                    // Apply final sign to result
                    if (result_negative)
                        result <= ~acc + 64'd1; // convert to negative
                    else
                        result <= acc;           // positive result
                    // values retained until next start
                end

                default: ; // safety: do nothing
            endcase
        end
    end

endmodule

