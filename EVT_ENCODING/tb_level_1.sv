// Module name: tb Module
// Module Description: Generating events for pixel hierarchy
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//-----------------------------------------------------------------------------------------------------------------

import lib_arbiter_pkg::*;                                     // Importing arbiter package containing parameter constants

 module tb_level_1;
 
  // Inputs
  logic clk_i                                                ; // Clock input
  logic reset_i                                              ; // Active high Reset input
  logic [ROWS-1:0][COLS-1:0][POLARITY-1:0]req_i              ; // Request signals for each row and column, with POLARITY bits 
  logic [ROWS-1:0][COLS-1:0] gnt_out_o                       ; //grant output
  logic grp_release_out_o                                    ; //Grouplease output
  logic [WIDTH-1:0] data_out_o                               ; //dataout of events
  
  top_pixel_hierarchy dut 
  (
            .clk_i             (clk_i)              ,               // Clock input
            .reset_i           (reset_i)            ,               // Active high Reset input
            .req_i             (req_i)              ,               // Request signals for each row and column, with POLARITY bits determining the signal's polarity 
            .gnt_out_o         (gnt_out_o)          ,               // grant outputs
			      .grp_release_out_o (grp_release_out_o)  ,               //Grouplease output
            .data_out_o        (data_out_o)                         //dataout of events

  );

 //-------------------------------------------Clock generation-------------------------------------------------------//
  
  // Clock Generation
  initial 
  begin
    clk_i = 0                   ;
    forever #5  clk_i = ~clk_i  ; //  Clock Generation
  end
 //-------------------------------------------End of Clock generation------------------------------------------------//

 
//--------------------------------------------Initialzing inputs-----------------------------------------------------//

//Initialzing inputs
task initialize;
 begin
  reset_i=0;
for(int i=0;i<ROWS;i++)
   begin
	 for(int j=0;j<COLS;j++)
	  begin
		   req_i[i][j]=0;
	  end
	end 
	end
endtask
//--------------------------------------------End of initializing inputs---------------------------------------------//

  
//--------------------------------------------Deasserting requests------------------------------------------------------//

//De-asserting granted requests
always_ff@(posedge clk_i)
 begin
 for(int i=0;i<ROWS;i++)
   begin
	 for(int j=0;j<COLS;j++)
	  begin
	    if(gnt_out_o[i][j])
		   begin
		    req_i[i][j]<='0;
			end
	  end
	end 
end

//-------------------------------------------End of Deasserting request----------------------------------------------//


//-------------------------------------------Apply Reset---------------------------------------------------------//

// Task to apply requests 
 task apply_reset;
 begin
  reset_i=1;
  #10;
  reset_i=0;
  #10;
 end
 endtask
 //-------------------------------------------End of apply Reset---------------------------------------------------------//

 
//--------------------------------------------Apply Random Requests---------------------------------------------------------//

//Task for random requests 
 task apply_requests;
 begin
  for(int i=0;i<ROWS;i++)
   begin
   for(int j=0;j<COLS;j++)
	 begin
	  req_i[i][j]=$urandom %3;
	 end
	end
end
endtask
//--------------------------------------------End of Random Requests---------------------------------------------------------//


//--------------------------------------------Apply Various Test Cases---------------------------------------------------------//
initial
begin
initialize;           //initializing inputs
#10;
apply_reset;          //apply reset
#10;
apply_requests;       //applying random requests for dynamic pixel sizes
// #20;       
// apply_requests;       //applying random requests for dynamic pixel sizes
// #25;
// apply_requests;       //applying random requests for dynamic pixel sizes
// #100; 
// apply_requests;       //applying random requests for dynamic pixel sizes
// #35; 
// apply_requests;       //applying random requests for dynamic pixel sizes
// #55; 
// apply_requests;       //applying random requests for dynamic pixel sizes
// #80; 
// apply_requests;       //applying random requests for dynamic pixel sizes
// #10; 
// apply_requests;       //applying random requests for dynamic pixel sizes
#500; 
$stop;                //stop simulation
end
//--------------------------------------------End of Various Test Cases---------------------------------------------------------//

endmodule 