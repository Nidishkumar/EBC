// Package: asyn_fifo_pkg
// Description: Asynchronous FIFO with read and write operations synchronized across clock domains
// Author: 
// Date: 
// Version: 

import asyn_fifo_pkg::*;

module asynchronous_fifo (
    input  logic               wclk_i,         // Write clock
    input  logic               wrst_n_i,       // Active-low reset for write domain
    input  logic               rclk_i,         // Read clock
    input  logic               rrst_n_i,       // Active-low reset for read domain
    input  logic               w_en_i,         // Write enable
    input  logic               r_en_i,         // Read enable
    input  logic [DATA_WIDTH-1:0] data_in_i,   // Data input
    output logic [DATA_WIDTH-1:0] data_out_o,  // Data output
    output logic               full_o,         // FIFO full flag
    output logic               empty_o         // FIFO empty flag
);

    localparam int PTR_WIDTH = $clog2(DEPTH);

    logic [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
    logic [PTR_WIDTH:0] b_wptr, b_rptr;
    logic [PTR_WIDTH:0] g_wptr, g_rptr;

    // Synchronizing write pointer to read clock domain
    synchronizer sync_wptr (
        .clk_i(rclk_i), 
        .rst_n_i(rrst_n_i), 
        .d_in_i(g_wptr), 
        .d_out_o(g_wptr_sync)
    );

    // Synchronizing read pointer to write clock domain
    synchronizer sync_rptr (
        .clk_i(wclk_i), 
        .rst_n_i(wrst_n_i), 
        .d_in_i(g_rptr), 
        .d_out_o(g_rptr_sync)
    );

    // Write Pointer Handler
    wptr_handler wptr_h (
        .wclk_i(wclk_i), 
        .wrst_n_i(wrst_n_i), 
        .w_en_i(w_en_i),
        .g_rptr_sync_i(g_rptr_sync),
        .b_wptr_o(b_wptr), 
        .g_wptr_o(g_wptr),
        .full_o(full_o)
    );

    // Read Pointer Handler
    rptr_handler rptr_h (
        .rclk_i(rclk_i), 
        .rrst_n_i(rrst_n_i), 
        .r_en_i(r_en_i),
        .g_wptr_sync_i(g_wptr_sync),
        .b_rptr_o(b_rptr), 
        .g_rptr_o(g_rptr),
        .empty_o(empty_o)
    );

    // FIFO Memory
    fifo_mem fifom (
        .wclk_i(wclk_i), 
        .w_en_i(w_en_i), 
        .rclk_i(rclk_i), 
        .r_en_i(r_en_i),
        .b_wptr_i(b_wptr), 
        .b_rptr_i(b_rptr),
        .data_in_i(data_in_i),
        .full_i(full_o),
        .empty_i(empty_o),
        .data_out_o(data_out_o)
    );

endmodule
