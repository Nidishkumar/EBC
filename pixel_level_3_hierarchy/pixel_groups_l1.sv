
import lib_arbiter_pkg::*;                      // Importing arbiter package containing parameter constants


module pixel_groups_l1 #(
    parameter PIXELS = 16,       // Size of the pixel array (e.g., 16x16)
    parameter GROUP_SIZE = 2,   // Group size (e.g., 2x2, 4x4, 8x8)
    parameter CONST = PIXELS / GROUP_SIZE, // Number of groups per row/column
    parameter NUM_GROUPS = CONST * CONST   // Total number of groups
)(
    input logic clk_i,
    input logic reset_i,
    input logic [PIXELS-1:0][PIXELS-1:0] set_i,
    input logic [CONST-1:0][CONST-1:0] gnt_top_i,
	 input logic  grp_release_i,
    output logic [CONST-1:0][CONST-1:0] req_o,
    output logic [NUM_GROUPS-1:0] grp_release_o,
    output logic [GROUP_SIZE-1:0][GROUP_SIZE-1:0] gnt_o,
    output logic  x_add_o,
    output logic  y_add_o,
    output logic  active_o
);
    // Grouped pixel array
    logic [NUM_GROUPS-1:0][GROUP_SIZE-1:0][GROUP_SIZE-1:0] set_group;

    // Temporary outputs for each group
    logic [NUM_GROUPS-1:0] x_add_temp;
    logic [NUM_GROUPS-1:0] y_add_temp;
    logic [NUM_GROUPS-1:0][1:0][1:0] gnt_temp;
    logic [NUM_GROUPS-1:0] active_temp;
    logic [NUM_GROUPS-1:0] grp_release_temp;
	 int base_col;
	 int base_row;

    assign active_o = |active_temp;

    // Dynamic grouping logic
    always_comb begin
        for (int group = 0; group < NUM_GROUPS; group++) begin
            // Calculate the top-left pixel of the group
             base_row = (group / CONST) * GROUP_SIZE;
             base_col = (group % CONST) * GROUP_SIZE;

            for (int row = 0; row < GROUP_SIZE; row++) begin
                for (int col = 0; col < GROUP_SIZE; col++) begin
                    set_group[group][row][col] = set_i[base_row + row][base_col + col];
                end
            end
        end
    end

    // Group-level instantiations
    genvar group;
    generate
        for (group = 0; group < NUM_GROUPS; group++) begin : groups
            pixel_int_level #(.GROUP_SIZE(GROUP_SIZE),.address(1)) 
				level1
				(
                .clk(clk_i),
                .rst_n(reset_i),
                .enable(gnt_top_i[group / CONST][group % CONST]),
                .set(set_group[group]),
					 .grp_release_i(grp_release_i),
                .req(req_o[group / CONST][group % CONST]),
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
        for (int group = 0; group < NUM_GROUPS; group++) begin
            if (gnt_top_i[group / CONST][group % CONST]) begin
                gnt_o= gnt_temp[group];
                x_add_o = x_add_temp[group];
                y_add_o = y_add_temp[group];
                grp_release_o = grp_release_temp[group];
            end
        end
    end
endmodule