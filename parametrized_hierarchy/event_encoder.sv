// Module name: AER Module
// Module Description: This module combines the event data row address,column address,timestamp and polarity when event occured
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
//`include "lib_arbiter_pkg.sv"

// import lib_arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

// module event_encoder 
//     (
//     input logic clk_i,                  // Clock input
//     input logic reset_i,                // Reset input (active high)
//     input logic enable_i,               // Enable signal for state transitions
//     input logic polarity_i,             // Event polarity (ON/OFF event)
//     input logic active_req,             // Active request signal
//     input logic [ROW_ADD-1:0] x_add_i,  // Pixel row address
//     input logic [COL_ADD-1:0] y_add_i,  // Pixel column address
//     input logic [SIZE-1:0] timestamp_i, // Captured timestamp data
//     output logic [WIDTH-1:0] data_out_o,// Encoded event data output
//     output logic valid_data_o
//     );

//   // Splitting the timestamp into high and low parts
//   logic [27:0] time_high;  // Upper bits of timestamp
//   logic [5:0] time_low;    // Lower 6 bits of timestamp
//   logic timehigh_temp;

//   assign time_high = timestamp_i[33:6];  
//   assign time_low  = timestamp_i[5:0];

//   // Defining FSM states for encoding events
//   typedef enum logic [2:0] { IDLE, TIME_HIGH, CD_ON, CD_OFF,CD_TIME_HIGH } state_t;   
//   state_t state, next_state; // Current and next state registers

//   // Sequential block: State transition on clock edge or reset
//   always_ff @(posedge clk_i or posedge reset_i)
//   begin
//       if (reset_i)
//           state <= IDLE;  // Reset state     
//       else
//           state <= next_state;  // Transition to next state
//   end

//   // Combinational logic for next state determination
//  always_comb
//   begin
//       next_state = state;  // Default assignment to prevent latches
//       timehigh_temp=0;
//       data_out_o = '0;  // Default output value
//       valid_data_o=1'b0;
//       case (state)
//         IDLE: 
//         begin
//             if (active_req )
//               begin
//                 data_out_o = '0; 
//                 next_state = TIME_HIGH;  // Move to TIME_HIGH if enabled
//                 valid_data_o=1'b0;
//               end
//         end
//         TIME_HIGH: 
//         begin
//                if (active_req )
//               begin
//                 data_out_o = {4'b1000, time_high};  // Encode high timestamp bits
//                 next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
//                 valid_data_o=1'b1;
//               end
//         end

//         CD_ON: 
//         begin
//             if ( enable_i)
//             begin
//                 data_out_o = {4'b0001, time_low, x_add_i, y_add_i};  // Encode event data for polarity ON
//                 valid_data_o=1'b1;
//             end
//             if (!active_req) 
//                 next_state = IDLE; 
//             else 
//              begin
//               if (!polarity_i) 
//                 next_state = CD_OFF;  // Switch to CD_ON if polarity changes
//               else if (time_low == 6'd63) 
//                 next_state = CD_TIME_HIGH;  // Return to TIME_HIGH after max time_low
//              end
//         end        
//         CD_OFF: 
//         begin
//             if (  enable_i)
//               begin
//                 data_out_o = {4'b0000, time_low, x_add_i, y_add_i};  // Encode event data for polarity OFF
//                 valid_data_o=1'b1;
//               end
//             if (!active_req) 
//                 next_state = IDLE;
//             else
//             begin
//              if (polarity_i) 
//                 next_state = CD_ON;  
//              else if (time_low == 6'd63) 
//                 next_state = CD_TIME_HIGH; 
//             end
//         end

//      CD_TIME_HIGH: 
//         begin
//               if (!enable_i && !timehigh_temp)
//               begin
//                data_out_o = {4'b1000, time_high};  // Encode high timestamp bits
//                valid_data_o = 1'b1;
//                timehigh_temp = timehigh_temp+1'b1;
//                next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
//               end
//         end     

//         default: 
//             next_state = IDLE;  // Default case to prevent latching
//       endcase
//   end

  
// endmodule

//---------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
// Module: event_encoder
// Description: Encodes event data based on the input pixel address, timestamp, and polarity.Implements a state machine for encoding event data efficiently.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//--------------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;  // Importing arbiter package containing parameter constants

