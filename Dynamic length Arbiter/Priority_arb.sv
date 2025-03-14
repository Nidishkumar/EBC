// Module name: Priority Arbiter Module
// Module Description: This priority arbiter module grants requests based on priority.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

module Priority_arb #(parameter ROWS=8)
(
  input logic [ROWS-1:0] req_i   ,  // Request inputs ROW and Column Arbiters
  output logic [ROWS-1:0] gnt_o     // One-hot grant signal
);

  // Port[0] has highest priority
  assign gnt_o[0] = req_i[0];        // Grant[0] if request[0] is active

  genvar i;
  generate
    // Grant[i] is asserted if req_i[i] is active and no higher priority grants are active
    for (i = 1; i < ROWS; i = i + 1) 
	    begin : loops
         assign gnt_o[i] = req_i[i] & ~(|gnt_o[i-1:0]);  
      end
  endgenerate

endmodule
