// Module name: Polarity Selecter Module
// Module Description: This Polarity Selecter module outputs based on polarity of requests.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
 import arbiter_pkg::*;                   // Importing arbiter package containing parameter constants

module polarity_selector (
    input logic [POLARITY-1:0] req_i  ,   // 2-bit input request signal (req_i)
    output logic pol_out                  // Output signal (polarity_o) representing the selected polarity
);

 // Determine the polarity (pol_out) based on the request input (req_i)     
	 begin
        case(req_i)
		    2'b10 : pol_out = 1'b1;
			2'b01 : pol_out = 1'b0;
		    default : pol_out = 1'b0;
        endcase
	 end	 
endmodule

  
  