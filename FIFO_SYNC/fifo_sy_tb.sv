import syn_fifo_pkg::*;

module fifo_sy_tb;
    logic clk_i;
    logic rst_n_i;
    logic cs_i;
    logic wr_en_i;
    logic rd_en_i;
    logic [WIDTH-1:0] data_in_i;
    logic [WIDTH-1:0] data_out_o;
    logic empty_o;
    logic full_o;
    
    integer i;
    
    // Instantiate FIFO
    fifo_sy uut (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .cs_i(cs_i),
        .wr_en_i(wr_en_i),
        .rd_en_i(rd_en_i),
        .data_in_i(data_in_i),
        .data_out_o(data_out_o),
        .empty_o(empty_o),
        .full_o(full_o)
    );

    // Clock generation
    always #5 clk_i = ~clk_i;
    
    // Task to write data into FIFO
    task write_data(input [WIDTH-1:0] d_in);
        begin
            @(posedge clk_i);
            cs_i = 1;
            wr_en_i = 1;
            data_in_i = d_in;
            $display($time, " write_data: data_in = %0d", data_in_i);
            @(posedge clk_i);
            cs_i = 1;
            wr_en_i = 0;
        end
    endtask
    
    // Task to read data from FIFO
    task read_data();
        begin
            @(posedge clk_i);
            cs_i = 1;
            rd_en_i = 1;
            @(posedge clk_i);
            $display($time, " read_data: data_out = %0d", data_out_o);
            cs_i = 1;
            rd_en_i = 0;
        end
    endtask

    // Testbench execution
    initial begin
        // Initialize signals
        clk_i = 0;
        rst_n_i = 0;
        wr_en_i = 0;
        rd_en_i = 0;
        data_in_i = 0;
        cs_i = 0;
        
        @(posedge clk_i);
        rst_n_i = 1;

        // SCENARIO 1: Basic Write and Read
        $display($time, "\n SCENARIO 1: Basic Write and Read");
        write_data(1);
        write_data(10);
        write_data(100);
        read_data();
        read_data();
        read_data();

        // SCENARIO 2: Write and Read with DEPTH iterations
        $display($time, "\n SCENARIO 2: Write and Read with DEPTH iterations");
        for (i = 0; i < DEPTH; i = i + 1) begin
            write_data(2**i);
            read_data();
        end

        // SCENARIO 3: Fill FIFO then Read all
        $display($time, "\n SCENARIO 3: Fill FIFO then Read all");
        for (i = 0; i < DEPTH; i = i + 1) begin
            write_data(2**i);
        end
        for (i = 0; i < DEPTH; i = i + 1) begin
            read_data();
        end
        
        #40 $finish;
    end

endmodule
