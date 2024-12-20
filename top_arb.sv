// Module name: RR Arbiter TopModule
// Module Description: 
// Author: 
// Date: 
// Version:
//------------------------------------------------------------------------------------------------------------------
module top_arb #(
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

    // Generate `row` signals to indicate active rows
    always_comb begin
        row = '0;  // Default no rows active
        for (int i = 0; i < ROWS; i++) begin
            row[i] = |req_i[i];  // OR all bits in each row
        end
    end

    // Extract the first active row's column requests
    always_comb begin
        col = '0;  
        for (int i = 0; i < ROWS; i++) begin
            if (row[i]) begin
                col = req_i[i];
                break;  // Stop after finding the first active row
            end
        end
    end

    // Instantiate RoundRobin module for column arbitration
    roundrobin RRA_Y (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .req_i(col),        // Column requests of the active row
        .gnt_o(y_gnt_o),    // Column grant outputs
        .add_o(x_add),
        .Grp_release_o(Grp_release)
    );

    // Instantiate RoundRobin module for row arbitration
    roundrobin RRA_X (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .req_i(row),        // Row requests
        .gnt_o(x_gnt_o),    // Row grant outputs
        .add_o(y_add),
        .Grp_release_o(Grp_release)
    );

endmodule
