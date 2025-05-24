module vector_register_file (
   input        clk,
   input        rst,
   input        write_enable,
   input  [2:0] addr_a,
   input  [2:0] addr_b,
   input  [2:0] write_addr,
   input  [31:0] write_data,
   output [31:0] vec_a,
   output [31:0] vec_b
);

   // Declare 8 general-purpose 32-bit registers
   reg [31:0] reg_file [0:7];

   // Output assignments
   assign vec_a = reg_file[addr_a];
   assign vec_b = reg_file[addr_b];

   // Optional preload values for simulation
   initial begin
      reg_file[0] = 32'h00000000;
      reg_file[1] = 32'h01020304;  // Lane A source 1
      reg_file[2] = 32'h05060708;  // Lane B source 1
      reg_file[3] = 32'h0C0B0A09;  // Lane A source 2
      reg_file[4] = 32'h00010002;  // Lane B source 2
      reg_file[5] = 32'hFFFFFFFF;
      reg_file[6] = 32'h00000000;
      reg_file[7] = 32'hA5A5A5A5;
   end

   // Synchronous write and reset behavior
   always @(posedge clk) begin
      if (rst) begin
         reg_file[0] <= 32'b0;
         reg_file[1] <= 32'b0;
         reg_file[2] <= 32'b0;
         reg_file[3] <= 32'b0;
         reg_file[4] <= 32'b0;
         reg_file[5] <= 32'b0;
         reg_file[6] <= 32'b0;
         reg_file[7] <= 32'b0;
      end else if (write_enable) begin
         reg_file[write_addr] <= write_data;
      end
   end

endmodule
