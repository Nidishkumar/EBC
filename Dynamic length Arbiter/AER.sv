// Module name: AER Module
// Module Description: This module combines the event data row address,column address,timestamp and polarity
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

module AER (
input logic [ROW_ADD-1:0] x_add,                 //pixel Row address 
input logic [COL_ADD-1:0] y_add,                 //pixel Column address
input logic [SIZE-1:0] timestamp,                //captured timestamp data
input logic polarity,                            //polarity output
output logic [WIDTH-1:0] data_out_o                //stores event data
);

always_comb
begin
    data_out_o={timestamp,x_add,y_add,polarity};  //combines event data like event row address ,column address,timestamp and polarity
end

endmodule