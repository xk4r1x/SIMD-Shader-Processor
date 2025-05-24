`timescale 1ns / 1ps

module vector_register_file_tb;

   // Inputs
   reg clk;
   reg rst;
   reg write_enable;
   reg [2:0] addr_a;
   reg [2:0] addr_b;
   reg [2:0] write_addr;
   reg [31:0] write_data;

   // Outputs
   wire [31:0] vec_a;
   wire [31:0] vec_b;

   // Instantiate the DUT
   vector_register_file dut (
      .clk(clk),
      .rst(rst),
      .write_enable(write_enable),
      .addr_a(addr_a),
      .addr_b(addr_b),
      .write_addr(write_addr),
      .write_data(write_data),
      .vec_a(vec_a),
      .vec_b(vec_b)
   );

   // Clock generation: 10ns period (100 MHz)
   always #5 clk = ~clk;

   initial begin
      $dumpfile("vector_register_file_tb.vcd");
      $dumpvars(0, vector_register_file_tb);

      $display("Time\taddr_a\tvec_a\taddr_b\tvec_b");

      // Init signals
      clk = 0;
      rst = 1;
      write_enable = 0;
      addr_a = 0;
      addr_b = 1;
      write_addr = 0;
      write_data = 0;

      // Step 1: Assert reset
      #10;
      rst = 0;

      // Step 2: Write 0xDEADBEEF to reg 3
      write_enable = 1;
      write_addr = 3;
      write_data = 32'hDEADBEEF;
      #10;

      // Step 3: Write 0xCAFEBABE to reg 5
      write_addr = 5;
      write_data = 32'hCAFEBABE;
      #10;

      // Step 4: Disable write, read back from addr_a = 3, addr_b = 5
      write_enable = 0;
      addr_a = 3;
      addr_b = 5;
      #10;
      $display("%0dns\t%0d\t%h\t%0d\t%h", $time, addr_a, vec_a, addr_b, vec_b);

      // Step 5: Change read addresses
      addr_a = 0;
      addr_b = 1;
      #10;
      $display("%0dns\t%0d\t%h\t%0d\t%h", $time, addr_a, vec_a, addr_b, vec_b);

      $finish;
   end

endmodule
// This testbench initializes the vector register file, performs writes to specific registers,
// and reads back values to verify correct functionality. It uses a clock with a 10ns period