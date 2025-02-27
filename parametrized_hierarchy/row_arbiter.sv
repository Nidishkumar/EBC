// Module name: Row Arbiter Module
// Module Description: This module provides grants to active row requests for the pixel block
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                                      // Importing arbiter package containing parameter constants

module row_arbiter #(parameter Lvl_ROWS=2 , parameter Lvl_ROW_ADD=1)

 (
    input  logic clk_i                    ,        // Clock input for Synchronization
    input  logic reset_i                  ,        // Active high Reset input
    input  logic enable_i                 ,        // Enable signal to control Row arbiter
    input  logic refresh_i                ,        // Initializes the Arbiter
    input  logic [Lvl_ROWS-1:0] req_i     ,        // Request for active row inputs
    output logic [Lvl_ROWS-1:0] gnt_o     ,        // Grant outputs
    output logic [Lvl_ROW_ADD-1:0] xadd_o ,        // Encoded output representing the granted row index
	 output logic grp_release_o                     // Grp_release will high after completion all active requests
 );

//------------------Arbiter Internal Signals------------------------------------------------------------------------------------------------
    logic [Lvl_ROWS-1:0] mask_ff ;                // Current mask (the active request set)
    logic [Lvl_ROWS-1:0] nxt_mask;                // Next mask value after evaluating grants
    logic [Lvl_ROWS-1:0] mask_req;                // Masked requests (and of req_i and mask_ff)
    logic [Lvl_ROWS-1:0] mask_gnt;                // Masked grants (output from masked priority arbiter)
    logic [Lvl_ROWS-1:0] raw_gnt ;                // Raw grants (output from raw priority arbiter)
    logic [Lvl_ROWS-1:0] gnt_temp;                // Temporary grant value before updating the output
    logic [Lvl_ROW_ADD-1:0] xadd_incr;
	 logic add_done;
//--------------------------------------------------------------------------------------------------------------------------------------- 

 
//-----------------Row Arbiter Assignments-------------------------------------------------------------------------
   
	 assign mask_req = req_i & mask_ff;                   // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign grp_release_o =  ~(|mask_req);                //Grp_release will be high if mask_req is zero
	 assign gnt_temp = (|mask_req ? mask_gnt : raw_gnt);  // Determine the final grant output: either masked grants or raw grants depending on the mask_req
    assign nxt_mask= ~((gnt_temp << 1)-({{(Lvl_ROWS-1){1'b0}}, 1'b1})); //Next mask updation based on grant

//---------------------------------------------------------------------------------------------------------------------------------------

//-----------------Mask and Grant logic----------------------------------------------------------------------
    always_ff @(posedge clk_i or posedge reset_i) 
	   begin
      if (reset_i) 
		  begin
            mask_ff <= {Lvl_ROWS{1'b1}};          // Reset mask to all ones (allow all requests)
            gnt_o   <= {Lvl_ROWS{1'b0}};          // Reset grant output to zero (no grants)
		 end 
		else if (enable_i) 
		 begin
            mask_ff <= nxt_mask;                  // Update mask based on next mask calculation
            gnt_o  <= gnt_temp;                   // Register the grant output
       end
      else if(refresh_i)
		 begin
			   mask_ff <= {Lvl_ROWS{1'b1}};          // Initialize mask to all ones (allow all requests)
            gnt_o   <= {Lvl_ROWS{1'b0}};
       end
      else
         begin
            mask_ff <= mask_ff;              // Update mask based on next mask 
            gnt_o   <= gnt_o;              // Register the grant temp to output
         end
      
      end   
//-----------------------------------------------------------------------------------------

    //     // Lint Warning for Multiple Assignmets of next_mask 
   /* always_comb 
	   begin
        nxt_mask = mask_ff;                   // Default: next mask is the current mask
        mask_done=1'b0;
        // Iterate through the gnt_temp bits to calculate the next mask
        for (int i = 0; i < Lvl_ROWS ; i = i + 1)
		   begin
            if (gnt_temp[i]&& !mask_done) 
			      begin
                 nxt_mask = ({Lvl_ROWS{1'b1}} << (i + 1)); // Next mask update based on current grant 
					  mask_done=1'b1;
               end
         end
      end */
		
//--------------------Encoding Granted Row Index Logic-----------------------------------------------------
    always_comb 
      begin
        xadd_o = {Lvl_ROW_ADD{1'b0}};              // Initialize yadd_o to 0
		  xadd_incr = {Lvl_ROW_ADD{1'b0}};             // Initialize yadd_incr to 0
		  add_done=0;                                  // Initialize add_done to 0
        for (int i = 0; i < Lvl_ROWS   ; i = i + 1) 
		   begin
            if (gnt_o[i] && !add_done)
			      begin
                  xadd_o = xadd_incr;              // Assign the increamented address to yadd_o
						add_done=1;                      // Assign add_done to 1
               end
				else
				      xadd_incr=xadd_incr+1'b1;        //Increament add_incr to 1

         end
      end  
    // Priority arbiter for masked requests (gives grants based on the masked requests)
    Priority_arb #(.Lvl_ROWS(Lvl_ROWS))
	 maskedGnt 
    (
        .req_i  (mask_req)  ,                   // Input masked requests
        .gnt_o  (mask_gnt)                      // Output masked grants
    );

    // Priority arbiter for raw requests (gives grants based on the original requests)
    Priority_arb  #(.Lvl_ROWS(Lvl_ROWS))
	 rawGnt 
    (
        .req_i  (req_i)     ,                   // Input raw requests
        .gnt_o  (raw_gnt)                       // Output raw grants
    );

endmodule