// Package: asyn_fifo_pkg
// Description: Write pointer handler for FIFO, managing write operations and full flag
// Author: 
// Date: 
// Version: 

import asyn_fifo_pkg::*;

module wptr_handler (
    input  logic               wclk_i,         // Write clock
    input  logic               wrst_n_i,       // Active-low reset
    input  logic               w_en_i,         // Write enable
    input  logic [PTR_WIDTH:0] g_rptr_sync_i,  // Synchronized read pointer in Gray code
    output logic [PTR_WIDTH:0] b_wptr_o,       // Write pointer in binary
    output logic [PTR_WIDTH:0] g_wptr_o,       // Write pointer in Gray code
    output logic               full_o          // FIFO full flag
);

    logic [PTR_WIDTH:0] b_wptr_next;
    logic [PTR_WIDTH:0] g_wptr_next;
    logic wfull;

    // Compute next write pointer values
    assign b_wptr_next = b_wptr_o + (w_en_i & !full_o);
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next; // Binary to Gray conversion

    // FIFO full condition
    assign wfull = (g_wptr_next == {~g_rptr_sync_i[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync_i[PTR_WIDTH-2:0]});

    // Update write pointers on clock edge
    always_ff @(posedge wclk_i or negedge wrst_n_i) begin
        if (!wrst_n_i) begin
            b_wptr_o <= '0;
            g_wptr_o <= '0;
        end else begin
            b_wptr_o <= b_wptr_next;
            g_wptr_o <= g_wptr_next;
        end
    end
    
    // Update full flag
    always_ff @(posedge wclk_i or negedge wrst_n_i) begin
        if (!wrst_n_i) 
            full_o <= 1'b0;
        else 
            full_o <= wfull;
    end

endmodule
