// =============================================
// INSTRUCTION FORMAT (32-bit):
// ---------------------------------------------
// [31:30]  op        → 2 bits (00=ADD, 01=MUL, 10=AND, 11=OR)
// [29:26]  mask      → 4 bits (1 bit per SIMD lane)
// [25:23]  dest_reg  → 3 bits (register to write result)
// [22:20]  srcA_reg  → 3 bits
// [19:17]  srcB_reg  → 3 bits
// [16:0]   unused/reserved
// =============================================

module shader_program (
    input        clk,
    input        rst,
    input  [3:0] pc,        // Program counter (can access up to 16 instructions)
    output reg [1:0] op,    // ALU operation
    output reg [3:0] mask,  // Lane mask
    output reg [2:0] dest,  // Destination register
    output reg [2:0] srcA,  // Source A register
    output reg [2:0] srcB   // Source B register
);


   // Instruction ROM (16 deep, 32-bit wide)
   reg [31:0] instruction_rom [0:15];

   //  ROM Initialization (example instructions)
   initial begin
      // ADD r1, r2 -> r0
      rom[0] = 32'b00_1111_000_001_010_00000000000000000; 

      // MUL r0, r3 -> r1
      rom[1] = 32'b01_1111_001_000_011_00000000000000000;

      // AND r3, r1 -> r2
      rom[2] = 32'b10_1100_010_011_001_00000000000000000;

      // OR r2, r0 -> r3
      rom[3] = 32'b11_0101_011_010_000_00000000000000000;

      //NOP (can be treated as all zeros)
      rom[4] = 32'b0;

      // Remaining slots empty (NOPs)
      rom[5] = 32'b0;
      rom[6] = 32'b0;
      rom[7] = 32'b0;
      rom[8] = 32'b0;
      rom[9] = 32'b0;
      rom[10] = 32'b0;
      rom[11] = 32'b0;
      rom[12] = 32'b0;
      rom[13] = 32'b0;
      rom[14] = 32'b0;
      rom[15] = 32'b0;
   end

   // Decode on positive clock edge
   always @(posedge clk) begin
      if (rst) begin
         op <= 2'b00;
         mask <= 4'b0000;
         dest <= 3'b000;
         srcA <= 3'b000;
         srcB <= 3'b000;
      end else begin
         // Fetch instruction from ROM
         op <= rom[pc][31:30]; // ALU operation
         mask <= rom[pc][29:26]; // Lane mask
         dest <= rom[pc][25:23]; // Destination registers
         srcA <= rom[pc][22:20]; // Source A register
         srcB <= rom[pc][19:17]; // Source B register
      end
   end
endmodule
// End of shader_program
// This module implements a simple shader program that fetches instructions from a ROM
// and decodes them into ALU operations, lane masks, and source/destination registers.

