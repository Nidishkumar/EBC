// Module name: AER Module
// Module Description: This module combines the event data row address,column address,timestamp and polarity when event occured
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

module AER
    (
    input logic enable_i              ,
    input logic [ROW_ADD-1:0] x_add_i ,                 //pixel Row address 
    input logic [COL_ADD-1:0] y_add_i ,                 //pixel Column address
    input logic [SIZE-1:0] timestamp_i,                 //captured timestamp data
    input logic polarity_i            ,                 //polarity output
    output logic[WIDTH-1:0] data_out_o                  //stores event data
    );

    always_comb
    begin
        if (enable_i) 
		   begin 
            data_out_o = {timestamp_i,x_add_i,y_add_i,polarity_i};  //combines event data like event row address ,column address,timestamp and polarity
         end
        else
         begin
             data_out_o = 'b0;
         end
    end

endmodule