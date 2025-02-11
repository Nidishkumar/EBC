// Module name: Row Arbiter TB Module
// Module Description:  generates active row requests to the arbiter
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module tb_x_roundrobin;

  // Parameters for the testbench
  parameter WIDTH = 8;        // Width of the request and grant signals
  parameter x_width = 3;      // Width of the index output
  parameter CLK_PERIOD = 10;  // Clock period (in time units)

  // Testbench signals
  logic clk_i;
  logic reset_i;
  logic enable_i;
  logic [WIDTH-1:0] req_i;
  logic [WIDTH-1:0] gnt_o;
  logic [x_width-1:0] xadd_o;

  // Instantiate the x_roundrobin module
  x_roundrobin #(
    .WIDTH(WIDTH),
    .x_width(x_width)
  ) uut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .enable_i(enable_i),
    .req_i(req_i),
    .x_gnt_o(gnt_o),
    .xadd_o(xadd_o)
  );

  // Clock generation
  always begin
    #(CLK_PERIOD / 2) clk_i = ~clk_i;
  end

  // Testbench logic
  initial begin
    // Initialize signals
    clk_i = 0;
    enable_i = 1'b0;
    req_i = 8'b01000111;

    // Apply reset
    reset_i = 1'b1;
    #10 reset_i = 0;

    // Test case 1
    req_i = 8'b10010011;
    #10 enable_i = 1'b1;
    #20;

    // Test case 2
    req_i = 8'b00110010; 
    #20;

    // Test case 3
    enable_i = 1'b0;
    req_i = 8'b01100000;
    #10;

    // Test case 4
    req_i = 8'b11101111;
    #10 enable_i = 1'b1;
    #10 reset_i = 1;
    #10 reset_i = 0;
    req_i = 8'b11110000;
    #50;

    // Test case 5
    #20 reset_i = 0;
    #50;

    // Test case 6
    req_i = 8'b10101010;
    #50;
    reset_i = 1;
    #20 reset_i = 0;
    req_i = 8'b01010101;
    #50;

    // Test case 7
    req_i = 8'b00010000; 
    #50;
    req_i = 8'b00000001;
    #50;

    // End simulation
    $stop;
  end
endmodule

