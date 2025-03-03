
// Package: asyn_fifo_pkg
// Description: Testbench for Asynchronous FIFO
// Author: 
// Date: 
// Version: 

import asyn_fifo_pkg::*;

module async_fifo_TB;

  logic [DATA_WIDTH-1:0] data_out_o;
  logic full_o;
  logic empty_o;
  logic [DATA_WIDTH-1:0] data_in_i;
  logic w_en_i, wclk_i, wrst_n_i;
  logic r_en_i, rclk_i, rrst_n_i;

  // Fixed-size array for storing written data
  logic [DATA_WIDTH-1:0] wdata_q[0:DEPTH-1];
  int wdata_q_front = 0, wdata_q_back = 0;
  logic [DATA_WIDTH-1:0] wdata;

  // Instantiate the asynchronous FIFO
  asynchronous_fifo as_fifo (
      .wclk_i(wclk_i), 
      .wrst_n_i(wrst_n_i),
      .rclk_i(rclk_i), 
      .rrst_n_i(rrst_n_i),
      .w_en_i(w_en_i),
      .r_en_i(r_en_i),
      .data_in_i(data_in_i),
      .data_out_o(data_out_o),
      .full_o(full_o),
      .empty_o(empty_o)
  );

  // Clock generation
  always #10 wclk_i = ~wclk_i;
  always #35 rclk_i = ~rclk_i;
  
  // Write process
  initial begin
    wclk_i = 1'b0; 
    wrst_n_i = 1'b0;
    w_en_i = 1'b0;
    data_in_i = 0;
    
    repeat(10) @(posedge wclk_i);
    wrst_n_i = 1'b1;

    repeat(2) begin
      for (int i = 0; i < 30; i++) begin
        @(posedge wclk_i);
        if (!full_o) begin
          w_en_i = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (w_en_i) begin
            data_in_i = $urandom;
            wdata_q[wdata_q_back % DEPTH] = data_in_i;
            wdata_q_back++;
          end
        end
      end
      #50;
    end
  end

  // Read process
  initial begin
    rclk_i = 1'b0; 
    rrst_n_i = 1'b0;
    r_en_i = 1'b0;

    repeat(20) @(posedge rclk_i);
    rrst_n_i = 1'b1;

    repeat(2) begin
      for (int i = 0; i < 30; i++) begin
        @(posedge rclk_i);
        if (!empty_o) begin
          r_en_i = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (r_en_i) begin
            wdata = wdata_q[wdata_q_front % DEPTH];
            wdata_q_front++;
            if (data_out_o !== wdata) 
              $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_out_o);
            else 
              $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h", $time, wdata, data_out_o);
          end
        end
      end
      #50;
    end

    $finish;
  end

endmodule
