package lib_arbiter_pkg;
  
  // Define constants
  parameter NO_levels = 3;
  parameter ROWS1=8;
  parameter COLS1=8;
  parameter int ROWS[NO_levels] = '{ROWS1, 4, 2};
  parameter int COLS[NO_levels] = '{COLS1, 4, 2};

  // Declare parameter arrays
  parameter int BASE_ROWS[NO_levels] = '{2, 2, 2};
  parameter int BASE_COLS[NO_levels] = '{2, 2, 2};
  
  parameter int Lvl_ROWS[NO_levels]=BASE_ROWS;
  parameter int Lvl_COLS[NO_levels]=BASE_COLS;
  parameter int NUM_GROUP[NO_levels]='{16, 4, 1};
  parameter int Lvl_ADD[NO_levels]='{1, 1, 1};

  parameter ROW_ADD=Lvl_ADD[0]+Lvl_ADD[1]+Lvl_ADD[2];
  parameter COL_ADD=Lvl_ADD[0]+Lvl_ADD[1]+Lvl_ADD[2];

  // // Declare other parameters that will be updated by the function
  // parameter int Lvl_ROWS[NO_levels] ='{default: 0}; // Default values to 0
  // parameter   int Lvl_COLS[NO_levels] ='{default: 0};
  // parameter   int Lvl_GROUP_SIZE[NO_levels]='{default: 0};
  // parameter   int NUM_GROUPS[NO_levels]='{default: 0}; 
  // parameter   int Lvl_ADD[NO_levels] ='{default: 0};
  // // $warning("------------Loop Passed group=[%d],[%d],[%d]------------------",NUM_GROUPS[1],Lvl_ROWS[0],Lvl_COLS[0]); 
  // // $warning("------------Loop Passed group=[%d],[%d],[%d]------------------",NUM_GROUPS[0],Lvl_ROWS[0],Lvl_COLS[0]); 

  // // Outputs to be used outside the function
  // parameter int ROW_ADD='0;
  // parameter int COL_ADD='0;

  // parameter int total_row_add = 0;
  // parameter int total_col_add = 0;
	//  //parameter int ROWS_PRODUCT = 1;
  // //parameter int COLS_PRODUCT = 1;
  // // Function to calculate address width for each level
  // function automatic void calculate_address_width
  // (
  //   input  int BASE_ROWS[NO_levels-1:0], 
  //   input  int BASE_COLS[NO_levels-1:0],
  //   output int Lvl_ROWS[NO_levels-1:0], 
  //   output int Lvl_COLS[NO_levels-1:0], 
  //   output int Lvl_GROUP_SIZE[NO_levels-1:0], 
  //   output int NUM_GROUPS[NO_levels-1:0], 
	//  output int Lvl_ADD[NO_levels-1:0] ,
  //   output int ROW_ADD, 
  //   output int COL_ADD
	//  );
  //   int total_col_add = 0;
  //   int total_row_add = 0;


  //   // Calculate the Lvl_ADD and other necessary variables for each level
  //   for (int i = 0; i < NO_levels; i++) 
	//   begin
  //       Lvl_ROWS[i] = BASE_ROWS[i];
  //       Lvl_COLS[i] = BASE_COLS[i];
  //       Lvl_GROUP_SIZE[i] = Lvl_ROWS[i] ; 
 
  //       // Calculate the product of group sizes for the previous levels
  //      // for (int j = 0; j < i; j++) begin
  //           //ROWS_PRODUCT = ROWS_PRODUCT * Lvl_GROUP_SIZE[j];
  //           //COLS_PRODUCT = COLS_PRODUCT * Lvl_GROUP_SIZE[j];

  //       // Calculate NUM_GROUPS[i] based on the product of previous levels
  //       NUM_GROUPS[i] = ((ROWS[i] /  Lvl_GROUP_SIZE[i]) *  (COLS[i] / Lvl_GROUP_SIZE[i]));
  //       //end

  //       // Calculate address width for each level
  //       Lvl_ADD[i] = $clog2(Lvl_GROUP_SIZE[i]);

  //       // Accumulate the column and row address width
  //       total_col_add = total_col_add + Lvl_ADD[i];
  //       total_row_add = total_row_add + Lvl_ADD[i];
  //   end

  //   // Assign the final address widths to the output arguments
  //   ROW_ADD = total_row_add;
  //   COL_ADD = total_col_add;
  // endfunction



  // Other parameters for timestamp and data width
  parameter int SIZE = 32;  // Width of the timestamp 
  parameter int POLARITY = 2;
  parameter int WIDTH = SIZE + ROW_ADD + COL_ADD + 1;

endpackage