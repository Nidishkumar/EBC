///////////////////////////////////////////////////////////////////////////////////////////////////

import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants
module top_pixel_hierarchy 
(
    input logic clk_i,                                    // Input clock for Synchronization
    input logic reset_i,                                  // Reset signal
    input logic [ROWS1-1:0][COLS1-1:0][POLARITY-1:0] req_i, // Pixel requests input with polarity for each pixel
    output logic [ROWS1-1:0][COLS1-1:0] gnt_out_o,          // Grant output  
    output logic grp_release_out_o,                      // Group release signal from higher level
    output logic [WIDTH-1:0] data_out_o                  // Data output (row, column, timestamp, polarity)
);

logic [SIZE-1:0] timestamp;
logic enable;
logic enable1;

logic polarity;
logic active;
logic [POLARITY-1:0]polarity_in;
//logic req1;
logic [ROW_ADD-1:0]x_add;
logic [COL_ADD-1:0]y_add;

logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] req [NO_levels-1:0];
//logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] req2 [NO_levels-1:0];

logic [Lvl_ROWS[NO_levels-1]-1:0][Lvl_COLS[NO_levels-1]-1:0] gnt_out [NO_levels-1:0];
logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] grant_enb [NO_levels-1:0];
logic [Lvl_ADD[NO_levels-1]-1:0] x_add_out [NO_levels-1:0];
logic [Lvl_ADD[NO_levels-1]-1:0] y_add_out [NO_levels-1:0];
logic grp_release [NO_levels-1:0];
logic active_out [NO_levels-1:0];
assign gnt_out_o=grant_enb[0];

 // Correct for single-bit signals.
//logic grp_release [NO_levels-1:0]; //previous declaration
genvar i;
generate
   // always_comb 
   // begin 
        for (i = 0; i < NO_levels-1; i++) 
        begin : level_hierarchy
            // Declarations should be at the start
            logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb [NO_levels-1:0];  // Use ROWS[i] and COLS[i]
            logic [ROWS[i]-1:0][COLS[i]-1:0] req [NO_levels-1:0];      // Use ROWS[i] and COLS[i]
            logic [Lvl_ROWS[i]-1:0][Lvl_COLS[i]-1:0] gnt_out [NO_levels-1:0]; // Use Lvl_ROWS[i] and Lvl_COLS[i]
            logic [Lvl_ADD[i]-1:0] x_add_out [NO_levels-1:0];        // Use Lvl_ADD[i]
            logic [Lvl_ADD[i]-1:0] y_add_out [NO_levels-1:0];        // Use Lvl_ADD[i]
            logic grp_release [NO_levels-1:0];
            logic active_out [NO_levels-1:0];	

            // Use $warning directly
          //  $warning("------------Loop Passed------------------");
        
            pixel_groups
            #(
                .LEVEL(i),
                .ROWS(ROWS[i]),
                .COLS(COLS[i]),
                .Lvl_ROWS(Lvl_ROWS[i]),
                .Lvl_COLS(Lvl_COLS[i]),
                .Lvl_ADD(Lvl_ADD[i])
            ) 
            level_inst
            (
                .clk_i          (clk_i),
                .reset_i        (reset_i),
                .enable_i       (grant_enb[i+1]),  
                .grp_enable_i   (i > 0 ? grp_release[i-1] : 1'b1),           
                .req_i          (req[i]),
                .gnt_o          (gnt_out[i]),
                .gnt_out_o      (grant_enb[i]),       
                .x_add_o        (x_add_out[i]),  
                .y_add_o        (y_add_out[i]),  
                .active_o       (active_out[i]),
                .req_o          (req[i+1]),  
                .grp_release_o  (grp_release[i])
            );
        end
   // end
endgenerate

// genvar i;
// generate
//     always_comb 
//     begin 
//    for (i = 0; i < NO_levels-1; i++) 
//    begin : level_hierarchy
//    assert
//        $warning("------------Loop Passed------------------");
//     logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb [NO_levels-1:0];  // Use ROWS[i] and COLS[i]
//     logic [ROWS[i]-1:0][COLS[i]-1:0] req [NO_levels-1:0];      // Use ROWS[i] and COLS[i]
//     logic [Lvl_ROWS[i]-1:0][Lvl_COLS[i]-1:0] gnt_out [NO_levels-1:0]; // Use Lvl_ROWS[i] and Lvl_COLS[i]
//     logic [Lvl_ADD[i]-1:0] x_add_out [NO_levels-1:0];        // Use Lvl_ADD[i]
//     logic [Lvl_ADD[i]-1:0] y_add_out [NO_levels-1:0];        // Use Lvl_ADD[i]
//     logic grp_release [NO_levels-1:0];
//     logic active_out [NO_levels-1:0];	

//         pixel_groups
//         #(
//             .LEVEL(i),
//             .ROWS(ROWS[i]),
//             .COLS(COLS[i]),
//             .Lvl_ROWS(Lvl_ROWS[i]),
//             .Lvl_COLS(Lvl_COLS[i]),
//             .Lvl_ADD(Lvl_ADD[i])
//         ) 
//         level_inst
//         (
//             .clk_i          (clk_i),
//             .reset_i        (reset_i),
//             .enable_i       (grant_enb[i+1]),  
//             .grp_enable_i   (i > 0 ? grp_release[i-1] : 1'b1),           
//             .req_i          (req[i]),
//             .gnt_o          (gnt_out[i]),
//             .gnt_out_o      (grant_enb[i]),       
//             .x_add_o        (x_add_out[i]),  
//             .y_add_o        (y_add_out[i]),  
//             .active_o       (active_out[i]),
//             .req_o          (req[i+1]),  
//             .grp_release_o  (grp_release[i])
//         );
// 	 end
//     end
// endgenerate


pixel_level 
				#(  
				    .Lvl_ROWS(ROWS[NO_levels-1]),
					.Lvl_COLS(ROWS[NO_levels-1]),
					.Lvl_ADD(Lvl_ADD[NO_levels-1])
				 ) 
