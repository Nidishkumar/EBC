
// import lib_arbiter_pkg::*; // Importing package for constants

// module pixel_groups_1 #(parameter LEVEL = 0, ROWS=16, COLS=16, Lvl_ROWS=2, Lvl_COLS=2, Lvl_ADD=1,NUM_GROUP=16,NXT_ROWS=8,NXT_COLS=8)
// (
//    input logic clk_i,  
//    input logic reset_i,  
//    input logic [ROWS-1:0][COLS-1:0] req_i,
//    input logic [NXT_ROWS-1:0][NXT_COLS-1:0] enable_i,
//    input logic grp_enable_i,
//    output logic [NXT_ROWS-1:0][NXT_COLS-1:0] req_o, 
//    output logic [ROWS-1:0][COLS-1:0] gnt_out_o,  
//   // output logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] gnt_o,  
//    output logic [Lvl_ADD-1:0] x_add_o,  
//    output logic [Lvl_ADD-1:0] y_add_o,  
//    output logic active_o,  
//    output logic grp_release_o  
//  );

//    //Dynamic group arrays
//    logic [NUM_GROUP-1:0][Lvl_ROWS-1:0][Lvl_COLS-1:0] set_group;
//    logic [NUM_GROUP-1:0] [Lvl_ADD-1:0] x_add_temp;
//    logic [NUM_GROUP-1:0] [Lvl_ADD-1:0] y_add_temp;
//    logic [NUM_GROUP-1:0][Lvl_ROWS-1:0][Lvl_COLS-1:0] gnt_temp;
//    logic [NUM_GROUP-1:0] active_temp;
//    logic [NUM_GROUP-1:0] grp_release_temp;

//    assign active_o = |active_temp;  

//    always_comb begin
//        for (int group = 0; group < NUM_GROUP; group++) begin
//            for (int row = 0; row < Lvl_ROWS; row++) begin
//                for (int col = 0; col < Lvl_COLS; col++) begin
//                    set_group[group][row][col] = req_i[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col];
//                    gnt_out_o[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col] = gnt_temp[group][row][col];
//                end
//            end
//        end
//    end


// generate
//         genvar no_group;
//         for (no_group = 0; no_group < NUM_GROUP; no_group++) begin : groups
//             pixel_level_1 #(
//                 .Lvl_ROWS(Lvl_ROWS),
//                 .Lvl_COLS(Lvl_COLS),
//                 .Lvl_ADD(Lvl_ADD)
//             ) next_level (
//                 .clk_i(clk_i),
//                 .reset_i(reset_i),
//                 .enable_i(enable_i[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
//                 .grp_enable_i(grp_enable_i),
//                 .req_i(set_group[no_group]),
//                 .req_o(req_o[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
//                 .gnt_o(gnt_temp[no_group]),
//                 .x_add_o(x_add_temp[no_group]),
//                 .y_add_o(y_add_temp[no_group]),
//                 .active_o(active_temp[no_group]),
//                 .grp_release_o(grp_release_temp[no_group])
//             );
//         end
// endgenerate

  
//    always_comb begin
//     //   gnt_o = 0;
//        x_add_o = 0;
//        y_add_o = 0;
//        grp_release_o = 0;
 

//        for (int group = 0; group < NUM_GROUP; group++) begin

//            if (enable_i[group / (ROWS/Lvl_ROWS)][group % (ROWS/Lvl_ROWS)]) 
//            begin
//            //    gnt_o = gnt_temp[group];
//                x_add_o = x_add_temp[group];
//                y_add_o = y_add_temp[group];
//                grp_release_o = grp_release_temp[group];
//            end
//        end
//    end
// endmodule
//----------------------------------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*; // Importing package for constants

module pixel_groups_1 #(parameter LEVEL = 0, 
                        ROWS=16, COLS=16, 
                        Lvl_ROWS=2, Lvl_COLS=2, 
                        Lvl_ADD=1, NUM_GROUP=16, 
                        NXT_ROWS=8, NXT_COLS=8)
