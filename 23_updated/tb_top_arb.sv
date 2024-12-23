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
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
  end

  // Tasks
  task initialize;
    begin
     // reset = 1;
      enable = 1;
      req_i= 16'b0000_0000_0000_1001;     
    end
  endtask

  task apply_reset;
    begin
      reset = 1;
      #10;
      reset = 0;
      #10;
    end
  endtask

  task apply_request(input [ROWS-1:0][COLS-1:0] request, input logic en);
    begin
      enable = en;
      req_i = request;
    end
  endtask

  // Test procedure
  initial begin

    // Initialize inputs
    initialize;

    // Reset the DUT
    apply_reset;

    // Test 1: Single request active
    apply_request({4'b0000, 4'b0000, 4'b0000, 4'b1101}, 1);
          #30;

    // Test 2: Multiple requests active
    apply_request({4'b0000, 4'b1010, 4'b1010, 4'b0000}, 1);
          #70;

    // Test 3: Enable deactivated
    apply_request({4'b0000, 4'b1111, 4'b0000, 4'b0101}, 0);
      #70;

    // Test 4: 
    apply_request({4'b0110, 4'b0011, 4'b0000, 4'b1000}, 1);
    reset = 1;
    #20;
	 reset = 0;
     #70;

    // Test 5: Another specific pattern
    apply_request({4'b0101, 4'b0000, 4'b1101, 4'b1110}, 1);

    // End simulation
    #100 $stop;
  end

endmodule


