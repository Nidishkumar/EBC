// Module name: TopModule
// Module Description: Top module controls the both rows and column arbiters
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
 import arbiter_pkg::*;                                         // Importing arbiter package containing parameter constants

module top_arb (
    input  logic                  clk_i                     ,   // Clock input
    input  logic                  reset_i                   ,   // Active high Reset input
    input  logic                  enable_i                  ,   // Enable signal to trigger arbitration
    input  logic [COLS-1:0][POLARITY-1:0]req_i[ROWS-1:0]    ,   // Request signals for each row and column, with POLARITY bits determining the signal's polarity or behavior
    output logic [ROWS-1:0][COLS-1:0] gnt_o                 ,   // grant outputs
    output logic                  polarity_o                ,   // Polarity output
    output logic [31:0]           timestamp_o                   //timestamp output
);

    // Internal signals
    logic [ROWS-1:0] row;          // Indicates which rows have active requests
    logic [COLS-1:0]col;           // Holds the column requests for the selected active row
    logic [x_width-1:0] x_add;     // Index for selected row in row arbitration logic
    logic [y_width-1:0] y_add;     // Index for selected column in column arbitration logic

    logic [COLS-1:0] y_gnt_o;
    logic [ROWS-1:0] x_gnt_o;

    logic x_enable, y_enable;      // Enables for row and column arbitration logic
    logic [POLARITY-1:0] polarity; // Temporary signal for column request polarity

    // State machine for managing arbitration states
    typedef enum logic [1:0] 
	 {
        IDLE       = 2'b00,         // IDLE state (no active arbitration)
        ROW_GRANT  = 2'b01,         // ROW_GRANT state (row arbitration in progress)
        COL_GRANT  = 2'b10          // COL_GRANT state (column arbitration in progress)
    } state_t;

    state_t current_state, next_state;  // State variables for FSM transitions

    // Generate row signals: Each bit represents whether there are active requests in that row
    always_comb begin
        row = {ROWS{1'b0}};  // Default: no active requests in any row
        for (int i = 0; i < ROWS; i++) 
         begin
            row[i] = |req_i[i];     // OR all bits in each row to detect active row requests
         end
    end

    // Assign the current column requests from the active row based on row index
    always_comb begin
        col = {COLS{1'b0}};
        for (int i = 0; i < COLS; i = i + 1) 
         begin
            col[i] = |req_i[x_add][i];
         end
    end

    // Active row's column requests
    assign polarity = req_i[x_add][y_add]; // Column request polarity for the active row

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
        x_enable = 1'b0;           // Disable row arbitration by default
        y_enable = 1'b0;           // Disable column arbitration by default

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
                x_enable = 1'b1;             // Keep row arbitration enabled during ROW_GRANT state
                if (x_gnt_o != {ROWS{1'b0}}) 
				 begin                       // If any row has been granted, move to column grant
                    y_enable = 1'b1;         // Enable column arbitration once row grant is done
                    x_enable = 1'b0;         // Disable row arbitration
                    next_state = COL_GRANT;  // Transition to column grant state
                 end
             end

            COL_GRANT: 
			 begin
                y_enable = 1'b1;             // Enable column arbitration during COL_GRANT state
                if (y_gnt_o == {COLS{1'b0}}) 
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
	 
	 //Output grant based on active row and column
    always_comb 
	  begin
        // Initialize all grants to 0
        for (int i = 0; i < ROWS; i++) 
		 begin
            for (int j = 0; j < COLS; j++) 
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
	 
    // Instantiate RoundRobin module for column arbitration (y-direction)
    y_roundrobin  RRA_Y 
    (
        .clk_i     (clk_i)    ,                 // Clock input
        .reset_i   (reset_i)  ,                 // Reset input
        .enable_i  (y_enable) ,                 // Enable signal for column arbitration
        .req_i     (col)      ,                 // Column requests for the active row
        .gnt_o     (y_gnt_o)  ,                 // Column grant outputs
        .yadd_o    (y_add)                      // output for column arbitration (index)
    );

    // Instantiate RoundRobin module for row arbitration (x-direction)
    x_roundrobin   RRA_X 
    (
        .clk_i     (clk_i)    ,                  // Clock input
        .reset_i   (reset_i)  ,                  // Reset input
        .enable_i  (x_enable) ,                  // Enable signal for row arbitration
        .req_i     (row)      ,                  // Row requests (active rows)
        .gnt_o     (x_gnt_o)  ,                  // Row grant outputs
        .xadd_o    (x_add)                       // output for row arbitration (index)
    );

    // Instantiate the tdc module to capture timestamp based on event trigger.
    polarity_selector polarity_sel
     (
        .req_i     (polarity)  ,                  // Polarity request input (column request)
        .pol_out   (polarity_o)                   // Output polarity signal
    );

    // Instantiate the tdc module to capture timestamp based on event trigger.
    tdc time_stamp 
	 (
	     .clk_i     (clk_i)     ,                 // Clock input
         .reset_i   (reset_i)   ,                 // Reset input
         .event_i   (y_enable)  ,                 // Connect event signal (y_enable) to trigger timestamp capture in the tdc module.
		.timestamp_o(timestamp_o)                 // Output the captured timestamp (timestamp_o) from the tdc module.
		  
	 );

endmodule
