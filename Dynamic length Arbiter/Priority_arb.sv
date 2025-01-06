// Module name: Priority Arbiter Module
// Module Description: This priority arbiter module grants requests based on priority.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                // Importing arbiter package containing parameter constants

module Priority_arb (
  input logic [WIDTH-1:0] req_i   ,  // Request inputs
  output logic [WIDTH-1:0] gnt_o     // One-hot grant signal
);

  // Port[0] has highest priority
  assign gnt_o[0] = req_i[0];        // Grant[0] if request[0] is active

  genvar i;
  generate
    // Grant[i] is asserted if req_i[i] is active and no higher-priority grants are active
    for (i = 1; i < WIDTH; i = i + 1) 
	   begin : loop
         assign gnt_o[i] = req_i[i] & ~(|gnt_o[i-1:0]);  
     end
  endgenerate

endmodule
