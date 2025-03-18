// Module name: AER Module
// Module Description: This module combines the event data row address,column address,timestamp and polarity when event occured
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants

module event_encoder 
    (
    input logic clk_i,               // Clock input
    input logic reset_i,             // Reset input (active high)
    input logic enable_i,            // Enable signal for state transitions
    input logic polarity_i,          // Event polarity (ON/OFF event)
    input logic active_req,          // Active request signal
    input logic [ROW_ADD-1:0] x_add_i,  // Pixel row address
    input logic [COL_ADD-1:0] y_add_i,  // Pixel column address
    input logic [SIZE-1:0] timestamp_i, // Captured timestamp data
    output logic [WIDTH-1:0] data_out_o, // Encoded event data output
    output logic valid_data_o
    );

  // Splitting the timestamp into high and low parts
  logic [27:0] time_high;  // Upper bits of timestamp
  logic [5:0] time_low;    // Lower 6 bits of timestamp
  logic temp;
  logic pol_in;
  logic [5:0] time_low_store;
  logic [ROW_ADD-1:0] state_x;
  logic [COL_ADD-1:0] state_y;


  assign time_high = timestamp_i[33:6];  
  assign time_low  = timestamp_i[5:0];

  // Defining FSM states for encoding events
  typedef enum logic [2:0] { IDLE, TIME_HIGH, CD_ON, CD_OFF,CD_TIME_HIGH } state_t;   
  state_t state, next_state; // Current and next state registers

  // Sequential block: State transition on clock edge or reset
  always_ff @(posedge clk_i or posedge reset_i)
  begin
      if (reset_i)
          state <= IDLE;  // Reset state     
      else
          state <= next_state;  // Transition to next state
  end

  // Combinational logic for next state determination
 always_comb
  begin
      next_state = state;  // Default assignment to prevent latches
      temp=0;
      case (state)
        IDLE: 
        begin
            if (active_req )
              begin
                data_out_o = '0; 
                next_state = TIME_HIGH;  // Move to TIME_HIGH if enabled
                valid_data_o=1'b0;
              end
            else
              begin
                data_out_o = '0;  // Clear output in IDLE state
                next_state = IDLE;  // Stay in IDLE state if not enabled
                valid_data_o=1'b0;
              end
        end
        TIME_HIGH: 
        begin
                data_out_o = {4'b1000, time_high};  // Encode high timestamp bits
                next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
                valid_data_o=1'b1;
        end

        CD_ON: 
        begin
            if ( active_req && enable_i)
            begin
                data_out_o = {4'b0001, time_low, x_add_i, y_add_i};  // Encode event data for polarity ON
                valid_data_o=1'b1;
            end
            else
            begin
               data_out_o = data_out_o;
               valid_data_o=1'b0;
            end
            if (!active_req) 
               next_state = IDLE; 
            else 
             begin
              if (!polarity_i) 
                next_state = CD_OFF;  // Switch to CD_ON if polarity changes
              else if (time_low == 6'd63) 
               next_state = CD_TIME_HIGH;  // Return to TIME_HIGH after max time_low
             end
        end        
        CD_OFF: 
        begin
            if (active_req && enable_i)
              begin
                data_out_o = {4'b0000, time_low, x_add_i, y_add_i};  // Encode event data for polarity OFF
                valid_data_o=1'b1;
              end
            else
              begin
                data_out_o = data_out_o;
                valid_data_o=1'b0;
              end
            if (!active_req) 
                next_state = IDLE;
            else
            begin
             if (polarity_i) 
               next_state = CD_ON;  
             else if (time_low == 6'd63) 
               next_state = CD_TIME_HIGH; 
            end
        end

     CD_TIME_HIGH: 
        begin
              if (active_req && enable_i && !temp)
              begin
               state_x=x_add_i;
               state_y=y_add_i;
               pol_in=polarity_i;
               time_low_store=time_low;
               data_out_o = {4'b1000, time_high};  // Encode high timestamp bits
               valid_data_o=1'b1;
               temp=temp+1'b1;
              end
              else
              begin
                 data_out_o = { 3'b000,pol_in,time_low_store,state_x,state_y};  // Encode event data for polarity ON      
                 valid_data_o=1'b1;  
                 next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
                 temp=0;
              end
        end     

        default: 
            next_state = IDLE;  // Default case to prevent latching
      endcase
  end

  
endmodule

