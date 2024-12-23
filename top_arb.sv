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

endmodule












// // Module name: RR Arbiter TopModule
// // Module Description: 
// // Author: 
// // Date: 
// // Version:
// //------------------------------------------------------------------------------------------------------------------
// module top_arb #(
//     parameter ROWS = 4,   // Number of rows
//     parameter COLS = 4    // Number of columns
// ) (
//     input  logic                  clk_i,
//     input  logic                  reset_i,
//     input  logic [ROWS-1:0][COLS-1:0] req_i, // Request inputs
//     input  logic                  enable_i,
//     output logic [ROWS-1:0]       x_gnt_o,   // Row grant outputs
//     output logic [COLS-1:0]       y_gnt_o    // Column grant outputs
// );

//     logic Grp_release;
//     logic [ROWS-1:0] row;         // Indicates if there's a request in a row
//     logic [COLS-1:0] col;         // Holds column requests for the active row
//     logic [1:0] x_add;
//     logic [1:0] y_add;
//      logic x_enable, y_enable;

//    typedef enum logic [1:0] {
//         IDLE    = 2'b00,
//         ROW_GRANT = 2'b01,
//         COL_GRANT = 2'b10
//     } state_t;

//      state_t current_state, next_state;

//     // Generate `row` signals to indicate active rows
//     always_comb begin
//         row = 4'b0;  // Default no rows active
//         for (int i = 0; i < ROWS; i++) begin
//             row[i] = |req_i[i];  // OR all bits in each row
//         end
//     end

// <<<<<<< HEAD
//     // Extract the first active row's column requests
//     always_comb begin
//         col = 4'b0;  
//             //if (row[x_add]) begin
//                 col = req_i[x_add];
          
//         //end
// =======
//     assign col = req_i[x_add];

//        // FSM state transition logic
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             current_state <= IDLE;
//         end else begin
//             current_state <= next_state;
//         end
// >>>>>>> 45c8ac03921747f7d73cce288ba4c744e2c0c83b
//     end

//     // FSM next state and output logic
//     always_comb begin
//         // Default values
//         next_state = current_state;
//         x_enable = 1'b0;
//         y_enable = 1'b0;

//         case (current_state)
//             IDLE: begin
//             //    x_enable = 1'b1; // Enable row arbitration in IDLE
//                 next_state = ROW_GRANT;
//             end

//             ROW_GRANT: begin
//                 x_enable = 1'b1; // Enable column arbitration in ROW_GRANT
//                 if (x_gnt_o != '0) begin
//                     y_enable = 1'b1; // Enable column arbitration in ROW_GRANT
//                     x_enable = 1'b0;
//                     next_state = COL_GRANT;
//                 end
//             end

//             COL_GRANT: begin
//                 y_enable = 1'b1; // Enable column arbitration in ROW_GRANT
//                 if (y_gnt_o == '0) begin
//                     x_enable = 1'b1; // Enable column arbitration in ROW_GRANT
//                     y_enable = 1'b0; // Enable column arbitration in ROW_GRANT
//                     next_state = ROW_GRANT; // Return to IDLE when column grants are done
//                 end
//             end

//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end


//     // Instantiate RoundRobin module for column arbitration
// <<<<<<< HEAD
//     roundrobin RRA_Y (
//         .clk_i(clk_i),
//         .reset_i(reset_i),
//         .enable_i(enable_i),
//         .req_i(col),        // Column requests of the active row
//         .gnt_o(y_gnt_o),    // Column grant outputs
//         .add_o(y_add),
//         .Grp_release_o(Grp_release)
//     );

//     // Instantiate RoundRobin module for row arbitration
//     roundrobin RRA_X (
//         .clk_i(clk_i),
//         .reset_i(reset_i),
//         .enable_i(enable_i),
//         .req_i(row),        // Row requests
//         .gnt_o(x_gnt_o),    // Row grant outputs
//         .add_o(x_add),
// =======
//     y_roundrobin RRA_Y (
//         .clk(clk),
//         .reset(reset),
//         .enable(y_enable),
//         .req_i(col),        // Column requests of the active row
//         .gnt_o(y_gnt_o),    // Column grant outputs
//         .add_o(y_add),
// >>>>>>> 45c8ac03921747f7d73cce288ba4c744e2c0c83b
//         .Grp_release_o(Grp_release)
//     );

//     // Instantiate RoundRobin module for row arbitration
//     x_roundrobin RRA_X (
//         .clk(clk),
//         .reset(reset),
//         .enable(x_enable),
//         .req_i(row),        // Row requests
//         .gnt_o(x_gnt_o),    // Row grant outputs
//         .add_o(x_add),
//         .Grp_release_o(Grp_release)
//     );

// endmodule
