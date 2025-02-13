//-----------------------------------------------------------------------------------------------------------------
// Module Name: Arbiter Package Module
// Module Description: This arbiter package module contains design parameter constants.
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------

package lib_func_pkg;
import lib_arbiter_pkg::*;                                      // Importing arbiter package containing parameter constants

 
function logic [Lvl_ADD-1:0] address(input logic [Lvl_ROWS-1:0] data);
      for(int i=0 ;i<Lvl_ROWS ;i++)
      begin
       if(data[i])
	      return i[Lvl_ADD-1:0];
	   end
	      return '0;
	  endfunction
	  
 function void get_data
	 ( 
	 input logic [Lvl_ROWS-1:0][Lvl_COLS-1:0] enable_i ,
	 input logic [NUM_GROUPS0-1:0][Lvl0_ROWS-1:0][Lvl0_COLS-1:0]gnt_temp, 
	 input logic [NUM_GROUPS0-1:0][Lvl0_ADD-1:0] x_add_temp,
	 input logic [NUM_GROUPS0-1:0][Lvl0_ADD-1:0] y_add_temp,
	 input logic [NUM_GROUPS0-1:0] grp_release_temp,
	 
	 output logic [Lvl0_ROWS-1:0][Lvl0_COLS-1:0]gnt_o,
	 output logic [Lvl0_ADD-1:0] x_add_o,
    output logic [Lvl0_ADD-1:0] y_add_o,
	 output logic grp_release_o

	 );
	 gnt_o='0;
	 x_add_o='0;
	 y_add_o='0;
	 grp_release_o='0;
      for (int groups = 0; groups < NUM_GROUPS0; groups++) 
		   begin
            if (enable_i[groups / CONST0][groups % CONST0])//if enable is high,we receive the active group arbitration data 
				 begin
                gnt_o = gnt_temp[groups];
                x_add_o = x_add_temp[groups];
                y_add_o = y_add_temp[groups];
                grp_release_o = grp_release_temp[groups];   
				 end
        end
	endfunction
	
endpackage


