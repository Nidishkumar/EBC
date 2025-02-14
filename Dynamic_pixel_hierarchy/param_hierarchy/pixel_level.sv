// Module name: pixel top level
// Module Description: This module perform arbiteration for the Primary level Pixel Block.  
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
//`include "lib_arbiter_pkg.sv"

//import lib_arbiter_pkg::*;      // Importing arbiter package containing parameter constants

module pixel_level #(parameter Lvl_ROWS=2,parameter Lvl_COLS=2,parameter Lvl_ADD=1)
(
    input  logic clk_i, reset_i                    ,             // Clock and reset signals
    input  logic enable_i                          ,             // Enable signal for the higher level
    input  logic [Lvl_ROWS-1:0][Lvl_COLS-1:0]req_i ,             // Input requests from lower level
    input  logic grp_enable_i                      ,             // Group release input signal from lower level acts as clock to higher level
    output logic [Lvl_ROWS-1:0][Lvl_COLS-1:0]gnt_o ,             // Grant for higher level
    output logic [Lvl_ADD-1:0] x_add_o             ,             // Selected row index for higher level
    output logic [Lvl_ADD-1:0] y_add_o             ,             // Selected column index for higher level
    output logic active_o                          ,             // Indicates the higher level arbitration is active or not
    output logic req_o                             ,             // Request signal from level acts as enable to this level if it has act requests
    output logic grp_release_o                                   // Group release output signal for higher level will high when it grants the all active requests
);
    //$warning("------------Loop Passed Lvl_ROWS=[%d],Lvl_COLS=[%d],Lvl_ADD=[%d]------------------",Lvl_ROWS,Lvl_COLS,Lvl_ADD); 

    logic [Lvl_ROWS-1:0] row_req   ;                             // Row-wise request signals
    logic [Lvl_COLS-1:0] col_req   ;                             // Column requests for the active row
    logic [Lvl_COLS-1:0] y_gnt_o   ;                             // Column arbitration grant signals
    logic [Lvl_ROWS-1:0] x_gnt_o   ;                             // Row arbitration grant signals

    logic x_enable, y_enable       ;                             // Enable signals for row and column arbitration
   // logic refresh                  ;                             // Refresh signal for initialize row arbiter
    logic grp_release_x            ;                             // Group release signal for row arbitration
    logic grp_release_y            ;                             // Group release signal for column arbitration
    logic grp_release_clk          ;                             // Clock signal for group release
    logic toggle                   ;                             // Toggle signal for FSM transitions

    assign req_o =  |req_i;                                      // Indicates high if any active requests in req_i
   

    always_comb //@(posedge clk_i or posedge reset_i) 
    begin
        if (reset_i) 
                grp_release_o = 1'b0;                              // Reset group release signal
        else 
        begin
            if (enable_i)
                grp_release_o = grp_release_x & grp_release_y;     // Assert group release when both row arbiter and column arbiter grp_releases are asserted
            else
                grp_release_o = 1'b0;
        end
    end

    // FSM state definitions for row and column arbitration
    typedef enum logic [1:0] 
    {
        IDLE       = 2'b00,                                     // IDLE state, no active arbitration
        ROW_GRANT  = 2'b01,                                     // ROW_GRANT state for row arbitration
        COL_GRANT  = 2'b10                                      // COL_GRANT state for column arbitration
    } state_t;  

    state_t current_state, next_state;                          // FSM state variables

	 
