// Module name: Column Arbiter Module
// Module Description: This module provides grants to active column requests for the selected row
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                                      // Importing arbiter package containing parameter constants

module y_roundrobin 
#(parameter Lvl_COLS=4 , parameter Lvl_COL_ADD=2)
(
    input  logic clk_i                    ,         // Clock input for Synchronization
    input  logic reset_i                  ,         // Active high Reset input
    input  logic enable_i                 ,         // Enable signal to control Column arbiter
    input  logic [Lvl_COLS-1:0]req_i      ,         // Request inputs (multi-bit for each request)
    output logic [Lvl_COLS-1:0] gnt_o     ,         // Grant outputs 
    output logic [Lvl_COL_ADD-1:0] yadd_o ,         // Encoded output representing the granted cloumn index
    output logic grp_release
);

     // Internal signals for mask and grant handling
    logic [Lvl_COLS-1:0] mask_ff     ;              // Current mask 
    logic [Lvl_COLS-1:0] nxt_mask    ;              // Next mask based on grants
    logic [Lvl_COLS-1:0] mask_req    ;              // Masked requests (and of req_i and mask_ff)
    logic [Lvl_COLS-1:0] mask_gnt    ;              // Masked grants (output from priority arbiter)
    logic [Lvl_COLS-1:0] gnt_temp    ;              // Temporary grant value before registering output
	 

     // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign mask_req = req_i & mask_ff;   
	 
	 //Grp_release will be high if mask_req is zero
    assign grp_release = !mask_req;


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

    // Next mask generation based on current grant outputs
    always_comb 
     begin
        nxt_mask = mask_ff;                    // Default: next mask is the current mask

        // Iterate through the gnt_temp bits to calculate the next mask
        for (int i = 0; i < Lvl_COLS ; i = i + 1) 
		   begin
            if (gnt_temp[i]) 
			      begin
                   nxt_mask = ({Lvl_COLS{1'b1}} << (i + 1)); // Next mask update based on current grant 
               end
         end
     end

    // Compute yadd_o based on the current grants
    always_comb 
      begin
        yadd_o = {Lvl_COL_ADD{1'b0}};               // Initialize yadd_o to 0
        for (int i = 0; i < Lvl_COLS; i = i + 1) 
		   begin
            if (gnt_o[i]) 
			      begin
                  yadd_o = i[Lvl_COL_ADD-1:0];      // Assign the index of the granted cloumn index to yadd_o
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