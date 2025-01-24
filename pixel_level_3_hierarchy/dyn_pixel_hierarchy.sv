// Module name: Dynamic Pixel Hierarchy
// Module Description: This module handles the pixel hierarchy for processing pixel requests and generating grant signals.
// It integrates multiple submodules including the polarity selector, timestamp generator, and address event generator.
// Author: []
// Date: []
// Version: []
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants

// Define the module 'dyn_pixel_hierarchy' with input/output ports
module pixel_hierarchy (
    input logic clk_i, reset_i,                            // Clock and reset inputs
    input logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0][POLARITY-1:0] set_i,  // Pixel requests input with polarity for each pixel
    output logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0] gnt_o,               // Grant output 
    output logic grp_release_out,                             // Group release signal for level 2
    output logic [WIDTH-1:0] data_out_o                     // Data output signal combining event data (row, column, timestamp, polarity)
);

// Internal signals for addressing pixel data
logic [ROW_ADD-1:0] x_add;     
logic [COL_ADD-1:0] y_add;

logic [ROW_ADD-1:0] x_add_ff;     
logic [COL_ADD-1:0] y_add_ff;

logic polarity;                     // Signal for the selected polarity
logic [SIZE-1:0] timestamp;         // Timestamp signal for event 

logic active_1, active_2, active_0; // Active signals form different pixel levels whether granting or not
logic enable;                       // Enable signal to control the level2 [higher level]
logic [POLARITY-1:0] polarity_in;   // Input signal for polarity

logic active;                        // Combined signal for all active signals from all levels
logic req_0;                         // Enable signal for level 2, it has active requests or not 

logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] req_l0; // Request signal for level 1 [intermediate level]
logic [Lvl2_PIXELS-1:0][Lvl2_PIXELS-1:0] req_1;  // Request signal for level 2 [higher level]
logic [Lvl0_ADD-1:0] x_add_0;       // Row Address for level 0 
logic [Lvl0_ADD-1:0] y_add_0;       // Column Address for level 0 
logic [Lvl1_ADD-1:0] x_add_1;       // Row Address for level 1 
logic [Lvl1_ADD-1:0] y_add_1;       // Column Address for level 1 
logic [Lvl2_ADD-1:0] x_add_2;       // Row Address for level 2 
logic [Lvl2_ADD-1:0] y_add_2;       // Column Address for level 2 

logic [Lvl0_GROUP_SIZE-1:0][Lvl0_GROUP_SIZE-1:0] gnt_0; // Grant signals for level 0
logic [Lvl1_GROUP_SIZE-1:0][Lvl1_GROUP_SIZE-1:0] gnt_1; // Grant signals for level 1
logic [Lvl2_PIXELS-1:0][Lvl2_PIXELS-1:0] gnt_2;         // Grant signals for level 2

logic grp_release_0, grp_release_1;  // Group release signals for levels 0 and 1

logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] gnt_o_1; // Signal is used to give as enable to the lower level [level0 from level1] 


// Signal assignments
assign enable = req_0; // Enable signal for the level2 [higher level]
assign x_add = {x_add_2, x_add_1, x_add_0};  // Combine all Row levels address 
assign y_add = {y_add_2, y_add_1, y_add_0};  // Combine all column levels address 

// Select polarity input for the Polarity Selector module
assign polarity_in = set_i[x_add][y_add]; // Sends the active row's column request polarity to the polarity module.
assign active = active_0 & active_1 & active_2; // All levels must be active for the overall system to be active

// Flip-flop to store addresses on rising edge of the clock or reset
always_ff @(posedge clk_i or posedge reset_i) 
begin
    if (reset_i) 
    begin
        x_add_ff <= 'b0;    // Reset row address
        y_add_ff <= 'b0;    // Reset column address
    end 
    else 
    begin
        x_add_ff <= x_add;    // Store row address
        y_add_ff <= y_add;    // Store column address
    end 
end 

// Instantiating submodules to handle different pixel levels
pixel_top_level 
#(
    .Lvl_ROWS(Lvl2_PIXELS),          // Number of rows in level 2
    .Lvl_COLS(Lvl2_PIXELS),          // Number of columns in level 2
    .Lvl_ROW_ADD(Lvl2_ADD),          // Address width for row in level 2
    .Lvl_COL_ADD(Lvl2_ADD)           // Address width for column in level 2
) 
level_2 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .enable_i(enable),
    .req_i(req_1),                     // Request input for level 2
    .grp_release_i(grp_release_1),     // Group release from level 1
    .gnt_o(gnt_2),                     // Grant output for level 2
    .x_add_o(x_add_2),                 // row index output from level 2
    .y_add_o(y_add_2),                 // column index output from level 2
    .active_o(active_2),               // Active signal from level 2
    .req_o(req_0),                     // enable input for level 2
    .grp_release_o(grp_release_out)      // Group release for level 2
);

// Instantiating pixel groups for level 1
pixel_groups_l1 pixel_level_1 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .gnt_top_i(gnt_2),                // Grant input from level 2 as enable
    .grp_release_i(grp_release_0),    // Group release for level 0
    .set_i(req_l0),                   // Request input for level 0
    .gnt_o_high(gnt_o_1),             // Grant output for higher-level as enable
    .gnt_o(gnt_1),                    // Grant output for level 1
    .x_add_o(x_add_1),                // x-coordinate address output for level 1
    .y_add_o(y_add_1),                // y-coordinate address output for level 1
    .active_o(active_1),              // Active signal for level 1
    .req_o(req_1),                    // Request output for level 1
    .grp_release_o(grp_release_1)     // Group release for level 1
);

// Instantiating pixel groups for level 0
pixel_groups_l0 level_0 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .gnt_top_i(gnt_o_1),          // Grant input from higher-level
    .set_i(set_i),                   // Pixel set input with polarity
    .gnt_o(gnt_0),                   // Lower-level grant output
    .gnt_o_0(gnt_o),                 // Overall grant for active requests
    .x_add_o(x_add_0),               // row address output for level 0
    .y_add_o(y_add_0),               // column address output for level 0
    .req_o(req_l0),                  // Request output for level 1
    .grp_release_o(grp_release_0),   // indication to the higher level as group has granted all active requests
    .active_o(active_0)              // Active signal from level0 indication of granting or not  
);

// Wall clock module to capture the timestamp
wall_clock time_stamp (
    .clk_i(clk_i),           // Clock input
    .reset_i(reset_i),       // Reset input
    .timestamp_o(timestamp)  // Timestamp output
);

// Instantiate the polarity selector module to get the polarity for the selected pixel
polarity_selector polarity_sel (
    .clk_i(clk_i),           // Clock input
    .reset_i(reset_i),       // Reset input
    .req_i(polarity_in),     // Polarity request input (from the active pixel)
    .polarity_out(polarity)  // Output polarity signal
);

// Instantiate the address event generator module to combine event data
AER address_event (
    .enable_i(active),       // Enable signal based on active status
    .x_add_i(x_add_ff),      // Row address from flip-flop
    .y_add_i(y_add_ff),      // Column address from flip-flop
    .timestamp_i(timestamp), // Timestamp from wall clock
    .polarity_i(polarity),   // Polarity output from polarity selector
    .data_out_o(data_out_o)  // Combined event data output
);  

endmodule



