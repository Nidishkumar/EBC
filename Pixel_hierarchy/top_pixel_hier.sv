module top_pixel_hier (
input logic clk,rst_n,input logic [15:0][15:0][1:0]set,
output logic [3:0][3:0]gnt_o,
output logic [3:0] x_add_o ,        // Index for selected row in row arbitration logic
output logic [3:0] y_add_o ,         // Index for selected column in column arbitration logic

output logic [3:0][3:0]in_gnt_o,
output logic polarity_out,
output logic [31:0]timestamp_out

);       


pixel_level_1 level_1
(
   .clk(clk),
	.rst_n(rst_n),
	.set(set),
	.gnt_o(gnt_o),
	.x_add_o(x_add_o),
	.y_add_o(y_add_o),
	.in_gnt_o(in_gnt_o),
	.polarity_out(polarity_out),
	.timestamp_out(timestamp_out)
);


endmodule