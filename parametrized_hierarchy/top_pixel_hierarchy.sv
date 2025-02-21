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

logic active;
logic polarity;
logic enable_in;
logic [SIZE-1:0] timestamp;

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

assign grp_release_out_o=grp_release_out[NO_levels-1];

//----------------------------GENERATE BLOCK FOR LEVEL HIERARCHY-----------------------------------------------------------------------------------------------

genvar i, j, k;
generate
    for (i = 0; i < NO_levels-1; i++) begin : level_hierarchy

        logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb ;   
        logic [ROWS[i]-1:0][COLS[i]-1:0] req_in;         
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] req_out ;      
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] enable_in ;      
        logic grp_out;

        if(i==0)
        begin
 //---------------------------------Lower leveL requests-----------------------------------------------------------------------------------------------------------------------
 // Assign input requests to the Lower level from input req_i     
        for (j = 0; j < ROWS[i]; j = j + 1) 
        begin 
            for (k = 0; k < COLS[i]; k = k + 1) 
            begin 
                assign req_in[j][k] = |req_i[j][k];
            end
        end
 //---------------------------------Lower level Grp_release-----------------------------------------------------------------------------------------------------------------------
// Assign group release signals to the Lower level
              assign grp_out=1'b1;
//----------------------------------Lower level Enable--------------------------------------------------------------------------------------------------------------------
    // Assign enable signals to the Lower level from the Higher level       
              for( j=0;j<ROWS[i+1];j++)
              begin
                for( k=0;k<COLS[i+1];k++)
                 begin
                  assign enable_in[j][k]=level_hierarchy[i+1].grant_enb[j][k];
                 end
              end
//-----------------------------------Lower level Grant----------------------------------------------------------------------------------------------------------------------
// Assign the grant signals as output grant from Lower Level
              for (j=0;j<ROWS[i];j++)
              begin
                for( k=0;k<COLS[i];k++)
                 begin
                  assign gnt_out_o[j][k] =grant_enb[j][k];
                 end
              end
 //--------------------------------------------------------------------------------------------------------------------------------------------------------
            end
        else
        begin
 //------------------------------Intermediate level requests--------------------------------------------------------------------------------------------------------------------------
// Assign input requests to the Intermediate levels
             for( j=0;j<ROWS[i];j++)
              begin
                for( k=0;k<COLS[i];k++)
                 begin
                   assign req_in[j][k] =level_hierarchy[i-1].req_out[j][k];
                 end
              end                 
//-------------------------------Intermediate level grp_enable-------------------------------------------------------------------------------------------------------------------------
  // Assign group release signals to the Intermediate levels
                assign grp_out=grp_release_out[i-1];
 //------------------------------Intermediate level enable--------------------------------------------------------------------------------------------------------------------------
  // Assign enable signals to the Intermediate levels
              if(i<NO_levels-2)
                 begin
                 for( j=0;j<ROWS[i+1];j++)
                  begin
                    for( k=0;k<COLS[i+1];k++)
                     begin
                       assign enable_in[j][k] =level_hierarchy[i+1].grant_enb[j][k];   // Enable signal from the next level grant 
                     end
                  end
                end
                else
                begin
                    for( j=0;j<ROWS[i+1];j++)
                  begin
                    for( k=0;k<COLS[i+1];k++)
                     begin
                       assign enable_in[j][k] =grant_out[NO_levels-1][j][k];           // Enable signal from the higher level grant
                     end
                  end   
                end
//--------------------------------Higher level input request------------------------------------------------------------------------------------------------------------------------     
    // Assign input requests to the higher level    
            if(i==NO_levels-2)
            begin
            for( j=0;j<ROWS[i+1];j++)
                        begin
                            for( k=0;k<COLS[i+1];k++)
                            begin
                              assign req[j][k]=req_out[j][k];
                            end
                        end
            end
        end
        // Instantiate the pixel_groups module for Lower and Intermediate levels
        // Instantiation of the pixel_groups module for each level
pixel_groups #(
    .LEVEL(i),                // Current level index
    .ROWS(ROWS[i]),           // Number of rows in the current level
    .COLS(COLS[i]),           // Number of columns in the current level
    .Lvl_ROWS(Lvl_ROWS[i]),   // Level-specific Number of rows
    .Lvl_COLS(Lvl_COLS[i]),   // Level-specific Number of columns
    .Lvl_ADD(Lvl_ADD[i]),     // Level-specific address width
    .NUM_GROUP(NUM_GROUP[i]), // Number of groups in the current level
    .NXT_ROWS(ROWS[i+1]),     // Number of rows in the next level
    .NXT_COLS(COLS[i+1])      // Number of columns in the next level
) level_inst (
    .clk_i(clk_i),              // Clock input
    .reset_i(reset_i),          // Reset input
    .enable_i(enable_in),       // Enable signal for this level
    .grp_enable_i(grp_out),     // Group enable signal from the previous level
    .req_i(req_in),             // Request input signal
    .gnt_o(grant_out[i]),       // Grant output for this level
    .gnt_out_o(grant_enb),      // Enable signal for the next level
    .x_add_o(x_add_out[i]),     // Row address output
    .y_add_o(y_add_out[i]),     // Column address output
    .active_o(active_out[i]),   // Active status output
    .req_o(req_out),            // Request propagation to the next level
    .grp_release_o(grp_release_out[i]) // Group release signal output
);
//------------------------------END OF GENERATE BLOCK ----------------------------------------------------------------------------------------------------------------------------------------------------------
    end
endgenerate

// Instantiate the highest level -pixel level module
pixel_level 
    #(  
        .Lvl_ROWS(ROWS[NO_levels-1]),   // Number of rows for the highest level
        .Lvl_COLS(ROWS[NO_levels-1]),   // Number of columns for the highest level
        .Lvl_ADD(Lvl_ADD[NO_levels-1])  // Address width for the highest level
    ) 
next_level 
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

always_comb begin
        for (int j = NO_levels-1; j >=0; j--) 
    begin
                                          // Combines x_add_out[j] with the accumulated x_add
        x_add = {x_add, x_add_out[j]};
                                          // Combines y_add_out[j] with the accumulated y_add
        y_add = {y_add, y_add_out[j]};
    end
end

assign polarity_in=req_i[x_add][y_add];

// AND all active_out bits from all levels for the final active signal
always_comb 
begin
    for (int i = 0; i < NO_levels-1; i++) begin
        active &= active_out[i]; // AND all bits in active_out
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


