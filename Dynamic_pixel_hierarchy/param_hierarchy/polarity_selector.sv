// Module name: Polarity Selector Module
// Module Description: This Polarity Selector module outputs a selected polarity based on the request signal's polarity.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants

module polarity_selector 
(
    input logic clk_i                 ,       // Input clock signal for Synchronization 
    input logic reset_i               ,       // Input reset active high signal 
    input logic [POLARITY-1:0] req_i  ,       // 2-bit input request signal (req_i)
    output logic polarity_out                 // Output signal (polarity_out) representing the selected polarity
);

always_ff @(posedge clk_i or posedge reset_i) 
begin
    if (reset_i) 
    begin
        polarity_out <= 1'b0;                 // Reset the output polarity to 0 when reset is triggered
    end
    else 
     begin
        case(req_i)
            2'b10   : polarity_out <= 1'b1;   // If req_i is 2'b10, set polarity_out to 1,indicates intensity higher than threshold
            2'b01   : polarity_out <= 1'b0;   // If req_i is 2'b01, set polarity_out to 0,indicates intensity lower than threshold
            default : polarity_out <= 1'b0;   // Default case:set polarity_out to 0
        endcase
     end
end

endmodule