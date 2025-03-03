
import syn_fifo_pkg::*;

module fifo_sy (
    input  logic                    clk_i,    // Clock signal
    input  logic                    rst_n_i,  // Active-low reset
    input  logic                    cs_i,     // Chip select
    input  logic                    wr_en_i,  // Write enable
    input  logic                    rd_en_i,  // Read enable
    input  logic [WIDTH-1:0]        data_in_i,  // Data input
    output logic [WIDTH-1:0]        data_out_o, // Data output
    output logic                    empty_o,    // FIFO empty flag
    output logic                    full_o      // FIFO full flag
);

// Local parameters
localparam int depth_log = $clog2(DEPTH); // Log2 of FIFO depth

// FIFO storage
logic [WIDTH-1:0] fifo [0:DEPTH-1];

// Read and Write Pointers
logic [depth_log:0] wr_ptr;
logic [depth_log:0] rd_ptr;

// Write Operation
always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        wr_ptr <= 0;
    end
    else if (cs_i && wr_en_i && !full_o) begin
        fifo[wr_ptr[depth_log-1:0]] <= data_in_i;
        wr_ptr <= wr_ptr + 1'b1;
    end
end

// Read Operation
always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        rd_ptr   <= 0;
        data_out_o <= '0; // Clear data output on reset
    end
    else if (cs_i && rd_en_i && !empty_o) begin
        data_out_o <= fifo[rd_ptr[depth_log-1:0]];
        rd_ptr <= rd_ptr + 1'b1;
    end
end

// Status Flags
assign empty_o = (rd_ptr == wr_ptr);  // FIFO is empty when read and write pointers match
assign full_o  = (rd_ptr == {~wr_ptr[depth_log], wr_ptr[depth_log-1:0]}); // Full when MSB of rd_ptr and wr_ptr differ

endmodule