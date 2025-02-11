// Module name: Column Arbiter Module
// Module Description: This module provides grants to active column requests for the selected row
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                        // Importing arbiter package containing parameter constants

module column_arbiter 
 (
    input  logic clk_i                ,        // Clock input
    input  logic reset_i              ,        // Active high Reset input
    input  logic enable_i             ,        // Enable signal to control Column arbiter
    input  logic [COLS-1:0]req_i      ,        // Request inputs (multi-bit for each request)
    output logic [COLS-1:0] gnt_o     ,        // Grant outputs (sequential)
    output logic [COL_ADD-1:0] y_add_o           // Encoded output representing the granted cloumn index
 );

    // Internal signals for mask and grant handling
    logic [COLS-1:0] mask_ff     ;              // Current mask 
    logic [COLS-1:0] nxt_mask    ;              // Next mask based on grants
    logic [COLS-1:0] mask_req    ;              // Masked requests (and of req_i and mask_ff)
    logic [COLS-1:0] mask_gnt    ;              // Masked grants (output from priority arbiter)
    logic [COLS-1:0] gnt_temp    ;              // Temporary grant value before registering output

    logic next_done;
    logic add_done;
    //logic [COL_ADD-1:0] add_incr;


     // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign mask_req = req_i & mask_ff;        

    // Mask and grant state update logic
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
            // Reset mask to all ones (allow all requests) and reset grant output to zero
            mask_ff <= {COLS{1'b1}};
            gnt_o   <= {COLS{1'b0}};          // Reset grant output to zero (no grants)
         end 
        else 
		   begin
            if (enable_i) 
			    begin
                mask_ff <= nxt_mask;           // Update mask based on next mask calculation
                gnt_o   <= gnt_temp;           // Register the combinational grant output
             end
            else
			    begin
                // Reset mask to all ones (allow all requests) when not enabled
                mask_ff <=  {COLS{1'b1}}; 
                gnt_o   <=  {COLS{1'b0}};     // No grants when not enabled
             end
         end
     end

    // Grant output is taken from the masked grants
    assign gnt_temp = mask_gnt;                // Register the combinational grant from masked arbiter

	assign nxt_mask= ~((gnt_temp << 1)-({{(COLS-1){1'b0}}, 1'b1})); 

    // Next mask generation based on current grant outputs
//    always_comb 
//     begin
//        nxt_mask = mask_ff;                    // Default: next mask is the current mask
//        next_done = 1'b0;
//
//        // Iterate through the gnt_temp bits to calculate the next mask
//        for (int i = 0; i < COLS; i = i + 1) 
//		   begin
//            if (gnt_temp[i] && (!next_done)) 
//			      begin
//                   nxt_mask = ({COLS{1'b1}} << (i + 1)); // Next mask update based on current grant 
//                   next_done = 1'b1;
//               end
//         end
//     end

	  
	  function logic [COL_ADD-1:0] address (input logic [COLS-1:0] data);
      for(int i=0 ;i<COLS ;i++)
      begin
       if(data[i])
	      return i[COL_ADD-1:0];
	   end
	      return '0;
	  endfunction


     always_comb
     begin
     if (gnt_o !=0)
      begin
       y_add_o =address(gnt_o);
      end
     else
       y_add_o ='0;
     end
    // Compute yadd_o based on the current grants
//    always_ff@(posedge clk_i or posedge reset_i)
//      begin
//       if(reset_i)
//		  begin
//		    y_add_o  <= {COL_ADD{1'b0}};
//			// add_incr <= {COL_ADD{1'b0}};
//        end
//		  else
//		  begin
//        for (int i = 0; i < COLS; i = i + 1) 
//		   begin
//            if (gnt_temp[i])
//                  y_add_o <= (gnt_temp!=0)?($clog2(gnt_temp)):{COL_ADD{1'b0}};      // Assign the index of the granted cloumn index to yadd_o
//         end
//      end
//     end
    // Priority arbiter for masked requests (maskedGnt)
    priority_arb  maskedGnt (
        .req_i  (mask_req)  ,                    // Input masked requests
        .gnt_o  (mask_gnt)                       // Output masked grants
    );

endmodule