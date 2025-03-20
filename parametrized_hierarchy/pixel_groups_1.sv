
import lib_arbiter_pkg::*; // Importing package for constants

module pixel_groups_1 #(parameter LEVEL = 0, ROWS=16, COLS=16, Lvl_ROWS=2, Lvl_COLS=2, Lvl_ADD=1,NUM_GROUP=16,NXT_ROWS=8,NXT_COLS=8)
(
   input logic clk_i,  
   input logic reset_i,  
   input logic [ROWS-1:0][COLS-1:0] req_i,
   input logic [NXT_ROWS-1:0][NXT_COLS-1:0] enable_i,
   input logic grp_enable_i,
   output logic [NXT_ROWS-1:0][NXT_COLS-1:0] req_o, 
   output logic [ROWS-1:0][COLS-1:0] gnt_out_o,  
   output logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] gnt_o,  
   output logic [Lvl_ADD-1:0] x_add_o,  
   output logic [Lvl_ADD-1:0] y_add_o,  
   output logic active_o,  
   output logic grp_release_o  
 );
// always_comb begin
//             $display("LEVEL[%d]===",LEVEL);
//             for (int j = 0; j < NXT_ROWS; j++) begin
//                 for (int m = 0; m < NXT_COLS; m++) begin
//                     $display($time,"req_o[%0d][%0d][%0d] = %0b",LEVEL, j, m, req_o[j][m]);
//                 end
//             end
//         end
//   always_comb begin
//             $display("===LEVEL [%0d] ====",LEVEL);
//             for ( int j = 0; j < ROWS; j++) begin
//                 for (int m = 0; m < COLS; m++) begin
//                     $display("req_i[%0d][%0d][%0d] = %0b",LEVEL, j, m, req_i[j][m]);
//                 end
//             end
//         end

//    always_comb begin
//             $display("===LEVEL [%0d] ====",LEVEL);
//             for ( int j = 0; j < ROWS; j++) begin
//                 for (int m = 0; m < COLS; m++) begin
//                     $display("grant_o[%0d][%0d][%0d] = %0b",LEVEL, j, m, gnt_out_o[j][m]);
//                 end
//             end
//         end


   //Dynamic group arrays
   logic [NUM_GROUP-1:0][Lvl_ROWS-1:0][Lvl_COLS-1:0] set_group;
   logic [NUM_GROUP-1:0] [Lvl_ADD-1:0] x_add_temp;
   logic [NUM_GROUP-1:0] [Lvl_ADD-1:0] y_add_temp;
   logic [NUM_GROUP-1:0][Lvl_ROWS-1:0][Lvl_COLS-1:0] gnt_temp;
   logic [NUM_GROUP-1:0] active_temp;
   logic [NUM_GROUP-1:0] grp_release_temp;

   assign active_o = |active_temp;  
   // $warning("----------NXT_ROWS[%d] = %0d, NXT_COLS[%d] = %0d -----------", LEVEL, NXT_ROWS, LEVEL, NXT_COLS);

   always_comb begin
       for (int group = 0; group < NUM_GROUP; group++) begin
                  // $warning("------------Loop Passed groups=[%d] ------------------",group); 
           for (int row = 0; row < Lvl_ROWS; row++) begin
               for (int col = 0; col < Lvl_COLS; col++) begin
                   set_group[group][row][col] = req_i[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col];
                   gnt_out_o[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col] = gnt_temp[group][row][col];
               end
           end
       end
   end


generate
        genvar no_group;
        for (no_group = 0; no_group < NUM_GROUP; no_group++) begin : groups
            pixel_level_1 #(
                .Lvl_ROWS(Lvl_ROWS),
                .Lvl_COLS(Lvl_COLS),
                .Lvl_ADD(Lvl_ADD)
            ) next_level (
                .clk_i(clk_i),
                .reset_i(reset_i),
                .enable_i(enable_i[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
                .grp_enable_i(grp_enable_i),
                .req_i(set_group[no_group]),
                .req_o(req_o[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
                .gnt_o(gnt_temp[no_group]),
                .x_add_o(x_add_temp[no_group]),
                .y_add_o(y_add_temp[no_group]),
                .active_o(active_temp[no_group]),
                .grp_release_o(grp_release_temp[no_group])
            );
        end
endgenerate

  
   always_comb begin
       gnt_o = 0;
       x_add_o = 0;
       y_add_o = 0;
       grp_release_o = 0;
 

       for (int group = 0; group < NUM_GROUP; group++) begin

           if (enable_i[group / (ROWS/Lvl_ROWS)][group % (ROWS/Lvl_ROWS)]) 
           begin
               gnt_o = gnt_temp[group];
               x_add_o = x_add_temp[group];
               y_add_o = y_add_temp[group];
               grp_release_o = grp_release_temp[group];
           end
       end
   end
endmodule

// if(LEVEL == 0) 
//   begin
//    genvar no_group;
//    generate
//        for (no_group = 0; no_group < NUM_GROUP; no_group++) 
//        begin : groups
//            pixel_level_0 
// 				#(  
// 				    .Lvl_ROWS(Lvl_ROWS),
// 					.Lvl_COLS(Lvl_COLS),
// 					.Lvl_ADD(Lvl_ADD)
// 				 ) 
// 				next_level 
// 				(
//                .clk_i            (clk_i),
//                .reset_i          (reset_i),
//                .enable_i         (enable_i[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
//                .req_i            (set_group[no_group]),					 
//                .req_o            (req_o[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
//                .gnt_o            (gnt_temp[no_group]),
//                .x_add_o          (x_add_temp[no_group]),
//                .y_add_o          (y_add_temp[no_group]),
//                .active_o         (active_temp[no_group]),
//                .grp_release_o    (grp_release_temp[no_group])
//            );
//        end
//    endgenerate
//   end
//   else
//   begin
//     genvar no_group;
//    generate
//        for (no_group = 0; no_group < NUM_GROUP; no_group++) 
//        begin : groups
//            pixel_level_1
// 				#(  
// 				    .Lvl_ROWS(Lvl_ROWS),
// 					.Lvl_COLS(Lvl_COLS),
// 					.Lvl_ADD(Lvl_ADD)
// 				 ) 
// 				next_level 
// 				(
//                .clk_i            (clk_i),
//                .reset_i          (reset_i),
//                .enable_i         (enable_i[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
//                .grp_enable_i     (grp_enable_i),
//                .req_i            (set_group[no_group]),					 
//                .req_o            (req_o[no_group / (ROWS/Lvl_ROWS)][no_group % (ROWS/Lvl_ROWS)]),
//                .gnt_o            (gnt_temp[no_group]),
//                .x_add_o          (x_add_temp[no_group]),
//                .y_add_o          (y_add_temp[no_group]),
//                .active_o         (active_temp[no_group]),
//                .grp_release_o    (grp_release_temp[no_group])
//            );
//        end
//    endgenerate
//     end