(
   input logic clk_i,    // Clock input
   input logic reset_i,  // Reset input
   input logic [ROWS-1:0][COLS-1:0] req_i,            // Input request signals from pixels
   input logic [NXT_ROWS-1:0][NXT_COLS-1:0] enable_i, // Enable signal for pixel groups
   input logic grp_enable_i,                          // group enable signal from previous level
   
   output logic [NXT_ROWS-1:0][NXT_COLS-1:0] req_o,   // Output requests to the next level
   output logic [ROWS-1:0][COLS-1:0] gnt_out_o,       // Grant signals for pixel groups
   output logic [Lvl_ADD-1:0] x_add_o,                // row address output
   output logic [Lvl_ADD-1:0] y_add_o,                // Column address output
   output logic active_o,                             // Indicates if any group is active
   output logic grp_release_o                         // Group release signal
 );

   // Dynamic group arrays to store requests and grant signals for groups
   logic [NUM_GROUP-1:0][Lvl_ROWS-1:0][Lvl_COLS-1:0] set_group; // Stores requests for each group
   logic [NUM_GROUP-1:0] [Lvl_ADD-1:0] x_add_temp;              // Temporary row address output storage
   logic [NUM_GROUP-1:0] [Lvl_ADD-1:0] y_add_temp;              // Temporary Column address output storage
   logic [NUM_GROUP-1:0][Lvl_ROWS-1:0][Lvl_COLS-1:0] gnt_temp;  // Temporary grant storage
   logic [NUM_GROUP-1:0] active_temp;                           // Stores active status of each group
   logic [NUM_GROUP-1:0] grp_release_temp;                      // Stores group release signals

   // Set active_o if any group is active
   assign active_o = |active_temp;  

   // Assign requests and grants for each group dynamically
   always_comb begin
       for (int group = 0; group < NUM_GROUP; group++) begin
           for (int row = 0; row < Lvl_ROWS; row++) begin
               for (int col = 0; col < Lvl_COLS; col++) begin
                   // Mapping pixel requests to groups
                   set_group[group][row][col] = req_i[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col];
                   // Assigning grants to respective pixels
                   gnt_out_o[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col] = gnt_temp[group][row][col];
               end
           end
       end
   end

   // Generate instances of pixel_level_1 for each group
   generate
        genvar no_group;
        for (no_group = 0; no_group < NUM_GROUP; no_group++) begin : groups
            pixel_level_1 #(
                .Lvl_ROWS       (Lvl_ROWS),                      // Number of pixel rows in levels
                .Lvl_COLS       (Lvl_COLS),                      // Number of pixel columns in level       
                .Lvl_ADD        (Lvl_ADD)                         // Address width of each level
            ) 
            next_level
            (
                .clk_i          (clk_i),                           // Clock input
                .reset_i        (reset_i),                         // Reset input
                .enable_i       (enable_i[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]), // Previos Level Grant as Enable signal
                .grp_enable_i   (grp_enable_i),                    // group enable signal
                .req_i          (set_group[no_group]),             // Grouped pixel requests
                .req_o          (req_o[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]), // Group request output
                .gnt_o          (gnt_temp[no_group]),              // Group grant output
                .x_add_o        (x_add_temp[no_group]),            // X-address output
                .y_add_o        (y_add_temp[no_group]),            // Y-address output
                .active_o       (active_temp[no_group]),           // Active status
                .grp_release_o  (grp_release_temp[no_group])       // Group release signal
            );
        end
   endgenerate

   // Assigning outputs based on enabled groups
   always_comb begin
       x_add_o = 0;
       y_add_o = 0;
       grp_release_o = 0;

       for (int group = 0; group < NUM_GROUP; group++) 
       begin
           if (enable_i[group / (ROWS/Lvl_ROWS)][group % (ROWS/Lvl_ROWS)]) 
           begin
               x_add_o = x_add_temp[group];             // Assign X-address
               y_add_o = y_add_temp[group];             // Assign Y-address
               grp_release_o = grp_release_temp[group]; // Assign release signal
           end
       end
   end
endmodule
