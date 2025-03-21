// Module name: pixel groups level0
// Module Description: This module perform lower level grouping and arbiteration to the lower level Pixel groups.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                      // Importing arbiter package containing parameter constants
module pixel_groups_level_0 
(
    input logic clk_i                                    ,   // Clock input
    input logic reset_i                                  ,   // Reset signal
    input logic [ROWS-1:0][COLS-1:0][POLARITY-1:0] req_i ,   // EBC Sensors input pixel data with polarity
    input logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] enable_i    ,   // Enable from the higher level hierarchy grant
    output logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] req_o      ,   // Request signals from each group to the higher level
  	output logic [ROWS-1:0][COLS-1:0] gnt_out_o          ,   //Overall grant for the all active requests
    output logic [Lvl0_ROWS-1:0][Lvl0_COLS-1:0] gnt_o    ,   // Grant for lower pixel groups 
    output logic [Lvl0_ADD-1:0] x_add_o                  ,   // Row address of the lower level group
    output logic [Lvl0_ADD-1:0] y_add_o                  ,   // Column address of the lower level group
    output logic active_o                                ,   // active_o indicates if any group arbitration is active
	output logic grp_release_o                               // Group release signal indicates completion of lower level group arbitration

);

    logic [NUM_GROUPS0-1:0][Lvl0_ROWS-1:0][Lvl0_COLS-1:0] set_group; // To store all Lower level groups based on size

//----------Temporary  for each group-----------------------------------------------
    
    logic [NUM_GROUPS0-1:0] [Lvl0_ADD-1:0] x_add_temp   ;    // Temporary row address for each group
    logic [NUM_GROUPS0-1:0] [Lvl0_ADD-1:0] y_add_temp   ;    // Temporary column address for each group
    logic [NUM_GROUPS0-1:0][Lvl0_ROWS-1:0][Lvl0_COLS-1:0] gnt_temp; // Temporary grant matrix for each group
    logic [NUM_GROUPS0-1:0] grp_release_temp            ;    // Group release signal for each group
    logic [NUM_GROUPS0-1:0] active_temp                 ;    // Active signal indicates lower level granting

//----------------------------------------------------------------------------------
    
    assign active_o = |active_temp;                          // Active output is high if any group arbitration active

//---------------Lower level Grouping Logic-----------------------------------------
   
    always_comb 
    begin
        for (int no_group = 0; no_group < NUM_GROUPS0; no_group++) 
		   begin

            for (int row = 0; row < Lvl0_ROWS; row++) 
				 begin
                    for (int col = 0; col < Lvl0_COLS; col++) 
					      begin
                           set_group[no_group][row][col] = (|req_i[(no_group / CONST0) * Lvl0_GROUP_SIZE + row][(no_group % CONST0) * Lvl0_GROUP_SIZE + col]);  // Mapping pixels to the individual groups
					       gnt_out_o[(no_group / CONST0) * Lvl0_GROUP_SIZE + row][(no_group % CONST0) * Lvl0_GROUP_SIZE + col] = gnt_temp[no_group][row][col]; // Mapping lower group grants to overall grant  
                     end 
                 end
           end
    end
//-----------------------------------------------------------------------------------------

//----------------Generate Block for Lower level Arbitration-------------------------------
    genvar no_groups;                                        
    generate
        for (no_groups = 0; no_groups < NUM_GROUPS0; no_groups++) 
		begin : Lvl0_groups
            // Instantiate pixel_level module for each group
            pixel_level_0 Level_0 
				(
                .clk_i                 (clk_i)             ,           // Clock input
                .reset_i               (reset_i)           ,           // Reset signal
                .enable_i              (enable_i[no_groups / CONST0][no_groups % CONST0]),  // Enable signal for the lower level group 
                .req_i                 (set_group[no_groups])  ,                        //Individual group Input requests 
                .req_o                 (req_o[no_groups / CONST0][no_groups % CONST0]),     // active groups request for the higher level as request input
                .gnt_o                 (gnt_temp[no_groups])   ,           // Grant output for the lower level group
                .x_add_o               (x_add_temp[no_groups]) ,           // Row address output for the lower group
                .y_add_o               (y_add_temp[no_groups]) ,           // Column address output for the lower group
                .active_o              (active_temp[no_groups]),           // arbitration status for the groups
                .grp_release_o         (grp_release_temp[no_groups])       // Group release signal for the lower groups
            );
        end
    endgenerate

//-----------------------------------------------------------------------------------------

// Lint Warning for Multiple assignments
    always_comb 
	  begin
        gnt_o = 0;                                       // Initialize group-level grant matrix
        x_add_o = 0;                                     // Initialize row address output
        y_add_o = 0;                                     // Initialize column address output
        grp_release_o = 0;                               // Initialize group release output
		  
        for (int no_group = 0; no_group < NUM_GROUPS0; no_group++) 
		   begin
            if (enable_i[no_group / CONST0][no_group % CONST0])//if enable is high,we receive the active group arbitration data 
				 begin
                gnt_o = gnt_temp[no_group];                 // Assign grant from the active group
                x_add_o = x_add_temp[no_group];             // Assign row address from the active group
                y_add_o = y_add_temp[no_group];             // Assign column address from the active group
                grp_release_o = grp_release_temp[no_group]; // Assign group release signal from the active group
             end
        end
    end	  
        
endmodule