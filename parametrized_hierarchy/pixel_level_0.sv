// Module name: Lower level arbitration
// Module Description: This module perform arbiteration to the lower level Pixel groups.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//--------------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*;         // Importing arbiter package containing parameter constants

module pixel_level_0  #(parameter Lvl_ROWS=2, Lvl_COLS=2, Lvl_ADD=1)

(
    input  logic clk_i, reset_i                                   ,  // Clock and Reset inputs
    input  logic enable_i                                         ,  // Enable signal to activate arbitration
    input  logic [Lvl_ROWS-1:0][Lvl_COLS-1:0]req_i              ,  // Input request with polarity from lower level groups
    output logic [Lvl_ROWS-1:0][Lvl_COLS-1:0]gnt_o              ,  // Grant for the corresponding loer level group requests
    output logic [Lvl_ADD-1:0] x_add_o                           ,  // Selected row index for lower level group
    output logic [Lvl_ADD-1:0] y_add_o                           ,  // Selected column index for lower level group
    output logic active_o                                         ,  // Indicates the arbitration is active or not
    output logic req_o                                            ,  // Indicates any active requests in each lower level group to give as input request to higher level
	 output logic grp_release_o                                       // Indicates group release for lower level group(all operations done)
);

    // Internal signals
    logic [Lvl_ROWS-1:0] row_req     ;                            // Row-wise request signals 
    logic [Lvl_COLS-1:0] col_req     ;                            // Column-wise requests for the selected active row
	logic [Lvl_ROWS-1:0] x_gnt_o     ;                            // Row arbiter grant signals
    logic [Lvl_COLS-1:0] y_gnt_o     ;                            // Column arbiter grant signals
    logic x_enable, y_enable         ;                            // Enables for row and column arbitration control through FSM
	logic refresh_x                  ;                            // Refresh signal for row arbiter to reset
	logic refresh_y                  ;                            // Refresh signal for row arbiter to reset   
	logic grp_release_x              ;                            // Group release signal for row arbiter
    logic grp_release_y              ;                            // Group release signal for column arbiter

    assign req_o =  |req_i;                                        // Logical OR of all input requests to detect active requests

//-----------------Arbiter Fsm States------------------------------------------------------------------------------------------
    typedef enum logic [1:0] 
	 {
        IDLE       = 2'b00,            // IDLE state (no active arbitration)
        ROW_GRANT  = 2'b01,            // ROW_GRANT state (row arbitration in progress)
        COL_GRANT  = 2'b10             // COL_GRANT state (column arbitration in progress)
     } state_t;  

    state_t current_state, next_state; // State variables for FSM transitions
//------------------------------------------------------------------------------------------------------------------------------

//-----------------Grp_release Logic---------------------------------------------------------------------------------------------
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		 begin
            grp_release_o <= 1'b0;                               // Reset group release to 0 when reset is triggered
         end 
		else 
		 begin
            if (enable_i)
                grp_release_o <= grp_release_x & grp_release_y; // Assert group release if both row and column reaches to final active request
            else
                grp_release_o <= 1'b0;                          // Default: group release is 0
         end
      end
//-------------------------------------------------------------------------------------------------------------------------
    
//-----------------Generate Active row signals Logic-----------------------------------------------------------------------
    always_comb 
    begin
        for (int i = 0; i < Lvl_ROWS; i++) 
         begin
            row_req[i] = |(req_i[i]);                      // Logical OR of each row to detect active row requests
         end
    end
//-------------------------------------------------------------------------------------------------------------------------

//------------------Active_o Logic--------------------------------------------------------------------------------------------
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		    begin
               active_o <= 'b0;                           // Reset active_o to 0 when reset is triggered
            end 
        else 
		    begin
               active_o <= |y_gnt_o;                      // Assert active_o if any column grant is active
            end 
      end 
//-------------------------------------------------------------------------------------------------------------------------
 
//------------------Generate Active Column for Selected row----------------------------------------------------------------
    always_comb 
    begin
        for (int i = 0; i < Lvl_COLS; i = i + 1) 
         begin
            col_req[i] = |req_i[x_add_o][i];              // Extract column requests for the active row
         end
    end
//--------------------------------------------------------------------------------------------------------------------------

//------------------FSM Current state logic--------------------------------------------------------------------------------- 
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		 begin
            current_state <= IDLE;                         // Reset state to IDLE when reset is triggered
         end 
		else 
		 begin
            current_state <= next_state;                   // Transition to the next state on clock edge
         end
      end
//--------------------------------------------------------------------------------------------------------------------------------- 

