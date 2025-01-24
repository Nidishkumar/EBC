// Module name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------
package lib_arbiter_pkg;

  // Define parameters
  parameter Lvl0_PIXELS      = 16  ;   // Number of rows in the design
  parameter l0_GROUP_SIZE    = 2   ;
  parameter CONST0 = Lvl0_PIXELS / l0_GROUP_SIZE; 
  parameter NUM_GROUPS0 = CONST0 * CONST0;
  parameter Lvl0_ADD =1;

  
  parameter Lvl1_PIXELS      = 8  ;   // Number of rows in the design
  parameter l1_GROUP_SIZE    = 2  ;
  parameter CONST1 = Lvl1_PIXELS / l1_GROUP_SIZE; 
  parameter NUM_GROUPS1 = CONST1 * CONST1;
  parameter Lvl1_ADD =1;

  
  parameter Lvl2_PIXELS      = 4  ;   // Number of rows in the design
  parameter Lvl2_ADD =2;
  
  parameter POLARITY =2;
  parameter COL_ADD = Lvl2_ADD + Lvl1_ADD + Lvl0_ADD ;
  parameter ROW_ADD = Lvl2_ADD + Lvl1_ADD + Lvl0_ADD ;

  parameter SIZE      = 32 ;   // To define the width of the timestamp
  parameter WIDTH     = SIZE + COL_ADD + ROW_ADD +1  ;   // Total width combining timestamp (32 bits), row address, column address, and polarity (1 bit)
  
endpackage