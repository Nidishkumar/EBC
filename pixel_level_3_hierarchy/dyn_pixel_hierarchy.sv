import lib_arbiter_pkg::*;                                // Importing arbiter package containing parameter constants
module dyn_pixel_hierarchy (
input logic clk_i,reset_i,
input logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0][POLARITY-1:0]set_i,
output logic [Lvl0_PIXELS-1:0][Lvl0_PIXELS-1:0]gnt_o,
output logic grp_release_2,
output logic [WIDTH-1:0] data_out_o
);       

logic [ROW_ADD-1:0] x_add;     
logic [COL_ADD-1:0] y_add;

logic [ROW_ADD-1:0] x_add_ff;     
logic [COL_ADD-1:0] y_add_ff;

logic polarity;
logic [SIZE-1:0]timestamp;


logic active_1;
logic active_2;


logic active_0;
logic enable;
logic [POLARITY-1:0] polarity_in;
logic active;


logic req_0;
logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0]req_l0;
logic [Lvl2_PIXELS-1:0][Lvl2_PIXELS-1:0]req_1;
logic [Lvl1_ADD-1:0]x_add_1;
logic [Lvl1_ADD-1:0]y_add_1;
//logic [1:0][1:0]gnt_o_1;
//logic [15:0]grp_release_1;
logic [l0_GROUP_SIZE-1:0][l0_GROUP_SIZE-1:0]gnt_0;
logic [l1_GROUP_SIZE-1:0][l1_GROUP_SIZE-1:0]gnt_1;
logic [Lvl0_ADD-1:0]x_add_0;
logic [Lvl0_ADD-1:0]y_add_0;
logic grp_release_0;
logic grp_release_1;
logic [Lvl2_PIXELS-1:0][Lvl2_PIXELS-1:0]gnt_2;
logic [Lvl2_ADD-1:0]x_add_2;
logic [Lvl2_ADD-1:0]y_add_2;
logic [Lvl1_PIXELS-1:0][Lvl1_PIXELS-1:0]gnt_o_high;
//logic [3:0][3:0]req_0;


assign enable = req_0;
assign gnt_o = 'b0;
assign x_add = {x_add_2,x_add_1,x_add_0};
assign y_add = {y_add_2,y_add_1,y_add_0};
    
// Active row's column requests
assign polarity_in = set_i[x_add][y_add]; // Sends active row's column request polarity to the polarity module.
assign active = active_0 & active_1 & active_2;

    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
               x_add_ff <= 'b0;          
               y_add_ff <= 'b0;
         end 
        else 
		   begin
               x_add_ff <= x_add;          
               y_add_ff <= y_add;
         end 
      end 
		
pixel_top_level 
#(
    
    .Lvl_ROWS(Lvl2_PIXELS),
    .Lvl_COLS(Lvl2_PIXELS),
    .Lvl_ROW_ADD(Lvl2_ADD),
    .Lvl_COL_ADD(Lvl2_ADD)
) 
level_2 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .enable_i(enable),
    .req_i(req_1),
    .grp_release_i(grp_release_1),
    .gnt_o(gnt_2),
    .x_add_o(x_add_2),
    .y_add_o(y_add_2),
    .active_o(active_2),
    .req_o(req_0),
    .grp_release_o(grp_release_2)
);


pixel_groups_l1 pixel_level_1 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .gnt_top_i(gnt_2),
	 .grp_release_i(grp_release_0),
    .set_i(req_l0),
	 .gnt_o_high(gnt_o_high),
    .gnt_o(gnt_1),
    .x_add_o(x_add_1),
    .y_add_o(y_add_1),
    .active_o(active_1),
    .req_o(req_1),
    .grp_release_o(grp_release_1)
);


pixel_groups_l0 level_0
 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .gnt_top_i(gnt_o_high),
    .set_i(set_i),
    .gnt_o(gnt_0),
    .x_add_o(x_add_0),
    .y_add_o(y_add_0),
    .req_o(req_l0),
    .grp_release_o(grp_release_0),
    .active_o(active_0)
);

wall_clock time_stamp 
(
	.clk_i     (clk_i)      ,                // Clock input
    .reset_i   (reset_i)    ,                // Reset input
	.timestamp_o(timestamp)                  // Output the captured timestamp (timestamp_o) from the wallclock module.
		  
);

// Instantiate Polarity Selecter module outputs polarity 
polarity_selector polarity_sel
(
    .clk_i         (clk_i)        , 
    .reset_i       (reset_i)      ,
    .req_i         (polarity_in)  ,         // Polarity request input (column request)
    .polarity_out  (polarity)              // Output polarity signal
);

    //Instantiate Address event module for the event data
AER address_event
( 
    .enable_i   (active)            ,
    .x_add_i    (x_add_ff)          ,             //Event Row address                        
	.y_add_i    (y_add_ff)          ,             //Event Column address  
	.timestamp_i(timestamp)         ,             //captured timestamp data
	.polarity_i (polarity)          ,             //polarity output
	.data_out_o (data_out_o)                        //combines event data like row address ,column address,timestamp and polarity
);	


endmodule