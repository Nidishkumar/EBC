// Module name: Testbench for polarity_selector module
// Module Description: 
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------

module tb_polarity_selector;

  // Parameters for the testbench
  parameter POLARITY = 2;      // Width of the req_i signal (2-bit input)
  parameter CLK_PERIOD = 10;   // Clock period (in time units)

  // Testbench signals
  logic clk_i;
  logic [POLARITY-1:0] req_i;      // 2-bit input request signal
  logic polarity_o;                // Output signal representing the selected polarity

  // Instantiate the polarity_selector module
  polarity_selector #(
    .POLARITY(POLARITY)
  ) uut (
    .req_i(req_i),
    .polarity_o(polarity_o)
  );

  // Clock generation
  always begin
    #(CLK_PERIOD / 2) clk_i = ~clk_i;
  end

  // Testbench logic
  initial begin
    // Initialize signals
    clk_i = 0;
    req_i = 2'b00;  

    #5;

    req_i = 2'b00;
    #20;

    req_i = 2'b01;
    #20;

    req_i = 2'b10;
    #20;

    req_i = 2'b10;
    #20;

    req_i = 2'b00;
    #20;
    req_i = 2'b01;
    #20;

    req_i = 2'b10;
    #20;
    req_i = 2'b00;
    #20;

    req_i = 2'b10;
    #20;
    req_i = 2'b00;
    #20;

    req_i = 2'b01;
    #20;
    req_i = 2'b01;
    #20;
    req_i = 2'b00;
    #20;

    // End simulation
    $stop;
  end

endmodule
