// Module name: tb Module
// Module Description: Generating events for 16X16 pixel
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]

 module tb_level_1;
  // Inputs
  logic clk_i                                   ; // Clock input
  logic reset_i                                 ; // Active high Reset input
  logic [15:0][15:0][1:0]req_i;       // Request signals for each row and column, with POLARITY bits determining the signal's polarity or behavior
  // Outputs
 logic [3:0][3:0] gnt_o             ; //grant output

 logic grp_release_o;
	logic [40:0] data_out_o;
  
  top_module
  dut (
            .clk_i        (clk_i)         ,     // Clock input
            .reset_i      (reset_i)       ,     // Active high Reset input
            .set_i        (req_i)         ,     // Request signals for each row and column, with POLARITY bits determining the signal's polarity 
            .gnt_o          (gnt_o)         ,     // grant outputs
				.grp_release_o(grp_release_o),
        .data_out_o(data_out_o)

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
	  req_i[i][j]=$urandom %3;
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
