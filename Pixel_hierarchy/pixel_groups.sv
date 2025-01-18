module pixel_groups (
input logic clk,rst_n,
input logic [15:0][15:0][1:0]set,
input logic [3:0][3:0]gnt_o,
output logic [3:0][3:0] req,
output logic [15:0]grp_release,
output logic [3:0][3:0] in_gnt_o,
output logic [1:0] in_x_add,
output logic [1:0]in_y_add,
output logic [31:0]timestamp_out,
output logic polarity_out
 );
logic [15:0][3:0][3:0][1:0] set_group;

logic [15:0][3:0][3:0] in_gnt_temp; // Array for grant outputs
logic [15:0][1:0] in_x_add_temp;     // Array for x_add outputs
logic [15:0][1:0] in_y_add_temp;     // Array for y_add outputs
logic [15:0] polarity_out_temp;      // Array for polarity outputs
logic [15:0][31:0] timestamp_temp; // Array for timestamp outputs

always_comb
 begin
        for (int group = 0; group < 16; group++) begin 
            for (int row = 0; row < 4; row++) begin 
                for (int col = 0; col < 4; col++) begin 
                     set_group[group][row][col] = set[(group / 4) * 4 + row][(group % 4) * 4 + col];
                end
            end
        end
end

    genvar group;
	 generate
    for ( group = 0; group < 16; group++) 
	 begin : groups
        pixel_level_0 pixel_level0 (
            .clk(clk),
            .rst_n(rst_n),
            .enable(gnt_o[group / 4][group % 4]),
            .set(set_group[group]),
            .req(req[group / 4][group % 4]),
				.gnt_o(in_gnt_temp[group / 4][group % 4]),
				.x_add(in_x_add_temp[group]),
				.y_add(in_y_add_temp[group]),
				.timestamp_out(timestamp_temp[group]),
				.polarity_out(polarity_out_temp[group]),
			   .grp_release(grp_release[group])
        );
    end
endgenerate

always_comb begin
  in_gnt_o = 0;
  in_x_add = 0;
  in_y_add = 0;
  timestamp_out = 0;
  polarity_out = 0;

  for (int group = 0; group < 16; group++) begin
    if (gnt_o[group / 4][group % 4]) begin
      in_gnt_o = in_gnt_temp[group / 4][group % 4];
      in_x_add = in_x_add_temp[group];
      in_y_add = in_y_add_temp[group];
      timestamp_out = timestamp_temp[group];
      polarity_out = polarity_out_temp[group];
    end
  end
end

endmodule
