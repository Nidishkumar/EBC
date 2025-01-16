module top_pixel_hier (
input logic clk,rst_n,input logic [15:0][15:0]set,
output logic [3:0][3:0]gnt_o,
output logic [1:0] x_add ,        // Index for selected row in row arbitration logic
output logic [1:0] y_add ,         // Index for selected column in column arbitration logic

output logic [3:0][3:0]in_gnt_o,
output logic [1:0] in_x_add ,        // Index for selected row in row arbitration logic
output logic [1:0] in_y_add          // Index for selected column in column arbitration logic

);       


pixel_level_1 level_1
(
   .clk(clk),
	.rst_n(rst_n),
	.set(set),
	.gnt_o(gnt_o),
	.x_add(x_add),
	.y_add(y_add)
);

pixel_level_0 level_0
(
   .clk(clk),
	.rst_n(rst_n),
   .gnt_o(in_gnt_o),
	.x_add(in_x_add),
	.y_add(in_y_add)
	
);

endmodule
