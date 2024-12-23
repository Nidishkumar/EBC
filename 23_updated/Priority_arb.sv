//--------------------------- End of RoundRobin ---------------------------

module Priority_arb #(
  parameter NUM_PORTS = 4        // Number of ports
)(
  input wire [NUM_PORTS-1:0] req_i,  // Request inputs
  output wire [NUM_PORTS-1:0] gnt_o  // One-hot grant signal
);

  // Port[0] has highest priority
  assign gnt_o[0] = req_i[0];       // Grant[0] if request[0] is active

  genvar i;
  generate
    for (i = 1; i < NUM_PORTS; i = i + 1) begin : loop
      assign gnt_o[i] = req_i[i] & ~(|gnt_o[i-1:0]); // Grant[i] if no higher grant is active
    end
  endgenerate

endmodule