module event_encoder 
    (
    input logic clk_i,                  // Clock input
    input logic reset_i,                // Reset input (active high)
    input logic enable_i,               // Enable signal for state transitions
    input logic polarity_i,             // Event polarity (ON/OFF event)
    input logic active_req_i,             // Active request signal
    input logic [ROW_ADD-1:0] x_add_i,  // Pixel row address
    input logic [COL_ADD-1:0] y_add_i,  // Pixel column address
    input logic [SIZE-1:0] timestamp_i, // Captured timestamp data
    output logic [WIDTH-1:0] data_out_o,// Encoded event data output
    output logic valid_data_o           // Output valid signal
    );

  // Splitting the timestamp into high and low parts
  logic [27:0] time_high;  // Upper 28 bits of timestamp
  logic [5:0] time_low;    // Lower 6 bits of timestamp
  logic timehigh_temp;     // Temporary flag for CD_time_high state

  assign time_high = timestamp_i[33:6];  // Extract upper bits
  assign time_low  = timestamp_i[5:0];   // Extract lower 6 bits

  // Defining FSM states for encoding events
  typedef enum logic [2:0] { IDLE, TIME_HIGH, CD_ON, CD_OFF, CD_TIME_HIGH } state_t;   
  state_t state, next_state; // Current and next states

  // Sequential block: State transition on clock edge or reset
  always_ff @(posedge clk_i or posedge reset_i)
  begin
      if (reset_i)
          state <= IDLE;        // Reset to IDLE state
      else
          state <= next_state;  // Transition to next state
  end

  // Combinational logic for next state determination
  always_comb
  begin
      next_state = state;  // Default assignment 
      timehigh_temp = 0;   // Reset temporary variable
      data_out_o = '0;     // Default output value
      valid_data_o = 1'b0; // Default valid signal

      case (state)
        // IDLE State: Wait for an active requests
        IDLE: 
        begin
            if (active_req_i)
            begin
                data_out_o = '0; 
                next_state = TIME_HIGH;  // Move to TIME_HIGH if active request is present
                valid_data_o = 1'b0;
            end
        end

        // TIME_HIGH State: Send the high bits of timestamp
        TIME_HIGH: 
        begin
            if (active_req_i)
            begin
                data_out_o = {4'b1000, time_high};           // Encode high timestamp bits
                next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
                valid_data_o = 1'b1;
            end
        end

        // CD_ON State: Encode event with ON polarity
        CD_ON: 
        begin
            if (enable_i)
            begin
                data_out_o = {4'b0001, time_low, x_add_i, y_add_i};  // Encode event data for polarity ON
                valid_data_o = 1'b1;     // Assert 1 when data_out_o holds valid encoded event data

            end
            if (!active_req_i) 
                next_state = IDLE;              // Return to IDLE if no request
            else 
            begin
                if (!polarity_i) 
                    next_state = CD_OFF;        // Switch to CD_OFF if polarity changes
                else if (time_low == 6'd63) 
                    next_state = CD_TIME_HIGH;  // Transition to CD_TIME_HIGH after max time_low
            end
        end        

        // CD_OFF State: Encode event with OFF polarity
        CD_OFF: 
        begin
            if (enable_i)
            begin
                data_out_o = {4'b0000, time_low, x_add_i, y_add_i};  // Encode event data for polarity OFF
                valid_data_o = 1'b1; // Assert 1 when data_out_o holds valid encoded event data
            end
            if (!active_req_i) 
                next_state = IDLE;   // Return to IDLE if no request
            else
            begin
                if (polarity_i) 
                    next_state = CD_ON;         // Switch to CD_ON if polarity changes
                else if (time_low == 6'd63) 
                    next_state = CD_TIME_HIGH;  // Transition to CD_TIME_HIGH after max time_low
            end
        end

        // CD_TIME_HIGH State: Send the high bits of timestamp again when needed
        CD_TIME_HIGH: 
        begin
            if (!enable_i && !timehigh_temp)
            begin
                data_out_o = {4'b1000, time_high};           // Encode high timestamp bits
                valid_data_o = 1'b1;                         // Assert 1 when data_out_o holds valid encoded event data
                timehigh_temp = timehigh_temp + 1'b1;
                next_state = (polarity_i) ? CD_ON : CD_OFF;  // Transition based on polarity
            end
        end     

        default: 
            next_state = IDLE;  // Default case to prevent latching
      endcase
  end

endmodule
