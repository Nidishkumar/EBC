
//-----------------------LVL - 1 ------------------------------------------------------------
module Group_LvL_1 #(
    parameter int DIMS = 16,
    parameter int SIZE = DIMS * DIMS
) (
    input  clk,
    input  rst_n,
    input  [SIZE-1:0] set,
    output [SIZE-1:0] Pout
);

    logic [15:0] Grp_release;
    logic [15:0] req;
    logic [15:0] gnt_o;

    Group_LvL_0 grp0  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[0]), .set(set[15:0]),
                       .Pout(Pout[15:0]), .req(req[0]), .Grp_release(Grp_release[0]));

    Group_LvL_0 grp1  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[1]), .set(set[31:16]),
                        .Pout(Pout[31:16]), .req(req[1]), .Grp_release(Grp_release[1]));

    Group_LvL_0 grp2  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[2]), .set(set[47:32]),
                        .Pout(Pout[47:32]), .req(req[2]), .Grp_release(Grp_release[2]));

    Group_LvL_0 grp3  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[3]), .set(set[63:48]),
                        .Pout(Pout[63:48]), .req(req[3]), .Grp_release(Grp_release[3]));

    Group_LvL_0 grp4  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[4]), .set(set[79:64]),
                        .Pout(Pout[79:64]), .req(req[4]), .Grp_release(Grp_release[4]));

    Group_LvL_0 grp5  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[5]), .set(set[95:80]),
                        .Pout(Pout[95:80]), .req(req[5]), .Grp_release(Grp_release[5]));

    Group_LvL_0 grp6  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[6]), .set(set[111:96]),
                        .Pout(Pout[111:96]), .req(req[6]), .Grp_release(Grp_release[6]));

    Group_LvL_0 grp7  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[7]), .set(set[127:112]),
                        .Pout(Pout[127:112]), .req(req[7]), .Grp_release(Grp_release[7]));

    Group_LvL_0 grp8  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[8]), .set(set[143:128]),
                        .Pout(Pout[143:128]), .req(req[8]), .Grp_release(Grp_release[8]));

    Group_LvL_0 grp9  (.clk(clk), .rst_n(rst_n), .enable(gnt_o[9]), .set(set[159:144]),
                        .Pout(Pout[159:144]), .req(req[9]), .Grp_release(Grp_release[9]));

    Group_LvL_0 grp10 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[10]), .set(set[175:160]),
                        .Pout(Pout[175:160]), .req(req[10]), .Grp_release(Grp_release[10]));

    Group_LvL_0 grp11 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[11]), .set(set[191:176]),
                        .Pout(Pout[191:176]), .req(req[11]), .Grp_release(Grp_release[11]));

    Group_LvL_0 grp12 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[12]), .set(set[207:192]),
                        .Pout(Pout[207:192]), .req(req[12]), .Grp_release(Grp_release[12]));

    Group_LvL_0 grp13 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[13]), .set(set[223:208]),
                        .Pout(Pout[223:208]), .req(req[13]), .Grp_release(Grp_release[13]));

    Group_LvL_0 grp14 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[14]), .set(set[239:224]),
                        .Pout(Pout[239:224]), .req(req[14]), .Grp_release(Grp_release[14]));

    Group_LvL_0 grp15 (.clk(clk), .rst_n(rst_n), .enable(gnt_o[15]), .set(set[255:240]),
                    .Pout(Pout[255:240]), .req(req[15]), .Grp_release(Grp_release[15]));


    /* generate
        genvar i;
        for (i = 0; i < DIMS; i = i + 1) begin : grp_inst
            Group_LvL_0 grp[i] (
                .clk(clk),
                .rst_n(rst_n),
                .enable(gnt_o[i]),
                .set(set[(i+1)*16-1 -: 16]), // 16-bit segments for set
                .Pout(Pout[(i+1)*16-1 -: 16]), // 16-bit segments for Pout
                .req(req[i]),
                .Grp_release(Grp_release[i])
            );
        end
    endgenerate
*/
    logic Grp_release_clk;
    assign Grp_release_clk = |Grp_release;

    RoundRobin_lvl1 RR1 (
        .clk(Grp_release_clk),
        .reset(rst_n),
        .enable(enable),
        .req_i(req),
        .gnt_o(gnt_o),
        .Grp_release_lvl1()
    );

