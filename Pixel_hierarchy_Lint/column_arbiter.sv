// Module name: Column Arbiter Module
// Module Description: This module provides grants to active column requests for the selected row
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                                      // Importing arbiter package containing parameter constants

module column_arbiter  #(parameter Lvl_COLS=2 , parameter Lvl_COL_ADD=1)
(
    input  logic clk_i                    ,         // Clock input for Synchronization
    input  logic reset_i                  ,         // Active high Reset input
    input  logic enable_i                 ,         // Enable signal to control Column arbiter
    input  logic [Lvl_COLS-1:0]req_i      ,         // Request inputs (multi-bit for each request)
    output logic [Lvl_COLS-1:0] gnt_o     ,         // Grant outputs 
    output logic [Lvl_COL_ADD-1:0] yadd_o ,         // Encoded output representing the granted cloumn index
    output logic grp_release_o
);

     // Internal signals for mask and grant handling
    logic [Lvl_COLS-1:0] mask_ff     ;              // Current mask 
    logic [Lvl_COLS-1:0] nxt_mask    ;              // Next mask based on grants
    logic [Lvl_COLS-1:0] mask_req    ;              // Masked requests (and of req_i and mask_ff)
    logic [Lvl_COLS-1:0] mask_gnt    ;              // Masked grants (output from priority arbiter)
    logic [Lvl_COLS-1:0] gnt_temp    ;              // Temporary grant value before registering output
	 logic [Lvl_COL_ADD-1:0] yadd_incr;              // Temporary address increament variable
	
     // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign mask_req = req_i & mask_ff;   
	 
	 //Grp_release will be high if mask_req is zero
    assign grp_release_o =  ~(|mask_req);


    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
            // Reset mask to all ones (allow all requests) and reset grant output to zero
            mask_ff <= {Lvl_COLS{1'b1}};
            gnt_o   <= {Lvl_COLS{1'b0}};           // Reset grant output to zero (no grants)

         end 
        else 
		   begin
            if (enable_i) 
			    begin
                mask_ff <= nxt_mask;              // Update mask based on next mask 
                gnt_o   <= gnt_temp;              // Register the grant temp to output
             end
            else
			    begin
                // Reset mask to all ones (allow all requests) when not enabled
                mask_ff <=  {Lvl_COLS{1'b1}}; 
                gnt_o   <=  {Lvl_COLS{1'b0}};     // No grants when not enabled

             end
         end
     end

    // Grant output is taken from the masked grants
    assign gnt_temp = mask_gnt;                   // Register the combinational grant from masked arbiter

	 //Next mask updation based on grant
	 assign nxt_mask= ~((gnt_temp << 1)-({{(Lvl_COLS-1){1'b0}}, 1'b1})); 

    // Lint Warning for Multiple Assignmets of next_mask 
    /*always_comb 
     begin
        nxt_mask = mask_ff;                    // Default: next mask is the current mask
        mask_done=1'b0;
        // Iterate through the gnt_temp bits to calculate the next mask
        for (int i = 0; i < Lvl_COLS ; i = i + 1) 
		   begin
            if (gnt_temp[i] && !mask_done) 
			      begin
                   nxt_mask = ({Lvl_COLS{1'b1}} << (i + 1)); // Next mask update based on current grant 
						 mask_done=1'b1;
               end
         end
     end */

	  function logic [Lvl_COL_ADD-1:0] address (input logic [Lvl_COLS-1:0] data);
      for(int i=0 ;i<Lvl_COLS ;i++)
      begin
       if(data[i])
	      return i[Lvl_COL_ADD-1:0];
	   end
	      return '0;
	  endfunction


     always_comb
     begin
     if (gnt_o !=0)
      begin
       yadd_o =address(gnt_o);
      end
     else
       yadd_o ='0;
     end
	  
    // Lint Warning for Multiple Assignmets of yadd_o
  /* always_comb 
      begin
        yadd_o = {Lvl_COL_ADD{1'b0}};              // Initialize yadd_o to 0
		  yadd_incr = {Lvl_COL_ADD{1'b0}};           // Initialize yadd_incr to 0
		  add_done=0;                                // Initialize add_done to 0
        for (int i = 0; i < Lvl_COLS   ; i = i + 1) 
		   begin
            if (gnt_o[i] && !add_done)
			      begin
                  yadd_o = yadd_incr;              // Assign the increamented address to yadd_o
						add_done=1;                      // Assign add_done to 1
               end
				else
				      yadd_incr=yadd_incr+1'b1;        //Increament add_incr to 1

         end
      end  */
		

    // Priority arbiter for masked requests (maskedGnt)
    Priority_arb #(.Lvl_ROWS(Lvl_COLS))
	 maskedGnt 
	 (
        .req_i  (mask_req)  ,                      // Input masked requests
        .gnt_o  (mask_gnt)                         // Output masked grants
    );

endmodule