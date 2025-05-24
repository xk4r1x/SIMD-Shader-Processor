// Author: Makari Green
// Description: 4-lane SIMD ALU supporting ADD, MUL, AND, OR

module simd_alu (
   input  [31:0] vec_a,
   input  [31:0] vec_b,
   input  [3:0]  mask,
   input  [1:0]  op,     // 00=ADD, 01=MUL, 10=AND, 11=OR
   output [31:0] result
);

   // Slice inputs into 4 individual 8-bit lanes

   wire [7:0] a0 = vec_a[7:0];    // LSB
   wire [7:0] a1 = vec_a[15:8];   
   wire [7:0] a2 = vec_a[23:16];  
   wire [7:0] a3 = vec_a[31:24];  // MSB

   wire [7:0] b0 = vec_b[7:0];    // LSB
   wire [7:0] b1 = vec_b[15:8];   
   wire [7:0] b2 = vec_b[23:16];  
   wire [7:0] b3 = vec_b[31:24];  // MSB

   // Function: Selects operation based on 2-bit opcode
   // Operates on a single lane (a, b)

   function [7:0] alu_lane;
      input [7:0] a, b;
      input [1:0] op;
      begin
         case(op)
            2'b00: alu_lane = a + b;
            2'b01: alu_lane = a * b;
            2'b10: alu_lane = a & b;
            2'b11: alu_lane = a | b;
         endcase
      end
   endfunction

   // Apply operation to each lane

   wire [7:0] r0 = (mask[0]) ? alu_lane(a0, b0, op) : 8'b0;
   wire [7:0] r1 = (mask[1]) ? alu_lane(a1, b1, op) : 8'b0;
   wire [7:0] r2 = (mask[2]) ? alu_lane(a2, b2, op) : 8'b0;
   wire [7:0] r3 = (mask[3]) ? alu_lane(a3, b3, op) : 8b0;
   


   // Concatenate all results into result

   assign result = {r3, r2, r1, r0};

endmodule