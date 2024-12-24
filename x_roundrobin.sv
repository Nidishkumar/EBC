// Module name: RR Arbiter Module
// Module Description: 
// Author: 
// Date: 
// Version:
//------------------------------------------------------------------------------------------------------------------

/*
module x_roundrobin (
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
  logic [3:0] mask_req;          // Masked requests
  assign mask_req = req_i & mask_q;  // Mask requests with current mask

  logic [3:0] mask_gnt;          // Masked grants
  logic [3:0] raw_gnt;           // Raw grants without masking

  // Flip-flop for mask state
  always_ff @(posedge clk or posedge reset)
    if (reset)
	  begin
      mask_q <= 4'b1111;
      gnt_o <= 4'b0000;
     end		// Reset mask to all ones
    else begin
      if (enable)  
   		begin// Update mask on enable
        mask_q <= nxt_mask;
		  gnt_o <= (|mask_req ? mask_gnt : raw_gnt);
		  end
      else
        mask_q <= mask_q;        // Retain previous mask
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
  Priority_arb #(4) rawGnt (
    .req_i(req_i),
    .gnt_o(raw_gnt)
  );


endmodule

*/

module x_roundrobin (
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















// // Module name: RR Arbiter Module
// // Module Description: 
// // Author: 
// // Date: 
// // Version:
// //------------------------------------------------------------------------------------------------------------------
// //<<<<<<< HEAD:RoundRobin.sv
// module roundrobin (
//   input clk_i,
//   input reset_i,
//   input enable_i,

// module x_roundrobin (
//   input clk,
//   input reset,
//   input enable,
// >>>>>>> 45c8ac03921747f7d73cce288ba4c744e2c0c83b:x_roundrobin.sv
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
//   always_ff @(posedge clk_i or posedge reset_i)
//     if (reset_i)
//       mask_q <= 4'b1111;         // Reset mask to all ones
//     else begin
//       if (enable_i)                // Update mask on enable
//         mask_q <= nxt_mask;
//       else
//         mask_q <= mask_q;        // Retain previous mask
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
//   Priority_arb #(4) rawGnt (
//     .req_i(req_i),
//     .gnt_o(raw_gnt)
//   );



//   assign gnt_o = (|mask_req ? mask_gnt : raw_gnt);


// endmodule