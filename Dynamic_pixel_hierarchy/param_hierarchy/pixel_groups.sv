
//import lib_arbiter_pkg::*; // Importing package for constants

module pixel_groups #(parameter LEVEL = 0,parameter ROWS=16,parameter COLS=16,parameter Lvl_ROWS=2, parameter Lvl_COLS=2,parameter Lvl_ADD=1)
(
   input logic clk_i,  
   input logic reset_i,  
   input logic [ROWS[LEVEL]-1:0][COLS[LEVEL]-1:0]req_i,
   input logic [ROWS[LEVEL+1]-1:0][COLS[LEVEL+1]-1:0] enable_i,  //higher level singel bit lower has multiple bits
   input logic grp_enable_i,                                        
   output logic [ROWS[LEVEL+1]-1:0][COLS[LEVEL+1]-1:0]req_o, 
   output logic [ROWS[LEVEL]-1:0][COLS[LEVEL]-1:0]gnt_out_o,  
   output logic [Lvl_ROWS[LEVEL]-1:0][Lvl_COLS[LEVEL]-1:0] gnt_o,  
   output logic [Lvl_ADD[LEVEL]-1:0] x_add_o,  
   output logic [Lvl_ADD[LEVEL]-1:0] y_add_o,  
   output logic active_o,  
   output logic grp_release_o  
);

   parameter int NUM_GROUPS = NUM_GROUP[LEVEL]; 

   //Dynamic group arrays
   logic [NUM_GROUPS-1:0][Lvl_ROWS[LEVEL]-1:0][Lvl_COLS[LEVEL]-1:0] set_group;
   logic [NUM_GROUPS-1:0] [Lvl_ADD[LEVEL]-1:0] x_add_temp;
   logic [NUM_GROUPS-1:0] [Lvl_ADD[LEVEL]-1:0] y_add_temp;
   logic [NUM_GROUPS-1:0][Lvl_ROWS[LEVEL]-1:0][Lvl_COLS[LEVEL]-1:0] gnt_temp;
   logic [NUM_GROUPS-1:0] active_temp;
   logic [NUM_GROUPS-1:0] grp_release_temp;

   assign active_o = |active_temp;  

   always_comb begin
       for (int group = 0; group < NUM_GROUPS; group++) begin
           for (int row = 0; row < Lvl_ROWS[LEVEL]; row++) begin
               for (int col = 0; col < Lvl_COLS[LEVEL]; col++) begin
           //  $warning("------------Loop Passed groups=[%d]------------------",group); 
       
                   set_group[group][row][col] = req_i[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col];
                   gnt_out_o[(group / (ROWS / Lvl_ROWS)) * Lvl_ROWS + row][(group % (COLS / Lvl_COLS)) * Lvl_COLS + col] = gnt_temp[group][row][col];
               end
           end
       end
   end

   // Instantiate lower-level pixel groups dynamically
   genvar group;
   generate
       for (group = 0; group < NUM_GROUPS; group++) 
       begin : groups
           pixel_level 
				#(  
				    .Lvl_ROWS(Lvl_ROWS),
					.Lvl_COLS(Lvl_COLS),
					.Lvl_ADD(Lvl_ADD)
				 ) 
				next_level 
				(
               .clk_i            (clk_i),
               .reset_i          (reset_i),
               .enable_i         (enable_i[group / (ROWS[LEVEL]/Lvl_ROWS[LEVEL])][group % (ROWS[LEVEL]/Lvl_ROWS[LEVEL])]),
               .grp_enable_i     (grp_enable_i),
               .req_i            (set_group[group]),					 
               .req_o            (req_o[group / (ROWS[LEVEL]/Lvl_ROWS[LEVEL])][group % (ROWS[LEVEL]/Lvl_ROWS[LEVEL])]),
               .gnt_o            (gnt_temp[group]),
               .x_add_o          (x_add_temp[group]),
               .y_add_o          (y_add_temp[group]),
               .active_o         (active_temp[group]),
               .grp_release_o    (grp_release_temp[group])
           );
       end
   endgenerate

   always_comb begin
    //    gnt_o = 0;
    //    x_add_o = 0;
    //    y_add_o = 0;
    //    grp_release_o = 0;
 

       for (int group = 0; group < NUM_GROUPS; group++) begin

           if (enable_i[group / (ROWS[LEVEL]/Lvl_ROWS[LEVEL])][group % (ROWS[LEVEL]/Lvl_ROWS[LEVEL])]) 
           begin
               gnt_o = gnt_temp[group];
               x_add_o = x_add_temp[group];
               y_add_o = y_add_temp[group];
               grp_release_o = grp_release_temp[group];
           end
       end
   end
endmodule

