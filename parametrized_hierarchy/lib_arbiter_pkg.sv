//--------------------------------------------------------------------------------------------------------------------
// 4 LEVEL HIERARCHY - Parameter Definitions for Arbiter Configuration
//--------------------------------------------------------------------------------------------------------------------

package lib_arbiter_pkg;

   // Number of hierarchical levels
   parameter NO_levels = 4;

   // Define dimensions for different levels  
   parameter ROWS1 = 64;
   parameter COLS1 = 64;

   // ROWS and COLS arrays define the hierarchical structure  
   parameter int ROWS[NO_levels] = '{ROWS1, 32, 8, 4};  
   parameter int COLS[NO_levels] = ROWS;   

   // Define the number of rows and columns in each level of the hierarchy  
   parameter int Lvl_ROWS[NO_levels] = '{2, 4, 2, 4};  
   parameter int Lvl_COLS[NO_levels] = Lvl_ROWS;    

   // Number of groups at each level  
   parameter int NUM_GROUP[NO_levels] = '{1024, 64, 16, 1};  

   // Address width at each level  
   // Determines how much addressing is required at each level  
   parameter int Lvl_ADD[NO_levels] = '{1, 2, 1, 2};  

   // Total addressing width across levels except the highest level   
   parameter int ADD = Lvl_ADD[0] + Lvl_ADD[1] + Lvl_ADD[2];  

   // Row and Column Address bit-widths  
   parameter ROW_ADD = 11;  
   parameter COL_ADD = 11;  

   // Additional parameters  
   parameter int SIZE = 34;      // Width of the timestamp  
   parameter int POLARITY = 2;   // Polarity encoding width  
   parameter int WIDTH = 32;     // Data width  

endpackage

//--------------------------------------------------------------------------------------------------------------------
// 3 LEVEL HIERARCHY - Parameter Definitions for Arbiter Configuration
//--------------------------------------------------------------------------------------------------------------------

// package lib_arbiter_pkg;

//    // Number of hierarchical levels
//    parameter NO_levels = 3;

//    // Define base dimensions for the topmost level
//    parameter ROWS1 = 32;  // Number of rows at the highest level
//    parameter COLS1 = 32;  // Number of columns at the highest level

//    // Define ROWS and COLS arrays for different hierarchy levels  
//    parameter int ROWS[NO_levels] = '{ROWS1, 4, 2};  
//    parameter int COLS[NO_levels] = '{COLS1, 4, 2};  

//    // Define the number of rows and columns at each hierarchical level  
//    parameter int Lvl_ROWS[NO_levels] = '{8, 2, 2};  
//    parameter int Lvl_COLS[NO_levels] = '{8, 2, 2};  

//    // Number of groups at each level  
//    parameter int NUM_GROUP[NO_levels] = '{16, 4, 1};  

//    // Address width required at each level  
//    parameter int Lvl_ADD[NO_levels] = '{3, 1, 1};  

//    // Total addressing width across levels except the highest level 
//    parameter int ADD = Lvl_ADD[0] + Lvl_ADD[1];  

//    // Row and Column Address bit-widths  
//    parameter ROW_ADD = 11;  
//    parameter COL_ADD = 11;  

//    // Additional configuration parameters  
//    parameter int SIZE = 34;      // Width of the timestamp  
//    parameter int POLARITY = 2;   // Polarity encoding width  
//    parameter int WIDTH = 32;     // Data width  

// endpackage

//------------------------------2 LEVEL HIERARCHY----------------------------------------------------------------------  

//--------------------------------------------------------------------------------------------------------------------
// 2 LEVEL HIERARCHY - Parameter Definitions for Arbiter Configuration
//--------------------------------------------------------------------------------------------------------------------

// package lib_arbiter_pkg;

//    // Number of hierarchical levels
//    parameter NO_levels = 2;

//    // Define base dimensions for the topmost level
//    parameter ROWS1 = 8;  // Number of rows at the highest level
//    parameter COLS1 = 8;  // Number of columns at the highest level

//    // Define ROWS and COLS arrays for different hierarchy levels  
//    parameter int ROWS[NO_levels] = '{ROWS1, 2};  
//    parameter int COLS[NO_levels] = '{COLS1, 2};  

//    // Define the number of rows and columns at each hierarchical level  
//    parameter int Lvl_ROWS[NO_levels] = '{4, 2};  
//    parameter int Lvl_COLS[NO_levels] = '{4, 2};  

//    // Number of groups at each level  
//    parameter int NUM_GROUP[NO_levels] = '{4, 1};  

//    // Address width required at each level  
//    parameter int Lvl_ADD[NO_levels] = '{2, 1};  

//    // Total addressing width (considering only the first level)  
//    parameter int ADD = Lvl_ADD[0];  

//    // Row and Column Address bit-widths  
//    parameter ROW_ADD = 11;  
//    parameter COL_ADD = 11;  

//    // Additional configuration parameters  
//    parameter int SIZE = 34;      // Width of the timestamp  
//    parameter int POLARITY = 2;   // Polarity encoding width  
//    parameter int WIDTH = 32;     // Data width  

// endpackage

//------------------------------SINGL PIXEL ARRAY----------------------------------------------------------------------  

//--------------------------------------------------------------------------------------------------------------------
// 1 LEVEL HIERARCHY - Parameter Definitions for Arbiter Configuration
//--------------------------------------------------------------------------------------------------------------------

// package lib_arbiter_pkg;

//    // Number of hierarchical levels
//    parameter NO_levels = 1;

//    // Define base dimensions for the level
//    parameter ROWS1 = 8;  // Number of rows
//    parameter COLS1 = 8;  // Number of columns

//    // Define the number of rows and columns in this level  
//    parameter int Lvl_ROWS[NO_levels] = '{2};  
//    parameter int Lvl_COLS[NO_levels] = '{2};  

//    // Number of groups at this level  
//    // Since it's a single level, there's only one group  
//    parameter int NUM_GROUP = 1;  

//    // Address width required for this level  
//    parameter int Lvl_ADD[NO_levels] = '{3};  

//    // Define ROWS and COLS arrays for this level  
//    parameter int ROWS[NO_levels] = '{ROWS1};  
//    parameter int COLS[NO_levels] = '{COLS1};  

//    // Total addressing width (only one level, so just Lvl_ADD[0])  
//    parameter int ADD = Lvl_ADD[0];  

//    // Row and Column Address bit-widths  
//    parameter ROW_ADD = 11;  
//    parameter COL_ADD = 11;  

//    // Additional configuration parameters  
//    parameter int SIZE = 34;      // Width of the timestamp  
//    parameter int POLARITY = 2;   // Polarity encoding width  
//    parameter int WIDTH = 32;     // Data width  

// endpackage
