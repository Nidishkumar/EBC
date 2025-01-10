// Module name: Address Event Module
// Module Description: 
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module aer (
  input logic [2:0] x_add_i,       // 3-bit input representing the row index of the event
  input logic [2:0] y_add_i,       // 3-bit input representing the column index of the event
  input logic [31:0] timestamp_i,  // 32-bit input representing the timestamp of the event
  input logic polarity_i,          // 1-bit input representing the polarity of the event
  output logic [38:0] data_out_o   // 39-bit output combining the inputs into a single vector
);

  always_comb
  begin
    data_out_o = {timestamp_i, x_add_i, y_add_i, polarity_i};
  end

endmodule
