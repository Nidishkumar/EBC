// Module name: RR Arbiter Module
// Module Description: 
// Author: 
// Date: 
// Version:
//------------------------------------------------------------------------------------------------------------------
module RoundRobin (
  input clk,
  input reset,
  input enable,
  input [3:0] req_i,             // Request inputs
  output logic [3:0] gnt_o,      // Grant outputs
  output logic Grp_release       // Group release signal
);

  logic [3:0] mask_q;            // Current mask
  logic [3:0] nxt_mask;          // Next mask
  logic single_cycle_stop;       // Stop condition for one cycle
  logic [1:0] x_add;             // Additional grant logic

  logic [3:0] mask_req;          // Masked requests
  assign mask_req = req_i & mask_q;  // Mask requests with current mask

  logic [3:0] mask_gnt;          // Masked grants
  logic [3:0] raw_gnt;           // Raw grants without masking

  // Flip-flop for mask state
  always_ff @(posedge clk or posedge reset)
    if (reset)
      mask_q <= 4'b1111;         // Reset mask to all ones
    else begin
      if (enable)                // Update mask on enable
        mask_q <= nxt_mask;
      else
        mask_q <= mask_q;        // Retain previous mask
    end

  assign single_cycle_stop = (mask_q == '0) ? 1 : 0; // Stop if mask is zero
  assign Grp_release = (nxt_mask > mask_q) ? 1 : 0; // Group release condition

  // Determine next mask based on current grant
  always_comb begin
    nxt_mask = mask_q;
    if (gnt_o[0]) nxt_mask = 4'b1110; // Update mask for grant[0]
    else if (gnt_o[1]) nxt_mask = 4'b1100; // Update mask for grant[1]
    else if (gnt_o[2]) nxt_mask = 4'b1000; // Update mask for grant[2]
    else if (gnt_o[3]) nxt_mask = 4'b0000; // Update mask for grant[3]

    x_add[1] = gnt_o[3] | gnt_o[2];  // Additional logic for x_add[1]
    x_add[0] = gnt_o[3] | gnt_o[1];  // Additional logic for x_add[0]
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

  // Combine masked and raw grants
  assign gnt_o = (|mask_req ? mask_gnt : raw_gnt);

endmodule

//--------------------------- End of RoundRobin ---------------------------

module Priority_arb #(
  parameter NUM_PORTS = 4        // Number of ports
)(
  input wire [NUM_PORTS-1:0] req_i,  // Request inputs
  output wire [NUM_PORTS-1:0] gnt_o  // One-hot grant signal
);

  // Port[0] has highest priority
  assign gnt_o[0] = req_i[0];       // Grant[0] if request[0] is active

  genvar i;
  generate
    for (i = 1; i < NUM_PORTS; i = i + 1) begin : loop
      assign gnt_o[i] = req_i[i] & ~(|gnt_o[i-1:0]); // Grant[i] if no higher grant is active
    end
  endgenerate

endmodule