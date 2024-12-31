// Module name:  Polarity Selector Module
// Module Description: Top-level module for the Round-Robin arbitration of rows and columns
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module polarity_selector (
    input logic [1:0] req_i,     // 2-bit input request signal (req_i)
    output logic pol_out         // Output signal (polarity_o) representing the selected polarity
);

    // Always block, sensitivity list includes all signals used in the block
    always_comb 
	  begin
        case(req_i)
		    2'b10 : pol_out = 1'b1;
			 2'b01 : pol_out = 1'b0;
		    default : pol_out = 1'b0;
        endcase
	  end	 
endmodule