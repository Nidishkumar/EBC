// Module name: Top Module
// Module Description: The top module manages pixel request arbitration across multiple levels, selecting a pixel based on requests and grants. It tracks activity, assigns polarity, and updates x/y addresses synchronously.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants
module top_pixel_hierarchy 
(
    input logic clk_i,                                      // Input clock for Synchronization
    input logic reset_i,                                    // Reset signal
    input logic [ROWS1-1:0][COLS1-1:0][POLARITY-1:0] req_i, // Pixel requests input with polarity for each pixel
    output logic [ROWS1-1:0][COLS1-1:0] gnt_out_o,          // Grant output  
    output logic grp_release_out_o,                         // Group release signal from higher level
    output logic [WIDTH-1:0] data_out_o  ,                  // Data output (row, column, timestamp, polarity)
    output logic valid_data_o                               // Valid signal indicating if output data is valid or not
);

logic active;                                   // Indicates if any request is active
logic polarity;                                 // Stores the polarity of an event
logic enable_in;                                // Enable signal for the hierarchy processing
logic [SIZE-1:0] timestamp;                     // Timestamp signal to mark event time
logic [NO_levels-1:0] active_in;                // Active signals at different levels of the hierarchy
logic active_req;                               // Aggregated active request signal

//---------------------------------Signals for Single pixel array-----------------------------------------------------------------------------------------------
logic [ROWS1-1:0][COLS1-1:0] req_1_in;          // Request signals for Single pixel array
logic req_1_o;                                  // enable signal for Single pixel array
logic enable_1_in;                              // Enable signal for Single pixel array
logic [ROWS1-1:0][COLS1-1:0] grant_1_out;       // Grant signals for Single pixel array
logic [Lvl_ADD[NO_levels-1]-1:0] x_add_1_out;   // Row address output for Single pixel array
logic [Lvl_ADD[NO_levels-1]-1:0] y_add_1_out;   // Column address output for Single pixel array
logic active_1_out;                             // Indicates if the Single pixel array arbitration is active
logic grp_release_1_out;                        // Group release signal for Single pixel array


//---------------------------------Assigments for  Single pixel array-----------------------------------------------------------------------------------------------
assign enable_1_in = req_1_o;
//---------------------------------End of Assigments for Single pixel array-----------------------------------------------------------------------------------------------


//---------------------------------Signals for Single pixel array-----------------------------------------------------------------------------------------------

logic req_o;                            // Aggregated request signal at the hierarchy level
assign enable_in = req_o;               // Enable signal is driven by request output

logic [POLARITY-1:0]polarity_in;        // Stores polarity information for each event
logic [ROW_ADD-1:0]x_add_o;             // Overall row address from all levels
logic [COL_ADD-1:0]y_add_o;             // Overall Column address from all levels
logic [ROW_ADD-1:0]x_add_ff;            // Registered row address
logic [COL_ADD-1:0]y_add_ff;            // Registered Column address
logic [ROW_ADD-1:0]x_add_f;             // Registered row address
logic [COL_ADD-1:0]y_add_f;             // Registered Column address

logic [ROWS[NO_levels-1]-1:0][COLS[NO_levels-1]-1:0] req;   // Request signals at the highest level from lower level

logic [Lvl_ROWS[NO_levels-1]-1:0][Lvl_COLS[NO_levels-1]-1:0] grant_out ; // Grant output for higher level
// ---------------- Address for Higher Level------------------------------------------------------------------------------------------ 
logic [Lvl_ADD[NO_levels-1]-1:0] x_add_out ;          // ROW address of the higher level
logic [Lvl_ADD[NO_levels-1]-1:0] y_add_out;           // Column address of the higher level
// ---------------- Group Release & Active Status ------------------------------------------------------------------------------------- 
logic grp_release_out [NO_levels-1:0];                // Group release signals for all levels
logic active_out [NO_levels-1:0];                     // Arbitration active status output for all levels
// ---------------- All Level Row and Column Address Storage except higher level ---------------- 
logic [ADD-1:0] x_add;                                
logic [ADD-1:0] y_add;

