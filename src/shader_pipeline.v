module shader_pipeline (
   input       clk,  
);
   
   // Program Counter
   reg [3:0] pc;

   // Instruction Fields
   wire [1:0] op;    // ALU operation
   wire [3:0] mask;  // Lane mask
   wire [2:0] dest;  // Destination register
   wire [2:0] srcA;  // Source A register
   wire [2:0] srcB;  // Source B register

   // Register File Connections
   wire [31:0] vec_a, vec_b;
   wire [31:0] result;

   reg write_enable;
   reg [31:0] result_reg;

   // === Instruction Memory === 

   shader_program prog (
      .clk(clk),
      .rst(rst),
      .pc(pc),
      .op(op),
      .mask(mask),
      .dest(dest),
      .srcA(srcA),
      .srcB(srcB)    
   );

   // === Vector Register File ===
   vector_register_file regfile (
      .clk(clk),
      .rst(rst),
      .write_enable(write_enable),
      .addr_a(srcA),
      .addr_b(srcB),
      .write_addr(dest),
      .write_data(result_reg),
      .vec_a(vec_a),
      .vec_b(vec_b)
   );

   // === SIMD ALU ===
   simd_alu alu (
      .vec_a(vec_a),
      .vec_b(vec_b),
      .mask(mask),
      .op(op),
      .result(result)
   );

   // === Execution Loop ===
   always @(posedge clk) begin
      if (rst) begin
         pc <= 0;
         write_enable <= 0;
      end else begin
         // Simulate writeback stage 1 cycle later
         result_reg <= result;
         write_enable <= 1;

         // Move to next instruction
         pc <= pc + 1;
      end
   end

endmodule
