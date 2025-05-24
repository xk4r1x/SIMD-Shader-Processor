`timescale 1ns / 1ps

module simd_alu_tb;

   // Declare testbench signals (inputs and output)

   reg  [31:0]  vec_a;
   reg  [31:0]  vec_b;
   reg  [1:0]   op;
   reg  [3:0]   mask;
   wire [31:0] result;


   // Instantiate the DUT (Device Under Test)

   simd_alu dut(
      .vec_a(vec_a),
      .vec_b(vec_b),
      .op(op),
      .mask(mask),
      .result(result)
   );

   initial begin

   // Open Waveform dump

      $dumpfile("simd_alu_tb.vcd");
      $dumpvars(0, simd_alu_tb);

      // Display header

      $display("Time\top\tvec_a\t\tvec_b\t\tresult");

      // Test Case 1: ADD
      
      vec_a = 32'h01020304; // a = [04, 03, 02, 01]
      vec_b = 32'h05060708;  // b = [08, 07, 06, 05]
      op = 2'b00;
      mask = 4'b1111;
      #10;  // wait 10 ns
      $display("%0dns\t%b\t%h\t%h\t%h", $time, op, vec_a, vec_b, result);

      // Test Case 2: MUL

      op = 2'b01;
      mask = 4'b0101;
      #10; 
      $display("%0dns\t%b\t%h\t%h\t%h", $time, op, vec_a, vec_b, result);

      // Test Case 3: AND

      vec_a = 32'h0C0B0A09; // a: [12, 11, 10, 9]
      vec_b = 32'h00010002; // b = [00, 01, 00, 02]
      op = 2'b10;
      mask = 4'b1010;
      #10;
      $display("%0dns\t%b\t%h\t%h\t%h", $time, op, vec_a, vec_b, result);

      // Test Case 4: OR

      vec_a = 32'h01010101;  // Lanes: [1, 1, 1, 1]
      vec_b = 32'h00010002; // b = [00, 01, 00, 02]
      op = 2'b11;
      mask = 4'b0100;
      #10;
      $display("%0dns\t%b\t%h\t%h\t%h", $time, op, vec_a, vec_b, result);

      // End Simulation

      $finish;

   end

endmodule