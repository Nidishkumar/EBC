// Module name: Arbiter Top Module
// Module Description: 
// Author: 
// Date: 
// Version: 
//-----------------------------------------------------------------------------------------------------------------
module top_arb #(
    parameter ROWS = 8,   // Number of rows
    parameter COLS = 8    // Number of columns
) (
    input  logic                  clk_i,               // Clock input
    input  logic                  reset_i,             // Reset input
    input  logic [ROWS-1:0][COLS-1:0] req_i,            // Request inputs for each row and column
    input  logic                  enable_i,            // Enable signal for arbitration
    output logic [ROWS-1:0]       x_gnt_o,             // Row grant outputs
    output logic [COLS-1:0]       y_gnt_o              // Column grant outputs
);

    // Internal signals
    logic Grp_release;             // Group release signal for synchronization
    logic [ROWS-1:0] row;          // Indicates if there are any active requests in each row
    logic [COLS-1:0] col;          // Holds column requests for the active row
    logic [2:0] x_add;             // Additional output for row arbitration
    logic [2:0] y_add;             // Additional output for column arbitration
    logic x_enable, y_enable;      // Enables for row and column arbitration

    // State machine states
    typedef enum logic [1:0] {
        IDLE       = 2'b00,         // Idle state
        ROW_GRANT  = 2'b01,         // Row grant state
        COL_GRANT  = 2'b10          // Column grant state
    } state_t;

    state_t current_state, next_state;  // State variables for FSM

    // Generate `row` signals to indicate active rows with requests
    always_comb begin
        row = '0;  // Default: no active rows
        for (int i = 0; i < ROWS; i++) begin
            row[i] = |req_i[i];  // OR all bits in each row to detect active requests
        end
    end

    // Assign the current column requests from the active row
    assign col = req_i[x_add];

    // FSM state transition logic
    always_ff @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            current_state <= IDLE;  // Reset state to IDLE
        end else begin
            current_state <= next_state;  // Transition to the next state
        end
    end

    // FSM next state and output logic
    always_comb begin
        // Default values
        next_state = current_state;
        x_enable = 1'b0;
        y_enable = 1'b0;

        case (current_state)
            IDLE: begin
                if(enable_i) begin
                    x_enable = 1'b1;  // Enable row arbitration in IDLE state
                    next_state = ROW_GRANT;  // Move to ROW_GRANT state
                end else begin
                    next_state = IDLE;  // Stay in IDLE if enable is not active
                end
            end

            ROW_GRANT: begin
                x_enable = 1'b1;  // Enable row arbitration in ROW_GRANT state
                if (x_gnt_o != 8'b0) begin
                    y_enable = 1'b1;  // Enable column arbitration when row grants are issued
                    x_enable = 1'b0;  // Disable row arbitration
                    next_state = COL_GRANT;  // Move to COL_GRANT state
                end
            end

            COL_GRANT: begin
                y_enable = 1'b1;  // Enable column arbitration in COL_GRANT state
                if (y_gnt_o == 8'b0) begin
                    x_enable = 1'b1;  // Enable row arbitration once column grants are done
                    y_enable = 1'b0;  // Disable column arbitration
                    next_state = ROW_GRANT;  // Return to ROW_GRANT state
                end
            end

            default: begin
                next_state = IDLE;  // Default state transition to IDLE
            end
        endcase
    end

    // Instantiate RoundRobin module for column arbitration
    y_roundrobin RRA_Y (
        .clk_i(clk_i),                // Clock input
        .reset_i(reset_i),            // Reset input
        .enable_i(y_enable),          // Enable signal for column arbitration
        .req_i(col),                  // Column requests from the active row
        .gnt_o(y_gnt_o),              // Column grant outputs
        .yadd_o(y_add),               // Additional output for column arbitration
        .Grp_release_o(Grp_release)   // Group release signal
    );

    // Instantiate RoundRobin module for row arbitration
    x_roundrobin RRA_X (
        .clk_i(clk_i),                // Clock input
        .reset_i(reset_i),            // Reset input
        .enable_i(x_enable),          // Enable signal for row arbitration
        .req_i(row),                  // Row requests
        .gnt_o(x_gnt_o),              // Row grant outputs
        .xadd_o(x_add),               // Additional output for row arbitration
        .Grp_release_o(Grp_release)   // Group release signal
    );

endmodule

/*module top_arb #(
    parameter ROWS = 4,   // Number of rows
    parameter COLS = 4    // Number of columns
) (
    input  logic                  clk,
    input  logic                  reset,
    input  logic [ROWS-1:0][COLS-1:0] req_i, // Request inputs
    input  logic                  enable,
    output logic [ROWS-1:0]       x_gnt_o,   // Row grant outputs
    output logic [COLS-1:0]       y_gnt_o    // Column grant outputs
);

    logic Grp_release;
    logic [ROWS-1:0] row;         // Indicates if there's a request in a row
    logic [COLS-1:0] col;         // Holds column requests for the active row
    logic [1:0] x_add;
    logic [1:0] y_add;
     logic x_enable, y_enable;

   typedef enum logic [1:0] {
        IDLE    = 2'b00,
        ROW_GRANT = 2'b01,
        COL_GRANT = 2'b10
    } state_t;

     state_t current_state, next_state;

    // Generate `row` signals to indicate active rows
    always_comb begin
        row = '0;  // Default no rows active
        for (int i = 0; i < ROWS; i++) begin
            row[i] = |req_i[i];  // OR all bits in each row
        end
    end

    assign col = req_i[x_add];

       // FSM state transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // FSM next state and output logic
    always_comb begin
        // Default values
        next_state = current_state;
        x_enable = 1'b0;
        y_enable = 1'b0;

        case (current_state)
            IDLE: begin
                if(enable) 
					  begin
					   x_enable = 1'b1; // Enable row arbitration in IDLE
                  next_state = ROW_GRANT;
					  end
					 else
					  next_state = IDLE;

					 
            end

            ROW_GRANT: begin
                x_enable = 1'b1; // Enable column arbitration in ROW_GRANT
                if (x_gnt_o != 4'b0) begin
                    y_enable = 1'b1; // Enable column arbitration in ROW_GRANT
                    x_enable = 1'b0;
                    next_state = COL_GRANT;
                end
            end

            COL_GRANT: begin
                y_enable = 1'b1; // Enable column arbitration in ROW_GRANT
                if (y_gnt_o == 4'b0) begin
                    x_enable = 1'b1; // Enable column arbitration in ROW_GRANT
                    y_enable = 1'b0; // Enable column arbitration in ROW_GRANT
                    next_state = ROW_GRANT; // Return to IDLE when column grants are done
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end


    // Instantiate RoundRobin module for column arbitration
    y_roundrobin RRA_Y (
        .clk(clk),
        .reset(reset),
        .enable(y_enable),
        .req_i(col),        // Column requests of the active row
        .gnt_o(y_gnt_o),    // Column grant outputs
        .add_o(y_add),
        .Grp_release_o(Grp_release)
    );

    // Instantiate RoundRobin module for row arbitration
    x_roundrobin RRA_X (
        .clk(clk),
        .reset(reset),
        .enable(x_enable),
        .req_i(row),        // Row requests
        .gnt_o(x_gnt_o),    // Row grant outputs
        .add_o(x_add),
        .Grp_release_o(Grp_release)
    );

endmodule*/

