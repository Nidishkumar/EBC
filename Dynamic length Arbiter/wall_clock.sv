// Module name: Wallclock module
// Module Description: This Module capture timestamp based on event.
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                      // Importing arbiter package containing parameter constants
module wall_clock (
  input  logic               clk_i,         // Clock input
  input  logic               reset_i,       // Reset input (active high)
  output logic [SIZE-1:0]    timestamp      // Output to hold the captured timestamp
);

  // Sequential process to capture the timestamp
  always_ff @(posedge clk_i or posedge reset_i) 
  begin
    if (reset_i) 
      timestamp  <= 0;                     // Reset the timestamp to zero
    else
      timestamp <=  timestamp +1;          //Increments whenever reset_i low
  end

endmodule