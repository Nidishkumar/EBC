// Module name: Testbench for wall_clock module
// Module Description: Testbench for verifying the functionality of the wall_clock module.
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------

module tb_wall_clock #(parameter SIZE = 32);
  // Declare testbench variables
  logic clk_i;                 // Clock input for driving the wall_clock module
  logic reset_i;               // Reset input for initializing or resetting the module
  logic is_active_i;           // Signal to capture the timestamp when active
  logic [SIZE-1:0] timestamp_o; // Output to observe the captured timestamp value

  // Instantiate the wall_clock module
  wall_clock dut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .is_active_i(is_active_i),
    .timestamp_o(timestamp_o)
  );

  // Clock generation: Generates a clock signal with a period of 10 time units
  always #5 clk_i = ~clk_i;

  // Testbench procedure
  initial begin
    // Initialize signals
    clk_i = 0;              // Start the clock at 0
    is_active_i = 0;        // Deassert the event signal
    reset_i = 0;            // Deassert the reset signal

    // Apply reset
    #10;
    reset_i = 1;            // Assert reset to initialize the module
    #10;
    reset_i = 0;            // Deassert reset
    #20;

    // Test Case 1: Trigger an event to capture the timestamp
    is_active_i = 1;        // Assert event signal
    #40;
    is_active_i = 0;        // Deassert event signal

    // Test Case 2: Wait for a few clock cycles without any events
    repeat (2) @(posedge clk_i);

    // Test Case 3: Trigger another event and check the timestamp
    is_active_i = 1;        // Assert event signal
    #30;
    reset_i = 1;            // Apply reset during event
    #10;
    reset_i = 0;            // Deassert reset

    // Test Case 4: Wait for a few clock cycles without triggering any events
    repeat (2) @(posedge clk_i);

    // Test Case 5: Trigger another event and observe the timestamp update
    #40;
    is_active_i = 0;        // Deassert event signal

    // Test Case 6: Apply reset again and observe the behavior
    reset_i = 1;            // Assert reset
    #10;
    reset_i = 0;            // Deassert reset
    #20;

    // End simulation
    $stop;
  end
endmodule