always_comb//@(posedge clk_i or posedge reset_i) 
 begin
    //grp_release_clk=0;
        case (current_state)
            IDLE: 
                grp_release_clk = clk_i; // Follow main clock in IDLE state
                
            ROW_GRANT: 
                grp_release_clk = clk_i; // Toggle in ROW_GRANT
            COL_GRANT:   
            begin
			 if(grp_enable_i)
	            grp_release_clk = clk_i;
			 else
				begin
                if (toggle)  
                    grp_release_clk = clk_i; // Toggle if all columns granted
                else
                    grp_release_clk = !grp_enable_i;  // Sync with lower-level group release
				end
            end
			 default:
			   grp_release_clk = 0;
        endcase

 end

    // FSM state transition logic
    always_ff @(posedge grp_release_clk or posedge reset_i) 
    begin
        if (reset_i) 
            current_state <= IDLE;                              // Reset state to IDLE
        else 
            current_state <= next_state;                        // Transition to next state
    end
    
    // Row request generation logic
    always_comb begin
        for (int i = 0; i < Lvl_ROWS; i++) 
            row_req[i] = |req_i[i];                             // OR all bits in each row to detect requests
    end

    // Active output signal logic
    always_ff @(posedge clk_i or posedge reset_i) 
    begin
        if (reset_i) 
            active_o <= 'b0;                                    // Reset active signal
        else 
            active_o <= |y_gnt_o;                               // Indicates higher level arbitration is active or not
    end 

    // Column request generation based on active row
    always_comb 
	 begin
        for (int i = 0; i < Lvl_COLS; i++) 
            col_req[i] = req_i[x_add_o][i];                    // Extract column requests for the selected row
    end

    // FSM next state and control signal generation
    always_comb 
    begin
        next_state = current_state;                             // Default state transition
        x_enable = 1'b0;                                        // Default disable row arbitration
        y_enable = 1'b0;                                        // Default disable column arbitration
    //    refresh = 1'b0;                                         // Default refresh signal
        toggle = 1'b0;                                          // Default toggle signal

        case (current_state)
            IDLE: 
            begin
                if (enable_i) 
                 begin
                    x_enable = 1'b1;                            // Enable row arbitration
                    next_state = ROW_GRANT;                     // Transition to ROW_GRANT state
                 end
					 else                                            //If enable is low,
					  begin
					    x_enable = 1'b0;                             //row enable will low  
						 y_enable = 1'b0;                             //column enable will low  
						 next_state = IDLE;                           //next_state to IDLE
					//	 refresh=1'b1;                                //Initialize the row arbiter
					  end  
            end

            ROW_GRANT: 
            begin
				  if (enable_i) 
                begin
                 x_enable = 1'b1;                                // Keep row arbitration enabled
                 if (x_gnt_o != 'b0) 
                  begin
                    y_enable = 1'b1;                            // Enable column arbitration
                    x_enable = 1'b0;                            // Disable row arbitration
                    next_state = COL_GRANT;                     // Transition to COL_GRANT state
                  end
					 end
					  else                                            //If enable is low,
					  begin
					    x_enable = 1'b0;                             //row enable will low  
						 y_enable = 1'b0;                             //column enable will low  
						 next_state = IDLE;                           //next_state to IDLE
						// refresh=1'b1;                                //Initialize the row arbiter
					  end  
            end
            
            COL_GRANT: 
            begin
				  if (enable_i) 
                begin
                y_enable = 1'b1;                                    // Enable column arbitration
                if (y_gnt_o == 'b0)                                 // If all columns are granted
                  begin
                        x_enable = 1'b1;                            // Re-enable row arbitration
                        y_enable = 1'b0;                            // Disable column arbitration
                        toggle = 1'b1;                              // Set toggle for FSM transition
                        next_state = ROW_GRANT;                     // Transition back to ROW_GRANT
                  end
					 end
					  else                                               //If enable is low,
					   begin
					    x_enable = 1'b0;                                 //row enable will low  
						 y_enable = 1'b0;                                 //column enable will low  
						 next_state = IDLE;                               //next_state to IDLE
						 //refresh=1'b1;                                    //Initialize the row arbiter
					   end  
					 
            end

            default:
                next_state = IDLE;                                  // Default state transition to IDLE
        endcase
    end
	 
    // Output grant generation based on active row and column
     always_comb
      begin
        for (int i = 0; i < Lvl_ROWS; i++)
		    begin
            for (int j = 0; j < Lvl_COLS; j++)  
 				  begin
                if (x_gnt_o != 0 && y_gnt_o != 0 && i == x_add_o && j == y_add_o)
					 
                    gnt_o[i][j] = 1'b1;                             // Activate grant for selected row and column
                else
                    gnt_o[i][j] = 1'b0;
					end
			end
      end

    // Instantiate RoundRobin module for row arbitration
    row_arbiter #(.Lvl_ROWS(Lvl_ROWS),.Lvl_ROW_ADD(Lvl_ADD))
    RRA_X
	 (
        .clk_i         (grp_release_clk),                          // Clock input
        .reset_i       (reset_i),                                  // Reset input
        .enable_i      (x_enable),                                 // Enable signal
      //  .refresh_i     (refresh),                                  // Refresh signal
        .req_i         (row_req),                                  // Row requests
        .gnt_o         (x_gnt_o),                                  // Row grants
        .xadd_o        (x_add_o),                                  // Row index
        .grp_release_o (grp_release_x)                             // Group release signal
    );

    // Instantiate RoundRobin module for column arbitration
    column_arbiter #(.Lvl_COLS(Lvl_COLS),.Lvl_COL_ADD(Lvl_ADD))
    RRA_Y 
	 (
        .clk_i         (grp_release_clk),                           // Clock input
        .reset_i       (reset_i),                                   // Reset input
        .enable_i      (y_enable),                                  // Enable signal
        .req_i         (col_req),                                   // Column requests
        .gnt_o         (y_gnt_o),                                   // Column grants
        .yadd_o        (y_add_o),                                   // Column index
        .grp_release_o (grp_release_y)                              // Group release signal
    );

endmodule  