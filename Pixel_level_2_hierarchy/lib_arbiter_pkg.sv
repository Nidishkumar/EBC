//-----------------------------------------------------------------------------------------------------------------
// Module Name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------

package lib_arbiter_pkg;

  parameter ROWS =8;        //Total number of pixels rows from EBC sensor
  parameter COLS =8;        //Total number of pixels cols from EBC sensor
  parameter NO_levels  = 2; //Total number of levels

  // Parameters for Lower Level of the hierarchy
  parameter Lvl0_ROWS       = 2;    // Total number of Rows in Level-0
  parameter Lvl0_COLS       = 2;    // Total number of Columns in Level-0
  parameter Lvl0_GROUP_SIZE   = Lvl0_ROWS ;               // Group size for subgroups in Level 0
  parameter CONST0            = ROWS / Lvl0_GROUP_SIZE;   // pixel array per group size  in Level 0 for grouping pixels
  parameter NUM_GROUPS0       = CONST0 * CONST0;          // Total number of groups in Final Level
  parameter Lvl0_ADD          = 1;  // Address size for Lower level groups 
  

  
  // Parameters for Higher Level of the hierarchy
  parameter Lvl_ROWS      = 4;      // Total number of Rows in Higher Level
  parameter Lvl_COLS      = 4;      // Total number of Columns in Higher Level
  parameter Lvl_ADD       = 2;      // Address size for Higher Level groups 

  
  // Parameters for polarity handling
  parameter POLARITY          = 2;      // Polarity signal width 

  
  // Parameters for address width calculation
  parameter COL_ADD           = Lvl_ADD + Lvl0_ADD;   // Total column address width (sum of all levels)
  parameter ROW_ADD           = Lvl_ADD + Lvl0_ADD;   // Total row address width (sum of all levels)
  
  // Parameters for timestamp and data width
  parameter SIZE              = 32;     // Width of the timestamp 
  parameter WIDTH             = SIZE + COL_ADD + ROW_ADD + 1; // Total width combining timestamp, row address, column address, and polarity

endpackage


