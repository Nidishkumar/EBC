// Package: asyn_fifo_pkg
// Description: FIFO memory storage module for read and write operations
// Author: 
// Date: 
// Version: 

import asyn_fifo_pkg::*;

module fifo_mem (
    input  logic               wclk_i,       // Write clock
    input  logic               w_en_i,       // Write enable
    input  logic               rclk_i,       // Read clock
    input  logic               r_en_i,       // Read enable
    input  logic [PTR_WIDTH:0] b_wptr_i,     // Write pointer in binary
    input  logic [PTR_WIDTH:0] b_rptr_i,     // Read pointer in binary
    input  logic [DATA_WIDTH-1:0] data_in_i, // Data input
    input  logic               full_i,       // FIFO full flag
    input  logic               empty_i,      // FIFO empty flag
    output logic [DATA_WIDTH-1:0] data_out_o // Data output
);

    logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

    // Write operation
    always_ff @(posedge wclk_i) begin
        if (w_en_i && !full_i) begin
            fifo[b_wptr_i[PTR_WIDTH-1:0]] <= data_in_i;
        end
    end

    // Read operation
    assign data_out_o = fifo[b_rptr_i[PTR_WIDTH-1:0]];

endmodule
