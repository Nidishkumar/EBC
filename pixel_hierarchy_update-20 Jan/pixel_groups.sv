module pixel_groups (
input logic clk_i,reset_i,
input logic [15:0][15:0][1:0]set_i,
input logic [3:0][3:0] gnt_top_i,
output logic [3:0][3:0] req_o,
output logic [15:0]grp_release_o,
output logic [3:0][3:0] gnt_o,
output logic [1:0] x_add_o,
output logic [1:0] y_add_o,
output logic active_o
 );
logic [15:0][3:0][3:0] set_group;

logic [15:0][3:0][3:0]  gnt_temp; // Array for grant outputs
logic [15:0][1:0]       x_add_temp;     // Array for x_add outputs
logic [15:0][1:0]       y_add_temp;     // Array for y_add outputs
logic [15:0]            active_temp;

assign active_o = |active_temp;

always_comb
 begin
        for (int group = 0; group < 16; group++) begin 
            for (int row = 0; row < 4; row++) begin 
                for (int col = 0; col < 4; col++) begin 
                     set_group[group][row][col] = set_i[(group / 4) * 4 + row][(group % 4) * 4 + col];
                end
            end
        end
end

genvar group;
	 generate
    for ( group = 0; group < 16; group++) 
	 begin : groups
        pixel_level i_pixel_level (
            .clk_i(clk_i),
            .reset_i(reset_i),
            .enable_i(gnt_top_i[group]),
            .req_i(set_group[group]),
            .req_o(req_o[group / 4][group % 4]),
				    .gnt_o(gnt_temp[group]),
				    .x_add_o(x_add_temp[group]),
				    .y_add_o(y_add_temp[group]),
            .active_o(active_temp[group]),
			      .grp_release_o(grp_release_o[group])
        );
    end
endgenerate

always_comb begin
  gnt_o = 0;
  x_add_o = 0;
  y_add_o = 0;
  for (int group = 0; group < 16; group++) begin
    if (gnt_top_i[group]) begin
      gnt_o = gnt_temp[group];
      x_add_o = x_add_temp[group];
      y_add_o = y_add_temp[group];
    end
  end
end

endmodule
