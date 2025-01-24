//-----------------------------------------------------------------------------------------------------------------
// Module Name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------

package lib_arbiter_pkg;

  // Parameters for Level 0 of the hierarchy
  parameter Lvl0_PIXELS       = 32; // Total number of pixels in Level 0 (16x16 matrix)
  parameter Lvl0_GROUP_SIZE   = 2;  // Group size for subgroups in Level 0
  parameter CONST0            = Lvl0_PIXELS / Lvl0_GROUP_SIZE; // Number of groups per row or column in Level 0
  parameter NUM_GROUPS0       = CONST0 * CONST0; // Total number of groups in Level 0
  parameter Lvl0_ADD          = 1;  // Address size for Level 0 groups (in bits)

  // Parameters for Level 1 of the hierarchy
  parameter Lvl1_PIXELS       = 16;  // Total number of pixels in Level 1 (8x8 matrix)
  parameter Lvl1_GROUP_SIZE   = 2;  // Group size for subgroups in Level 1
  parameter CONST1            = Lvl1_PIXELS / Lvl1_GROUP_SIZE; // Number of groups per row or column in Level 1
  parameter NUM_GROUPS1       = CONST1 * CONST1; // Total number of groups in Level 1
  parameter Lvl1_ADD          = 1;  // Address size for Level 1 groups (in bits)

  // Parameters for Level 2 of the hierarchy
  parameter Lvl2_PIXELS       = 8;  // Total number of pixels in Level 2 (4x4 matrix)
  parameter Lvl2_ADD          = 3;  // Address size for Level 2 groups (in bits)

  // Parameters for polarity handling
  parameter POLARITY          = 2;  // Polarity signal width (e.g., 2 for +ve and -ve polarities)

  // Parameters for address width calculation
  parameter COL_ADD           = Lvl2_ADD + Lvl1_ADD + Lvl0_ADD; // Total column address width (sum of all levels)
  parameter ROW_ADD           = Lvl2_ADD + Lvl1_ADD + Lvl0_ADD; // Total row address width (sum of all levels)

  // Parameters for timestamp and data width
  parameter SIZE              = 32; // Width of the timestamp (in bits)
  parameter WIDTH             = SIZE + COL_ADD + ROW_ADD + 1; // Total width combining timestamp, row address, column address, and polarity

endpackage



/*// Module name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------
package lib_arbiter_pkg;

  // Define parameters
  parameter Lvl0_PIXELS      = 16  ;   // Number of rows in the design
  parameter Lvl0_GROUP_SIZE    = 2   ;
  parameter CONST0 = Lvl0_PIXELS / Lvl0_GROUP_SIZE; 
  parameter NUM_GROUPS0 = CONST0 * CONST0;
  parameter Lvl0_ADD =1;
  
  
  parameter Lvl1_PIXELS      = 8  ;   // Number of rows in the design
  parameter Lvl1_GROUP_SIZE    = 2  ;
  parameter CONST1 = Lvl1_PIXELS / Lvl1_GROUP_SIZE; 
  parameter NUM_GROUPS1 = CONST1 * CONST1;
  parameter Lvl1_ADD =1;

  
  parameter Lvl2_PIXELS      = 4  ;   // Number of rows in the design
  parameter Lvl2_ADD =2;
  
  parameter POLARITY =2;
  parameter COL_ADD = Lvl2_ADD + Lvl1_ADD + Lvl0_ADD ;
  parameter ROW_ADD = Lvl2_ADD + Lvl1_ADD + Lvl0_ADD ;

  parameter SIZE      = 32 ;   // To define the width of the timestamp
  parameter WIDTH     = SIZE + COL_ADD + ROW_ADD +1  ;   // Total width combining timestamp (32 bits), row address, column address, and polarity (1 bit)
  
endpackage */