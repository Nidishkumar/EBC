// Module name: tb Module
// Module Description: Round-Robin Arbiter for request prioritization and grant assignment
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*; 

 module tb_top_arb;
  // Inputs
  logic clk_i;
  logic reset_i;
  logic enable_i;
  logic [COLS-1:0][POLARITY-1:0] req_i[ROWS-1:0];

  // Outputs
  logic [ROWS-1:0][COLS-1:0] gnt_o;
  //logic [COLS-1:0] y_gnt_o;
  logic polarity_o;

  // Instantiate the Top Module
  top_arb  dut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .req_i(req_i),
    .enable_i(enable_i),
    .gnt_o(gnt_o),
	 .polarity_o(polarity_o)
  );

  // Clock Generation
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i; //  clock period
  end
  
 always_ff @(posedge clk_i)
 begin
  for (int i = 0; i < ROWS; i++) begin
    for (int j = 0; j < COLS; j++) begin
      if (gnt_o[i][j] == 1'b1) begin
        req_i[i][j] <= 1'b0; // Deassert request upon grant
      end
    end
  end
end 
  // Tasks
  task initialize;
    begin
      enable_i = 0;
      req_i = {{2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}}; 

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

  task apply_request(input [COLS-1:0][POLARITY-1:0] request[ROWS-1:0], input logic en);
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
    apply_request({{2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b01, 2'b00, 2'b01, 2'b00, 2'b10, 2'b10, 2'b01}}, 1);
    #30;

    // Test 2: Multiple requests active
    apply_request(
	               {{2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00}, 
               {2'b10, 2'b10, 2'b10, 2'b00, 2'b00, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01}, 
               {2'b00, 2'b01, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b01}, 
               {2'b00, 2'b00, 2'b10, 2'b01, 2'b00, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}}, 1);
    #30;
    
	 apply_reset;
    apply_request(
	               {{2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b10, 2'b01}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01}, 
               {2'b00, 2'b10, 2'b00, 2'b10, 2'b10, 2'b10, 2'b01, 2'b01}, 
               {2'b00, 2'b00, 2'b01, 2'b01, 2'b00, 2'b10, 2'b00, 2'b01}, 
               {2'b10, 2'b10, 2'b00, 2'b00, 2'b01, 2'b00, 2'b00, 2'b10}}, 1);
    #60;
	 apply_request(
	               {{2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b01, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b01, 2'b00, 2'b01}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b01, 2'b01, 2'b10, 2'b01}, 
               {2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b10}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b01, 2'b00, 2'b00, 2'b00, 2'b00, 2'b10, 2'b00}}, 0);
    #100;
     apply_request(
	               {{2'b10, 2'b10, 2'b00, 2'b10, 2'b00, 2'b01, 2'b00, 2'b00}, 
               {2'b01, 2'b00, 2'b00, 2'b00, 2'b10, 2'b01, 2'b10, 2'b00}, 
               {2'b01, 2'b10, 2'b10, 2'b00, 2'b01, 2'b00, 2'b10, 2'b10}, 
               {2'b10, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b10, 2'b01, 2'b10, 2'b01, 2'b01}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b01, 2'b00, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01}}, 1);
    #70;
    // End simulation
    $stop;
  end

endmodule 