// Module name: Column Arbiter Module
// Module Description: 
// Author: 
// Date: 
// Version:
//------------------------------------------------------------------------------------------------------------------
module y_roundrobin #(parameter WIDTH = 8) (
  input logic clk_i,                        // Clock input
  input logic reset_i,                      // Reset input
  input logic enable_i,                     // Enable signal to control updates
  input logic [WIDTH-1:0] req_i,            // Request inputs
  output logic [WIDTH-1:0] gnt_o,           // Grant outputs (sequential)
  output logic Grp_release_o,               // Group release signal
  output logic [2:0] yadd_o                 // Additional output logic (xadd_o equivalent)
);

  // Internal signals for mask and grant handling
  logic [WIDTH-1:0] mask_ff;                // Current mask (active request set)
  logic [WIDTH-1:0] nxt_mask;               // Next mask based on grants
  logic [WIDTH-1:0] mask_req;               // Masked requests (AND of req_i and mask_ff)
  logic [WIDTH-1:0] mask_gnt;               // Masked grants (from priority arbiter)
  logic [WIDTH-1:0] gnt_temp;               // Temporary grant value before registering

  // Masked request generation
  assign mask_req = req_i & mask_ff;        // Mask requests using the current mask

  // Mask and grant state update logic
  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      mask_ff <= 8'b11111111;               // Reset mask to all ones (allow all requests)
      gnt_o  <= 8'b00000000;                // Reset grant output to zero (no grants)
    end 
    else begin
      if (enable_i) begin
        mask_ff <= nxt_mask;                // Update mask based on next mask calculation
        gnt_o <= gnt_temp;                  // Register the combinational grant output
      end
      else begin
        mask_ff <= 8'b11111111;            // Keep the mask enabled (all requests allowed)
        gnt_o <= 8'b00000000;              // No grants if not enabled
      end 
    end
  end

  // Grant output is the value from the masked grants
  assign gnt_temp = mask_gnt;               // Register the combinational grant from masked arbiter

  // Group release condition: High when the next mask is greater than the current mask
  assign Grp_release_o = (nxt_mask > mask_ff);

  // Next mask generation based on current grant outputs
  always_comb begin
    nxt_mask = mask_ff;  // Default to the current mask value

    // Iterate through the grant bits to generate the next mask
    for (int i = 0; i < 8; i = i + 1) begin
        if (gnt_temp[i]) begin
            nxt_mask = (8'b11111111 << (i+1));  // Update mask after the granted bit
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







/*module y_roundrobin (
  input logic clk,
  input logic reset,
  input logic enable,
  input logic [3:0] req_i,             // Request inputs
  output logic [3:0] gnt_o,            // Grant outputs (sequential)
  output logic Grp_release_o,          // Group release signal
  output logic [1:0] add_o             // Additional output logic
);

  logic [3:0] mask_q;                  // Current mask
  logic [3:0] nxt_mask;                // Next mask
  logic [3:0] mask_req;                // Masked requests
  logic [3:0] mask_gnt;                // Masked grants (combinational)
  logic [3:0] gnt_reg;                 // Registered grant outputs

  // Masked request generation
  assign mask_req = req_i & mask_q;   // Mask requests with current mask

  // Mask state update logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      mask_q <= 4'b1111;              // Reset mask to all ones
      gnt_o <= 4'b0000;             // Reset registered grant outputs
    end 
    else begin
      if (enable) begin
        mask_q <= nxt_mask;             // Update mask on enable
        gnt_o <= gnt_reg;            // Register the combinational grant
      end
      else begin
        mask_q <= 4'b1111;
        gnt_o <= 4'b0000;
      end 
    end
  end

  // Grant output (registered value)
  assign gnt_reg = mask_gnt;            // Register the combinational grant


  // Group release condition
  assign Grp_release_o = (nxt_mask > mask_q);

  // Next mask generation based on current grant
  always_comb begin
    nxt_mask = mask_q;
    if (mask_gnt[0]) nxt_mask = 4'b1110;
    else if (mask_gnt[1]) nxt_mask = 4'b1100;
    else if (mask_gnt[2]) nxt_mask = 4'b1000;
    else if (mask_gnt[3]) nxt_mask = 4'b0000;

    // Additional output logic
    add_o[1] = mask_gnt[3] | mask_gnt[2];
    add_o[0] = mask_gnt[3] | mask_gnt[1];
  end

  // Priority arbiter for masked requests
  Priority_arb #(4) maskedGnt (
    .req_i(mask_req),
    .gnt_o(mask_gnt)
  );

endmodule*/

