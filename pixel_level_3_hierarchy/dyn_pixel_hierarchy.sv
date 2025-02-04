// Module name: Dynamic Pixel Hierarchy
// Module Description: This module handles the pixel hierarchy for processing pixel requests and generating grant signals.
// It integrates multiple submodules including the polarity selector, timestamp generator, and address event generator.
// Author: []
// Date: []
// Version: []
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants


module top_pixel_hierarchy (
    input logic clk_i                                                  ,  // Input clock for Synchronization
	 input logic reset_i                                                ,  // Reset signal
    input logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0][POLARITY-1:0] set_i ,  // Pixel requests input with polarity for each pixel
    output logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0] gnt_o              ,  // Grant output  
    output logic grp_release_out                                       ,  // Group release signal from level 2[higher level] indicates the all active requests are granted
    output logic [WIDTH-1:0] data_out_o                                   // Data output signal combining event data (row address, column address, timestamp and polarity)
);

// Internal signals for addressing pixel data
logic [ROW_ADD-1:0] x_add   ;     
logic [COL_ADD-1:0] y_add   ;

logic [ROW_ADD-1:0] x_add_ff;     
logic [COL_ADD-1:0] y_add_ff;

logic polarity ;                     // Signal for the selected polarity
logic [SIZE-1:0] timestamp;          // Timestamp signal for event 

logic active_1, active_2, active_0; // Active signals form different pixel levels whether the arbitrations in each level active or not
logic enable;                       // Enable signal to control the level2 [higher level]
logic [POLARITY-1:0] polarity_in;   // Input signal for polarity module

logic active;                        // overall arbitration active signal from all levels
logic req_o_2;                         // Enable signal for level 2[higher level], it has active requests or not 

logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] req_o_0; // Request signal for level 1 [intermediate level]
logic [Lvl2_PIXELS-1:0][Lvl2_PIXELS-1:0] req_o_1;  // Request signal for level 2 [higher level]
logic [Lvl0_ADD-1:0] x_add_0;       // Row Address for level 0 
logic [Lvl0_ADD-1:0] y_add_0;       // Column Address for level 0 
logic [Lvl1_ADD-1:0] x_add_1;       // Row Address for level 1 
logic [Lvl1_ADD-1:0] y_add_1;       // Column Address for level 1 
logic [Lvl2_ADD-1:0] x_add_2;       // Row Address for level 2 
logic [Lvl2_ADD-1:0] y_add_2;       // Column Address for level 2 

logic [Lvl0_GROUP_SIZE-1:0][Lvl0_GROUP_SIZE-1:0] gnt_o_0; // Grant signals for level 0
logic [Lvl1_GROUP_SIZE-1:0][Lvl1_GROUP_SIZE-1:0] gnt_o_1; // Grant signals for level 1
logic [Lvl2_PIXELS-1:0][Lvl2_PIXELS-1:0] gnt_o_2;         // Grant signals for level 2

logic grp_release_0, grp_release_1;  // Group release signals for levels 0 and 1

logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0] gnt_out_1; // Signal is used to give as enable to the lower level [level0 from level1] 


// Signal assignments
assign enable = req_o_2; // Enable signal for the level2 [higher level]

assign x_add = {x_add_2, x_add_1, x_add_0};  // Combine all levels Row addresses 
assign y_add = {y_add_2, y_add_1, y_add_0};  // Combine all levels column address 

// polarity input for the Polarity Selector module
assign polarity_in = set_i[x_add][y_add]; // Sends the active row's ,column's request polarity to the polarity module.

