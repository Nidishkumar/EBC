///////////////////////////////////////////////////////////////////////////////////////////////////
`include "pixel_groups.sv"
`include "pixel_level_0.sv"
`include "pixel_level_1.sv"
`include "column_arbiter.sv"
`include "row_arbiter.sv"
`include "event_encoder.sv"
`include "polarity_selector.sv"
`include "wall_clock.sv"
`include "priority_arb.sv"


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

logic active;
logic polarity;
logic enable_in;
logic [SIZE-1:0] timestamp;

//---------------------------------Signals for Single pixel array-----------------------------------------------------------------------------------------------
logic [ROWS[0]-1:0][COLS[0]-1:0] req_1_in;
logic req_1_o;   
logic enable_1_in;
logic [ROWS[0]-1:0][COLS[0]-1:0] grant_1_out;
logic [Lvl_ADD[0]-1:0] x_add_1_out;
logic [Lvl_ADD[0]-1:0] y_add_1_out;
logic active_1_out;
logic grp_release_1_out;

//---------------------------------Assigments for Single pixel array-----------------------------------------------------------------------------------------------
assign enable_1_in = req_1_o;
//---------------------------------End of Assigments for Single pixel array-----------------------------------------------------------------------------------------------
//---------------------------------Signals for Single pixel array-----------------------------------------------------------------------------------------------


logic req_o;
assign enable_in = req_o;

logic [POLARITY-1:0]polarity_in;
logic [ROW_ADD-1:0]x_add;
logic [COL_ADD-1:0]y_add;

logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] req;

logic [Lvl_ROWS[NO_levels-1]-1:0][Lvl_COLS[NO_levels-1]-1:0] grant_out [NO_levels-1:0]; // Grant output for all levels Groups
logic [Lvl_ADD[NO_levels-1]-1:0] x_add_out [NO_levels-1:0];                              // Row address output for all levels
logic [Lvl_ADD[NO_levels-1]-1:0] y_add_out [NO_levels-1:0];                              // Column address output for all levels
logic grp_release_out [NO_levels-1:0];                                                   // Group release signals for all levels
logic active_out [NO_levels-1:0];                                                        // Arbitration active status output for all levels

assign grp_release_out_o= NO_levels==1 ? grp_release_1_out : grp_release_out[NO_levels-1];

//----------------------------GENERATE BLOCK FOR LEVEL HIERARCHY-----------------------------------------------------------------------------------------------

if (NO_levels > 1) begin
    genvar i, j, k;
    generate
    for (i = 0; i < NO_levels-1; i = i + 1) begin : level_hierarchy
        logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb;   
        logic [ROWS[i]-1:0][COLS[i]-1:0] req_in;         
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] req_out;      
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] enable_in;      
        logic grp_out;

        if (i == 0) begin
            for (j = 0; j < ROWS[i]; j = j + 1) begin : loops1
                for (k = 0; k < COLS[i]; k = k + 1) begin : loops2
                    assign req_in[j][k] = |req_i[j][k];
                end
            end
            assign grp_out = 1'b1;
            for (j = 0; j < ROWS[i+1]; j = j + 1) begin : loops3
                for (k = 0; k < COLS[i+1]; k = k + 1) begin : loops4
                    assign enable_in[j][k] = level_hierarchy[i+1].grant_enb[j][k];   
                end
            end
            for (j = 0; j < ROWS[i]; j = j + 1) begin : loops4
                for (k = 0; k < COLS[i]; k = k + 1) begin : loops5
                    assign gnt_out_o[j][k] = grant_enb[j][k];
                end
            end
        end else begin
            for (j = 0; j < ROWS[i]; j = j + 1) begin : loops6
                for (k = 0; k < COLS[i]; k = k + 1) begin : loops7
                    assign req_in[j][k] = level_hierarchy[i-1].req_out[j][k];   
                end
            end
            assign grp_out = grp_release_out[i-1];
            if (i < NO_levels-2) begin
                for (j = 0; j < ROWS[i+1]; j = j + 1) begin : loops8
                    for (k = 0; k < COLS[i+1]; k = k + 1) begin : loops9
                        assign enable_in[j][k] = level_hierarchy[i+1].grant_enb[j][k];   
                    end
                end
            end else begin
                for (j = 0; j < ROWS[i+1]; j = j + 1) begin : loops10
                    for (k = 0; k < COLS[i+1]; k = k + 1) begin : loops11
                        assign enable_in[j][k] = grant_out[NO_levels-1][j][k];           
                    end
                end   
            end
            if (i == NO_levels-2) begin
                for (j = 0; j < ROWS[i+1]; j = j + 1) begin : loops12
                    for (k = 0; k < COLS[i+1]; k = k + 1) begin : loops13
                        assign req[j][k] = req_out[j][k];
                    end
                end
            end
        end

        pixel_groups #(
            .LEVEL(i),                
            .ROWS(ROWS[i]),           
            .COLS(COLS[i]),           
            .Lvl_ROWS(Lvl_ROWS[i]),   
            .Lvl_COLS(Lvl_COLS[i]),   
            .Lvl_ADD(Lvl_ADD[i]),     
            .NUM_GROUP(NUM_GROUP[i]), 
            .NXT_ROWS(ROWS[i+1]),     
            .NXT_COLS(COLS[i+1])      
        ) level_inst (
            .clk_i(clk_i),              
            .reset_i(reset_i),          
            .enable_i(enable_in),       
            .grp_enable_i(grp_out),     
            .req_i(req_in),             
            .gnt_o(grant_out[i]),       
            .gnt_out_o(grant_enb),      
            .x_add_o(x_add_out[i]),     
            .y_add_o(y_add_out[i]),     
            .active_o(active_out[i]),   
            .req_o(req_out),            
            .grp_release_o(grp_release_out[i])
        );
    end
    endgenerate
end 
else begin
    always_comb begin
        for (int j = 0; j < ROWS; j = j + 1) begin
            for (int k = 0; k < COLS; k = k + 1) begin
                req_1_in[j][k] = |req_i[j][k];
            end
        end
    end

    pixel_level_0 #(
        .Lvl_ROWS(ROWS[0]),   // Number of rows for the highest level
        .Lvl_COLS(COLS[0]),   // Number of columns for the highest level
        .Lvl_ADD(Lvl_ADD[0])  // Address width for the highest level
    ) next_level (
        .clk_i(clk_i),                              // System clock input
        .reset_i(reset_i),                          // System reset input
        .enable_i(enable_1_in),                       // Enable signal for the highest level
        .req_i(req_1_in),                                // Request input for the highest level
        .gnt_o(grant_1_out),             // Grant output for the highest level
        .x_add_o(x_add_1_out),           // row address output for the highest level
        .y_add_o(y_add_1_out),           // column address output for the highest level
        .req_o(req_1_o),                              // Request output to control the Higher level
        .active_o(active_1_out),         // Active status output for the highest level
        .grp_release_o(grp_release_1_out) // Group release output for the highest level
    );
end




pixel_level_1
    #(  
        .Lvl_ROWS(ROWS[NO_levels-1]),   // Number of rows for the highest level
        .Lvl_COLS(ROWS[NO_levels-1]),   // Number of columns for the highest level
        .Lvl_ADD(Lvl_ADD[NO_levels-1])  // Address width for the highest level
    ) 
next_level_1
    (
        .clk_i(clk_i),                              // System clock input
        .reset_i(reset_i),                          // System reset input
        .enable_i(enable_in),                       // Enable signal for the highest level
        .grp_enable_i(grp_release_out[NO_levels-2]),   // Group enable from the previous level
        .req_i(req),                                // Request input for the highest level
        .gnt_o(grant_out[NO_levels-1]),             // Grant output for the highest level
        .x_add_o(x_add_out[NO_levels-1]),           // row address output for the highest level
        .y_add_o(y_add_out[NO_levels-1]),           // column address output for the highest level
        .req_o(req_o),                              // Request output to control the Higher level
        .active_o(active_out[NO_levels-1]),         // Active status output for the highest level
        .grp_release_o(grp_release_out[NO_levels-1]) // Group release output for the highest level
    );

// Combinational block to concatenate address outputs from all levels

// always_comb begin
//         for (int j = NO_levels-1; j >=0; j--) 
//     begin
//                                           // Combines x_add_out[j] with the accumulated x_add
//         x_add = { x_add_out[j]};
//                                           // Combines y_add_out[j] with the accumulated y_add
//         y_add = {y_add_out[j]};
//     end
// end

// assign polarity_in=req_i[x_add][y_add];

// // AND all active_out bits from all levels for the final active signal
// always_comb 
// begin
//     for (int i = 0; i < NO_levels-1; i++) begin
//         active &= active_out[i]; // AND all bits in active_out
//     end
// end  

// Wall clock module to capture timestamp
// wall_clock time_stamp (
//     .clk_i       (clk_i),
//     .reset_i     (reset_i),
//     .timestamp_o (timestamp)
// );

// Polarity selector module to get pixel polarity
// polarity_selector polarity_sel (
//     .clk_i        (clk_i),
//     .reset_i      (reset_i),
//     .req_i        (polarity_in),
//     .polarity_out (polarity)
// );

// //Address Event Representation (AER) to combine event data
// event_encoder address_event (
//     .enable_i     (active), // Enable signal from last arbitration level
//     .x_add_i      (x_add),
//     .y_add_i      (y_add),
//     .timestamp_i  (timestamp),
//     .polarity_i   (polarity),
//     .data_out_o   (data_out_o)
// );

endmodule









































// if (NO_levels > 1) begin
//     genvar i, j, k;
//     generate
//         for (i = 0; i < NO_levels - 1; i++) begin : level_hierarchy
//             logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb;   
//             logic [ROWS[i]-1:0][COLS[i]-1:0] req_in;         
//             logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] req_out;      
//             logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] enable_in;      
//             logic grp_out;
            
//             // Lower level requests
//             for (j = 0; j < ROWS[i]; j++)  
//                 for (k = 0; k < COLS[i]; k++) 
//                     assign req_in[j][k] = |req_i[j][k];

//             // Lower level group release
//             assign grp_out = 1'b1;

//             // Lower level enable
//             for (j = 0; j < ROWS[i+1]; j++)
//                 for (k = 0; k < COLS[i+1]; k++)
//                     assign enable_in[j][k] = level_hierarchy[i+1].grant_enb[j][k];

//             // Lower level Grant
//             for (j = 0; j < ROWS[i]; j++)
//                 for (k = 0; k < COLS[i]; k++)
//                     assign gnt_out_o[j][k] = grant_enb[j][k];

//             if (i > 0) begin
//                 // Intermediate level requests
//                 for (j = 0; j < ROWS[i]; j++)
//                     for (k = 0; k < COLS[i]; k++)
//                         assign req_in[j][k] = level_hierarchy[i-1].req_out[j][k];

//                 // Intermediate level group enable
//                 assign grp_out = grp_release_out[i-1];

//                 // Intermediate level enable
//                 if (i < NO_levels - 2) begin
//                     for (j = 0; j < ROWS[i+1]; j++)
//                         for (k = 0; k < COLS[i+1]; k++)
//                             assign enable_in[j][k] = level_hierarchy[i+1].grant_enb[j][k];
//                 end else begin
//                     for (j = 0; j < ROWS[i+1]; j++)
//                         for (k = 0; k < COLS[i+1]; k++)
//                             assign enable_in[j][k] = grant_out[NO_levels-1][j][k];
//                 end

//                 // Higher level input request
//                 if (i == NO_levels - 2) begin
//                     for (j = 0; j < ROWS[i+1]; j++)
//                         for (k = 0; k < COLS[i+1]; k++)
//                             assign req[j][k] = req_out[j][k];
//                 end
//             end

//             // Instantiate pixel_groups module
//             pixel_groups #(
//                 .LEVEL(i),
//                 .ROWS(ROWS[i]),
//                 .COLS(COLS[i]),
//                 .Lvl_ROWS(Lvl_ROWS[i]),
//                 .Lvl_COLS(Lvl_COLS[i]),
//                 .Lvl_ADD(Lvl_ADD[i]),
//                 .NUM_GROUP(NUM_GROUP[i]),
//                 .NXT_ROWS(ROWS[i+1]),
//                 .NXT_COLS(COLS[i+1])
//             ) level_inst (
//                 .clk_i(clk_i),
//                 .reset_i(reset_i),
//                 .enable_i(enable_in),
//                 .grp_enable_i(grp_out),
//                 .req_i(req_in),
//                 .gnt_o(grant_out[i]),
//                 .gnt_out_o(grant_enb),
//                 .x_add_o(x_add_out[i]),
//                 .y_add_o(y_add_out[i]),
//                 .active_o(active_out[i]),
//                 .req_o(req_out),
//                 .grp_release_o(grp_release_out[i])
//             );

//         end
//     endgenerate
// end
