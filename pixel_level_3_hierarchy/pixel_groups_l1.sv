// Module name: pixel groups level1
// Module Description: This module perform intermediate level grouping and arbiteration to the intermediate level groups
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*;                      // Importing arbiter package containing parameter constants

module pixel_groups_l1 
(
    input logic clk_i                                            ,   // Clock input
    input logic reset_i                                          ,   // Reset signal
    input logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] set_i         ,   // Input pixel set matrix from lower level
    input logic [CONST1-1:0][CONST1-1:0] gnt_top_i               ,   // enable signal for each group from top level
	input logic  grp_release_i                                   ,   // Group release signal from the lower level
    output logic [CONST1-1:0][CONST1-1:0] req_o                  ,   // Output request signal for each group to higher level
	output logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] gnt_o_high   ,   //grant matrix for lower level as enable
    output logic [Lvl1_GROUP_SIZE-1:0][Lvl1_GROUP_SIZE-1:0] gnt_o,   // Grant output from intermediate groups
    output logic [Lvl1_ADD-1:0]x_add_o                           ,   // Row address of the granted pixel group
    output logic [Lvl1_ADD-1:0]y_add_o                           ,   // Column address of the granted pixel group
    output logic  active_o                                       ,   // Indicates if any group is active
	output logic grp_release_o                                       // Group release signal for all operations done

);

    logic [NUM_GROUPS1-1:0][Lvl1_GROUP_SIZE-1:0][Lvl1_GROUP_SIZE-1:0] set_group; // Subgroups of pixels

    // Temporary outputs for each group
    logic [NUM_GROUPS1-1:0][Lvl1_ADD-1:0] x_add_temp    ;      // Temporary row address for each group
    logic [NUM_GROUPS1-1:0][Lvl1_ADD-1:0] y_add_temp    ;      // Temporary column address for each group
    logic [NUM_GROUPS1-1:0][Lvl1_GROUP_SIZE-1:0][Lvl1_GROUP_SIZE-1:0] gnt_temp; // Temporary grant for each group
    logic [NUM_GROUPS1-1:0] active_temp                 ;      // Active status for each group
    logic [NUM_GROUPS1-1:0] grp_release_temp            ;      // Group release signals for each group
	// int base_col;                                         // Base column index of the current group
	 //int base_row;                                         // Base row index of the current group

    assign active_o = |active_temp;                        // Active output is high if any group is active

    always_comb 
	  begin
	     gnt_o_high = '0;                                   // Initialize the grant matrix to 0

        for (int group = 0; group < NUM_GROUPS1; group++) 
		   begin

           //  base_row = (group / CONST1) * Lvl1_GROUP_SIZE; // Calculate base row for the current group
             //base_col = (group % CONST1) * Lvl1_GROUP_SIZE; // Calculate base column for the current group

            for (int row = 0; row < Lvl1_GROUP_SIZE; row++) 
				 begin
                for (int col = 0; col < Lvl1_GROUP_SIZE; col++) 
					  begin
                          set_group[group][row][col] = set_i[(group / CONST1) * Lvl1_GROUP_SIZE + row][(group % CONST1) * Lvl1_GROUP_SIZE + col];     // Mapping pixels to the individual groups
						  gnt_o_high[(group / CONST1) * Lvl1_GROUP_SIZE + row][(group % CONST1) * Lvl1_GROUP_SIZE + col] = gnt_temp[group][row][col]; // Mapping lower group grants to overall grant,acts as enable to the lower level
                 end
             end
         end
    end   

    genvar group;                                          
    generate
        for (group = 0; group < NUM_GROUPS1; group++) 
		   begin : groups
		  
            // Instantiate pixel_top_level for each group
            pixel_top_level #(.Lvl_ROWS    (Lvl1_GROUP_SIZE) , 
                              .Lvl_COLS    (Lvl1_GROUP_SIZE) , 
                              .Lvl_ROW_ADD (Lvl1_ADD)        , 
                              .Lvl_COL_ADD (Lvl1_ADD)) 
				level1
				(
                .clk_i              (clk_i)                                    ,    // Clock input
                .reset_i            (reset_i)                                  ,    // Reset input
                .enable_i           (gnt_top_i[group / CONST1][group % CONST1]),    // Enable signal for the current group
                .req_i              (set_group[group])                         ,    // Pixel requests for the current group
			    .grp_release_i      (grp_release_i)                            ,    // Group release input from the top level
                .req_o              (req_o[group / CONST1][group % CONST1])    ,    // Request output for the top level
                .gnt_o              (gnt_temp[group])                          ,    // Grant output for the intermediate level group
                .x_add_o            (x_add_temp[group])                        ,    // Row address output for the intermediate level group
                .y_add_o            (y_add_temp[group])                        ,    // Column address output for the intermediate level group
                .active_o           (active_temp[group])                       ,    // Active status for the intermediate level group
                .grp_release_o      (grp_release_temp[group])                       // Group release signal for the intermediate level group
            );
        end
    endgenerate

    // Combine outputs from all groups
    always_comb 
	  begin
        gnt_o = 0;                                         // Initialize group-level grant 
        x_add_o = 0;                                       // Initialize row address output
        y_add_o = 0;                                       // Initialize column address output
        grp_release_o = 0;                                 // Initialize group release output
        for (int group = 0; group < NUM_GROUPS1; group++) 
		   begin
            if ( gnt_top_i[group / CONST1][group % CONST1]) 
				 begin
                gnt_o = gnt_temp[group];                   // Assign grant from the active intermediate group
                x_add_o = x_add_temp[group];               // Assign row address from the active intermediate group
                y_add_o = y_add_temp[group];               // Assign column address from the active intermediate group
                grp_release_o = grp_release_temp[group];   // Assign release signal from the active intermediate group
            end
        end
    end
	 
endmodule