assign active = active_0 & active_1 & active_2; // overall arbitration is active if all levels arbitration active 


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
    .Lvl_ROWS    (Lvl2_PIXELS) ,          // Number of rows in level 2
    .Lvl_COLS    (Lvl2_PIXELS) ,          // Number of columns in level 2
    .Lvl_ROW_ADD (Lvl2_ADD)    ,          // Address width for row in level 2
    .Lvl_COL_ADD (Lvl2_ADD)               // Address width for column in level 2
) 
level_2 
(
    .clk_i          (clk_i)          ,     // Input clock
    .reset_i        (reset_i)        ,     // Input Reset
    .enable_i       (enable)         ,     // Input Enable
    .req_i          (req_o_1)          ,     // Request input from level 1
    .grp_release_i  (grp_release_1)  ,     // Group release from level 1
    .gnt_o          (gnt_o_2)          ,     // Grant output for level 2
    .x_add_o        (x_add_2)        ,     // row index output from level 2
    .y_add_o        (y_add_2)        ,     // column index output from level 2
    .active_o       (active_2)       ,     // Active signal from level 2 indicates the higher level arbitration is active or not
    .req_o          (req_o_2)          ,     // enable input for level 2 
    .grp_release_o  (grp_release_out)      // Group release for level 2,it will high if grants all active requests
);

// Instantiating pixel groups for Intermediate Level
pixel_groups_l1 level_1 
 (
    .clk_i          (clk_i)          ,     // Input clock
    .reset_i        (reset_i)        ,     // Input reset
    .gnt_top_i      (gnt_o_2)          ,     // Grant output from level 2 as enable
    .grp_release_i  (grp_release_0)  ,     // Group release from final level acts as clock
    .set_i          (req_o_0)        ,     // Request input for Final Level
    .gnt_o_high     (gnt_out_1)      ,     // Grant output for lower level as enable
    .gnt_o          (gnt_o_1)        ,     // Grant output for Intermediate groups
    .x_add_o        (x_add_1)        ,     // row address for Intermediate groups
    .y_add_o        (y_add_1)        ,     // Column address for Intermediate groups
    .active_o       (active_1)       ,     // Active signal from Intermediate Level indicates the Intermediate arbitration is active or not
    .req_o          (req_o_1)          ,     // Request from level 1 each groups to higher level
    .grp_release_o  (grp_release_1)        // Group release for level 1,it will high if grants all active requests in level1 
);

// Instantiating  for Final Level
pixel_groups_l0 level_0 
(
    .clk_i          (clk_i)          ,    // Input clock 
    .reset_i        (reset_i)        ,    //Input Reset
    .gnt_top_i      (gnt_out_1)      ,    // Grant output from level 1 as enable
    .set_i          (set_i)          ,    // Pixel set input with polarity
    .gnt_o          (gnt_o_0)        ,    // Lower-level grant outputs
    .gnt_o_0        (gnt_o)          ,    // Overall grant for active requests
    .x_add_o        (x_add_0)        ,    // row address for level 0
    .y_add_o        (y_add_0)        ,    // column address for level 0
    .req_o          (req_o_0)         ,    // Request input for level 1
    .grp_release_o  (grp_release_0)  ,    // indication to the higher level as group has granted all active requests
    .active_o       (active_0)            // Active signal from level0 indication active arbitration in level0  
);

// Wall clock module to capture the timestamp
wall_clock time_stamp 
(
    .clk_i       (clk_i)    ,           // Clock input
    .reset_i     (reset_i)  ,           // Reset input
    .timestamp_o (timestamp)            // Timestamp output
);

// Instantiate the polarity selector module to get the polarity for the selected pixel
polarity_selector polarity_sel 
(
    .clk_i        (clk_i)       ,       // Clock input
    .reset_i      (reset_i)     ,       // Reset input
    .req_i        (polarity_in) ,       // Polarity request input (from the active pixel)
    .polarity_out (polarity)            // Output polarity signal
);

// Instantiate the address event generator module to combine event data
AER address_event 
(
    .enable_i     (active)   ,       // Enable signal based on active arbitration in all each level
    .x_add_i      (x_add_ff) ,       // Active event's Row address 
    .y_add_i      (y_add_ff) ,       // Active event's Column address 
    .timestamp_i  (timestamp),       // Event's timestamp 
    .polarity_i   (polarity) ,       // Polarity output from polarity selector
    .data_out_o   (data_out_o)       // Combined event data output
);  

endmodule



