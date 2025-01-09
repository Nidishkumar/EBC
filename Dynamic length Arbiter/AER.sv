// Module name: AER Module
// Module Description: This module combines the event data row address,column address,timestamp and polarity
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

module address_event (
input logic [x_width-1:0] x_add_i,                 //pixel Row address 
input logic [y_width-1:0] y_add_i,                 //pixel Column address
input logic [SIZE-1:0] timestamp_i,                //captured timestamp data
input logic polarity_i,                            //polarity output
output logic [WIDTH-1:0] data_out_o                //stores event data
);

always_comb
begin
    data_out_o={timestamp_i,x_add_i,y_add_i,polarity_i};  //combines event data like event row address ,column address,timestamp and polarity
end

endmodule