assign grp_release_out_o = (NO_levels==1) ? grp_release_1_out : grp_release_out[NO_levels-1];

//----------------------------GENERATE BLOCK FOR LEVEL HIERARCHY-----------------------------------------------------------------------------------------------

if (NO_levels > 1) 
begin
    genvar i, j, k;
    for (i = 0; i < NO_levels-1; i = i + 1) begin : level_hierarchy
        logic [ROWS[i]-1:0][COLS[i]-1:0] grant_enb;   
        logic [ROWS[i]-1:0][COLS[i]-1:0] req_in;         
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] req_out;      
        logic [ROWS[i+1]-1:0][COLS[i+1]-1:0] enable_in;  
        logic [Lvl_ADD[i]-1:0] x_add_out1 ; // Row address output for all levels
        logic [Lvl_ADD[i]-1:0] y_add_out1 ; // Column address output for all levels
        logic grp_out;

        if (i == 0) 
        begin
//------------------------------------------------------------------------------------------------------------------
            for (j = 0; j < ROWS[i]; j = j + 1) 
            begin : loops1
                for (k = 0; k < COLS[i]; k = k + 1) 
                begin : loops2
                    assign req_in[j][k] = |req_i[j][k];
                end
            end
//------------------------------------------------------------------------------------------------------------------
            for (j = 0; j < ROWS[i]; j = j + 1) 
            begin : loops4
                for (k = 0; k < COLS[i]; k = k + 1) 
                begin : loops5
                    assign gnt_out_o[j][k] = grant_enb[j][k];
                end
            end
//------------------------------------------------------------------------------------------------------------------
           assign grp_out = 1'b1;
           if(NO_levels==2)
           begin
            for (j = 0; j < ROWS[i+1]; j = j + 1) 
            begin : loops3
                for (k = 0; k < COLS[i+1]; k = k + 1) 
                begin : loops4
                    assign enable_in[j][k] = grant_out[j][k];   
                end
            end
             for (j = 0; j < ROWS[i+1]; j = j + 1) 
             begin : loops12
                    for (k = 0; k < COLS[i+1]; k = k + 1) 
                    begin : loops13
                        assign req[j][k] = req_out[j][k];
                    end
                end
           end
           else
              begin
            for (j = 0; j < ROWS[i+1]; j = j + 1) 
            begin : loops13
                for (k = 0; k < COLS[i+1]; k = k + 1) 
                begin : loops14
                    assign enable_in[j][k] = level_hierarchy[i+1].grant_enb[j][k];   
                end
            end
              end
//------------------------------------------------------------------------------------------------------------------          
        end 
//------------------------------------------------------------------------------------------------------------------
   else
        begin
//------------------------------------------------------------------------------------------------------------------
            for (j = 0; j < ROWS[i]; j = j + 1) 
            begin : loops6
                for (k = 0; k < COLS[i]; k = k + 1) 
                begin : loops7
                    assign req_in[j][k] = level_hierarchy[i-1].req_out[j][k];   
                end
            end
//------------------------------------------------------------------------------------------------------------------
            assign grp_out = grp_release_out[i-1];
            if (i < NO_levels-2) 
            begin
                for (j = 0; j < ROWS[i+1]; j = j + 1) 
                    begin : loops8
                    for (k = 0; k < COLS[i+1]; k = k + 1) 
                    begin : loops9
                        assign enable_in[j][k] = level_hierarchy[i+1].grant_enb[j][k];   
                    end
                end
            end 
            else 
            begin
                for (j = 0; j < ROWS[i+1]; j = j + 1) 
                begin : loops10
                    for (k = 0; k < COLS[i+1]; k = k + 1) 
                    begin : loops11
                        assign enable_in[j][k] = grant_out[j][k];           
                    end
                end   
            end
//------------------------------------------------------------------------------------------------------------------

            if (i == NO_levels-2) 
            begin
                for (j = 0; j < ROWS[i+1]; j = j + 1) 
                begin : loops12
                    for (k = 0; k < COLS[i+1]; k = k + 1) 
                    begin : loops17
                        assign req[j][k] = req_out[j][k];
                    end
                end
            end
