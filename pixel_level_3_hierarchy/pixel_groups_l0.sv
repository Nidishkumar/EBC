
import lib_arbiter_pkg::*;                      // Importing arbiter package containing parameter constants

module pixel_groups_l0 
(
    input logic clk_i,
    input logic reset_i,
    input logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0][POLARITY-1:0] set_i,
    input logic [CONST0-1:0][CONST0-1:0] gnt_top_i,
    output logic [CONST0-1:0][CONST0-1:0] req_o,
	 output logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0] gnt_o_0,
    output logic grp_release_o,
    output logic [l0_GROUP_SIZE-1:0][l0_GROUP_SIZE-1:0] gnt_o,
    output logic  x_add_o,
    output logic  y_add_o,
    output logic active_o
);
    // Grouped pixel array
    logic [NUM_GROUPS0-1:0][l0_GROUP_SIZE-1:0][l0_GROUP_SIZE-1:0][POLARITY-1:0] set_group;

    // Temporary outputs for each group
    logic [NUM_GROUPS0-1:0] x_add_temp;
    logic [NUM_GROUPS0-1:0] y_add_temp;
    logic [NUM_GROUPS0-1:0][l0_GROUP_SIZE-1:0][l0_GROUP_SIZE-1:0] gnt_temp;
    logic [NUM_GROUPS0-1:0] active_temp;
    logic [NUM_GROUPS0-1:0] grp_release_temp;
	 int base_col;
	 int base_row;

    assign active_o = |active_temp;

    // Dynamic grouping logic
    always_comb begin
        for (int group = 0; group < NUM_GROUPS0; group++) begin
            // Calculate the top-left pixel of the group
             base_row = (group / CONST0) * l0_GROUP_SIZE;
             base_col = (group % CONST0) * l0_GROUP_SIZE;

            for (int row = 0; row < l0_GROUP_SIZE; row++) begin
                for (int col = 0; col < l0_GROUP_SIZE; col++) begin
                    set_group[group][row][col] = set_i[base_row + row][base_col + col];
						  gnt_o_0[base_row + row][base_col + col] = gnt_temp[group][row][col];

                end
            end
        end
    end

    // Group-level instantiations
    genvar group;
    generate
        for (group = 0; group < NUM_GROUPS0; group++) 
		  begin : groups
            pixel_level #(.GROUP_SIZE(l0_GROUP_SIZE),.Lvl_ADD(Lvl0_ADD))
				i_pixel_level 
				(
                .clk_i(clk_i),
                .reset_i(reset_i),
                .enable_i(gnt_top_i[group / CONST0][group % CONST0]),
                .req_i(set_group[group]),
                .req_o(req_o[group / CONST0][group % CONST0]),
                .gnt_o(gnt_temp[group]),
                .x_add_o(x_add_temp[group]),
                .y_add_o(y_add_temp[group]),
                .active_o(active_temp[group]),
                .grp_release_o(grp_release_temp[group])
            );
        end
    endgenerate

    always_comb begin
        gnt_o = 0;
        x_add_o = 0;
        y_add_o = 0;
        grp_release_o = 0;
        for (int group = 0; group < NUM_GROUPS0; group++) begin
            if (gnt_top_i[group / CONST0][group % CONST0])
				begin
                gnt_o= gnt_temp[group];
                x_add_o = x_add_temp[group];
                y_add_o = y_add_temp[group];
                grp_release_o = grp_release_temp[group];
            end
        end
    end
endmodule
