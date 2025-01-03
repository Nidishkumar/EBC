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
  parameter POLARITY = 2 ;   // Represents the each column length of a pixel in the design
  parameter y_width = 3  ;   // To identify the granted column index
  parameter x_width = 3  ;   // To identify the granted row index
  parameter WIDTH = ROWS ;   // Alias for the number of rows


endpackage