endmodule


//-----------------------End of LVL - 1 ------------------------------------------------------------


//-----------------------LVL - 0------------------------------------------------------------

module Group_LvL_0 #(
    parameter int DIMS = 4,
    parameter int SIZE = DIMS * DIMS
) (
    input clk,
    input rst_n,
    input enable,
    input  [SIZE-1:0] set,
    output [SIZE-1:0] Pout,
    output logic req,
    output Grp_release
);


    logic [15:0] gnt_o;
    logic [15:0] req_out;
    //logic req;

    Pixel_array PXL_ARR (
        .clk(clk),
        .rst_n(rst_n),
        .set(set),  //Load in pixel values
        .clear(gnt_o),
        .Pout(Pout),
        .req(req)
    );

    RoundRobin RR (
        .clk(clk),
        .reset(rst_n),
        .enable(enable),
        .req_i(Pout),
        .gnt_o(gnt_o),
        .Grp_release(Grp_release)
    );


endmodule

//-----------------------End of LVL - 1 ------------------------------------------------------------


//---------------------------Round Robin -----------------------------------------------------------

module RoundRobin (
  input clk,
  input reset,
  input enable,
  input [15:0] req_i,
  output logic [15:0] gnt_o,
  output logic Grp_release
);

  logic [15:0] mask_q;
  logic [15:0] nxt_mask;
  logic single_cycle_stop;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      mask_q <= 16'hFFFF;
    else begin
        if(enable)  //Stop, Start
            mask_q <= nxt_mask;
        else
            mask_q <= 16'hFFFF;
    end

    assign single_cycle_stop = (mask_q == '0)? 1 : 0;
    assign Grp_release = (nxt_mask > mask_q) ? 1 : 0;

  always_comb begin
    nxt_mask = mask_q;
         if (gnt_o[0]) nxt_mask  = 16'b1111_1111_1111_1110;
    else if (gnt_o[1]) nxt_mask  = 16'b1111_1111_1111_1100;
    else if (gnt_o[2]) nxt_mask  = 16'b1111_1111_1111_1000;
    else if (gnt_o[3]) nxt_mask  = 16'b1111_1111_1111_0000;
    else if (gnt_o[4]) nxt_mask  = 16'b1111_1111_1110_0000;
    else if (gnt_o[5]) nxt_mask  = 16'b1111_1111_1100_0000;
    else if (gnt_o[6]) nxt_mask  = 16'b1111_1111_1000_0000;
    else if (gnt_o[7]) nxt_mask  = 16'b1111_1111_0000_0000;
    else if (gnt_o[8]) nxt_mask  = 16'b1111_1110_0000_0000;
    else if (gnt_o[9]) nxt_mask  = 16'b1111_1100_0000_0000;
    else if (gnt_o[10]) nxt_mask = 16'b1111_1000_0000_0000;
    else if (gnt_o[11]) nxt_mask = 16'b1111_0000_0000_0000;
    else if (gnt_o[12]) nxt_mask = 16'b1110_0000_0000_0000;
    else if (gnt_o[13]) nxt_mask = 16'b1100_0000_0000_0000;
    else if (gnt_o[14]) nxt_mask = 16'b1000_0000_0000_0000;
    else if (gnt_o[15]) nxt_mask = 16'b0000_0000_0000_0000;
  end

  logic [15:0] mask_req;
  assign mask_req = req_i & mask_q;
  logic [15:0] mask_gnt;
  logic [15:0] raw_gnt;

  Priority_arb #(16) maskedGnt (.req_i (mask_req), .gnt_o (mask_gnt));
  Priority_arb #(16) rawGnt    (.req_i (req_i),    .gnt_o (raw_gnt));

  assign gnt_o = {16{enable}} & (|mask_req ? mask_gnt : raw_gnt);
endmodule

//---------------------------end of Round Robin -----------------------------------------------------------




module Priority_arb #(
  parameter NUM_PORTS = 4
)(
    input       wire[NUM_PORTS-1:0] req_i,
    output      wire[NUM_PORTS-1:0] gnt_o   // One-hot grant signal
);
  // Port[0] has highest priority
  assign gnt_o[0] = req_i[0];

 
  genvar i;
  generate
  for (i=1; i<NUM_PORTS; i=i+1) begin :loop
    assign gnt_o[i] = req_i[i] & ~(|gnt_o[i-1:0]);
  end
 endgenerate

