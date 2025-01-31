// Module name: TopModule
// Module Description: Top module controls the both rows and column arbiters
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                                         // Importing arbiter package containing parameter constants

module top_single_pixel 
(
    input  logic                        clk_i               ,   // Clock input
    input  logic                        reset_i             ,   // Active high Reset input
    input  logic                        enable_i            ,   // Enable signal to trigger arbitration
    input  logic [COLS-1:0][POLARITY-1:0]req_i[ROWS-1:0]    ,   // Request signals for each row and column, with POLARITY bits determining the signal's polarity
    output logic [ROWS-1:0][COLS-1:0]   gnt_o               ,   // grant outputs
	output logic [WIDTH-1:0]            data_out_o              // Combines event data such as pixel's row address, column address, polarity, and timestamp
  
);

    // Internal signals
    logic [ROWS-1:0] row_req ;             // Indicates which rows have active requests
    logic [COLS-1:0] column_req ;        	   // Holds the column requests for the selected active row
	 
    logic [ROW_ADD-1:0] x_add ;        // Index for selected row in row arbitration 
    logic [COL_ADD-1:0] y_add ;        // Index for selected column in column arbitration

    logic [ROW_ADD-1:0] x_add_ff ;        // Index for selected row in row arbitration 
    logic [COL_ADD-1:0] y_add_ff ;        // Index for selected column in column arbitration 

    logic [COLS-1:0] y_gnt_o ;         // column arbiter grant information
    logic [ROWS-1:0] x_gnt_o ;         // row arbiter grant information

    logic active_ff;

    logic row_enable, column_enable ;         // Enables for row and column arbitration 
	 
     logic [POLARITY-1:0] polarity_in ;     // To send granted column data to polarity selector module 
	 logic [SIZE-1:0] timestamp    ;    // Temporary signal to store timestamp values coming from timestamp module 
	 logic  polarity               ;    //polarity output from polarity selector module
	 
    // State machine for managing arbitration states
    typedef enum logic [1:0] 
	 {
        IDLE       = 2'b00,            // IDLE state (no active arbitration)
        ROW_GRANT  = 2'b01,            // ROW_GRANT state (row arbitration in progress)
        COL_GRANT  = 2'b10             // COL_GRANT state (column arbitration in progress)
    } state_t;  

    state_t current_state, next_state; // State variables for FSM transitions
	 

    // Generate row signals: Each bit represents whether there are active requests in that row
    always_comb begin
        for (int i = 0; i < ROWS; i++) 
         begin
            row_req[i] = |req_i[i];        // OR all bits in each row to detect active row requests
         end
    end

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

    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
               active_ff <= 'b0;

            end 
        else 
		   begin
               active_ff <= |y_gnt_o;
         end 
      end 
	 


    // Assign the current column requests from the active row based on row index
    always_comb begin
        for (int i = 0; i < COLS; i = i + 1) 
         begin
            column_req[i] = |req_i[x_add][i];
         end
    end

    // Active row's column requests
    assign polarity_in = req_i[x_add][y_add]; // Sends active row's column request polarity to the polarity module.

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

    // FSM next state and output logic based on current state
    always_comb 
	  begin
        // Default state transitions and signal assignments
        next_state = current_state;
        row_enable = 1'b0;           // Disable row arbitration by default
        column_enable = 1'b0;           // Disable column arbitration by default

        case (current_state)
            IDLE: 
			 begin
                if (enable_i) 
				 begin
                    row_enable = 1'b1;       // Enable row arbitration if enable_i is high
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
                row_enable = 1'b1;             // Keep row arbitration enabled during ROW_GRANT state
                if (x_gnt_o != {ROWS{1'b0}}) 
				 begin                       // If any row has been granted, move to column grant
                    column_enable = 1'b1;         // Enable column arbitration once row grant is done
                    row_enable = 1'b0;         // Disable row arbitration
                    next_state = COL_GRANT;  // Transition to column grant state
                 end
              end
			else
			 begin
				row_enable = 1'b0;           // Disable row arbitration 
                column_enable = 1'b0;           // Disable column arbitration
				next_state = IDLE;	  
			 end
            end

            COL_GRANT: 
			begin
			    if(enable_i)
			     begin
                  column_enable = 1'b1;             // Enable column arbitration during COL_GRANT state
                 if (y_gnt_o == {COLS{1'b0}}) 
				  begin                       // If no column grant, transition back to row arbitration
                    row_enable = 1'b1;         // Enable row arbitration once column grant is done
                    column_enable = 1'b0;         // Disable column arbitration
                    next_state = ROW_GRANT;  // Transition back to row grant state
                  end
                 end
				else
				 begin
				    row_enable = 1'b0;           // Disable row arbitration 
                    column_enable = 1'b0;           // Disable column arbitration
					next_state = IDLE;	  
				 end
			end
            default:
			 begin
                next_state = IDLE;           // Default state transition to IDLE
             end
        endcase
      end
	 
	 //Output grant based on active row and column
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		   begin
               for (int i = 0; i < ROWS; i++) 
                begin
                    for (int j = 0; j < COLS; j++) 
                    begin
                        gnt_o[i][j] <= 1'b0;
                    end
                end
            end 
        else begin
        // Initialize all grants to 0
        for (int i = 0; i < ROWS; i++) 
		 begin
            for (int j = 0; j < COLS; j++) 
			 begin
                if((i == x_add) && (j == y_add) && (|y_gnt_o == 1'b1))
                    gnt_o[i][j] <= 1'b1;
                else
                    gnt_o[i][j] <= 1'b0;
             end
         end
      end
      end


	 
    // Instantiate RoundRobin module for column arbitration (y-direction)
    column_arbiter  RRA_Y 
    (
        .clk_i     (clk_i)          ,                 // Clock input
        .reset_i   (reset_i)        ,                 // Reset input
        .enable_i  (column_enable)  ,                 // Enable signal for column arbitration
        .req_i     (column_req)     ,                 // Column requests for the active row
        .gnt_o     (y_gnt_o)        ,                 // Column grant outputs
        .y_add_o     (y_add)                            // Index for selected column  
    );

    // Instantiate RoundRobin module for row arbitration (x-direction)
    row_arbiter   RRA_X 
    (
        .clk_i     (clk_i)      ,                  // Clock input
        .reset_i   (reset_i)    ,                  // Reset input
        .enable_i  (row_enable) ,                  // Enable signal for row arbitration
        .req_i     (row_req)    ,                  // Row requests (active rows)
        .gnt_o     (x_gnt_o)    ,                  // Row grant outputs
        .x_add_o      (x_add)                        // Index for selected row 
    );

    // Instantiate Polarity Selecter module outputs polarity 
    polarity_selector polarity_sel
     (
        .clk_i         (clk_i)        , 
        .reset_i       (reset_i)      ,
        .req_i         (polarity_in)  ,         // Polarity request input (column request)
        .polarity_out  (polarity)              // Output polarity signal
    );

    // Instantiate the wallclock module to capture timestamp based on event trigger.
    wall_clock time_stamp 
	 (
	    .clk_i     (clk_i)      ,                // Clock input
        .reset_i   (reset_i)    ,                // Reset input
		.timestamp_o(timestamp)                    // Output the captured timestamp (timestamp_o) from the wallclock module.
		  
	 );
    
    //Instantiate Address event module for the event data
	AER address_event
	 ( 
        .enable_i   (active_ff)         ,
	    .x_add_i    (x_add_ff)          ,             //Event Row address                        
		.y_add_i    (y_add_ff)          ,             //Event Column address  
		.timestamp_i(timestamp)         ,             //captured timestamp data
		.polarity_i (polarity)          ,             //polarity output
		.data_out_o (data_out_o)                        //combines event data like row address ,column address,timestamp and polarity
	 );	 
endmodule