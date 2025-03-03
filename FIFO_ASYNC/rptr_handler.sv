// Package: asyn_fifo_pkg
// Description: Read pointer handler for FIFO, managing read operations and empty flag
// Author: 
// Date: 
// Version: 

import asyn_fifo_pkg::*;

module rptr_handler (
    input  logic               rclk_i,         // Read clock
    input  logic               rrst_n_i,       // Active-low reset
    input  logic               r_en_i,         // Read enable
    input  logic [PTR_WIDTH:0] g_wptr_sync_i,  // Synchronized write pointer in Gray code
    output logic [PTR_WIDTH:0] b_rptr_o,       // Read pointer in binary
    output logic [PTR_WIDTH:0] g_rptr_o,       // Read pointer in Gray code
    output logic               empty_o         // FIFO empty flag
);

    logic [PTR_WIDTH:0] b_rptr_next;
    logic [PTR_WIDTH:0] g_rptr_next;
    logic rempty;

    // Calculate next read pointer values
    assign b_rptr_next = b_rptr_o + (r_en_i & !empty_o);
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next; // Binary to Gray conversion
    assign rempty      = (g_wptr_sync_i == g_rptr_next);   // FIFO empty condition

    // Update read pointers on clock edge
    always_ff @(posedge rclk_i or negedge rrst_n_i) begin
        if (!rrst_n_i) begin
            b_rptr_o <= '0;
            g_rptr_o <= '0;
        end else begin
            b_rptr_o <= b_rptr_next;
            g_rptr_o <= g_rptr_next;
        end
    end

    // Update empty flag
    always_ff @(posedge rclk_i or negedge rrst_n_i) begin
        if (!rrst_n_i) 
            empty_o <= 1'b1;
        else        
            empty_o <= rempty;
    end

endmodule