//------------------FSM state transition logic-------------------------------------------------------------------------------------  
    always_comb 
	  begin
        // Default state transitions and signal assignments
        next_state = current_state;                       // Maintain current state by default
        x_enable = 1'b0;                                  // Disable row arbitration by default
        y_enable = 1'b0;                                  // Disable column arbitration by default
       

        case (current_state)
 //------------------IDLE State-----------------------------------------------------------------------------------------------------    
            IDLE: 
			 begin
                if (enable_i) 
				 begin
                    x_enable = 1'b1;                      // Enable row arbitration if enable_i is high
                    next_state = ROW_GRANT;               // Transition to row grant state
                    refresh_x = 1'b0;
                    refresh_y = 1'b0; 

                 end 
				else 
				 begin			       
                    next_state = IDLE;                    // Stay in IDLE state if enable_i is low
                    refresh_x = 1'b1;                                   // Default refresh is 0
                    refresh_y=1'b1;
                 end 
             end
//--------------------------------------------------------------------------------------------------------------------------------- 

//--------------------ROW_GRANT state------------------------------------------------------------------------------------------------------------ 
            ROW_GRANT: 
			begin
		        if (enable_i)
			     begin
                    x_enable = 1'b1;                     // Keep row arbitration enabled during ROW_GRANT state
                    if (x_gnt_o != 'b0) 
				     begin                                   // If any row has been granted, move to column grant
                        y_enable = 1'b1;                 // Enable column arbitration once row grant is done
                        x_enable = 1'b0;                 // Disable row arbitration
                        next_state = COL_GRANT;
                        refresh_x = 1'b0;
                        refresh_y = 1'b0; 
 
          // Transition to column grant state
                     end
                  end
		        else
			     begin
				    x_enable = 1'b0;                         // Disable row arbitration, if enable is low
                    y_enable = 1'b0;                         // Disable column arbitration, if enable is low
				    next_state = IDLE;                       // Transition to IDLE if enable, is low
                    refresh_x = 1'b1;                          // Refresh the row arbiter, if enable is low
			        refresh_y=1'b1;
				 end                                          // Refresh the column arbiter, if enable is low
				  
            end
//--------------------------------------------------------------------------------------------------------------------------------- 

//--------------------COL_GRANT state------------------------------------------------------------------------------------------------------------ 
            COL_GRANT: 
			begin
			    if (enable_i)
			     begin
                    y_enable = 1'b1;                  // Enable column arbitration during COL_GRANT state
                    if (y_gnt_o == 'b0) 
				     begin                                // If all active columns granted, transition back to row arbitration for next active row
                        x_enable = 1'b1;              // Enable row arbitration once column grant is done
                        y_enable = 1'b0;              // Disable column arbitration
						refresh_y = 1'b1; 
                        refresh_x = 1'b0; 
                        next_state = ROW_GRANT;       // Transition back to row grant state
                      end
                 end
				else
				 begin
				     x_enable = 1'b0;                       // Disable row arbitration,if enable is low
                     y_enable = 1'b0;                   // Disable column arbitration,if enable is low
					 next_state = IDLE;                      // Transition to IDLE,if enable is low
                     refresh_x = 1'b1;                    // Refresh the row arbiter,if enable is low
				      refresh_y=1'b1;

				 end    
			end
//--------------------------------------------------------------------------------------------------------------------------
            default:
			 begin
                    next_state = IDLE;                      // Default state transition to IDLE
             end
        endcase
      end

	 
//-------------------Grant logic--------------------------------------------------------------------------------------------
    always_comb
       begin
        for (int i = 0; i < Lvl_ROWS; i++)
            for (int j = 0; j < Lvl_COLS; j++)   
			 begin
                if (x_gnt_o != 0 && y_gnt_o != 0 && i == x_add_o && j == y_add_o)
                    gnt_o[i][j] = 1'b1;                                  // Activate grant for selected row and column
                else
                    gnt_o[i][j] = 1'b0;
             end
       end
//--------------------------------------------------------------------------------------------------------------------------
		
		
		
    // Instantiate RoundRobin module for column arbitration (y-direction)
    row_arbiter  #(.Lvl_ROWS(Lvl_ROWS),.Lvl_ROW_ADD(Lvl_ADD))
	 RRA_X
	 (
        .clk_i         (clk_i)   ,               // Clock input
        .reset_i       (reset_i) ,               // Reset input
        .enable_i      (x_enable),               // Enable signal for row arbitration
        .refresh_i     (refresh_x) ,               // Refresh signal
        .req_i         (row_req) ,               // Row requests (active rows)
        .gnt_o         (x_gnt_o) ,               // Row grant outputs
        .xadd_o        (x_add_o) ,               // Selected row index
        .grp_release_o (grp_release_x)           // Group release signal for row
    );

    column_arbiter  #(.Lvl_COLS(Lvl_COLS),.Lvl_COL_ADD(Lvl_ADD))
	 RRA_Y
	 (
        .clk_i         (clk_i)   ,                // Clock input
        .reset_i       (reset_i) ,                // Reset input
        .enable_i      (y_enable),                // Enable signal for column arbitration
		.refresh_i     (refresh_y) ,               // Refresh signal
        .req_i         (col_req) ,                // Column requests for the active row
        .gnt_o         (y_gnt_o) ,                // Column grant outputs
        .yadd_o        (y_add_o) ,                // Selected column index
        .grp_release_o (grp_release_y)            // Group release signal for column
    );

endmodule

