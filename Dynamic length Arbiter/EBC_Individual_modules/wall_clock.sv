// Module name: Wall Clock module
// Module Description: 
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------

module wall_clock #(parameter SIZE=32) (
  input  logic               clk_i,         // Clock input
  input  logic               reset_i,       // Reset input (active high)
  input  logic               is_active_i,       // Event signal to capture the timestamp
  output logic [SIZE-1:0]    timestamp_o    // Output to hold the captured timestamp
  
);

  logic [SIZE-1:0] counter_ff;              // Register to hold the counter value

  // Sequential process to manage the counter
  always_ff @(posedge clk_i or posedge reset_i) 
  begin
    if (reset_i) 
      counter_ff <= 0;                     // Reset the counter to zero 
    else 
      counter_ff <= counter_ff + 1;         // Increment the counter on each clock cycle
  end

  // Sequential process to capture the timestamp
  always_ff @(posedge clk_i or posedge reset_i) 
  begin
    if (reset_i) 
      timestamp_o <= 0;                    // Reset the timestamp to zero
    else 
	  begin
	 if (is_active_i) 
      timestamp_o <= counter_ff; 
	 else
	   timestamp_o <= 0;      
    end
 end

endmodule