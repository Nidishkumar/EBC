// Module name: Row Arbiter Module
// Module Description: 
// Author: 
// Date: 
// Version:
//------------------------------------------------------------------------------------------------------------------
module x_roundrobin #(parameter WIDTH = 8) (
  input logic clk_i,                        // Clock input
  input logic reset_i,                      // Reset input
  input logic enable_i,                     // Enable signal for updating mask and grants
  input logic [WIDTH-1:0] req_i,            // Request inputs
  output logic [WIDTH-1:0] gnt_o,           // Grant outputs
  output logic Grp_release_o,               // Group release signal
  output logic [2:0] xadd_o                 // Additional output for xadd_o[2:0]
);

  // Internal signals
  logic [WIDTH-1:0] mask_ff;                // Current mask (the active request set)
  logic [WIDTH-1:0] nxt_mask;               // Next mask value after evaluating grants
  logic [WIDTH-1:0] mask_req;               // Masked requests (AND of req_i and mask_ff)
  logic [WIDTH-1:0] mask_gnt;               // Masked grants (output from masked priority arbiter)
  logic [WIDTH-1:0] raw_gnt;                // Raw grants (output from raw priority arbiter)
  logic [WIDTH-1:0] gnt_temp;               // Temporary grant value before updating the output

  // Mask requests with the current mask
  assign mask_req = req_i & mask_ff;

  // Update mask and grant signals on the clock edge
  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      mask_ff <= 8'b11111111;               // Reset mask to all ones (allow all requests)
      gnt_o  <= 8'b00000000;                // Reset grant output to zero (no grants)
    end else if (enable_i) begin
      mask_ff <= nxt_mask;                  // Update mask based on next mask calculation
      gnt_o <= gnt_temp;                    // Register the grant output
    end
  end

  // Determine the final grant output: either masked grants or raw grants depending on mask
  assign gnt_temp = (|mask_req ? mask_gnt : raw_gnt); 

  // Group release signal: high when the next mask is greater than the current mask
  assign Grp_release_o = (nxt_mask > mask_ff);

  // Generate the next mask based on the current grant outputs
  always_comb begin
    nxt_mask = mask_ff;  // Default: next mask is the current mask

    // Iterate through the gnt_temp bits to calculate the next mask
    for (int i = 0; i < 8; i = i + 1) begin
        if (gnt_temp[i]) begin
            nxt_mask = (8'b11111111 << (i+1));  // Set mask to 1 after the granted index
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





/*module x_roundrobin (
  input logic clk,
  input logic reset,
  input logic enable,
  input logic [3:0] req_i,             // Request inputs
  output logic [3:0] gnt_o,            // Grant outputs
  output logic Grp_release_o,          // Group release signal
  output logic [1:0] add_o             // Additional outputs
);

  logic [3:0] mask_q;                  // Current mask
  logic [3:0] nxt_mask;                // Next mask
  logic [3:0] mask_req;                // Masked requests
  logic [3:0] mask_gnt;                // Masked grants
  logic [3:0] raw_gnt;                 // Raw grants
  logic [3:0] gnt_reg;                 // Registered grant output

  // Mask requests with the current mask
  assign mask_req = req_i & mask_q;

  // Update mask and grant signals on the clock edge
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      mask_q <= 4'b1111;               // Reset mask to all ones
      gnt_o <= 4'b0000;              // Reset registered grant output
    end else if (enable) begin
      mask_q <= nxt_mask;              // Update mask
      gnt_o <= gnt_reg;
    end
  end

  // Assign the sequential grant output
  //assign gnt_o = gnt_reg;
  assign gnt_reg = (|mask_req ? mask_gnt : raw_gnt); // Register grant

  // Generate the Group Release Output
  assign Grp_release_o = (nxt_mask > mask_q);

  // Next mask generation based on grant outputs
  always_comb begin
    nxt_mask = mask_q;
    if (gnt_reg[0]) nxt_mask = 4'b1110; // Update mask for grant[0]
    else if (gnt_reg[1]) nxt_mask = 4'b1100; // Update mask for grant[1]
    else if (gnt_reg[2]) nxt_mask = 4'b1000; // Update mask for grant[2]
    else if (gnt_reg[3]) nxt_mask = 4'b0000; // Update mask for grant[3]

    // Generate additional output logic
    add_o[1] = gnt_reg[3] | gnt_reg[2];
    add_o[0] = gnt_reg[3] | gnt_reg[1];
  end

  // Priority arbiter for masked requests
  Priority_arb #(4) maskedGnt (
    .req_i(mask_req),
    .gnt_o(mask_gnt)
  );

  // Priority arbiter for raw requests
  Priority_arb #(4) rawGnt (
    .req_i(req_i),
    .gnt_o(raw_gnt)
  );

endmodule
*/