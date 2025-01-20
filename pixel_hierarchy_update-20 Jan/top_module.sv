module top_module (
input logic clk_i,reset_i,
input logic [15:0][15:0][1:0]set_i,
output logic [3:0][3:0]gnt_o,
output logic grp_release_o,
output logic [40:0] data_out_o
);       

logic [3:0] x_add;     
logic [3:0] y_add;

logic [3:0] x_add_ff;     
logic [3:0] y_add_ff;

logic polarity;
logic [31:0]timestamp;

//logic [3:0][3:0] gnt_top_1;
logic [3:0][3:0] req_1;
logic [15:0]grp_release_0;
logic [3:0][3:0] gnt_o_0;
logic [1:0] x_add_0;
logic [1:0] y_add_0;
logic active_o_1;

logic req_0;
logic [3:0][3:0] gnt_o_1;
logic [1:0] x_add_1;
logic [1:0] y_add_1;
logic active_o_0;
logic enable;
logic [1:0] polarity_in;
logic active;


assign enable = req_0;
assign gnt_o = 'b0;
assign x_add = {x_add_1,x_add_0};
assign y_add = {y_add_1,y_add_0};
    
// Active row's column requests
assign polarity_in = set_i[x_add][y_add]; // Sends active row's column request polarity to the polarity module.
assign active = active_o_0 & active_o_0;

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
pixel_top_level level_1
(
    .clk_i(clk_i),
	.reset_i(reset_i),
	.enable_i(enable),
	.req_i(req_1),
	.grp_release_i(|grp_release_0),
	.gnt_o(gnt_o_1),
	.x_add_o(x_add_1),
	.y_add_o(y_add_1),
	.active_o(active_o_1),
	.req_o(req_0),
	.grp_release_o(grp_release_o)	
);

pixel_groups pixel_level_0
(
	.clk_i(clk_i),
	.reset_i(reset_i),
	.gnt_top_i(gnt_o_1),
	.set_i(set_i),
	.gnt_o(gnt_o_0),
	.x_add_o(x_add_0),
	.y_add_o(y_add_0),
	.active_o(active_o_0),
	.req_o(req_1),
	.grp_release_o(grp_release_0)
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