endmodule

module Pixel_array #(
    parameter int DIMS = 4,
    parameter int SIZE = DIMS * DIMS
) (
    input clk,
    input rst_n,
    input  [SIZE-1:0] set,
    input  [SIZE-1:0] clear,
    output logic [SIZE-1:0] Pout,
    output req
);

    logic [SIZE-1:0] PXL;

    always_ff@(posedge clk, posedge rst_n) begin
        if(rst_n)
            PXL <= set;
        else if(|clear)
            PXL <= PXL & ~clear;
        else
            PXL <= PXL;
    end

    assign Pout = PXL;
    assign req = |PXL;
endmodule

module RoundRobin_lvl1(
  input clk,
  input reset,
  input enable,
  input [15:0] req_i,
  output logic [15:0] gnt_o,
  output logic Grp_release_lvl1
);

  logic [15:0] mask_q;
  logic [15:0] nxt_mask;
  logic single_cycle_stop;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      mask_q <= 16'hFFFF;
    else begin
        if(enable)  //Stop, Start
            mask_q <= nxt_mask;
        else
            mask_q <= 16'hFFFF;
    end

    assign single_cycle_stop = (mask_q == '0)? 1 : 0;
    assign Grp_release_lvl1 = (nxt_mask > mask_q) ? 1 : 0;

  always_comb begin
    nxt_mask = mask_q;
         if (gnt_o[0]) nxt_mask  = 16'b1111_1111_1111_1110;
    else if (gnt_o[1]) nxt_mask  = 16'b1111_1111_1111_1100;
    else if (gnt_o[2]) nxt_mask  = 16'b1111_1111_1111_1000;
    else if (gnt_o[3]) nxt_mask  = 16'b1111_1111_1111_0000;
    else if (gnt_o[4]) nxt_mask  = 16'b1111_1111_1110_0000;
    else if (gnt_o[5]) nxt_mask  = 16'b1111_1111_1100_0000;
    else if (gnt_o[6]) nxt_mask  = 16'b1111_1111_1000_0000;
    else if (gnt_o[7]) nxt_mask  = 16'b1111_1111_0000_0000;
    else if (gnt_o[8]) nxt_mask  = 16'b1111_1110_0000_0000;
    else if (gnt_o[9]) nxt_mask  = 16'b1111_1100_0000_0000;
    else if (gnt_o[10]) nxt_mask = 16'b1111_1000_0000_0000;
    else if (gnt_o[11]) nxt_mask = 16'b1111_0000_0000_0000;
    else if (gnt_o[12]) nxt_mask = 16'b1110_0000_0000_0000;
    else if (gnt_o[13]) nxt_mask = 16'b1100_0000_0000_0000;
    else if (gnt_o[14]) nxt_mask = 16'b1000_0000_0000_0000;
    else if (gnt_o[15]) nxt_mask = 16'b0000_0000_0000_0000;
  end

  logic [15:0] mask_req;
  assign mask_req = req_i & mask_q;
  logic [15:0] mask_gnt;
  logic [15:0] raw_gnt;

  Priority_arb #(16) maskedGnt (.req_i (mask_req), .gnt_o (mask_gnt));
  Priority_arb #(16) rawGnt    (.req_i (req_i),    .gnt_o (raw_gnt));

  assign gnt_o = {16{enable}} & (|mask_req ? mask_gnt : raw_gnt);
endmodule
