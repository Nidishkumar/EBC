 package lib_arbiter_pkg;
  
   // Define constants
   parameter NO_levels = 3;
   parameter ROWS1=8;
   parameter COLS1=8;
   parameter int ROWS[NO_levels] = '{ROWS1, 4 ,2};
   parameter int COLS[NO_levels] = '{COLS1, 4, 2};

   // Declare parameter arrays
   parameter int Lvl_ROWS[NO_levels]='{2, 2, 2};;
   parameter int Lvl_COLS[NO_levels]='{2, 2, 2};
   parameter int NUM_GROUP[NO_levels]='{16, 4, 1};
   parameter int Lvl_ADD[NO_levels]='{1, 1,1};

   parameter ROW_ADD=Lvl_ADD[0]+Lvl_ADD[1]+Lvl_ADD[2];
   parameter COL_ADD=Lvl_ADD[0]+Lvl_ADD[1]+Lvl_ADD[2];
   parameter int SIZE = 32;  // Width of the timestamp 
   parameter int POLARITY = 2;
   parameter int WIDTH = SIZE + ROW_ADD + COL_ADD + 1;
endpackage
//  package lib_arbiter_pkg;
  
//    // Define constants
//    parameter NO_levels = 1;
//    parameter ROWS=8;
//    parameter COLS=8;
//    //parameter int ROWS[NO_levels] = ROWS1;
//    //parameter int COLS[NO_levels] = COLS1;

//   //  // Declare parameter arrays
//   //  parameter int BASE_ROWS[NO_levels] = '{2, 2, 2, 2,2};
//   //  parameter int BASE_COLS[NO_levels] = '{2, 2, 2, 2, 2};
  
//    parameter int Lvl_ROWS=ROWS;
//    parameter int Lvl_COLS=ROWS;
//    parameter int NUM_GROUP=1;
//    parameter int Lvl_ADD=3;

//    parameter ROW_ADD=Lvl_ADD;
//    parameter COL_ADD=Lvl_ADD;
//    parameter int SIZE = 32;  // Width of the timestamp 
//    parameter int POLARITY = 2;
//    parameter int WIDTH = SIZE + ROW_ADD + COL_ADD + 1;
//  endpackage
//package lib_arbiter_pkg;
//  
//  // Define constants
//  parameter NO_levels = 3;
//  parameter ROWS1 = 16;
//  parameter COLS1 = 16;
//  parameter int Lvl_GROUP_SIZE[NO_levels] = '{2, 2, 4};
//  static int ROWS[NO_levels] = '{default: 0};
//  static int COLS[NO_levels] = '{default: 0};
//
//  // Declare parameter arrays
//  static int Lvl_ROWS[NO_levels] = '{default: 0};
//  static int Lvl_COLS[NO_levels] = '{default: 0}; 
//  static int NUM_GROUP[NO_levels] = '{default: 0};
//  static int Lvl_ADD[NO_levels] = '{default: 0};
//
//  // Outputs to be used outside the function
//  static int ROW_ADD = 0;
//  static int COL_ADD = 0;
//
//  // parameter int total_row_add = 0;
//  // parameter int total_col_add = 0;
//
//  
//function void calculate_address_width();
// static int total_col_add=0;
// static int total_row_add=0;
//    // Calculate the Lvl_ADD and other necessary variables for each level
//    for (int i = 0; i < NO_levels; i++) 
//    begin
//      if (i == 0)
//      begin
//        ROWS[i] = ROWS1;
//        COLS[i] = COLS1;
//      end
//      else
//      begin
//        ROWS[i] = ROWS[i-1] / Lvl_GROUP_SIZE[i-1];
//        COLS[i] = COLS[i-1] / Lvl_GROUP_SIZE[i-1];
//      end
//
//      Lvl_ROWS[i] = Lvl_GROUP_SIZE[i];
//      Lvl_COLS[i] = Lvl_GROUP_SIZE[i];
//      NUM_GROUP[i] = ((ROWS[i] / Lvl_GROUP_SIZE[i]) * (COLS[i] / Lvl_GROUP_SIZE[i]));
//
//
//      // Calculate address width for each level
//      Lvl_ADD[i] = $clog2(Lvl_GROUP_SIZE[i]);
//
//      total_col_add = total_col_add + Lvl_ADD[i];
//      total_row_add = total_row_add + Lvl_ADD[i];
//    end
//
//    // Assign the final address widths to the output arguments
//    ROW_ADD = total_row_add;
//    COL_ADD = total_col_add;
//  endfunction
//
//  // Other parameters for timestamp and data width
//  parameter int SIZE = 32;  // Width of the timestamp 
//  parameter int POLARITY = 2;
//  static int WIDTH = SIZE + ROW_ADD + COL_ADD + 1;
//
//endpackage
