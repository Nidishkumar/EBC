// Package: asyn_fifo_pkg
// Description: Synchronizer module for metastability reduction
// Author: 
// Date: 
// Version: 

import asyn_fifo_pkg::*;

module synchronizer (
    input  logic               clk_i, 
    input  logic               rst_n_i,
    input  logic [PTR_WIDTH:0] d_in_i,
    output logic [PTR_WIDTH:0] d_out_o
);

    logic [PTR_WIDTH:0] q1, q2;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            q1 <= '0;
            q2 <= '0;
        end else begin
            q1 <= d_in_i;
            q2 <= q1;
        end
    end

    assign d_out_o = q2;

endmodule
