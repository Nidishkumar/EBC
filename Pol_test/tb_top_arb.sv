// Module name: Testbench for Arbiter Top Module
// Module Description: 
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------
module tb_top_arb;

  // Parameters
  parameter ROWS = 8;
  parameter COLS = 8;

  // Inputs
  logic clk_i;
  logic reset_i;
  logic enable_i;
  logic [ROWS-1:0][COLS-1:0] req_i;

  // Outputs
  logic [ROWS-1:0] x_gnt_o;
  logic [COLS-1:0] y_gnt_o;

  // Instantiate the Top Module
  top_arb #(
    .ROWS(ROWS),
    .COLS(COLS)
  ) dut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .req_i(req_i),
    .enable_i(enable_i),
    .x_gnt_o(x_gnt_o),
    .y_gnt_o(y_gnt_o)
  );

  // Clock Generation
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i; // 10ns clock period
  end

  // Tasks
  task initialize;
    begin
      enable_i = 0;
      req_i = 64'b0; // Default no requests
    end
  endtask

  task apply_reset;
    begin
      reset_i = 1;
      #10;
      reset_i = 0;
      #10;
    end
  endtask

  task apply_request(input [ROWS-1:0][COLS-1:0] request, input logic en);
    begin
      enable_i = en;
      req_i = request;
    end
  endtask

  // Test procedure
  initial begin

    // Initialize inputs
    initialize;

    // Reset the DUT
    apply_reset;
    enable_i = 0;

    // Test 1: Single request active
    apply_request({8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b11010001}, 1);
    #50;

    // Test 2: Multiple requests active
    apply_request({8'b00000000, 8'b10101010, 8'b11100011, 8'b00000000, 8'b00001111, 8'b01010101, 8'b00110011, 8'b00000000}, 1);
    #70;

    // Test 3: Enable deactivated
    apply_request({8'b00000000, 8'b11111111, 8'b00000000, 8'b10101010, 8'b00101010, 8'b00000000, 8'b10011001, 8'b11000011}, 0);
    #70;

    // Test 4: Reset in between operation
    apply_request({8'b11100011, 8'b01100110, 8'b00011110, 8'b01010101, 8'b11001100, 8'b11110000, 8'b00001111, 8'b10101010}, 1);
    reset_i = 1;
    #20;
    reset_i = 0;
    #70;

    // Test 5: Another specific pattern
    apply_request({8'b00011100, 8'b11110011, 8'b10101010, 8'b11001100, 8'b00000001, 8'b00001111, 8'b11100000, 8'b01010101}, 1);
    #100;

    // End simulation
    $stop;
  end

endmodule

// module tb_top_arb;

//   // Parameters
//   parameter ROWS = 4;
//   parameter COLS = 4;

//   // Inputs
//   logic clk;
//   logic reset;
//   logic enable;
//   logic [ROWS-1:0][COLS-1:0] req_i;

//   // Outputs
//   logic [ROWS-1:0] x_gnt_o;
//   logic [COLS-1:0] y_gnt_o;

//   // Instantiate the Top Module
//   top_arb #(
//     .ROWS(ROWS),
//     .COLS(COLS)
//   ) dut (
//     .clk(clk),
//     .reset(reset),
//     .req_i(req_i),
//     .enable(enable),
//     .x_gnt_o(x_gnt_o),
//     .y_gnt_o(y_gnt_o)
//   );

//   // Clock Generation
//   initial begin
//     clk = 0;
//     forever #5 clk = ~clk; // 10ns clock period
//   end

//   // Tasks
//   task initialize;
//     begin
//       enable = 0;
//       req_i= 16'b0000_0000_0000_0000;     
//     end
//   endtask

//   task apply_reset;
//     begin
//       reset = 1;
//       #10;
//       reset = 0;
//       #10;
//     end
//   endtask

//   task apply_request(input [ROWS-1:0][COLS-1:0] request, input logic en);
//     begin
//       enable = en;
//       req_i = request;
//     end
//   endtask

//   // Test procedure
//   initial begin

//     // Initialize inputs
//     initialize;

//     // Reset the DUT
//     apply_reset;
//     enable = 0;

//     // Test 1: Single request active
//     apply_request({4'b0000, 4'b0000, 4'b0000, 4'b1101}, 1);
//           #30;

//     // Test 2: Multiple requests active
//     apply_request({4'b0000, 4'b1010, 4'b1010, 4'b0000}, 1);
//           #70;

//     // Test 3: Enable deactivated
//     apply_request({4'b0000, 4'b1111, 4'b0000, 4'b0101}, 0);
//       #70;

//     // Test 4: 
//     apply_request({4'b0110, 4'b0011, 4'b0000, 4'b1000}, 1);
//     reset = 1;
//     #20;
// 	 reset = 0;
//      #70;

//     // Test 5: Another specific pattern
//     apply_request({4'b0101, 4'b0000, 4'b1101, 4'b1110}, 1);

//     // End simulation
//     #100 $stop;
//   end

// endmodule