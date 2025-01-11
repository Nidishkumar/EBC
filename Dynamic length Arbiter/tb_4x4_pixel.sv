//------------------------------------------------------------------------------------------------------------------
// Module name: tb Module
// Module Description: Round-Robin Arbiter for request prioritization and grant assignment
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

module tb_4x4_pixel;

  //----------- Inputs Declaration ----------------------------------------------------------------------------------------
  logic clk_i;
  logic reset_i;
  logic enable_i;
  logic [COLS-1:0][POLARITY-1:0] req_i[ROWS-1:0];

  //----------- Outputs Declaration ---------------------------------------------------------------------------------------
  logic [ROWS-1:0][COLS-1:0] gnt_o;
  logic [WIDTH-1:0] data_out_o;

  //----------- Instantiate the Top Module --------------------------------------------------------------------------------
  top_arb dut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .req_i(req_i),
    .enable_i(enable_i),
    .gnt_o(gnt_o),
    .data_out_o(data_out_o)
  );

  //-----------Clock Generation -------------------------------------------------------------------------------------------
  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i; // 10ns clock period
  end

  //----------- Request Deassertion Logic ----------------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    for (int i = 0; i < ROWS; i++) begin
      for (int j = 0; j < COLS; j++) begin
        if (gnt_o[i][j] == 1'b1) begin
          req_i[i][j] <= 1'b0; // Deassert request upon grant
        end
      end
    end
  end

  
  //----------- Initialize inputs ----------------------------------------------------------------------------------------
  task initialize;
    begin
      enable_i = 1;
      req_i = { 
        {2'b10, 2'b00, 2'b00, 2'b00}, 
        {2'b00, 2'b10, 2'b00, 2'b00}, 
        {2'b00, 2'b00, 2'b10, 2'b00}, 
        {2'b00, 2'b10, 2'b00, 2'b00} }; // Initialize all requests to 0
    end
  endtask

  //----------- Apply Reset Task --------------------------------------------------------------------------------------
  task apply_reset;
    begin
      reset_i = 1;
      #10;
      reset_i = 0;
      #10;
    end
  endtask

  //----------- Apply Request Task --------------------------------------------------------------------------------------
  task apply_request(input [COLS-1:0][POLARITY-1:0] request[ROWS-1:0], input logic en);
    begin
      enable_i = en;
      req_i = request;
    end
  endtask

  //----------- Test Procedure ---------------------------------------------------------------------------------------
  initial begin
    // Initialize inputs
    initialize;
    reset_i = 0;
    #10; 

    // Apply reset
    enable_i = 1;
    apply_reset;
    #20;

    //----------- Test 1: Pixel has one active event in each row ---------------------------------------------------
    apply_request({ 
      {2'b10, 2'b00, 2'b00, 2'b00}, 
      {2'b00, 2'b10, 2'b00, 2'b00}, 
      {2'b00, 2'b00, 2'b10, 2'b00}, 
      {2'b00, 2'b00, 2'b00, 2'b10}}, 1);
    #80;

    //----------- Test 2: Random events in pixel ------------------------------------------------------------------
    apply_request({ 
      {2'b10, 2'b10, 2'b00, 2'b10}, 
      {2'b10, 2'b00, 2'b10, 2'b01}, 
      {2'b01, 2'b00, 2'b00, 2'b01}, 
      {2'b00, 2'b01, 2'b00, 2'b01}}, 1);
    #70;

    //----------- Test 3: No active requests ------------------------------------------------------------------------
    apply_request({ 
      {2'b00, 2'b00, 2'b00, 2'b00}, 
      {2'b00, 2'b00, 2'b00, 2'b00}, 
      {2'b00, 2'b00, 2'b00, 2'b00}, 
      {2'b00, 2'b00, 2'b00, 2'b00}}, 1);
    #30;

    //-----------xxx Test 4: All rows have active events -----------------------------------------------------------
    apply_request({ 
      {2'b10, 2'b01, 2'b01, 2'b10}, 
      {2'b01, 2'b10, 2'b00, 2'b10}, 
      {2'b01, 2'b10, 2'b01, 2'b10}, 
      {2'b10, 2'b10, 2'b01, 2'b10}}, 1);
    #70;

    //----------- Enable Off-On Transition -------------------------------------------------------------------------
    enable_i = 0;
    #20;
    enable_i = 1;

    //----------- Test 5: Alternate row has active  requests --------------------------------------------------------
    apply_request({ 
      {2'b00, 2'b00, 2'b00, 2'b00}, 
      {2'b10, 2'b10, 2'b00, 2'b10}, 
		{2'b10, 2'b01, 2'b10, 2'b01},
      {2'b00, 2'b00, 2'b00, 2'b00}}, 1);
    #50;

    //----------- Final Reset ---------------------------------------------------------------------------------------
    reset_i = 1;
    #10;
    reset_i = 0;
	 
	 //----------- Test 5: Random requests --------------------------------------------------------------------------
    apply_request({ 
      {2'b00, 2'b10, 2'b00, 2'b00}, 
      {2'b00, 2'b10, 2'b01, 2'b10}, 
      {2'b10, 2'b00, 2'b01, 2'b01}, 
      {2'b00, 2'b01, 2'b01, 2'b01}}, 1);
    #50;
	 

    //----------- End Simulation ----------------------------------------------------------------------------------
    $stop;
  end

endmodule
