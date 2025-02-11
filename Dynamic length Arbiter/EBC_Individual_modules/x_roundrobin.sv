// Module name: Row Arbiter Module
// Module Description: This module provides grants to active row requests for the pixel block
// Author: [Your Name]
// Date: [Current Date]
// Version: [Version Number]
//------------------------------------------------------------------------------------------------------------------
module x_roundrobin #(parameter WIDTH=8, x_width=3)
 (
    input  logic clk_i                 ,       // Clock input
    input  logic reset_i               ,       // Active high Reset input
    input  logic enable_i              ,       // Enable signal to control Row arbiter
    input  logic [WIDTH-1:0] req_i     ,       // Request inputs
    output logic [WIDTH-1:0] x_gnt_o     ,       // Grant outputs
    output logic [x_width-1:0] xadd_o          // Encoded output representing the granted row index
 );

    // Internal signals for mask and grant handling
    logic [WIDTH-1:0] mask_ff ;                // Current mask (the active request set)
    logic [WIDTH-1:0] nxt_mask;                // Next mask value after evaluating grants
    logic [WIDTH-1:0] mask_req;                // Masked requests (and of req_i and mask_ff)
    logic [WIDTH-1:0] mask_gnt;                // Masked grants (output from masked priority arbiter)
    logic [WIDTH-1:0] raw_gnt ;                // Raw grants (output from raw priority arbiter)
    logic [WIDTH-1:0] gnt_temp;                // Temporary grant value before updating the output
	 logic [x_width-1:0] x_add  ;

    // Masking the input request signals (req_i) using the current mask (mask_ff) to filter active requests
    assign mask_req = req_i & mask_ff;
	 //logic [x_width-1:0] xadd_o;

	 
    // Update mask and grant signals on the clock edge
    always_ff @(posedge clk_i or posedge reset_i) 
	  begin
        if (reset_i) 
		 begin
            mask_ff <= {WIDTH{1'b1}};          // Reset mask to all ones (allow all requests)
            x_gnt_o   <= {WIDTH{1'b0}}; 				// Reset grant output to zero (no grants)
			//xadd_o    <={x_width{1'b0}}; 
				
         end 
		else if (enable_i) 
		 begin
            mask_ff <= nxt_mask;              // Update mask based on next mask calculation
            x_gnt_o  <= gnt_temp; 				// Register the grant output
			//xadd_o    <=x_add;
         end
      end
	 

    // Determine the final grant output: either masked grants or raw grants depending on the mask
    assign gnt_temp = (|mask_req ? mask_gnt : raw_gnt); 

        assign nxt_mask= ~((gnt_temp << 1)-({{(WIDTH-1){1'b0}}, 1'b1})); 
		 
	  
    // Compute xadd_o based on the current grants
//    always_comb 
//     begin
//       // x_add = {x_width{1'b0}};              // Initialize xadd_o to 0
//        for (int i = 0; i < WIDTH ; i = i + 1) 
//		 begin
//            if (gnt_temp[i])
//			 begin
//                x_add = i[x_width-1:0];       // Assign the index of the granted bit to xadd_o
//             end
//         end
//     end
//    always_ff @(posedge clk_i or posedge reset_i) begin
//    if (reset_i) 
//	 begin
//        xadd_o <= '0;  // Reset addr to 0
//    end 
//	 else 
//	 begin
//        for (int i = 0; i < WIDTH; i = i + 1) 
//		  begin
//            if (x_gnt_o[i]) 
//				begin
//                xadd_o <= x_add; // Assign tracked value instead of `i`
//            end
//                x_add <= x_add + 1'b1; // Increment separately
//        end
//    end
//end

//function automatic logic [x_width-1:0] address(input logic [WIDTH-1:0] data);
//    for (int i = 0; i < WIDTH; i++) 
//        if (data[i]) 
//			return i[x_width-1:0];  			// return x_width'(i);  
//		else			
//    		return '0; 							// Default if no bit is set
//endfunction
//always_ff@(posedge clk_i or posedge reset_i) 
//begin
//	if(reset_i)
//		xadd_o <= '0;
//	else 
//	begin
//	if (gnt_temp != 0)
//		xadd_o <= address(gnt_temp) ;
//	else 
//		xadd_o<= '0;
//	end
//end
function logic [x_width-1:0] address (input logic [WIDTH-1:0] data);
  for(int i=0 ;i<WIDTH ;i++)
   begin
    if(data[i])
     begin
	   return i[x_width-1:0];
	 end
	 end
	  return '0;
	  
endfunction


always_comb//@(posedge clk_i or posedge reset_i)
begin

 if (x_gnt_o !=0)
begin
  xadd_o =address(x_gnt_o);
end
 else
  xadd_o ='0;
 end


    // Priority arbiter for masked requests (gives grants based on the masked requests)
    Priority_arb  maskedGnt 
    (
        .req_i  (mask_req)  ,                   // Input masked requests
        .gnt_o  (mask_gnt)                      // Output masked grants
    );

    // Priority arbiter for raw requests (gives grants based on the original requests)
    Priority_arb  rawGnt 
    (
        .req_i  (req_i)     ,                   // Input raw requests
        .gnt_o  (raw_gnt)                       // Output raw grants
    );

endmodule