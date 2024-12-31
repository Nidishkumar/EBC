// Module name: Row Arbiter Module
// Module Description: Round-Robin Arbiter for request prioritization and grant assignment
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module x_roundrobin #(parameter WIDTH = 8) (
    input  logic clk_i,                        // Clock input
    input  logic reset_i,                      // Reset input
    input  logic enable_i,                     // Enable signal for updating mask and grants
    input  logic [WIDTH-1:0] req_i,            // Request inputs
    output logic [WIDTH-1:0] gnt_o,            // Grant outputs
    output logic Grp_release_o,                // Group release signal
    output logic [2:0] xadd_o                  // Encoded output representing the granted request index
);

    // Internal signals
    logic [WIDTH-1:0] mask_ff;                 // Current mask (the active request set)
    logic [WIDTH-1:0] nxt_mask;                // Next mask value after evaluating grants
    logic [WIDTH-1:0] mask_req;                // Masked requests (AND of req_i and mask_ff)
    logic [WIDTH-1:0] mask_gnt;                // Masked grants (output from masked priority arbiter)
    logic [WIDTH-1:0] raw_gnt;                 // Raw grants (output from raw priority arbiter)
    logic [WIDTH-1:0] gnt_temp;                // Temporary grant value before updating the output
	 

    // Mask requests with the current mask
    assign mask_req = req_i & mask_ff;

	 
    // Update mask and grant signals on the clock edge
    always_ff @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            mask_ff <= 8'b11111111;            // Reset mask to all ones (allow all requests)
            gnt_o   <= 8'b00000000;           // Reset grant output to zero (no grants)
        end else if (enable_i) begin
            mask_ff <= nxt_mask;              // Update mask based on next mask calculation
            gnt_o  <= gnt_temp;               // Register the grant output
        end
    end
	 

    // Determine the final grant output: either masked grants or raw grants depending on the mask
    assign gnt_temp = (|mask_req ? mask_gnt : raw_gnt); 
	 

    // Group release signal: high when the next mask is greater than the current mask
    assign Grp_release_o = (nxt_mask > mask_ff);
	 

    // Generate the next mask based on the current grant outputs
    always_comb begin
        nxt_mask = mask_ff;                   // Default: next mask is the current mask

        // Iterate through the gnt_temp bits to calculate the next mask
        for (int i = 0; i < WIDTH ; i = i + 1) begin
            if (gnt_temp[i]) begin
                nxt_mask = (8'b11111111 << (i + 1)); // Set mask to 1 after the granted index
            end
        end
    end

    // Compute xadd_o (additional outputs) based on the current grants
    always_comb begin
        xadd_o = 3'b0;                        // Initialize xadd_o to 0
        for (int i = 0; i < WIDTH ; i = i + 1) begin
            if (gnt_o[i]) begin
                xadd_o = i[2:0];                   // Assign the index of the granted bit to xadd_o
            end
        end
    end

    // Priority arbiter for masked requests (gives grants based on the masked requests)
    Priority_arb #(WIDTH) maskedGnt (
        .req_i(mask_req),                     // Input masked requests
        .gnt_o(mask_gnt)                      // Output masked grants
    );

    // Priority arbiter for raw requests (gives grants based on the original requests)
    Priority_arb #(WIDTH) rawGnt (
        .req_i(req_i),                        // Input raw requests
        .gnt_o(raw_gnt)                       // Output raw grants
    );

endmodule


