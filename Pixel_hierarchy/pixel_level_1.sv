module pixel_level_1
(
input logic clk,rst_n,
input logic [15:0][15:0]set,
output logic [3:0][3:0]gnt_o,
output logic [1:0] x_add ,        // Index for selected row in row arbitration logic
output logic [1:0] y_add          // Index for selected column in column arbitration logic
);       

logic [3:0]row;
logic [3:0]col;

logic x_enable,y_enable;

logic [3:0][3:0] req;      // Packed array for 4x4 request signals

 logic [3:0] y_gnt_o ;         // column arbiter grant information
 logic [3:0] x_gnt_o ;         // row arbiter grant information
 
    pixel_level_0 grp0 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[0][0]), .set(set[3:0][3:0]), .req(req[0][0]));
    pixel_level_0 grp1 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[0][1]), .set(set[3:0][7:4]), .req(req[0][1]));
    pixel_level_0 grp2 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[0][2]), .set(set[3:0][11:8]), .req(req[0][2]));
    pixel_level_0 grp3 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[0][3]), .set(set[3:0][15:12]), .req(req[0][3]));

    pixel_level_0 grp4 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[1][0]), .set(set[7:4][3:0]), .req(req[1][0]));
    pixel_level_0 grp5 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[1][1]), .set(set[7:4][7:4]), .req(req[1][1]));
    pixel_level_0 grp6 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[1][2]), .set(set[7:4][11:8]), .req(req[1][2]));
    pixel_level_0 grp7 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[1][3]), .set(set[7:4][15:12]), .req(req[1][3]));

    pixel_level_0 grp8 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[2][0]), .set(set[11:8][3:0]), .req(req[2][0]));
    pixel_level_0 grp9 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[2][1]), .set(set[11:8][7:4]), .req(req[2][1]));
    pixel_level_0 grp10 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[2][2]), .set(set[11:8][11:8]), .req(req[2][2]));
    pixel_level_0 grp11 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[2][3]), .set(set[11:8][15:12]), .req(req[2][3]));

    pixel_level_0 grp12 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[3][0]), .set(set[15:12][3:0]), .req(req[3][0]));
    pixel_level_0 grp13 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[3][1]), .set(set[15:12][7:4]), .req(req[3][1]));
    pixel_level_0 grp14 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[3][2]), .set(set[15:12][11:8]), .req(req[3][2]));
    pixel_level_0 grp15 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[3][3]), .set(set[15:12][15:12]), .req(req[3][3]));
//---------------------------------------------------------------------------------------------
/*
     logic [15:0][3:0][3:0] set_group;

 always_comb
 begin
        for (int group = 0; group < 16; group++) begin 
            for (int row = 0; row < 4; row++) begin 
                for (int col = 0; col < 4; col++) begin 
                     set_group[group][row][col] = set[(group / 4) * 4 + row][(group % 4) * 4 + col];
                end
            end
        end
end

    genvar group;
	 generate
    for ( group = 0; group < 16; group++) 
	 begin : groups
        pixel_level_0 pixel_level0 (
            .clk(clk),
            .rst_n(rst_n),
            .enable(gnt_o[group / 4][group % 4]),
            .set(set_group[group]),
            .req(req[group / 4][group % 4])
        );
    end
endgenerate	
    */
//---------------------------------------------------------------------------------------------

	typedef enum logic [1:0]
 {
       IDLE =2'b00,
		 ROW_GRANT =2'b01,
		 COL_GRANT =2'b10 
 } state_t;
 
 state_t current_state,next_state;
 
 //--------------------------------------------------------------------------------------------------------------
	always_ff @(posedge clk or posedge rst_n) 
	  begin
        if (rst_n) 
		 begin
            current_state <= IDLE;  // Reset state to IDLE when reset is triggered
         end 
		else 
		 begin
            current_state <= next_state;  // Transition to the next state
         end
      end
//------------------------------------------------------------------------------------------------------------
    // FSM next state and output logic based on current state
    always_comb 
	  begin
        // Default state transitions and signal assignments
        next_state = current_state;
        x_enable = 1'b0;           // Disable row arbitration by default
        y_enable = 1'b0;           // Disable column arbitration by default

        case (current_state)
            IDLE: 
			      begin
                 x_enable = 1'b1;       // Enable row arbitration if enable_i is high
                 next_state = ROW_GRANT;// Transition to row grant state
               end 
            ROW_GRANT: 
			      begin
                x_enable = 1'b1;             // Keep row arbitration enabled during ROW_GRANT state
                if (x_gnt_o != {4{1'b0}}) 
				     begin                       // If any row has been granted, move to column grant
                    y_enable = 1'b1;         // Enable column arbitration once row grant is done
                    x_enable = 1'b0;         // Disable row arbitration
                    next_state = COL_GRANT;  // Transition to column grant state
                 end
                end
            COL_GRANT: 
			       begin
                  y_enable = 1'b1;             // Enable column arbitration during COL_GRANT state
                  if (y_gnt_o == {4{1'b0}}) 
				       begin                       // If no column grant, transition back to row arbitration
                    x_enable = 1'b1;         // Enable row arbitration once column grant is done
                    y_enable = 1'b0;         // Disable column arbitration
                    next_state = ROW_GRANT;  // Transition back to row grant state
                   end
                 end
            default:
			 begin
                next_state = IDLE;           // Default state transition to IDLE
             end
        endcase
      end
//----------------------------------------------------------------------------------------------------------

always_comb 
 begin
        row = {4{1'b0}};            // Default: no active requests in any row
        for (int i = 0; i < 4 ; i++) 
         begin
	  for (int j = 0; j < 4; j++) 
         begin
            row[i] = |req[i][j];        // OR all bits in each row to detect active row requests
         end
       end
    end

//----------------------------------------------------------------------------------------------------------------------
always_comb 
 begin
        col = {4{1'b0}};            // Default: no active requests in any row
        
	  for (int j = 0; j < 4; j++) 
         begin
            col[j] = req[x_add][j];        // OR all bits in each row to detect active row requests
         end
       end
//----------------------------------------------------------------------------------------------------------------------
always_comb 
	  begin
        // Initialize all grants to 0
        for (int i = 0; i < 4; i++) 
		 begin
            for (int j = 0; j < 4; j++) 
			 begin
                gnt_o[i][j] = 1'b0;
             end
         end

        // Activate the grant for the selected row and column
        if (x_gnt_o != 0 && y_gnt_o != 0) 
		 begin
            gnt_o[x_add][y_add] = 1'b1; // Grant the intersection of active row and column
         end
      end
//------------------------------------------------------------------------------------------------------------

 x_roundrobin   RRA_X 
    (
        .clk_i     (clk)    ,                  // Clock input
        .reset_i   (rst_n)  ,                  // Reset input
        .enable_i  (x_enable) ,                  // Enable signal for row arbitration
        .req_i     (row)      ,                  // Row requests (active rows)
        .gnt_o     (x_gnt_o)  ,                  // Row grant outputs
        .xadd_o    (x_add)                       // output for row arbitration (index)
    );

    // Instantiate RoundRobin module for column arbitration (y-direction)
    y_roundrobin  RRA_Y 
    (
        .clk_i     (clk)    ,                 // Clock input
        .reset_i   (rst_n)  ,                 // Reset input
        .enable_i  (y_enable) ,                 // Enable signal for column arbitration
        .req_i     (col)      ,                 // Column requests for the active row
        .gnt_o     (y_gnt_o)  ,                 // Column grant outputs
        .yadd_o    (y_add)                      // output for column arbitration (index)
    );

endmodule

