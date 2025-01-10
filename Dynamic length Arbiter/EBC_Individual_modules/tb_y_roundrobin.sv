// Module name: Row Arbiter TB Module
// Module Description:  generates active row requests to the arbiter
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module tb_y_roundrobin;

  // Parameters for the testbench
  parameter WIDTH = 8;       // Width of the request and grant signals
  parameter y_width = 3;     // Width of the index output
  parameter CLK_PERIOD = 10; // Clock period (in time units)

  // Testbench signals
  logic clk_i;
  logic reset_i;
  logic enable_i;
  logic [WIDTH-1:0] req_i;
  logic [WIDTH-1:0] gnt_o;
  logic [y_width-1:0] yadd_o;

  // Instantiate the y_roundrobin module
  y_roundrobin #(
    .WIDTH(WIDTH),
    .y_width(y_width)
  ) uut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .enable_i(enable_i),
    .req_i(req_i),
    .gnt_o(gnt_o),
    .yadd_o(yadd_o)
  );

  // Clock generation
  always begin
    #(CLK_PERIOD / 2) clk_i = ~clk_i;
  end

  // Testbench logic
  initial begin
    // Initialize signals
    clk_i = 0;
    enable_i = 0;
    req_i = 8'b01000111;

    // Apply reset
    reset_i = 1;
    #10 reset_i = 0;


    req_i = 8'b10010011;
    #10 enable_i = 1;
    #20;


    req_i = 8'b01100100;
    #30;


    req_i = 8'b11010000;
    

    enable_i = 0;
    req_i = 8'b11100010;
    #10;

    enable_i = 1;
    req_i = 8'b11101111;
    #10 reset_i = 1;
    #10 reset_i = 0;
    req_i = 8'b11110010;
    #50;


    #20 reset_i = 1;
    #10 reset_i = 0;
    #50;


    req_i = 8'b10101010;
    #50;
    reset_i = 1;
    #20 reset_i = 0;
    req_i = 8'b01010101;
    #50;


    req_i = 8'b00010000;
    #50;
    req_i = 8'b00000001;
    #50;

    // End simulation
    $stop;
  end
endmodule
