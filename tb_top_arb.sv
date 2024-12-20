// Module name: Testbench for Arbiter Top Module
// Module Description: 
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------
module tb_top_arb;

  // Parameters
  parameter ROWS = 4;
  parameter COLS = 4;

  // Inputs
  logic clk;
  logic reset;
  logic enable;
  logic [ROWS-1:0][COLS-1:0] req_i;

  // Outputs
  logic [ROWS-1:0] x_gnt_o;
  logic [COLS-1:0] y_gnt_o;

  // Internal variables
  logic Grp_release;

  // Instantiate the Top Module
  top_arb #(
    .ROWS(ROWS),
    .COLS(COLS)
  ) dut (
    .clk(clk),
    .reset(reset),
    .req_i(req_i),
    .enable(enable),
    .x_gnt_o(x_gnt_o),
    .y_gnt_o(y_gnt_o)
  );

  // Clock Generation
  initial clk = 0;
  always #5 clk = ~clk; // 10ns clock period

  // Stimulus
  initial begin
    reset = 1;
    enable = 1;
    req_i = 16'b0000_0000_0000_1010;
    #5;
    reset = 0;
    #10;

    req_i = 16'b0000_0000_0101_0000;
    #20;

    req_i = 16'b0000_0011_0000_0000;
    #30;

    req_i = 16'b0101_0000_0000_0000;
    #20;

    $stop;
  end  

endmodule



