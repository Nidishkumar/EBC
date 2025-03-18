// Module name:   Event Encoder Module
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
    input logic [ROW_ADD-1:0] x_add_i,  // Pixel row address
    input logic [COL_ADD-1:0] y_add_i,  // Pixel column address
    input logic [SIZE-1:0] timestamp_i, // Captured timestamp data
    output logic [WIDTH-1:0] data_out_o // Encoded event data output
    );

  // Splitting the timestamp into high and low parts
  logic [27:0] time_high;  // Upper bits of timestamp
  logic [5:0] time_low;    // Lower 6 bits of timestamp

  assign time_high = timestamp_i[33:6];  
  assign time_low  = timestamp_i[5:0];

  // Defining FSM states for encoding events
  typedef enum logic [1:0] { IDLE, TIME_HIGH, CD_ON, CD_OFF } state_t;   
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

      case (state)
        IDLE: 
        begin
            if (enable_i)
                next_state = TIME_HIGH;  // Move to TIME_HIGH if enabled
        end

        TIME_HIGH: 
        begin
            if (enable_i)
                next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
            else
                next_state = IDLE;
        end

        CD_ON: 
        begin
            if (enable_i)
            begin
                if (!polarity_i)
                    next_state = CD_OFF;  // Switch to CD_OFF if polarity changes
                else if (time_low == 6'd63)
                    next_state = TIME_HIGH;  // Return to TIME_HIGH after max time_low
            end
            else
                next_state = IDLE;
        end

        CD_OFF: 
        begin
            if (enable_i)
            begin
                if (polarity_i)
                    next_state = CD_ON;  // Switch to CD_ON if polarity changes
                else if (time_low == 6'd63)
                    next_state = TIME_HIGH;  // Return to TIME_HIGH after max time_low
            end
            else
                next_state = IDLE;
        end

        default: 
            next_state = IDLE;  // Default case to prevent latching
      endcase
  end

  // Sequential block for output logic (better than assigning in always_comb)
  always_ff @(posedge clk_i or posedge reset_i)
  begin
      if (reset_i)
          data_out_o <= '0;
      else
      begin
          case (state)
            IDLE: 
                data_out_o <= '0;  // Clear output in IDLE state

            TIME_HIGH: 
                data_out_o <= {4'b1000, time_high};  // Encode high timestamp bits

            CD_ON: 
                data_out_o <= {4'b0001, time_low, x_add_i, y_add_i};  // Encode event data for polarity ON

            CD_OFF: 
                data_out_o <= {4'b0000, time_low, x_add_i, y_add_i};  // Encode event data for polarity OFF

            default: 
                data_out_o <= '0;  // Default output assignment
          endcase
      end
  end
endmodule