//------------------------------------------------------------------------------------------------------------------
        end     
       
        pixel_groups_1 #(
        .LEVEL         (i),              // Current hierarchy level
        .ROWS          (ROWS[i]),        // Number of rows at this level
        .COLS          (COLS[i]),        // Number of columns at this level
        .Lvl_ROWS      (Lvl_ROWS[i]),    // Number of rows in the next processing level
        .Lvl_COLS      (Lvl_COLS[i]),    // Number of columns in the next processing level
        .Lvl_ADD       (Lvl_ADD[i]),     // Address width required for current level
        .NUM_GROUP     (NUM_GROUP[i]),   // Number of groups in the current level
        .NXT_ROWS      (ROWS[i+1]),      // Number of rows in the next level
        .NXT_COLS      (COLS[i+1])       // Number of columns in the next level
    ) 
        level_inst_1 
        (
        .clk_i         (clk_i),               // Clock input
        .reset_i       (reset_i),             // Reset signal (active high)
        .enable_i      (enable_in),           // Enable signal from the previous level
        .grp_enable_i  (grp_out),             // Group enable signal for arbitration
        .req_i         (req_in),              // Input request signals for the current level
        .gnt_out_o     (grant_enb),           // Grant output signals for the current level
        .x_add_o       (x_add_out1),          // X-address output for this level
        .y_add_o       (y_add_out1),          // Y-address output for this level
        .active_o      (active_out[i]),       // Active flag output (indicating an active request)
        .req_o         (req_out),             // Request output for the next level
        .grp_release_o (grp_release_out[i])   // Group release signal for the next level
    );
    assign x_add[(i+1)*ADD-1 : i*ADD] = x_add_out1;  // All levels row Addresses are concatenated
    assign y_add[(i+1)*ADD-1 : i*ADD] = y_add_out1;  // All levels column Addresses are concatenated
   end  
    end
//------------------------SINGLE PIXEL ARRAY ARBITRATION---------------------------------------------------------------------------------------------------------------------
else 
begin
    always_comb begin
        // Iterate over each row and column of the pixel array
        for (int j = 0; j < ROWS1; j = j + 1) 
        begin
            for (int k = 0; k < COLS1; k = k + 1) 
            begin
                req_1_in[j][k] = |req_i[j][k];   //Input requests to single pixel array
            end
        end
        
        // Iterate again to assign grant outputs for each pixel
        for (int j = 0; j < ROWS1; j = j + 1) 
        begin
            for (int k = 0; k < COLS1; k = k + 1) 
            begin
                gnt_out_o[j][k] = grant_1_out[j][k];   // Assign grant output based on arbitration results
            end
        end
    end

    pixel_level_0 #(
        .Lvl_ROWS      (ROWS1),   // Number of rows for the highest level
        .Lvl_COLS      (COLS1),   // Number of columns for the highest level
        .Lvl_ADD       (Lvl_ADD[NO_levels-1])   // Address width for the highest level
    ) 
    next_level 
    (
        .clk_i         (clk_i),                // System clock input
        .reset_i       (reset_i),              // System reset input
        .enable_i      (enable_1_in),          // Enable signal for the highest level
        .req_i         (req_1_in),             // Request input for the highest level
        .gnt_o         (grant_1_out),          // Grant output for the highest level
        .x_add_o       (x_add_1_out),          // row address output for the highest level
        .y_add_o       (y_add_1_out),          // column address output for the highest level
        .req_o         (req_1_o),              // Request output to control the Higher level
        .active_o      (active_1_out),         // Active status output for the highest level
        .grp_release_o (grp_release_1_out)     // Group release output for the highest level
    );
end
//-------------------------END SINGLE PIXEL ARRAY ARBITRATION--------------------------------------------------------------------------------------------------------------------------------

//-------------------------HIGHER LEVEL PIIXEL ARBITRATION---------------------------------------------------------------------------------------
pixel_level_1
    #(  
        .Lvl_ROWS    (ROWS[NO_levels-1]),   // Number of rows for the highest level
        .Lvl_COLS    (ROWS[NO_levels-1]),   // Number of columns for the highest level
        .Lvl_ADD     (Lvl_ADD[NO_levels-1])  // Address width for the highest level
    ) 
