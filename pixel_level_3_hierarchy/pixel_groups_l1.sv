	import lib_arbiter_pkg::*;                      // Importing arbiter package containing parameter constants


module pixel_groups_l1 
(
    input logic clk_i,
    input logic reset_i,
    input logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] set_i,
    input logic [CONST1-1:0][CONST1-1:0] gnt_top_i,
	 input logic  grp_release_i,
    output logic [CONST1-1:0][CONST1-1:0] req_o,
    output logic grp_release_o,
	 output logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] gnt_o_high,
    output logic [l1_GROUP_SIZE-1:0][l1_GROUP_SIZE-1:0] gnt_o,
    output logic  x_add_o,
    output logic  y_add_o,
    output logic  active_o
);
    // Grouped pixel array
    logic [NUM_GROUPS1-1:0][l1_GROUP_SIZE-1:0][l1_GROUP_SIZE-1:0] set_group;

    // Temporary outputs for each group
    logic [NUM_GROUPS1-1:0] x_add_temp;
    logic [NUM_GROUPS1-1:0] y_add_temp;
    logic [NUM_GROUPS1-1:0][l1_GROUP_SIZE-1:0][l1_GROUP_SIZE-1:0] gnt_temp;
    logic [NUM_GROUPS1-1:0] active_temp;
    logic [NUM_GROUPS1-1:0] grp_release_temp;
	 int base_col;
	 int base_row;

    assign active_o = |active_temp;

    // Dynamic grouping logic
    always_comb begin
	     gnt_o_high = '0;

        for (int group = 0; group < NUM_GROUPS1; group++) begin
            // Calculate the top-left pixel of the group
             base_row = (group / CONST1) * l1_GROUP_SIZE;
             base_col = (group % CONST1) * l1_GROUP_SIZE;

            for (int row = 0; row < l1_GROUP_SIZE; row++) begin
                for (int col = 0; col < l1_GROUP_SIZE; col++) begin
                    set_group[group][row][col] = set_i[base_row + row][base_col + col];
						  gnt_o_high[base_row + row][base_col + col] = gnt_temp[group][row][col];

                end
            end
        end
    end   


    // Group-level instantiations
    genvar group;
    generate
        for (group = 0; group < NUM_GROUPS1; group++) begin : groups
		  
            pixel_top_level #(.Lvl_ROWS(l1_GROUP_SIZE),.Lvl_COLS(l1_GROUP_SIZE),.Lvl_ROW_ADD(Lvl1_ADD),.Lvl_COL_ADD(Lvl1_ADD)) 
				level1
				(
                .clk_i(clk_i),
                .reset_i(reset_i),
                .enable_i(gnt_top_i[group / CONST1][group % CONST1]),
                .req_i(set_group[group]),
					 .grp_release_i(grp_release_i),
                .req_o(req_o[group / CONST1][group % CONST1]),
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
        for (int group = 0; group < NUM_GROUPS1; group++) begin
            if ( gnt_top_i[group / CONST1][group % CONST1]) begin
                gnt_o = gnt_temp[group];
                x_add_o = x_add_temp[group];
                y_add_o = y_add_temp[group];
                grp_release_o = grp_release_temp[group];
            end
        end
    end
	 
endmodule