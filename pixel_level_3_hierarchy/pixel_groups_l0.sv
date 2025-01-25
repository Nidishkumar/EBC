// Module name: pixel groups level0
// Module Description: This module perform lower level grouping and arbiteration to the lower level groups
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*;                      // Importing arbiter package containing parameter constants

module pixel_groups_l0 
(
    input logic clk_i,                                    // Clock input
    input logic reset_i,                                  // Reset signal
    input logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0][POLARITY-1:0] set_i, // Input pixel data with polarity
    input logic [CONST0-1:0][CONST0-1:0] gnt_top_i,       // Enable from the higher level hierarchy
    output logic [CONST0-1:0][CONST0-1:0] req_o,          // Request signals from each group to the higher level
	 output logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0] gnt_o_0,      //Overaall grant for the all active requests
    output logic grp_release_o,                           // Group release signal indicates completion of lower level groups arbitration
    output logic [Lvl0_GROUP_SIZE-1:0][Lvl0_GROUP_SIZE-1:0] gnt_o, // Grant for lower pixel groups 
    output logic [Lvl0_ADD-1:0] x_add_o,                  // Row address of the lower level group
    output logic [Lvl0_ADD-1:0] y_add_o,                  // Column address of the lower level group
    output logic active_o                                 // Indicates if any group arbitration is active
);
    // Grouped pixel array
    logic [NUM_GROUPS0-1:0][Lvl0_GROUP_SIZE-1:0][Lvl0_GROUP_SIZE-1:0][POLARITY-1:0] set_group; // Pixels grouped dynamically based on size

    // Temporary outputs for each group
    logic [NUM_GROUPS0-1:0] [Lvl0_ADD-1:0] x_add_temp;    // Temporary row address for each group
    logic [NUM_GROUPS0-1:0] [Lvl0_ADD-1:0] y_add_temp;    // Temporary column address for each group
    logic [NUM_GROUPS0-1:0][Lvl0_GROUP_SIZE-1:0][Lvl0_GROUP_SIZE-1:0] gnt_temp; // Temporary grant matrix for each group
    logic [NUM_GROUPS0-1:0] active_temp;                  // Active signal indicates lower level granting
    logic [NUM_GROUPS0-1:0] grp_release_temp;             // Group release signal for each group
	 int base_col;                                        // Base column index for grouping
	 int base_row;                                        // Base row index for grouping

    assign active_o = |active_temp;                       // Active output is high if any group is arbitration active


    always_comb begin
        for (int group = 0; group < NUM_GROUPS0; group++) begin
            // Calculate the top-left pixel index of the current group
             base_row = (group / CONST0) * Lvl0_GROUP_SIZE; // Compute base row for the group
             base_col = (group % CONST0) * Lvl0_GROUP_SIZE; // Compute base column for the group

            for (int row = 0; row < Lvl0_GROUP_SIZE; row++) begin
                for (int col = 0; col < Lvl0_GROUP_SIZE; col++) begin
                    set_group[group][row][col] = set_i[base_row + row][base_col + col];  // Mapping pixels to the individual groups
					gnt_o_0[base_row + row][base_col + col] = gnt_temp[group][row][col]; // Mapping lower group grants to overall grant  
                end
            end
        end
    end

    genvar group;                                        
    generate
        for (group = 0; group < NUM_GROUPS0; group++) 
		  begin : groups
            // Instantiate pixel_level module for each group
            pixel_level #(
                .GROUP_SIZE(Lvl0_GROUP_SIZE),            // Parameter for group size
                .Lvl_ADD(Lvl0_ADD)                       // Parameter for address width
            ) i_pixel_level (
                .clk_i(clk_i),                           // Clock input
                .reset_i(reset_i),                       // Reset signal
                .enable_i(gnt_top_i[group / CONST0][group % CONST0]), // Enable signal for the group
                .req_i(set_group[group]),                //Individual group Input requests 
                .req_o(req_o[group / CONST0][group % CONST0]), // active groups request for the higher level
                .gnt_o(gnt_temp[group]),                 // Grant output for the lower level group
                .x_add_o(x_add_temp[group]),             // Row address output for the lower group
                .y_add_o(y_add_temp[group]),             // Column address output for the lower group
                .active_o(active_temp[group]),           // Active status for the group
                .grp_release_o(grp_release_temp[group])  // Group release signal for the lower groups
            );
        end
    endgenerate

    // Combine outputs from all groups
    always_comb begin
        gnt_o = 0;                                       // Initialize group-level grant matrix
        x_add_o = 0;                                     // Initialize row address output
        y_add_o = 0;                                     // Initialize column address output
        grp_release_o = 0;                               // Initialize group release output
        for (int group = 0; group < NUM_GROUPS0; group++) begin
            if (gnt_top_i[group / CONST0][group % CONST0]) begin
                gnt_o = gnt_temp[group];                 // Assign grant from the active group
                x_add_o = x_add_temp[group];             // Assign row address from the active group
                y_add_o = y_add_temp[group];             // Assign column address from the active group
                grp_release_o = grp_release_temp[group]; // Assign group release signal from the active group
            end
        end
    end
endmodule