next_level_1
    (
        .clk_i        (clk_i),                          // System clock input
        .reset_i      (reset_i),                        // System reset input
        .enable_i     (enable_in),                      // Enable signal for the highest level
        .grp_enable_i (grp_release_out[NO_levels-2]),   // Group enable from the previous level
        .req_i        (req),                            // Request input for the highest level
        .gnt_o        (grant_out),                      // Grant output for the highest level
        .x_add_o      (x_add_out),                      // row address output for the highest level
        .y_add_o      (y_add_out),                      // column address output for the highest level
        .req_o        (req_o),                          // Request output to control the Higher level
        .active_o     (active_out[NO_levels-1]),        // Active status output for the highest level
        .grp_release_o(grp_release_out[NO_levels-1])    // Group release output for the highest level
    );
//-------------------------END OF HIGHER LEVEL PIIXEL ARBITRATION---------------------------------------------------------------------------------------

// Combinational block to concatenate address outputs from all levels
always_comb
    begin 
    if(NO_levels==1)
    begin
        assign x_add_o = x_add_1_out;     //Single pixel array row address
        assign y_add_o = y_add_1_out;     //Singl pixel array column address
        $write("x_add_o=[%0b],y_add_o=[%0b]\n",x_add_o,y_add_o);
    end
    else
    begin
        assign x_add_o = {x_add_out, x_add};  // Row address from all levels
        assign y_add_o = {y_add_out, y_add};  // Column address from all levels
    end
end

// Assign polarity input based on the request at the granted row and column addresses
assign polarity_in=req_i[x_add][y_add];

always_ff@(posedge clk_i or posedge reset_i)
begin
    if(reset_i)
    begin
        x_add_f <= 'b0;  // Clear row adresss
        y_add_f <= 'b0;  // Clear column address
        x_add_ff <= 'b0; // Clear delayed  row address
        y_add_ff <= 'b0; // Clear delayed  column address

    end
    else
    begin
        x_add_f <= x_add_o; // Store current x address
        y_add_f <= y_add_o; // Store current y address
        x_add_ff <= x_add_f;// Store previous x address
        y_add_ff <= y_add_f;// Store previous y address
    end
end

 // AND all active_out bits from all levels for the final active signal
always_comb 
begin
    if(NO_levels==1)
       active_in=active_1_out;   // Single level case: directly assign active_1_out
    else
    begin
    active_in=0;                 // Initialize active input to 0
    for (int i = 0; i < NO_levels; i++) 
    begin
       active_in = {active_in,active_out[i]};   // Concatenation of all active_out signals from all levels
    end
    end
end  

// // Sequential logic to determine active request status
always_ff@(posedge clk_i or posedge reset_i)
begin
if(reset_i)               // Reset condition
begin
   active_req <=0;        // Clear active request signal
   active =0;
end
else
begin
   active_req <= |req_i;      // Assert active request if any request is received
   if(NO_levels==1)
    active <= active_1_out;   // Single level case: assign active_1_out
   else
   active =&active_in;        // Multi-level case: AND all active_in signals
end
end
wall_clock time_stamp (
    .clk_i       (clk_i),
    .reset_i     (reset_i),
    .timestamp_o (timestamp)
);

// // Polarity selector module to get pixel polarity
polarity_selector polarity_sel (
    .clk_i        (clk_i),
    .reset_i      (reset_i),
    .req_i        (polarity_in),
    .polarity_out (polarity)
);

// // //Address Event Representation (AER) to combine event data
event_encoder address_event (
    .clk_i        (clk_i),
    .reset_i      (reset_i),
    .active_req_i (active_req),
    .enable_i     (active), // Enable signal from last arbitration level
    .x_add_i      (x_add_ff),
    .y_add_i      (y_add_ff),
    .timestamp_i  (timestamp),
    .polarity_i   (polarity),
    .data_out_o   (data_out_o),
    .valid_data_o (valid_data_o)
);

endmodule

