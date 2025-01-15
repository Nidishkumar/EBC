module pixel_level_0 (
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic [3:0][3:0] set,
    output logic [3:0][3:0] gnt_o,
    output logic [1:0] x_add,       // Index for selected row in row arbitration logic
    output logic [1:0] y_add,       // Index for selected column in column arbitration logic
    output logic req
);

    logic [3:0] row;
    logic [3:0] col;
    logic x_enable, y_enable;

    logic [3:0] y_gnt_o; // Column arbiter grant information
    logic [3:0] x_gnt_o; // Row arbiter grant information

    //----------------------------------------------------------------------------------------------------------

    always_comb begin
        req = 1'b0; // Default request
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                req |= set[i][j];
            end
        end
    end

    //----------------------------------------------------------------------------------------------------------

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
					if(enable)
					 begin
                 x_enable = 1'b1;       // Enable row arbitration if enable_i is high
                 next_state = ROW_GRANT;// Transition to row grant state
                end
					else
					 begin
					  x_enable = 1'b0;           // Disable row arbitration by default
                 y_enable = 1'b0; 
					  next_state = IDLE;
					 end
				end
            ROW_GRANT: 
			      begin
					 if(enable)
					 begin
                x_enable = 1'b1;             // Keep row arbitration enabled during ROW_GRANT state
                if (x_gnt_o != {4{1'b0}}) 
				     begin                       // If any row has been granted, move to column grant
                    y_enable = 1'b1;         // Enable column arbitration once row grant is done
                    x_enable = 1'b0;         // Disable row arbitration
                    next_state = COL_GRANT;  // Transition to column grant state
                 end
					 end
					else
					 begin
					      x_enable = 1'b0;           // Disable row arbitration by default
                     y_enable = 1'b0; 
					      next_state = IDLE;  
                end
				end
            COL_GRANT: 
			       begin
					 if(enable)
					 begin
                  y_enable = 1'b1;             // Enable column arbitration during COL_GRANT state
                  if (y_gnt_o == {4{1'b0}}) 
				       begin                       // If no column grant, transition back to row arbitration
                    x_enable = 1'b1;         // Enable row arbitration once column grant is done
                    y_enable = 1'b0;         // Disable column arbitration
                    next_state = ROW_GRANT;  // Transition back to row grant state
                   end
						end
					 else
					  begin
					     x_enable = 1'b0;           // Disable row arbitration by default
                    y_enable = 1'b0; 
					     next_state = IDLE;
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
            row[i] = |set[i][j];        // OR all bits in each row to detect active row requests
         end
       end
  end

//----------------------------------------------------------------------------------------------------------------------
always_comb 
 begin
        col = {4{1'b0}};            // Default: no active requests in any row
        
	  for (int j = 0; j < 4; j++) 
         begin
            col[j] = set[x_add][j];        // OR all bits in each row to detect active row requests
         end
       end

//---------------------------------------------------------------------------------------------------------------------
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

    //----------------------------------------------------------------------------------------------------------

    x_roundrobin RRA_X (
        .clk_i(clk),                  // Clock input
        .reset_i(rst_n),            // Reset input
        .enable_i(x_enable),          // Enable signal for row arbitration
        .req_i(row),                  // Row requests (active rows)
        .gnt_o(x_gnt_o),              // Row grant outputs
        .xadd_o(x_add)                // Output for row arbitration (index)
    );

    y_roundrobin RRA_Y (
        .clk_i(clk),                  // Clock input
        .reset_i(rst_n),            // Reset input
        .enable_i(y_enable),          // Enable signal for column arbitration
        .req_i(col),                  // Column requests for the active row
        .gnt_o(y_gnt_o),              // Column grant outputs
        .yadd_o(y_add)                // Output for column arbitration (index)
    );

endmodule
