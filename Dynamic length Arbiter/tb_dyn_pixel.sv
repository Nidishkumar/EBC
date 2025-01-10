// Module name: tb Module
// Module Description: Generating random inputs for dynamic pixel widths
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------

import arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

 module tb_top_arb;
  // Inputs
  logic clk_i                                   ; // Clock input
  logic reset_i                                 ; // Active high Reset input
  logic enable_i                                ; // Enable signal to trigger arbitration
  logic [COLS-1:0][POLARITY-1:0] req_i[ROWS-1:0]; // Request signals for each row and column, with POLARITY bits determining the signal's polarity or behavior
  // Outputs
  logic [ROWS-1:0][COLS-1:0] gnt_o              ; //grant output
  logic [WIDTH-1:0] data_out_o                  ; //event data

  // Instantiate the Top Module
  top_arb   dut (
            .clk_i          (clk_i)         ,     // Clock input
            .reset_i        (reset_i)       ,     // Active high Reset input
            .req_i          (req_i)         ,     // Request signals for each row and column, with POLARITY bits determining the signal's polarity 
            .enable_i       (enable_i)      ,     // Enable signal to trigger arbitration
            .gnt_o          (gnt_o)         ,     // grant outputs
            .data_out_o     (data_out_o)          // current event information 
  );



 //-------------------------------------------Clock generation-----------------------------------------------//
  // Clock Generation
  initial begin
                clk_i = 0       ;
    forever #5  clk_i = ~clk_i  ; //  clock period
  end
//--------------------------------------------End of Clock generation----------------------------------------//
  

//-------------------------------------------Deasserting request---------------------------------------------//
// Deassert the request when the corresponding grant is active
 always_ff @(posedge clk_i)
 begin
  for (int i = 0; i < ROWS; i++) begin
    for (int j = 0; j < COLS; j++) 
     begin
      if (gnt_o[i][j] == 1'b1) 
       begin
          req_i[i][j] <= 1'b0;     // Deassert request upon grant
       end
     end
  end
end 
//------------------------------------------End of deasserting request-----------------------------------------//

//-------------------------------------------initializing inputs---------------------------------------------//
//Initialzing inputs
task initialize;
 begin
  enable_i=0;
  reset_i=0;
for(int i=0;i<ROWS;i++)
   begin
	 for(int j=0;j<=COLS;j++)
	  begin
		   req_i[i][j]=0;
	  end
	end end
endtask
//-------------------------------------------End of initializing inputs---------------------------------------------//

  
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

  
//-------------------------------------------Apply enable---------------------------------------------------------//
// Task to apply enable as hign 
 task apply_enable;
 begin
 enable_i=1;
 #10;
 end
 endtask
 //-------------------------------------------End of apply enable---------------------------------------------------------//

 
 //-------------------------------------------Disable enable---------------------------------------------------------//
 task disable_enable;
 begin
 enable_i=0;
 end
 endtask
 //-------------------------------------------End of Disable enable---------------------------------------------------------//

 
//-------------------------------------------Apply Random Requests---------------------------------------------------------//
//Task for random requests 
 task apply_requests;
 begin
  for(int i=0;i<ROWS;i++)
   begin
   for(int j=0;j<COLS;j++)
	 begin
	  req_i[i][j]=$urandom % 3;
	 end
	end
end
endtask
//-------------------------------------------End of Random Requests---------------------------------------------------------//

//-------------------------------------------Apply Various Test Cases---------------------------------------------------------//
initial
begin
initialize;           //initializing inputs
#10;
apply_reset;          //apply reset
#10;
apply_enable;         //apply enable as high
apply_requests;       //applying random requests for dynamic pixel sizes
#100;
disable_enable;       //Disable enable
#20;
apply_enable;         //apply enable as high
apply_requests;       //applying random requests for dynamic pixel sizes
#40;
apply_requests;       //applying random requests for dynamic pixel sizes
#100
$stop;                //stop simulation
end
//-------------------------------------------End of Various Test Cases---------------------------------------------------------//

endmodule