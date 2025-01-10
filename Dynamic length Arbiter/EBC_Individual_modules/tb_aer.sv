// Module name: TB of Address event module
// Module Description:  
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module tb_aer;

  // Inputs
  logic [2:0] x_add_i;
  logic [2:0] y_add_i;
  logic [31:0] timestamp_i;
  logic polarity_i;

  // Output
  logic [38:0] data_out_o;

  // Instantiate the DUT (Device Under Test)
  aer uut (
    .x_add_i(x_add_i),
    .y_add_i(y_add_i),
    .timestamp_i(timestamp_i),
    .polarity_i(polarity_i),
    .data_out_o(data_out_o)
  );

  // Test Stimulus
  initial begin

    // Apply test cases
    x_add_i = 3'b001;
    y_add_i = 3'b010;
    timestamp_i = 32'h4;
    polarity_i = 1'b0;
    #10;

    x_add_i = 3'b111;
    y_add_i = 3'b000;
    timestamp_i = 32'h8;
    polarity_i = 1'b1;
    #10;

    x_add_i = 3'b100;
    y_add_i = 3'b101;
    timestamp_i = 32'hF;
    polarity_i = 1'b0;
    #10;

    x_add_i = 3'b011;
    y_add_i = 3'b011;
    timestamp_i = 32'hA;
    polarity_i = 1'b1;
    #10;

    // End simulation
    $finish;
  end

endmodule