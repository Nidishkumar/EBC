// Module name: RR Arbiter Module
// Module Description: 
// Author: 
// Date: 
// Version:
//------------------------------------------------------------------------------------------------------------------
/*

module y_roundrobin (
  input clk,
  input reset,
  input enable,
  input [3:0] req_i,             // Request inputs
  output logic [3:0] gnt_o,      // Grant outputs
  output logic Grp_release_o,    // Group release signal
  output logic [1:0] add_o
);

  logic [3:0] mask_q;            // Current mask
  logic [3:0] nxt_mask;          // Next mask
  logic single_cycle_stop;       // Stop condition for one cycle

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
        mask_q <= 4'b1111;        // Retain previous mask
    end

  assign single_cycle_stop = (mask_q == 4'b0) ? 1'b1 : 1'b0; // Stop if mask is zero
  assign Grp_release_o = (nxt_mask > mask_q) ? 1'b1 : 1'b0; // Group release condition

  // Determine next mask based on current grant
  always_comb begin
    nxt_mask = mask_q;
    if (gnt_o[0]) nxt_mask = 4'b1110; // Update mask for grant[0]
    else if (gnt_o[1]) nxt_mask = 4'b1100; // Update mask for grant[1]
    else if (gnt_o[2]) nxt_mask = 4'b1000; // Update mask for grant[2]
    else if (gnt_o[3]) nxt_mask = 4'b0000; // Update mask for grant[3]

    add_o[1] = gnt_o[3] | gnt_o[2];  // Additional logic for x_add[1]
    add_o[0] = gnt_o[3] | gnt_o[1];  // Additional logic for x_add[0]
  end

  // Priority arbiter for masked requests
  Priority_arb #(4) maskedGnt (
    .req_i(mask_req),
    .gnt_o(mask_gnt)
  );

  // Priority arbiter for raw requests
  //Priority_arb #(4) rawGnt (
  //  .req_i(req_i),
  //  .gnt_o(raw_gnt)
  //);

  // Flip-flop for mask state
  assign gnt_o = ~{4{reset}} & (|mask_req ? mask_gnt : 4'b0000);


endmodule
*/
module y_roundrobin (
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

endmodule















// // Module name: RR Arbiter Module
// // Module Description: 
// // Author: 
// // Date: 
// // Version:
// //------------------------------------------------------------------------------------------------------------------
// module y_roundrobin (
//   input clk,
//   input reset,
//   input enable,
//   input [3:0] req_i,             // Request inputs
//   output logic [3:0] gnt_o,      // Grant outputs
//   output logic Grp_release_o,    // Group release signal
//   output logic [1:0] add_o
// );

//   logic [3:0] mask_q;            // Current mask
//   logic [3:0] nxt_mask;          // Next mask
//   logic single_cycle_stop;       // Stop condition for one cycle

//   logic [3:0] mask_req;          // Masked requests
//   assign mask_req = req_i & mask_q;  // Mask requests with current mask

//   logic [3:0] mask_gnt;          // Masked grants
//   logic [3:0] raw_gnt;           // Raw grants without masking

//   // Flip-flop for mask state
//   always_ff @(posedge clk or posedge reset)
//     if (reset)
//       mask_q <= 4'b1111;         // Reset mask to all ones
//     else begin
//       if (enable)                // Update mask on enable
//         mask_q <= nxt_mask;
//       else
//         mask_q <= 4'b1111;        // Retain previous mask
//     end

//   assign single_cycle_stop = (mask_q == '0) ? 1 : 0; // Stop if mask is zero
//   assign Grp_release_o = (nxt_mask > mask_q) ? 1 : 0; // Group release condition

//   // Determine next mask based on current grant
//   always_comb begin
//     nxt_mask = mask_q;
//     if (gnt_o[0]) nxt_mask = 4'b1110; // Update mask for grant[0]
//     else if (gnt_o[1]) nxt_mask = 4'b1100; // Update mask for grant[1]
//     else if (gnt_o[2]) nxt_mask = 4'b1000; // Update mask for grant[2]
//     else if (gnt_o[3]) nxt_mask = 4'b0000; // Update mask for grant[3]

//     add_o[1] = gnt_o[3] | gnt_o[2];  // Additional logic for x_add[1]
//     add_o[0] = gnt_o[3] | gnt_o[1];  // Additional logic for x_add[0]
//   end

//   // Priority arbiter for masked requests
//   Priority_arb #(4) maskedGnt (
//     .req_i(mask_req),
//     .gnt_o(mask_gnt)
//   );

//   // Priority arbiter for raw requests
//   //Priority_arb #(4) rawGnt (
//   //  .req_i(req_i),
//   //  .gnt_o(raw_gnt)
//   //);

//   // Flip-flop for mask state
//   assign gnt_o = (|mask_req ? mask_gnt : 4'b0000);


// endmodule
