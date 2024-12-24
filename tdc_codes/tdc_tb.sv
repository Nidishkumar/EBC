module tdc_tb #(parameter SIZE = 32);
  // Declare testbench variables
  logic clk_i;
  logic reset_i;
  logic load_i;
  logic event_i;
  logic [SIZE-1:0] lddata_i;
  logic [SIZE-1:0] timestamp_o;

  // Instantiate the TDC module
  tdc dut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .load_i(load_i),
    .event_i(event_i),
    .lddata_i(lddata_i),
    .timestamp_o(timestamp_o)
  );

  // Clock generation
  always #5 clk_i = ~clk_i; // 10ns clock period

  // Task for reset
  task apply_reset();
    begin
      reset_i = 1;         // Assert reset
      #10;                 // Wait for 10 time units
      reset_i = 0;         // Deassert reset
    end
  endtask

  // Task for loading data into the counter
  task load_counter(input [SIZE-1:0] load_value);
    begin
      load_i = 1;          // Assert load signal
      lddata_i = load_value; // Set the load value
      #15;                 // Wait for 15 time units
      load_i = 0;          // Deassert load signal
    end
  endtask

  // Task for triggering an event
  task trigger_event();
    begin
      event_i = 1;         // Assert event signal
              // Deassert event signal
    end
  endtask

  initial begin
    // Initialize signals
    clk_i = 0;
    load_i = 0;
    event_i = 0;
    reset_i = 0;
    lddata_i = 0;

    // Apply reset using task
    apply_reset();

    // Test Case 1: Load counter with a specific value
    load_counter(32'h0000_0005);

    // Test Case 2: Increment counter
    repeat (5) @(posedge clk_i);

    // Test Case 3: Capture timestamp on event
    trigger_event();

    // Test Case 4: Verify counter continues incrementing
    repeat (10) @(posedge clk_i);
    event_i = 0;
    repeat (3) @(posedge clk_i);

    // Test Case 5: Trigger another event
    trigger_event();

    // Test Case 6: Load counter with a different value
    load_counter(32'h0000_0003);

    // Test Case 7: Increment counter after loading
    repeat (5) @(posedge clk_i);

    // Apply reset again
    apply_reset();

    $stop;
  end
endmodule
