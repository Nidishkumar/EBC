// Module name: Row Arbiter Module
// Module Description: This module provides grants to active row requests for the pixel block
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*;                        // Importing arbiter package containing parameter constants

module row_arbiter
 (
    input  logic clk_i                 ,       // Clock input
    input  logic reset_i               ,       // Active high Reset input
    input  logic enable_i              ,       // Enable signal to control Row arbiter
    input  logic [ROWS-1:0] req_i      ,       // Request inputs
    output logic [ROWS-1:0] gnt_o      ,       // Grant outputs
    output logic [ROW_ADD-1:0] x_add_o          // Encoded output representing the granted row index
 );

    // Internal signals for mask and grant handling
    logic [ROWS-1:0] mask_ff ;                // Current mask (the active request set)
    logic [ROWS-1:0] nxt_mask;                // Next mask value after evaluating grants
    logic [ROWS-1:0] mask_req;                // Masked requests (and of req_i and mask_ff)
    logic [ROWS-1:0] mask_gnt;                // Masked grants (output from masked priority arbiter)
    logic [ROWS-1:0] raw_gnt ;                // Raw grants (output from raw priority arbiter)
    logic [ROWS-1:0] gnt_temp;                // Temporary grant value before updating the output
    
	 

    // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign mask_req = req_i & mask_ff;

	 
// Update mask and grant signals on the clock edge
    always_ff @(posedge clk_i or posedge reset_i) 
	   begin
        if (reset_i) 
		   begin
            mask_ff <= {ROWS{1'b1}};          // Reset mask to all ones (allow all requests)
            gnt_o   <= {ROWS{1'b0}};          // Reset grant output to zero (no grants)
			end 
		  else if (enable_i) 
		   begin
            mask_ff <= nxt_mask;              // Update mask based on next mask calculation
            gnt_o  <= gnt_temp;               // Register the grant output
         end
      end
	 

// Determine the final grant output: either masked grants or raw grants depending on the mask
    assign gnt_temp = (|mask_req ? mask_gnt : raw_gnt); 

// Generate the next mask based on the current grant outputs
   	assign nxt_mask= ~((gnt_temp << 1)-({{(ROWS-1){1'b0}}, 1'b1})); 

/*Lint issue for Multiple Assignmets of nxt_mask 
   always_comb 
	   begin
       nxt_mask = mask_ff;                   // Default: next mask is the current mask
       next_done = 1'b0;

       // Iterate through the gnt_temp bits to calculate the next mask
       for (int i = 0; i < ROWS ; i = i + 1)
		   begin
           if (gnt_temp[i] && (!next_done)) 
			      begin
                nxt_mask = ({ROWS{1'b1}} << (i + 1)); // Next mask update based on current grant 
                next_done = 1'b1;
              end
        end
     end */


// Compute yadd_o based on the current grants
    function logic [ROW_ADD-1:0] address (input logic [ROWS-1:0] data);
        for(int i=0 ;i<ROWS ;i++)
        begin
        if(data[i])
          return i[ROW_ADD-1:0];
      end
          return '0;
      endfunction

      always_comb
      begin
      if (gnt_o !=0)
        begin
        x_add_o =address(gnt_o);
        end
      else
        x_add_o ='0;
      end

/*Lint issue for Multiple Assignmets of x_add_o 
  always_ff@(posedge clk_i or posedge reset_i)
     begin
      if(reset_i)
		  begin
		    x_add_o  <= {ROW_ADD{1'b0}};
			 add_incr <= {ROW_ADD{1'b0}};
       end
		  else
		  begin
       for (int i = 0; i < ROWS; i = i + 1) 
		   begin
           if (gnt_temp[i])
                 x_add_o <= add_incr;      // Assign the index of the granted cloumn index to yadd_o
           else
                add_incr <= add_incr + 1'b1;
        end
     end
    end */



    // Priority arbiter for masked requests (gives grants based on the masked requests)
    priority_arb  maskedGnt 
    (
        .req_i  (mask_req)  ,                   // Input masked requests
        .gnt_o  (mask_gnt)                      // Output masked grants
    );

    // Priority arbiter for raw requests (gives grants based on the original requests)
    priority_arb  rawGnt 
    (
        .req_i  (req_i)     ,                   // Input raw requests
        .gnt_o  (raw_gnt)                       // Output raw grants
    );

endmodule