next_level 
				(
                .clk_i(clk_i),
                .reset_i(reset_i),
                .enable_i(enable1),
                .grp_enable_i(grp_release[NO_levels-2]),
                .req_i(req[NO_levels-1]),
                .req_o(enable),
                .gnt_o(gnt_out[NO_levels-1]),
                .x_add_o(x_add_out[NO_levels-1]),
                .y_add_o(y_add_out[NO_levels-1]),
                .active_o(active_out[NO_levels-1]),
                .grp_release_o(grp_release[NO_levels-1])
            );


// Declare array of structs for different levels
always_comb begin
  for (int m = 0; m < ROWS1; m++) begin
    for (int j = 0; j < COLS1; j++) begin
      automatic int index = m * COLS1 + j;  // Explicitly declare as 'automatic'
      req[0][index] = |req_i[m][j];
    end
  end
end

// Generate block to instantiate hierarchical levels


always_comb begin
    x_add = '0;
    y_add = '0;
    for (int j = 0; j < NO_levels; j++) begin
        x_add = {x_add,  x_add_out[j]};
        y_add = {y_add,  y_add_out[j]};
    end
end
assign polarity_in=req_i[x_add][y_add];

// Summing up the active signals dynamically
always_comb begin
    active = '0;
    for (int j = 0; j < NO_levels; j++) begin
        active &= active_out[j];
    end
end
 

// Wall clock module to capture timestamp
wall_clock time_stamp (
    .clk_i       (clk_i),
    .reset_i     (reset_i),
    .timestamp_o (timestamp)
);

// Polarity selector module to get pixel polarity
polarity_selector polarity_sel (
    .clk_i        (clk_i),
    .reset_i      (reset_i),
    .req_i        (polarity_in),
    .polarity_out (polarity)
);

// Address Event Representation (AER) to combine event data
event_encoder address_event (
    .enable_i     (active), // Enable signal from last arbitration level
    .x_add_i      (x_add),
    .y_add_i      (y_add),
    .timestamp_i  (timestamp),
    .polarity_i   (polarity),
    .data_out_o   (data_out_o)
);

endmodule
