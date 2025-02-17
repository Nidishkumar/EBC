///////////////////////////////////////////////////////////////////////////////////////////////////
`include "wall_clock.sv"
`include "row_arbiter.sv"
`include "polarity_selector.sv"
`include "pixel_level.sv"
`include "pixel_groups.sv"
`include "column_arbiter.sv"
`include "Priority_arb.sv"
`include "event_encoder.sv" 
`include "lib_arbiter_pkg.sv"

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

assign gnt_out_o='0;
assign data_out_o='0;
assign grp_release_out_o='0;

 //logic [ROWS[0]-1:0][COLS[0]-1:0] req;
 logic [ROWS[2]-1:0][COLS[2]-1:0] req;
 // Combinational block for polarity reduction
// always_comb begin
//     // Loop through all rows and columns
//     for (int m = 0; m < ROWS1; m++) begin
//         for (int j = 0; j < COLS1; j++) begin   
//             // If any bit is high, req[0][m][j] becomes high
//             req[m][j] = |req_i[m][j];
//         end
//     end
// end
 logic [Lvl_ROWS[2]-1:0][Lvl_COLS[2]-1:0] gnt_out [NO_levels-1:0]; // Grant output for all levels Groups
// logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] grant_enb [NO_levels-1:0];       // Overall Grant signals for all levels,acts as enable to higher levels
logic [Lvl_ADD[2]-1:0] x_add_out [NO_levels-1:0];       // Row address output for all levels
logic [Lvl_ADD[2]-1:0] y_add_out [NO_levels-1:0];      // Column address output for all levels
logic grp_release_out [NO_levels-1:0];  // Group release signals for all levels
logic active_out [NO_levels-1:0];   // Arbitration active status output for all levels

// assign gnt_out_o = grant_enb[0];
// always_comb
// begin
// for (int i = 0; i < NO_levels; i++) begin
//     end
// end

//logic grp_release [NO_levels-1:0]; //previous declaration
// Generate block to create hierarchy for each level
// genvar i,j,m;
// generate
      
//     // Loop through all levels except the last one
//     for (i = 0; i < 2; i++) 
//     begin : level_hierarchy

//         // if ((ROWS[i]) > 0 && COLS[i] > 0 && Lvl_ROWS[i] > 0 && Lvl_COLS[i] > 0 && Lvl_ADD[i] > 0) 
//         // begin
//         // logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb [i];          // Grant enable signals for current level
//         // logic [ROWS[i]-1:0][COLS[i]-1:0] req [i];                // Request signals for current level
//         // logic [Lvl_ROWS[i]-1:0][Lvl_COLS[i]-1:0] gnt_out [i];           // Grant output signals for current level
//         // logic  x_add_o [i];                // X-coordinate address output for current level
//         // logic  y_add_o [i]; 
//         // logic grp_release [i];  // Group release signals for all levels
//         // logic active [i];   
//         typedef logic [ROWS[i]-1:0][COLS[i]-1:0] array_1;
//         typedef logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] array_2;
//         logic grp_out;
//         array_1 enable[2];
//         array_1 grant_enb[2];
//         array_1 req_out[2]; 
//         array_2 req1[2];
    
  
//    if(i==0)
//    begin
//     for (j = 0; j < ROWS[0]; j++) 
//     begin 
//         for (m = 0; m < COLS[0]; m++) begin
//            assign req_out[i][j][m] = req[j][m];
//         end
//     end
//     assign grp_out=1'b1;
//     for (j = 0; j < ROWS[1]; j++) 
//     begin 
//         for (m = 0; m < COLS[1]; m++) begin
//            assign enable[i][j][m] = grant_enb[i+1][j][m];
//         end
//     end

//    end
//    else
//    begin
//       for (j = 0; j < ROWS[i]; j++) 
//     begin 
//         for (m = 0; m < COLS[i]; m++) begin
//            assign req_out[i][j][m] = req1[i][j][m];
//         end
//     end
//     assign grp_out=grp_release_out[i-1];
//     for (j = 0; j < ROWS[i+1]; j++) 
//     begin 
//         for (m = 0; m < COLS[i+1]; m++) begin
//            assign enable[i][j][m] = gnt_out[2][j][m];
//         end
//     end
//    end

//         $warning("----------Lvl_ROWS[%d] = %0d, Lvl_COLs[%d] = %0d -----------",i,Lvl_ROWS[i],i, Lvl_COLS[i]);

//         pixel_groups
//         #(
//             .LEVEL(i),                 // Current level index
//             .ROWS(ROWS[i]),             // Row count for current level
//             .COLS(COLS[i]),             // Column count for current level
//             .Lvl_ROWS(Lvl_ROWS[i]),     // Selected Level number of rows 
//             .Lvl_COLS(Lvl_COLS[i]),     // Selected Level number of rows column 
//             .Lvl_ADD(Lvl_ADD[i]),      // Address width for current level
//             .NUM_GROUP(NUM_GROUP[i])

//         ) 
//         level_inst
//         (
//             .clk_i          (clk_i),                    // System clock input
//             .reset_i        (reset_i),                  // System reset input
//             .enable_i       (enable[i]),           // Enable signal from the higher level
//             .grp_enable_i   (grp_out), // Group enable signal from previous level 
//             .req_i          (req_out[i]),                   // Request input for current level
//             .gnt_o          (gnt_out[i]),               // Grant output for current level
//             .gnt_out_o      (grant_enb[i]),             // Grant enable output for current level
//             .x_add_o        (x_add_out[i]),             // Row address output for current level
//             .y_add_o        (y_add_out[i]),             // Column address output for current level
//             .active_o       (active_out[i]),            // Active status output for current level
//             .req_o          (req1[i]),                 // Request output to the next level
//             .grp_release_o  (grp_release_out[i])            // Group release output for current level
//         );
//     //    assign req_f=req1[2];

//     end

// endgenerate

genvar i, j, m;
    generate
        // Loop through all levels except the last one
        for (i = 0; i < NO_levels-1; i++) begin : level_hierarchy
        //     typedef logic [ROWS[i]-1:0][COLS[i]-1:0] array_1;
        //     typedef logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] array_2;
        //     logic grp_out;
        //     array_2 enable;
        //     array_1 grant_enb;
        //     array_1 req_out; 
        //     array_2 req1;
         logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb [1:0];  
         logic [ROWS[i]-1:0][COLS[i]-1:0] req_out [1:0];      
         logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] req1 [1:0];      
         logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] enable1 [1:0];      
         logic grp_out;

            if (i == 0) begin
                for (j = 0; j < ROWS[i]; j++) begin
                    for (m = 0; m < COLS[i]; m++) begin
                        assign req_out[i][j][m] = |req_i[j][m];
                    end
                end
            
            for ( j= 0; j < ROWS[0]; j++) begin
                $warning("[ ");  
                for ( m = 0; m < COLS[0]; m++) 
                begin
                    $warning("%b ", |req_i[j][m]);  
                end
                   $warning("]\n"); // End of row and move to next line
                end
                assign grp_out = 1'b1;
                for (j = 0; j < ROWS[i+1]; j++) begin
                    for (m = 0; m < COLS[i+1]; m++) begin
                        assign enable1[0][j][m] = grant_enb[1][j][m];
                    end
                end
            end 
            else begin
                for (j = 0; j < ROWS[i]; j++) begin
                    for (m = 0; m < COLS[i]; m++) begin
                        assign req_out[i][j][m] = req1[i-1][j][m];
                    end
                end
                assign grp_out = grp_release_out[i-1];
                for (j = 0; j < ROWS[i+1]; j++) begin
                    for (m = 0; m < COLS[i+1]; m++) begin
                        assign enable1[i][j][m] = gnt_out[i+1][j][m];
                    end
                end
                for (j = 0; j < ROWS[2]; j++) begin
                    for (m = 0; m < COLS[2]; m++) begin
                        assign req[j][m] = req1[j][m];
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
            ) 
            level_inst (
                .clk_i(clk_i),
                .reset_i(reset_i),
                .enable_i(enable1[i]),
                .grp_enable_i(grp_out),
                .req_i(req_out[i]),
                .gnt_o(gnt_out[i]),
                .gnt_out_o(grant_enb[i]),
                .x_add_o(x_add_out[i]),
                .y_add_o(y_add_out[i]),
                .active_o(active_out[i]),
                .req_o(req1[i]),
                .grp_release_o(grp_release_out[i])
            );
       
        end
    endgenerate

// Instantiation of pixel_level module for the highest level

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
        .enable_i(enable1),                          // Enable signal for the highest level
        .grp_enable_i(grp_release_out[NO_levels-2]),      // Group enable from the previous level
        .req_i(req),                     // Request input for the highest level
        .req_o(enable),                              // Request output for feedback or control
        .gnt_o(gnt_out[NO_levels-1]),                 // Grant output for the highest level
        .x_add_o(x_add_out[NO_levels-1]),             // row address output for the highest level
        .y_add_o(y_add_out[NO_levels-1]),             // column address output for the highest level
        .active_o(active_out[NO_levels-1]),           // Active status output for the highest level
        .grp_release_o(grp_release_out[NO_levels-1])      // Group release output for the highest level
    );




always_comb begin
  $display("\n------------ req[0] Matrix (%0dx%0d) ------------", ROWS1, COLS1);
  for (int m = 0; m < ROWS1; m++) begin
    $write("[ ");  // Start of row
    for (int j = 0; j < COLS1; j++) 
    begin
        $write("%b ", req[m][j]);  
    end
    $write("]\n"); // End of row and move to next line
  end
  $display("----------------------------------------\n");
end


// Combinational block to concatenate address outputs from all levels

always_comb begin
    // Initialize x_add and y_add to zero
    x_add = '0;
    y_add = '0;
        for (int j = 0; j < NO_levels; j++) 
    begin
                                          // Combines x_add_out[j] with the accumulated x_add
        x_add = {x_add, x_add_out[j]};
                                          // Combines y_add_out[j] with the accumulated y_add
        y_add = {y_add, y_add_out[j]};
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
// event_encoder address_event (
//     .enable_i     (active), // Enable signal from last arbitration level
//     .x_add_i      (x_add),
//     .y_add_i      (y_add),
//     .timestamp_i  (timestamp),
//     .polarity_i   (polarity),
//     .data_out_o   (data_out_o)
// );

endmodule


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


// function logic [ROW_ADD-1:0] add_con(input logic [Lvl_ADD-1:0]addr);
// for(int i=0;i<NO_levels-1;i++)
//   begin
//     xaddr={xaddr,addr[i]}
//   end
// endfunction

// always_comb
// begin
//     for(int i=0;i<NO_levels;i++)
//     begin
//         x_add=add_con(x_add_out[i]);
//     end
// end
// always_comb
// begin
//     for(int i=0;i<NO_levels;i++)
//     begin
//         y_add=add_con(y_add_out[i]);
//     end
// end




// if(gnt==0001) then (x=00)
// if(gnt==0010) then (x=01)
// if(gnt==0100) then (x=10)
// if(gnt==1000) then (x=11)
// ......
