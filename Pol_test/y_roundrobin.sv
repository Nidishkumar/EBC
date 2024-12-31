// Module name: Column Arbiter Module
// Module Description: Round-Robin Arbiter for request prioritization and grant assignment
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

module y_roundrobin #(parameter WIDTH = 8) (
    input  logic clk_i,                        // Clock input
    input  logic reset_i,                      // Reset input
    input  logic enable_i,                     // Enable signal to control updates
    input  logic [WIDTH-1:0]req_i, // Request inputs (multi-bit for each request)
    output logic [WIDTH-1:0] gnt_o,            // Grant outputs (sequential)
    output logic Grp_release_o,                // Group release signal (indicates a mask change)
    output logic [2:0] yadd_o                  // Additional output logic (yadd_o equivalent to xadd_o)
);

    // Internal signals for mask and grant handling
    logic [WIDTH-1:0] mask_ff;     // Current mask (active request set)
    logic [WIDTH-1:0] nxt_mask;    // Next mask based on grants
    logic [WIDTH-1:0] mask_req;    // Masked requests (AND of req_i and mask_ff)
    logic [WIDTH-1:0] mask_gnt;                  // Masked grants (output from priority arbiter)
    logic [WIDTH-1:0] gnt_temp;                  // Temporary grant value before registering output

    // Masked request generation (AND the request signals with the current mask)
    assign mask_req = req_i & mask_ff;           // Mask requests using the current mask

    // Mask and grant state update logic
    always_ff @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            // Reset mask to all ones (allow all requests) and reset grant output to zero
            mask_ff <=  8'b11111111;
            gnt_o   <=  8'b00000000;               // Reset grant output to zero (no grants)
        end 
        else begin
            if (enable_i) begin
                mask_ff <= nxt_mask;             // Update mask based on next mask calculation
                gnt_o   <= gnt_temp;             // Register the combinational grant output
            end
            else begin
                // Reset mask to all ones (allow all requests) when not enabled
                mask_ff <=  8'b11111111; 
                gnt_o   <=  8'b00000000;          // No grants when not enabled
            end
        end
    end

    // Grant output is taken from the masked grants
    assign gnt_temp = mask_gnt;                   // Register the combinational grant from masked arbiter

    // Group release condition: High when the next mask is greater than the current mask
    assign Grp_release_o = (nxt_mask > mask_ff);

    // Next mask generation based on current grant outputs
    always_comb begin
        nxt_mask = mask_ff;                   // Default: next mask is the current mask

        // Iterate through the gnt_temp bits to calculate the next mask
        for (int i = 0; i < WIDTH ; i = i + 1) begin
            if (gnt_temp[i]) begin
                nxt_mask = (8'b11111111 << (i + 1)); // Set mask to 1 after the granted index
            end
        end
    end

    // Compute yadd_o (additional output logic) based on the current grants
    always_comb begin
        yadd_o = 3'b0;                        // Initialize yadd_o to 0
        for (int i = 0; i < WIDTH; i = i + 1) begin
            if (gnt_o[i]) begin
                yadd_o = i[2:0];                   // Assign the index of the granted request to yadd_o
            end
        end
    end

    // Priority arbiter for masked requests (maskedGnt)
    Priority_arb #(WIDTH) maskedGnt (
        .req_i(mask_req),                     // Input masked requests
        .gnt_o(mask_gnt)                      // Output masked grants
    );

endmodule
