// Module name: Polarity Selecter Module
// Module Description: This Polarity Selecter module outputs based on polarity of requests.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

module polarity_selector #(parameter POLARITY=2)(
    input logic [POLARITY-1:0] req_i  ,   // 2-bit input request signal (req_i)
    output logic polarity_o                  // Output signal (polarity_o) representing the selected polarity
);

 // Determine the polarity (pol_out) based on the request input (req_i)     
	always_comb 
	  begin
        case(req_i)
		     2'b10   :    polarity_o  = 1'b1;
			  2'b01  :    polarity_o = 1'b0;
		     default :    polarity_o = 1'b0;
        endcase
	  end	 	 
endmodule