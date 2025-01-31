// Module name: Polarity Selector Module
// Module Description: This Polarity Selector module outputs based on the polarity of requests.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*; // Importing arbiter package containing parameter constants

module polarity_selector 
(
    input  logic clk_i,
    input  logic reset_i,
    input  logic [POLARITY-1:0] req_i, // 2-bit input request signal (req_i)
    output logic polarity_out          // Output signal (polarity_out) representing the selected polarity
);

    // Determine the polarity (polarity_out) based on the request input (req_i)
    always_ff @(posedge clk_i or posedge reset_i) 
    begin
        if (reset_i) 
        begin
            polarity_out <= 1'b0; 
        end
        else
        begin
            case (req_i)
                2'b10   : polarity_out <= 1'b1; 
                2'b01   : polarity_out <= 1'b0; 
                default : polarity_out <= 1'b0; 
            endcase
        end
    end
endmodule


  
  