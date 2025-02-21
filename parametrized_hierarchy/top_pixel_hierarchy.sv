///////////////////////////////////////////////////////////////////////////////////////////////////

`include "wall_clock.sv"
`include "row_arbiter.sv"
`include "polarity_selector.sv"
`include "pixel_level.sv"
`include "pixel_groups.sv"
`include "column_arbiter.sv"
`include "Priority_arb.sv"
`include "event_encoder.sv" 

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
logic enable2;
assign enable2=enable;


logic polarity;
logic active;
logic [POLARITY-1:0]polarity_in;
//logic req1;
logic [ROW_ADD-1:0]x_add;
logic [COL_ADD-1:0]y_add;

//assign gnt_out_o='0;
assign data_out_o=data_out_o;

 //logic [ROWS[0]-1:0][COLS[0]-1:0] req;
 logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] req;
//logic [ROWS[0]-1:0][COLS[0]-1:0] req_in;

 logic [Lvl_ROWS[NO_levels-1]-1:0][Lvl_COLS[NO_levels-1]-1:0] gnt_out [NO_levels-1:0]; // Grant output for all levels Groups
// logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] grant_enb [NO_levels-1:0];       // Overall Grant signals for all levels,acts as enable to higher levels
logic [Lvl_ADD[NO_levels-1]-1:0] x_add_out [NO_levels-1:0];       // Row address output for all levels
logic [Lvl_ADD[NO_levels-1]-1:0] y_add_out [NO_levels-1:0];      // Column address output for all levels
logic grp_release_out [NO_levels-1:0];  // Group release signals for all levels
logic active_out [NO_levels-1:0];   // Arbitration active status output for all levels
assign grp_release_out_o=grp_release_out[NO_levels-1];

genvar i, j, k;
generate
    for (i = 0; i < NO_levels-1; i++) begin : level_hierarchy

        logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb ;   
        logic [ROWS[i]-1:0][COLS[i]-1:0] req_out;         
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] req1 ;      
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] enable1 ;      
        logic grp_out;

        if(i==0)
        begin
 //----------------------------------------------------------------------------------------------------------
        for (j = 0; j < ROWS[i]; j = j + 1) begin 
            for (k = 0; k < COLS[i]; k = k + 1) begin 
                assign req_out[j][k] = |req_i[j][k];
            end
        end
 //----------------------------------------------------------------------------------------------------------
              assign grp_out=1'b1;

              for( j=0;j<ROWS[i+1];j++)
              begin
                for( k=0;k<COLS[i+1];k++)
                 begin
                  assign enable1[j][k]=level_hierarchy[i+1].grant_enb[j][k];
                 end
              end
//-----------------------------------------------------------------------------------------------------------
              for (j=0;j<ROWS[i];j++)
              begin
                for( k=0;k<COLS[i];k++)
                 begin
                  assign gnt_out_o[j][k] =grant_enb[j][k];
                 end
              end
            
 //----------------------------------------------------------------------------------------------------------
            end
        else
        begin
 //----------------------------------------------------------------------------------------------------------
             for( j=0;j<ROWS[i];j++)
              begin
                for( k=0;k<COLS[i];k++)
                 begin
                   assign req_out[j][k] =level_hierarchy[i-1].req1[j][k];
                 end
              end                 
//----------------------------------------------------------------------------------------------------------
            
                assign grp_out=grp_release_out[i-1];

                for( j=0;j<ROWS[i+1];j++)
                begin
                    for( k=0;k<COLS[i+1];k++)
                     begin
                       assign enable1[j][k] =gnt_out[NO_levels-1][j][k];
                     end
                end

//----------------------------------------------------------------------------------------------------------
           
            if(i==NO_levels-2)
            begin
            for( j=0;j<ROWS[i+1];j++)
                        begin
                            for( k=0;k<COLS[i+1];k++)
                            begin
                              assign req[j][k]=req1[j][k];
                            end
                        end
            end
 //----------------------------------------------------------------------------------------------------------
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
            .enable_i(enable1),
            .grp_enable_i(grp_out),
            .req_i(req_out),
            .gnt_o(gnt_out[i]),
            .gnt_out_o(grant_enb),
            .x_add_o(x_add_out[i]),
            .y_add_o(y_add_out[i]),
            .active_o(active_out[i]),
            .req_o(req1),  // Propagate to the next level
            .grp_release_o(grp_release_out[i])
        );
    end
endgenerate


pixel_level 
    #(  
        .Lvl_ROWS(ROWS[NO_levels-1]),   // Number of rows for the highest level
        .Lvl_COLS(ROWS[NO_levels-1]),   // Number of columns for the highest level
        .Lvl_ADD(Lvl_ADD[NO_levels-1])  // Address width for the highest level
    ) 
next_level 
    (
        .clk_i(clk_i),                              // System clock input
        .reset_i(reset_i),                           // System reset input
        .enable_i(enable2),                          // Enable signal for the highest level
        .grp_enable_i(grp_release_out[1]),      // Group enable from the previous level
        .req_i(req),                     // Request input for the highest level
        .req_o(enable),                              // Request output for feedback or control
        .gnt_o(gnt_out[NO_levels-1]),                 // Grant output for the highest level
        .x_add_o(x_add_out[NO_levels-1]),             // row address output for the highest level
        .y_add_o(y_add_out[NO_levels-1]),             // column address output for the highest level
        .active_o(active_out[NO_levels-1]),           // Active status output for the highest level
        .grp_release_o(grp_release_out[NO_levels-1])      // Group release output for the highest level
    );



// Combinational block to concatenate address outputs from all levels

always_comb begin
    x_add = '0;                          
    y_add = '0;
        for (int j = NO_levels-1; j >=0; j--) 
    begin
                                          // Combines x_add_out[j] with the accumulated x_add
        x_add = {x_add, x_add_out[j]};
                                          // Combines y_add_out[j] with the accumulated y_add
        y_add = {y_add, y_add_out[j]};
    end
end

assign polarity_in=req_i[x_add][y_add];

// Summing up the active signals dynamically
// always_comb begin
//     active = '0;
//     for (int j = 0; j < NO_levels; j++) begin
assign  active = active_out[2] & active_out[0] &active_out[1];
  //end
 //end

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

//Address Event Representation (AER) to combine event data
event_encoder address_event (
    .enable_i     (active), // Enable signal from last arbitration level
    .x_add_i      (x_add),
    .y_add_i      (y_add),
    .timestamp_i  (timestamp),
    .polarity_i   (polarity),
    .data_out_o   (data_out_o)
);

endmodule


