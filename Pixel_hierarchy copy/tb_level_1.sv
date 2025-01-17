// Module name: tb Module
// Module Description: Generating events for 16X16 pixel
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
//import arbiter_pkg::*;                             // Importing arbiter package containing parameter constants

 module tb_level_1;
  // Inputs
  logic clk_i                                   ; // Clock input
  logic reset_i                                 ; // Active high Reset input
  logic [15:0][15:0] req_i; // Request signals for each row and column, with POLARITY bits determining the signal's polarity or behavior
  // Outputs
 logic [3:0][3:0] gnt_o             ; //grant output
 logic [1:0] x_add ;      // Index for selected row in row arbitration logic
 logic [1:0] y_add ;
 
logic [3:0][3:0]in_gnt_o;
  logic [1:0]in_x_add;
   logic [1:0]in_y_add; 
  
  top_pixel_hier
  dut (
            .clk         (clk_i)         ,     // Clock input
            .rst_n        (reset_i)       ,     // Active high Reset input
            .set          (req_i)         ,     // Request signals for each row and column, with POLARITY bits determining the signal's polarity 
            .gnt_o          (gnt_o)         ,     // grant outputs
            .x_add     (x_add),
				.y_add(y_add) ,
				
				.in_gnt_o(in_gnt_o),
            .in_x_add(in_x_add),       // Index for selected row in row arbitration logic
            .in_y_add(in_y_add) 
  );

 //-------------------------------------------Clock generation-----------------------------------------------//
  // Clock Generation
  initial begin
                clk_i = 0       ;
    forever #5  clk_i = ~clk_i  ; //  clock period
  end


//-------------------------------------------Deasserting request---------------------------------------------//
//Initialzing inputs
task initialize;
 begin
  reset_i=0;
for(int i=0;i<16;i++)
   begin
	 for(int j=0;j<16;j++)
	  begin
		   req_i[i][j]=0;
	  end
	end 
	end
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

//-------------------------------------------Apply Random Requests---------------------------------------------------------//
//Task for random requests 
 task apply_requests;
 begin
  for(int i=0;i<16;i++)
   begin
   for(int j=0;j<16;j++)
	 begin
	  req_i[i][j]=$urandom %2;
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
;         //apply enable as high
apply_requests;       //applying random requests for dynamic pixel sizes
#200;       //Disable enabl
apply_requests;       //applying random requests for dynamic pixel sizes
#100;
apply_requests;       //applying random requests for dynamic pixel sizes
#100
$stop;                //stop simulation
end
//-------------------------------------------End of Various Test Cases---------------------------------------------------------//

endmodule