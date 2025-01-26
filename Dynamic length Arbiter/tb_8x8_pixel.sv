// Module name: tb Module
// Module Description: Generating Random events for 8*8 pixel
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                          // Importing arbiter package containing parameter constants

 module tb_8x8_pixel;
  // Inputs
  logic clk_i                                   ; // Clock input
  logic reset_i                                 ; // Active high Reset input
  logic enable_i                                ; // Enable signal to trigger arbitration
  logic [COLS-1:0][POLARITY-1:0] req_i[ROWS-1:0]; // Request signals for each row and column, with POLARITY bits determining the signal's polarity or behavior
  // Outputs
  logic [ROWS-1:0][COLS-1:0] gnt_o              ; //grant output
  logic [WIDTH-1:0] data_out_o                  ; //event data

  // Instantiate the Top Module
  Top_single_pixel   dut (
            .clk_i          (clk_i)         ,     // Clock input
            .reset_i        (reset_i)       ,     // Active high Reset input
            .req_i          (req_i)         ,     // Request signals for each row and column, with POLARITY bits determining the signal's polarity 
            .enable_i       (enable_i)      ,     // Enable signal to trigger arbitration
            .gnt_o          (gnt_o)         ,     // grant outputs
            .data_out_o     (data_out_o)          // current event information 
  );

//--------------------------------------------------Clock generation----------------------------------------------//
  // Clock Generation
  initial begin
                clk_i = 0       ;
    forever #5  clk_i = ~clk_i  ; //  clock period
  end
//--------------------------------------------End of Clock generation---------------------------------------------//
  
 
//-------------------------------------------Deasserting request--------------------------------------------------//
// Deassert the request when the corresponding grant is active
 always_ff @(posedge clk_i)
 begin
  for (int i = 0; i < ROWS; i++) begin
    for (int j = 0; j < COLS; j++) 
     begin
      if (gnt_o[i][j] == 1'b1) 
       begin
          req_i[i][j] <= 1'b0;     // Deassert request upon grant
       end
     end
  end
end 
//------------------------------------------End of deasserting request-------------------------------------------------//


//-------------------------------------------Initializing inputs-------------------------------------------------------//
  // Initialize request input matrix (req_i) to all zeros
  task initialize;
    begin
      enable_i = 1;
      req_i = {
		         {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b10, 2'b10, 2'b00, 2'b00, 2'b00, 2'b01} }; 
   end
  endtask
//-------------------------------------------End of initializing inputs------------------------------------------------//


//-------------------------------------------Apply Reset---------------------------------------------------------------//
 // Apply a reset pulse: Assert the reset signal for 10 time units, then deassert it for 10 time units
  task apply_reset;
    begin
      reset_i = 1;
      #10;
      reset_i = 0;
      #10;
    end
  endtask
//-------------------------------------------End of apply Reset---------------------------------------------------------//


//-------------------------------------------Apply Request-------------------------------------------------------------//
// Set the enable signal and assign the input request to req_i
  task apply_request(input [COLS-1:0][POLARITY-1:0] request[ROWS-1:0], input logic en);
    begin
      enable_i = en;
      req_i = request;
    end
  endtask
//-------------------------------------------End of Apply Request---------------------------------------------------------//


//-------------------------------------------Apply Various Test Cases---------------------------------------------------------//
  // Test procedure
  initial begin

    // Initialize inputs
    initialize;
    
    // Reset the DUT
    apply_reset;
	 
	 //Applying Enable
	 
	 #20;

    // Test 1: Random Events across pixel
    apply_request({
	            {2'b00, 2'b01, 2'b00, 2'b00, 2'b01, 2'b01, 2'b00, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b00, 2'b00}, 
               {2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b01, 2'b00, 2'b10, 2'b00, 2'b00, 2'b10, 2'b01}}, 1);
    #30;

    // Test 2: First row updated with new events
	 
    apply_request(
	               {{2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00}, 
               {2'b10, 2'b10, 2'b10, 2'b00, 2'b00, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01}, 
               {2'b00, 2'b01, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b01}, 
               {2'b00, 2'b00, 2'b10, 2'b01, 2'b00, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}}, 1);
    #40;
	 
    // Test 3: Active events in 3rd row of pixel
    apply_request({
	            {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b01, 2'b10, 2'b10, 2'b10, 2'b10, 2'b01, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}}, 1);
    #50;
	  // Test 4: One Active event in each row
    apply_request({
	            {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b01}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
					     {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00}, 
               {2'b10, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}}, 1);
	#60;
   // Apply reset to deassert the grant signal
	 apply_reset;
	 #50;
	// Apply enable low to halt the granting 
    enable_i = 0;
	 #20;
	// Apply enable high to continue the granting where it left
	 enable_i = 1;
	 
	// Test 5: Random Events across last four rows 
	 apply_request({
	            {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
					     {2'b00, 2'b01, 2'b10, 2'b00, 2'b01, 2'b01, 2'b10, 2'b01}, 
               {2'b10, 2'b00, 2'b10, 2'b00, 2'b00, 2'b00, 2'b01, 2'b10}, 
               {2'b00, 2'b01, 2'b00, 2'b10, 2'b00, 2'b10, 2'b00, 2'b01}, 
               {2'b10, 2'b01, 2'b00, 2'b01, 2'b00, 2'b00, 2'b10, 2'b01}}, 1);
    #120;  
	 // Test 6: No active Events
	 apply_request({
	            {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}},1);
	 #40;
	 // Test 7: Alternate Row has Active Events
     apply_request({
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
               {2'b01, 2'b10, 2'b00, 2'b10, 2'b10, 2'b01, 2'b10, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
               {2'b10, 2'b10, 2'b00, 2'b00, 2'b01, 2'b00, 2'b01, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
               {2'b01, 2'b00, 2'b10, 2'b00, 2'b01, 2'b00, 2'b10, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b01, 2'b10, 2'b10, 2'b01}}, 1);
					
    #200;
	 // Test 8: Last Row of pixel has Active Events
    apply_request({
               {2'b10, 2'b10, 2'b01, 2'b00, 2'b10, 2'b01, 2'b01, 2'b10}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00},
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}, 
               {2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00, 2'b00}},1);
					
    #200;
    $stop;
  end
//-------------------------------------------End of test Cases---------------------------------------------------------//


endmodule 