module vector_register_file (
   input   clk,
   input   rst,
   input   write_enable,
   input  [2:0] addr_a,
   input  [2:0] addr_b,
   input  [2:0] write_addr,
   input  [31:0] write_data,
   output [31:0] vec_a,
   output [31:0] vec_b
);

   //Declare the register file
   reg [31:0] reg_file [0:7]; // 8 registers, each 32 bits

   assign vec_a = reg_file[addr_a];
   assign vec_b = reg_file[addr_b];

   always @(posedge clk) begin
      if (rst) begin
         // Reset all registers to zero
         reg_file[0] <= 32'b0;
         reg_file[1] <= 32'b0;
         reg_file[2] <= 32'b0;
         reg_file[3] <= 32'b0;
         reg_file[4] <= 32'b0;
         reg_file[5] <= 32'b0;
         reg_file[6] <= 32'b0;
         reg_file[7] <= 32'b0;
      end
      else if (write_enable) begin
         // Write data to the specified register
         reg_file[write_addr] <= write_data;
      end
   end
endmodule