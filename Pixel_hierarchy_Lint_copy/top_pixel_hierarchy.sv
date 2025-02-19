// Module name: Top Pixel Hierarchy
// Module Description: This module handles the pixel hierarchy for processing pixel requests and generating grant signals.
// It integrates multiple submodules including the polarity selector, timestamp generator, and address event generator.
// Author: []
// Date: []
// Version: []
//------------------------------------------------------------------------------------------------------------------
`include "wall_clock.sv"
`include "row_arbiter.sv"
`include "polarity_selector.sv"
`include "pixel_level_0.sv"
`include "pixel_level_1.sv"
`include "pixel_groups_level_0.sv"
`include "column_arbiter.sv"
`include "Priority_arb.sv"
`include "event_encoder.sv" 
`include "lib_arbiter_pkg.sv"
`include "lib_func_pkg.sv"


import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants

module top_pixel_hierarchy 
(
    input logic clk_i                                    ,  // Input clock for Synchronization
	 input logic reset_i                                  ,  // Reset signal
    input logic [ROWS-1:0][COLS-1:0][POLARITY-1:0] req_i ,  // Pixel requests input with polarity for each pixel
    output logic [ROWS-1:0][COLS-1:0] gnt_out_o          ,  // Grant output  
    output logic grp_release_out_o                       ,  // Group release signal from higher level indicates the all active requests are granted
    output logic [WIDTH-1:0] data_out_o                     // Data output signal combining event data (row address, column address, timestamp and polarity)
);

// Internal signals for addressing pixel data
logic [ROW_ADD-1:0] x_add   ;     
logic [COL_ADD-1:0] y_add   ;
logic [ROW_ADD-1:0] x_add_ff;     
logic [COL_ADD-1:0] y_add_ff;

logic polarity ;                    // Signal for the selected polarity
logic [POLARITY-1:0] polarity_in;   // Input signal for polarity module
logic [SIZE-1:0] timestamp;         // Timestamp signal for event 

logic [NO_levels-1:0]active;        // Active signals form different pixel levels whether the arbitrations in each level active or not
logic active_in;                    // overall arbitration active signal from 2 levels

logic enable;                       // Enable signal to control the higher level
logic req_o_1;                      // Request signal from higher level acts as enable to higher level

logic [Lvl0_ADD-1:0] x_add_0;       // Row Address for lower level 
logic [Lvl0_ADD-1:0] y_add_0;       // Column Address for lower level 
logic [Lvl_ADD-1:0] x_add_1;        // Row Address for higher level 
logic [Lvl_ADD-1:0] y_add_1;        // Column Address for higher level  

logic [Lvl0_ROWS-1:0][Lvl0_COLS-1:0] gnt_o_0; // Grant signals for lower level 
logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] req_o_0;   // Request signal for higher level 
logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] gnt_o_1;   // Grant signals for higher level 

logic [NO_levels-1:0]grp_release;   // Group release signals for lower levels actss as clock to the higher level

//-------------------Signal assignments--------------------------------------------------------------------------------------------
assign enable = req_o_1;                // Enable signal for the higher level
assign grp_release_out_o=grp_release[1];//grp_release as a indication of all active requests are granted
assign x_add = {x_add_1, x_add_0};      // Combine all levels Row addresses 
assign y_add = {y_add_1, y_add_0};      // Combine all levels column address 
assign polarity_in = req_i[x_add][y_add]; // Sends the active row's ,column's request polarity to the polarity module.
assign active_in = &active;               // overall arbitration will active, if all levels arbitration active 
//---------------------------------------------------------------------------------------------------------------------------------------------

//-------------------Granted Pixel Row and Column address logic--------------------------------------------------------------------------------------------
always_ff @(posedge clk_i or posedge reset_i) 
 begin
    if (reset_i) 
    begin
        x_add_ff <= 'b0;      // Reset row address
        y_add_ff <= 'b0;      // Reset column address
    end 
    else 
    begin
        x_add_ff <= x_add;    // Store row address
        y_add_ff <= y_add;    // Store column address
    end 
 end 
//---------------------------------------------------------------------------------------------------------------------------------------------

// Instantiating submodules to handle different pixel levels
pixel_level_1 level_1 
(
    .clk_i          (clk_i)          ,     // Input clock
    .reset_i        (reset_i)        ,     // Input Reset
    .enable_i       (enable)         ,     // Input Enable
    .req_i          (req_o_0)        ,     // Request input from level 1
    .grp_enable_i   (grp_release[0]) ,     // Group release from lower level,acts as clock for higher level 
    .gnt_o          (gnt_o_1)        ,     // Grant output for higher level 
    .x_add_o        (x_add_1)        ,     // Granted row index output higher level 
    .y_add_o        (y_add_1)        ,     // Granted column index output higher level 2
    .active_o       (active[1])      ,     // Active signal from higher level indicates the higher level arbitration is active or not
    .req_o          (req_o_1)        ,     // Acts as enable for this level,if  has active requests  
    .grp_release_o  (grp_release[1])       // Group release for higher level,it will high if grants all active requests
);


// Instantiating  for Final Level
pixel_groups_level_0 level_0 
(
    .clk_i          (clk_i)          ,    // Input clock 
    .reset_i        (reset_i)        ,    //Input Reset
    .enable_i       (gnt_o_1)        ,    // Grant output from level 1 as enable
    .req_i          (req_i)          ,    // Pixel set input with polarity
    .gnt_o          (gnt_o_0)        ,    // Lower-level grant outputs
    .gnt_out_o      (gnt_out_o)      ,    // Overall grant for active requests
    .x_add_o        (x_add_0)        ,    // row address for level 0
    .y_add_o        (y_add_0)        ,    // column address for level 0
	 .active_o       (active[0])      ,    // Active signal from level0 indication active arbitration in level0  
    .req_o          (req_o_0)        ,    // Request input for level 1
    .grp_release_o  (grp_release[0])      // indication to the higher level as group has granted all active requests
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
event_encoder address_event 
(
    .enable_i     (active_in),       // Enable signal based on active arbitration in all each level
    .x_add_i      (x_add_ff) ,       // Active event's Row address 
    .y_add_i      (y_add_ff) ,       // Active event's Column address 
    .timestamp_i  (timestamp),       // Event's timestamp 
    .polarity_i   (polarity) ,       // Polarity output from polarity selector
    .data_out_o   (data_out_o)       // Combined event data output
);  

endmodule



