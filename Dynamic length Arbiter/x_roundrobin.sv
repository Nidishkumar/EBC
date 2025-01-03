// Module name: Row Arbiter Module
// Module Description: This module provides grants to active row requests for the pixel block
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
 import arbiter_pkg::*; 

module x_roundrobin (
    input  logic clk_i,                        // Clock input
    input  logic reset_i,                      // Active high Reset input
    input  logic enable_i,                     // Enable signal to control Row arbiter
    input  logic [WIDTH-1:0] req_i,            // Request inputs
    output logic [WIDTH-1:0] gnt_o,            // Grant outputs
    output logic [x_width-1:0] xadd_o          // Encoded output representing the granted row index
);

    // Internal signals for mask and grant handling
    logic [WIDTH-1:0] mask_ff;                 // Current mask (the active request set)
    logic [WIDTH-1:0] nxt_mask;                // Next mask value after evaluating grants
    logic [WIDTH-1:0] mask_req;                // Masked requests (and of req_i and mask_ff)
    logic [WIDTH-1:0] mask_gnt;                // Masked grants (output from masked priority arbiter)
    logic [WIDTH-1:0] raw_gnt;                 // Raw grants (output from raw priority arbiter)
    logic [WIDTH-1:0] gnt_temp;                // Temporary grant value before updating the output
	 

    // Mask requests with the current mask
    assign mask_req = req_i & mask_ff;

	 
    // Update mask and grant signals on the clock edge
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		 begin
            mask_ff <= {WIDTH{1'b1}};          // Reset mask to all ones (allow all requests)
            gnt_o   <= {WIDTH{1'b0}};          // Reset grant output to zero (no grants)
				
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
    always_comb 
	  begin
        nxt_mask = mask_ff;                   // Default: next mask is the current mask

        // Iterate through the gnt_temp bits to calculate the next mask
        for (int i = 0; i < WIDTH ; i = i + 1)
		 begin
            if (gnt_temp[i]) 
			 begin
                nxt_mask = ({WIDTH{1'b1}} << (i + 1)); // Next mask update based on current grant 
             end
         end
      end

    // Compute xadd_o based on the current grants
    always_comb 
     begin
        xadd_o = {x_width{1'b0}};              // Initialize xadd_o to 0
        for (int i = 0; i < WIDTH ; i = i + 1) 
		 begin
            if (gnt_o[i])
			 begin
                xadd_o = i[x_width-1:0];       // Assign the index of the granted bit to xadd_o
             end
         end
     end

    // Priority arbiter for masked requests (gives grants based on the masked requests)
    Priority_arb  maskedGnt (
        .req_i(mask_req),                     // Input masked requests
        .gnt_o(mask_gnt)                      // Output masked grants
    );

    // Priority arbiter for raw requests (gives grants based on the original requests)
    Priority_arb  rawGnt (
        .req_i(req_i),                        // Input raw requests
        .gnt_o(raw_gnt)                       // Output raw grants
    );

endmodule