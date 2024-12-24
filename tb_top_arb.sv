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
      enable = 0;
      req_i= 16'b0000_0000_0000_0000;     
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
    enable = 0;

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













// // Module name: Testbench for Arbiter Top Module
// // Module Description: 
// // Author: 
// // Date: 
// // Version: 
// //-----------------------------------------------------------------------------------------------------------------
// module tb_top_arb;

//   // Parameters
//   parameter ROWS = 4;
//   parameter COLS = 4;

//   // Inputs
//   logic clk_i;
//   logic reset_i;
//   logic enable_i;
//   logic [ROWS-1:0][COLS-1:0] req_i;

//   // Outputs
//   logic [ROWS-1:0] x_gnt_o;
//   logic [COLS-1:0] y_gnt_o;

//   // Internal variables
//   logic Grp_release;

//   // Instantiate the Top Module
//   top_arb #(
//     .ROWS(ROWS),
//     .COLS(COLS)
//   ) dut (
//     .clk_i(clk_i),
//     .reset_i(reset_i),
//     .req_i(req_i),
//     .enable_i(enable_i),
//     .x_gnt_o(x_gnt_o),
//     .y_gnt_o(y_gnt_o)
//   );

//   // Clock Generation
//   initial clk_i = 0;
//   always #5 clk_i = ~clk_i; // 10ns clock period

//   // Stimulus
//   initial begin
// <<<<<<< HEAD
//     reset_i = 1;
//     enable_i = 1;
//     req_i = 16'b0000_0000_1110_1010;
//     #5;
//     reset_i = 0;
// =======
//     reset = 1;
//     enable = 1;
// >>>>>>> 45c8ac03921747f7d73cce288ba4c744e2c0c83b
//     #10;
//     reset = 0;
//     #15;
//     req_i = 16'b0000_1010_0000_1010;
    

// <<<<<<< HEAD
//     req_i = 16'b0000_0000_0101_0001;
// =======
//   /*  req_i = 16'b0000_0000_0101_0000;
// >>>>>>> 45c8ac03921747f7d73cce288ba4c744e2c0c83b
//     #20;

//     req_i = 16'b0000_0011_1000_0000;
//     #30;

// <<<<<<< HEAD
//     req_i = 16'b1101_0000_00011_000;
//     #20;

// =======
//     req_i = 16'b0101_0000_0000_0000;
    
// */#20;
// >>>>>>> 45c8ac03921747f7d73cce288ba4c744e2c0c83b
//     $stop;
//   end  

// endmodule



