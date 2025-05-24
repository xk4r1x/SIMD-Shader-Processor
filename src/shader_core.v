// Author: Makari Green
// Description: Shader Core connecting vector register file to SIMD ALU

module shader_core (
    input         clk,
    input         rst,
    input         write_enable,
    input  [2:0]  addr_a,
    input  [2:0]  addr_b,
    input  [2:0]  write_addr,
    input  [31:0] write_data,
    input  [1:0]  op,
    input  [3:0]  mask,
    output [31:0] result
);

   wire [31:0] vec_a;
   wire [31:0] vec_b;

   // Instantiate the vector register file
   vector_register_file regfile (
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

   // Instantiate the SIMD ALU
   simd_alu alu (
       .vec_a(vec_a),
       .vec_b(vec_b),
       .mask(mask),
       .op(op),
       .result(result)
   );
endmodule
