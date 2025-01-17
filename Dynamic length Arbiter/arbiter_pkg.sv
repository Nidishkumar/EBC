// Module name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------
package arbiter_pkg;

  // Define parameters
  parameter ROWS = 8     ;   // Number of rows in the design
  parameter COLS = 8     ;   // Number of columns in the design
  parameter POLARITY = 2 ;   // Represents the each column length of a pixel 
  parameter ROW_ADD = 3  ;   // To identify the granted column index
  parameter COL_ADD = 3  ;   // To identify the granted row index
  parameter SIZE  = 32   ;   // To define the width of the timestamp
  parameter WIDTH =39    ;   // Total width combining timestamp (32 bits), row address, column address, and polarity (1 bit)
  


endpackage