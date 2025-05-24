`timescale  1ns/1ps

module shader_pipeline_tb (
      // Inputs
      input clk,
      input rst
      
      // Instanntiate the DUT 
      shader_pipeline dut (
         .clk(clk),
         .rst(rst)
      );

      // Clock generation: 10ns period (100 MHz)
      always #5 clk = ~clk;

      inital begin
         // Waveform dump for GTKWave
         $dumpfile("shader_pipeline_tb.vcd");
         $dumpvars(0, shader_pipeline_tb);

         // Start of simulation
         $display("Time\tInstruction Executing");

         //Initialize inputs
         clk = 0;
         rst = 1;
         #10; // Wait for 10 ns
         rst = 0; // Release reset

         // Run for a few instruction 
         repeat (10) begin
            #10; // Wait for 10 ns
               $display("%0dns\tPC = %d", $time, dut.pc);
               $display("Register[0] = %h", dut.regfile.reg_file[0]);
               $display("Register[1] = %h", dut.regfile.reg_file[1]);
               $display("Register[2] = %h", dut.regfile.reg_file[2]);
               $display("Register[3] = %h", dut.regfile.reg_file[3]);
         end
         $finish; // End simulation
      end        
);
   
endmodule