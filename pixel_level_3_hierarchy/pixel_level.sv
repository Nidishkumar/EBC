// Module name: TopModule
// Module Description: Top module controls the both rows and column arbiters
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*;                                      // Importing arbiter package containing parameter constants

module pixel_level#(parameter GROUP_SIZE = 2,parameter Lvl_ADD=1)

(
    input  logic clk_i, reset_i,
    input  logic enable_i,
    input  logic [GROUP_SIZE-1:0][GROUP_SIZE-1:0][POLARITY-1:0]req_i,
    output logic [GROUP_SIZE-1:0][GROUP_SIZE-1:0]gnt_o,
    output logic [Lvl_ADD-1:0] x_add_o ,        // Index for selected row in row arbitration logic
    output logic [Lvl_ADD-1:0]y_add_o ,
    output logic active_o,
    output logic req_o,
	output logic grp_release_o         
     
);

    // Internal signals
    logic [GROUP_SIZE-1:0] row_req ;             // Indicates which rows have active requests
    logic [GROUP_SIZE-1:0] col_req ;        	   // Holds the column requests for the selected active row
	 
    logic [GROUP_SIZE-1:0] y_gnt_o ;         // column arbiter grant information
    logic [GROUP_SIZE-1:0] x_gnt_o ;         // row arbiter grant information

   // logic active_ff;

    logic x_enable, y_enable ;         // Enables for row and column arbitration 
	 
    logic refresh;

    logic grp_release_x;
    logic grp_release_y;

    assign req_o =  |req_i;

	 
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		 begin
            grp_release_o <= 1'b0;  // Reset state to IDLE when reset is triggered
         end 
		else 
		 begin
            if (enable_i)
                grp_release_o <= grp_release_x & grp_release_y;
            else
                grp_release_o <= 1'b0;
        end
    end
    
    // State machine for managing arbitration states
    typedef enum logic [1:0] 
	 {
        IDLE       = 2'b00,            // IDLE state (no active arbitration)
        ROW_GRANT  = 2'b01,            // ROW_GRANT state (row arbitration in progress)
        COL_GRANT  = 2'b10             // COL_GRANT state (column arbitration in progress)
    } state_t;  

    state_t current_state, next_state; // State variables for FSM transitions

        // FSM state transition logic for row and column arbitration
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		 begin
            current_state <= IDLE;  // Reset state to IDLE when reset is triggered
         end 
		else 
		 begin
            current_state <= next_state;  // Transition to the next state
         end
      end

    // Generate row signals: Each bit represents whether there are active requests in that row
    always_comb begin
        for (int i = 0; i < 2; i++) 
         begin
            row_req[i] = |(req_i[i]);        // OR all bits in each row to detect active row requests
         end
    end


    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
               active_o <= 'b0;
         end 
        else 
		   begin
               active_o <= |y_gnt_o;
         end 
      end 
	 

    // Assign the current column requests from the active row based on row index
    always_comb begin
        for (int i = 0; i < 2; i = i + 1) 
         begin
            col_req[i] = |req_i[x_add_o][i];
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
        refresh = 1'b0;

        case (current_state)
            IDLE: 
			 begin
                if (enable_i) 
				 begin
                    x_enable = 1'b1;       // Enable row arbitration if enable_i is high
                    next_state = ROW_GRANT;// Transition to row grant state
                 end 
				else 
				 begin			       
                    next_state = IDLE;     // Stay in IDLE state if enable_i is low
                 end
             end

            ROW_GRANT: 
			begin
		    if(enable_i)
			  begin
                x_enable = 1'b1;             // Keep row arbitration enabled during ROW_GRANT state
                if (x_gnt_o != 'b0) 
				 begin                       // If any row has been granted, move to column grant
                    y_enable = 1'b1;         // Enable column arbitration once row grant is done
                    x_enable = 1'b0;         // Disable row arbitration
                    next_state = COL_GRANT;  // Transition to column grant state
                 end
              end

			else
			 begin
				x_enable = 1'b0;           // Disable row arbitration 
                y_enable = 1'b0;           // Disable column arbitration
				next_state = IDLE;
                refresh = 1'b1;		  
			 end
            end
            
            COL_GRANT: 
			begin
			    if(enable_i)
			     begin
                  y_enable = 1'b1;             // Enable column arbitration during COL_GRANT state
                 if (y_gnt_o == 'b0) 
				  begin                       // If no column grant, transition back to row arbitration
                    x_enable = 1'b1;         // Enable row arbitration once column grant is done
                    y_enable = 1'b0;         // Disable column arbitration
                    next_state = ROW_GRANT;  // Transition back to row grant state
                  end
                 end
				else
				 begin
				    x_enable = 1'b0;           // Disable row arbitration 
                    y_enable = 1'b0;           // Disable column arbitration
					next_state = IDLE;
                    refresh = 1'b1;	  
				 end
			end
            default:
			 begin
                next_state = IDLE;           // Default state transition to IDLE
             end
        endcase
      end
	 
	 //Output grant based on active row and column
    always_comb 
	  begin
        // Initialize all grants to 0
        for (int i = 0; i < 2; i++) 
		 begin
            for (int j = 0; j < 2; j++) 
			 begin
                gnt_o[i][j] = 1'b0;
             end
         end

        // Activate the grant for the selected row and column
        if (x_gnt_o != 0 && y_gnt_o != 0) 
		 begin
            gnt_o[x_add_o][y_add_o] = 1'b1; // Grant active row and column
         end
      end 
		
	/*	always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
               for (int i = 0; i < Lvl_ROWS; i++) 
                begin
                    for (int j = 0; j < Lvl_COLS; j++) 
                    begin
                        gnt_o[i][j] <= 1'b0;
                    end
                end
            end 
        else begin
        // Initialize all grants to 0
        for (int i = 0; i < Lvl_ROWS; i++) 
		 begin
            for (int j = 0; j < Lvl_COLS; j++) 
			 begin
                if((i == x_add_o) && (j == y_add_o) && (|y_gnt_o == 1'b1))
                    gnt_o[i][j] = 1'b1;
                else
                    gnt_o[i][j] = 1'b0;
             end
         end
      end
      end  */
	 
    // Instantiate RoundRobin module for column arbitration (y-direction)
    x_roundrobin  #(.Lvl_ROWS(GROUP_SIZE),.Lvl_ROW_ADD(Lvl_ADD))
	 RRA_X
	 (
        .clk_i(clk_i),                  // Clock input
        .reset_i(reset_i),            // Reset input
        .enable_i(x_enable),          // Enable signal for row arbitration
        .refresh_i(refresh),
        .req_i(row_req),                  // Row requests (active rows)
        .gnt_o(x_gnt_o),              // Row grant outputs
        .xadd_o(x_add_o) ,
        .grp_release(grp_release_x)                     		  // Output for row arbitration (index)
    );

    y_roundrobin  #(.Lvl_COLS(GROUP_SIZE),.Lvl_COL_ADD(Lvl_ADD))
	 RRA_Y
	 (
        .clk_i(clk_i),                  // Clock input
        .reset_i(reset_i),            // Reset input
        .enable_i(y_enable),          // Enable signal for column arbitration
        .req_i(col_req),                  // Column requests for the active row
        .gnt_o(y_gnt_o),              // Column grant outputs
        .yadd_o(y_add_o),                // Output for column arbitration (index)
        .grp_release(grp_release_y)                     		  // Output for row arbitration (index)
    );

endmodule