package lib_pixel_storage;
import lib_arbiter_pkg::*; // Importing package for constants

    logic [ROWS[1]-1:0][COLS[1]-1:0] req1_store; 
    logic [ROWS[1]-1:0][COLS[1]-1:0] grant_enb_store; 
    
    function  void store_req1(input int LEVEL, input logic [ROWS[1]-1:0][COLS[1]-1:0] data);
        req1_store = data;
    endfunction

    function  logic [ROWS[1]-1:0][COLS[1]-1:0] get_req1( input int LEVEL);
        return req1_store;
    endfunction

    function  void store_grant(input int LEVEL,input logic [ROWS[1]-1:0][COLS[1]-1:0] data);
        grant_enb_store = data;
    endfunction

    function  logic [ROWS[1]-1:0][COLS[1]-1:0] get_grant(input int LEVEL);
        return grant_enb_store;
    endfunction

 endpackage
// package lib_pixel_storage;
//     import lib_arbiter_pkg::*; // Importing ROWS, COLS definitions

//     // Declare ROWS and COLS as parameters or constants if needed
//     parameter int ROW_SIZE = ROWS[1];
//     parameter int COL_SIZE = COLS[1];

//     logic [ROW_SIZE-1:0][COL_SIZE-1:0] req1_store;
//     logic [ROW_SIZE-1:0][COL_SIZE-1:0] grant_enb_store;

//     function void store_req1(input int LEVEL, input logic [ROW_SIZE-1:0][COL_SIZE-1:0] data);
//         req1_store = data;
//     endfunction

//     function logic [ROW_SIZE-1:0][COL_SIZE-1:0] get_req1(input int LEVEL);
//         return req1_store;
//     endfunction

//     function void store_grant(input int LEVEL, input logic [ROW_SIZE-1:0][COL_SIZE-1:0] data);
//         grant_enb_store = data;
//     endfunction

//     function logic [ROW_SIZE-1:0][COL_SIZE-1:0] get_grant(input int LEVEL);
//         return grant_enb_store;
//     endfunction
// endpackage
