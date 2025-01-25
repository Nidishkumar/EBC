import lib_arbiter_pkg::*;                                      // Importing arbiter package containing parameter constants

module pixel_top_level 
#(parameter Lvl_ROWS=2,parameter Lvl_COLS=2,parameter Lvl_ROW_ADD=1,parameter Lvl_COL_ADD=1)

(
    input  logic clk_i, reset_i,                                // Clock and reset signals
    input  logic enable_i,                                      // Enable signal for the module
    input  logic [Lvl_ROWS-1:0][Lvl_COLS-1:0]req_i,             // pixel group requests from level1 and level2
    input  logic grp_release_i,                                 // Group release input signal from lower levels
    output logic [Lvl_ROWS-1:0][Lvl_COLS-1:0]gnt_o,             // Grant indicating for level groups
    output logic [Lvl_ROW_ADD-1:0] x_add_o ,                    // Selected row index from row arbitration
    output logic [Lvl_COL_ADD-1:0] y_add_o ,                    // Selected column index from column arbitration
    output logic active_o,                                      // Indicates if arbitration is active
    output logic req_o,                                         // Combined request signal
    output logic grp_release_o                                  // Group release output signal
);

    // Internal signals
    logic [Lvl_ROWS-1:0] row_req;                               // Row-wise request signals
    logic [Lvl_COLS-1:0] col_req;                               // Column requests for the active row
    logic [Lvl_COLS-1:0] y_gnt_o;                               // Column arbitration grant signals
    logic [Lvl_ROWS-1:0] x_gnt_o;                               // Row arbitration grant signals

    logic x_enable, y_enable;                                   // Enable signals for row and column arbitration
    logic refresh;                                              // Refresh signal for row arbitration
    logic grp_release_x;                                        // Group release signal for row arbitration
    logic grp_release_y;                                        // Group release signal for column arbitration
    logic grp_release_clk;                                      // Clock signal for group release
    logic toggle;                                               // Toggle signal for FSM transitions

    assign req_o =  |req_i;                                     // Indicates lower group as active if any has any active requests


    always_ff @(posedge grp_release_clk or posedge reset_i) 
    begin
        if (reset_i) 
            grp_release_o <= 1'b0;                              // Reset group release signal
        else 
        begin
            if (enable_i)
                grp_release_o <= grp_release_x & grp_release_y; // Assert group release when both sub-releases are asserted
            else
                grp_release_o <= 1'b0;
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

    // Group release clock toggle logic
    always_ff @(posedge clk_i or posedge reset_i) 
    begin
        if (reset_i) 
            grp_release_clk <= 1'b0;                            // Reset group release clock
        else if (enable_i) 
        begin
            case (current_state) 
                IDLE: grp_release_clk <= !grp_release_clk;       // Toggle clock in IDLE state
                ROW_GRANT: grp_release_clk <= !grp_release_clk;  // Toggle clock in ROW_GRANT state
                default: begin if (toggle)  
                            grp_release_clk <= !grp_release_clk;
                         else
                            grp_release_clk <= |grp_release_i; 
								end
            endcase
        end
        else
            grp_release_clk <= 1'b0;                            // Disable group release clock when not enabled
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
            active_o <= |y_gnt_o;                               // Set active signal based on column grants
    end 

    // Column request generation based on active row
    always_comb begin
        for (int i = 0; i < Lvl_COLS; i++) 
            col_req[i] = |req_i[x_add_o][i];                    // Extract column requests for the selected row
    end

    // FSM next state and control signal generation
    always_comb 
    begin
        next_state = current_state;                             // Default state transition
        x_enable = 1'b0;                                        // Default disable row arbitration
        y_enable = 1'b0;                                        // Default disable column arbitration
        refresh = 1'b0;                                         // Default refresh signal
        toggle = 1'b0;                                          // Default toggle signal

        case (current_state)
            IDLE: 
            begin
                if (enable_i) 
                begin
                    x_enable = 1'b1;                            // Enable row arbitration
                    next_state = ROW_GRANT;                     // Transition to ROW_GRANT state
                end 
            end

            ROW_GRANT: 
            begin
                x_enable = 1'b1;                                // Keep row arbitration enabled
                if (x_gnt_o != 'b0) 
                begin
                    y_enable = 1'b1;                            // Enable column arbitration
                    x_enable = 1'b0;                            // Disable row arbitration
                    next_state = COL_GRANT;                     // Transition to COL_GRANT state
                end
            end
            
            COL_GRANT: 
            begin
                y_enable = 1'b1;                                // Enable column arbitration
                if (y_gnt_o == 'b0)                             // If no column grant
                begin
                    if(|x_add_o == 1'b1) 
                        refresh = 1'b1;                         // Refresh row arbitration
                    x_enable = 1'b1;                            // Re-enable row arbitration
                    y_enable = 1'b0;                            // Disable column arbitration
                    toggle = 1'b1;                              // Set toggle for FSM transition
                    next_state = ROW_GRANT;                     // Transition back to ROW_GRANT
                end
            end

            default:
                next_state = IDLE;                              // Default state transition to IDLE
        endcase
    end
	 
    // Output grant generation based on active row and column
    always_comb 
    begin
        for (int i = 0; i < Lvl_ROWS; i++) 
            for (int j = 0; j < Lvl_COLS; j++) 
                gnt_o[i][j] = 1'b0;                             // Initialize all grants to 0

        if (x_gnt_o != 0 && y_gnt_o != 0) 
            gnt_o[x_add_o][y_add_o] = 1'b1;                     // Activate grant for selected row and column
    end 

    // Instantiate RoundRobin module for row arbitration
    x_roundrobin #(.Lvl_ROWS(Lvl_ROWS),.Lvl_ROW_ADD(Lvl_ROW_ADD))
    RRA_X (
        .clk_i(grp_release_clk),                                // Clock input
        .reset_i(reset_i),                                      // Reset input
        .enable_i(x_enable),                                    // Enable signal
        .refresh_i(refresh),                                    // Refresh signal
        .req_i(row_req),                                        // Row requests
        .gnt_o(x_gnt_o),                                        // Row grants
        .xadd_o(x_add_o),                                       // Row index
        .grp_release(grp_release_x)                            // Group release signal
    );

    // Instantiate RoundRobin module for column arbitration
    y_roundrobin #(.Lvl_COLS(Lvl_COLS),.Lvl_COL_ADD(Lvl_COL_ADD))
    RRA_Y (
        .clk_i(grp_release_clk),                                // Clock input
        .reset_i(reset_i),                                      // Reset input
        .enable_i(y_enable),                                    // Enable signal
        .req_i(col_req),                                        // Column requests
        .gnt_o(y_gnt_o),                                        // Column grants
        .yadd_o(y_add_o),                                       // Column index
        .grp_release(grp_release_y)                            // Group release signal
    );

endmodule

