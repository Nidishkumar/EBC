// Module name: Column Arbiter Module
// Module Description: This module provides grants to active column requests for the selected row
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                          // Importing arbiter package containing parameter constants

module column_arbiter #(parameter Lvl_COLS=2 , parameter Lvl_COL_ADD=1)
(
    input  logic clk_i                    ,         // Clock input for Synchronization
    input  logic reset_i                  ,         // Active high Reset input
    input  logic enable_i                 ,         // Enable signal to control Column arbiter
    input  logic refresh_i                ,         // Refresh signal to initialize the Arbiter
    input  logic [Lvl_COLS-1:0]req_i      ,         // Request input of columns
    output logic [Lvl_COLS-1:0] gnt_o     ,         // Outputs the granted cloumn 
    output logic [Lvl_COL_ADD-1:0] yadd_o ,         // Encoded output representing the granted cloumn index
    output logic grp_release_o
);
  
//------------------Arbiter Internal Signals------------------------------------------------------------------------

    logic [Lvl_COLS-1:0] mask_ff     ;              // Current mask 
    logic [Lvl_COLS-1:0] nxt_mask    ;              // Next mask based on grants
    logic [Lvl_COLS-1:0] mask_req    ;              // Masked requests (and of req_i and mask_ff)
    logic [Lvl_COLS-1:0] mask_gnt    ;              // Masked grants (output from priority arbiter)
    logic [Lvl_COLS-1:0] gnt_temp    ;              // Temporary grant value before registering output
	  logic mask_done;
//--------------------------------------------------------------------------------------------------------------------
//-----------------Mask and Grant logic------------------------------------------------------------------------------------

    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
          begin
           mask_ff <= (Lvl_COLS > 0) ? {Lvl_COLS{1'b1}} : 1'b1;
           gnt_o   <= (Lvl_COLS > 0) ? {Lvl_COLS{1'b0}} : 1'b0;
          end 
        else if (enable_i) 
			    begin
            mask_ff <= nxt_mask;              // Update mask based on next mask 
            gnt_o   <= gnt_temp;              // Register the grant temp to output
          end
        else if(refresh_i)
		      begin
			      mask_ff <= (Lvl_COLS > 0) ? {Lvl_COLS{1'b1}} : 1'b1;
            gnt_o   <= (Lvl_COLS > 0) ? {Lvl_COLS{1'b0}} : 1'b0;
          end
        else
          begin
            mask_ff <= mask_ff;              // Update mask based on next mask 
            gnt_o   <= gnt_o;               // Register the grant temp to output
          end
    end
//---------------------------------------------------------------------------------------------------------------------------------------

//-----------------Column Arbiter Assignments-------------------------------------------------------------------------
   
    assign mask_req = req_i & mask_ff ;              // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign grp_release_o =  ~(|mask_req) ;           //Grp_release will be high if mask_req is zero
    assign gnt_temp = mask_gnt ;                     // Register the combinational grant from masked arbiter
    assign nxt_mask= ~((gnt_temp << 1)-({{(Lvl_COLS-1){1'b0}}, 1'b1})); //Next mask updation based on grant
    // assign nxt_mask = ~((gnt_temp << 1) - ({(Lvl_COLS-1) ' (1'b0), 1'b1}));

//----------------------------------------------------------------------------------------------------------------------	 
    // Lint Warning for Multiple Assignmets of next_mask 
    // always_comb 
    //  begin
    //     nxt_mask = mask_ff;                    // Default: next mask is the current mask
    //     mask_done=1'b0;
    //     // Iterate through the gnt_temp bits to calculate the next mask
    //     for (int i = 0; i < Lvl_COLS ; i = i + 1) 
		//    begin
    //         if (gnt_temp[i] && !mask_done) 
		// 	      begin
    //                nxt_mask = ({Lvl_COLS{1'b1}} << (i + 1)); // Next mask update based on current grant 
		// 			      	 mask_done=1'b1;
    //            end
    //      end
    //  end 

//--------------------Encoding Granted Column Index Logic---------------------------------------------------------------------------------------------------
    // Lint Warning for Multiple Assignmets of yadd_o
   // Lint Warning for Multiple Assignmets of yadd_o
      always_comb begin
        yadd_o = {Lvl_COL_ADD{1'b0}};                        // Initialize xadd_o to 0
        for (int i = 0; i < Lvl_COLS ; i = i + 1) begin
            if (gnt_o[i]) begin
                yadd_o = Lvl_COL_ADD'(i);                   // Assign the index of the granted bit to xadd_o
            end
        end
    end 
		

    // Priority arbiter for masked requests (maskedGnt)
   Priority_arb #(.Lvl_ROWS(Lvl_COLS))
	 maskedGnt 
	  (
        .req_i  (mask_req)  ,                      // Input masked requests
        .gnt_o  (mask_gnt)                         // Output masked grants
    );

endmodule