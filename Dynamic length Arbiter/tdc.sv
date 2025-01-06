// Module name: Testbench for tdc module
// Module Description: 
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                     // Importing arbiter package containing parameter constants
module tdc (
  input  logic               clk_i,         // Clock input
  input  logic               reset_i,       // Reset input (active high)
  input  logic               event_i,       // Event signal to capture the timestamp
  output logic [SIZE-1:0]    timestamp_o    // Output to hold the captured timestamp
);

  logic [SIZE-1:0] counter_ff;              // Register to hold the counter value

  // Sequential process to manage the counter
  always_ff @(posedge clk_i or posedge reset_i) 
  begin
    if (reset_i) 
      counter_ff <= '0;                     // Reset the counter to zero 
    else 
      counter_ff <= counter_ff + 1;         // Increment the counter on each clock cycle
  end

  // Sequential process to capture the timestamp
  always_ff @(posedge clk_i or posedge reset_i) 
  begin
    if (reset_i) 
      timestamp_o <= '0;                    // Reset the timestamp to zero
    else if (event_i) 
      timestamp_o <= counter_ff;            // Capture the current counter value as the timestamp
  end

endmodule