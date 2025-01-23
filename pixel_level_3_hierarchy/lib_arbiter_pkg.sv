// Module name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------
package lib_arbiter_pkg;

  // Define parameters
  parameter ROWS      = 16  ;   // Number of rows in the design
  parameter COLS      = 16  ;   // Number of columns in the design
  
  parameter Lvl_ROWS      = 8  ;   // Number of columns in the design
  parameter Lvl_COLS      = 8  ;   // Number of columns in the design
  
  parameter Lv0_ROWS      = 2  ;   // Number of columns in the design
  parameter Lv0_COLS      = 2  ;   // Number of columns in the design
  
  parameter Lv0_ROW_ADD   = 1  ;   // To identify the granted column index
  parameter Lv0_COL_ADD   = 1  ;   // To identify the granted row index
  
  
  parameter POLARITY  = 2  ;   // Represents the each column length of a pixel 
  
  parameter ROW_ADD   = 4  ;   // To identify the granted column index
  parameter COL_ADD   = 4  ;   // To identify the granted row index
  
  parameter Lvl_ROW_ADD   = 2  ;   // To identify the granted column index
  parameter Lvl_COL_ADD   = 2  ;   // To identify the granted row index
  
  parameter CONST=4;
  parameter no_blocks=16;
  parameter SIZE      = 32 ;   // To define the width of the timestamp
  parameter WIDTH     = SIZE + COL_ADD + ROW_ADD +1  ;   // Total width combining timestamp (32 bits), row address, column address, and polarity (1 bit)
  


endpackage