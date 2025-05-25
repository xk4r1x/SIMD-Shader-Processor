`timescale 1ns / 1ps

// =============================================
// TOP LEVEL MODULE: SIMD Shader Processor
// Author: Makari Green
// =============================================

module simd_shader_processor_top (
    input        clk,
    input        rst,
    output [3:0] current_pc,
    output [31:0] current_result,
    output [1:0] current_op,
    output [3:0] current_mask,
    output [31:0] reg0_value,
    output [31:0] reg1_value,
    output [31:0] reg2_value,
    output [31:0] reg3_value
);

    wire [1:0] op_wire;
    wire [3:0] mask_wire;
    wire [2:0] dest_wire, srcA_wire, srcB_wire;
    wire [31:0] vec_a, vec_b, result;

    reg [3:0] pc;
    reg [31:0] result_reg;
    reg write_enable_reg;
    reg [2:0] dest_reg;
    reg [1:0] op_reg;
    reg [3:0] mask_reg;
    reg [1:0] stage;

    shader_program prog (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .op(op_wire),
        .mask(mask_wire),
        .dest(dest_wire),
        .srcA(srcA_wire),
        .srcB(srcB_wire)
    );

    vector_register_file regfile (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable_reg && (stage == 2'd3)),
        .addr_a(srcA_wire),
        .addr_b(srcB_wire),
        .write_addr(dest_reg),
        .write_data(result_reg),
        .vec_a(vec_a),
        .vec_b(vec_b)
    );

    simd_alu alu (
        .vec_a(vec_a),
        .vec_b(vec_b),
        .mask(mask_wire),
        .op(op_wire),
        .result(result)
    );

    always @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            result_reg <= 0;
            write_enable_reg <= 0;
            dest_reg <= 0;
            op_reg <= 0;
            mask_reg <= 0;
            stage <= 0;
        end else begin
            case (stage)
                2'd0: stage <= 2'd1;
                2'd1: begin
                    op_reg <= op_wire;
                    mask_reg <= mask_wire;
                    dest_reg <= dest_wire;
                    stage <= 2'd2;
                end
                2'd2: begin
                    result_reg <= result;
                    write_enable_reg <= (dest_wire != 3'd0);
                    stage <= 2'd3;
                end
                2'd3: begin
                    write_enable_reg <= 0;
                    stage <= 2'd0;
                    pc <= (pc >= 4'd15) ? 4'd0 : pc + 1;
                end
            endcase
        end
    end

    assign current_pc = pc;
    assign current_result = result;
    assign current_op = op_wire;
    assign current_mask = mask_wire;
    assign reg0_value = regfile.reg_file[0];
    assign reg1_value = regfile.reg_file[1];
    assign reg2_value = regfile.reg_file[2];
    assign reg3_value = regfile.reg_file[3];

endmodule

module shader_program (
    input        clk,
    input        rst,
    input  [3:0] pc,
    output reg [1:0] op,
    output reg [3:0] mask,
    output reg [2:0] dest,
    output reg [2:0] srcA,
    output reg [2:0] srcB
);

    reg [31:0] instruction_rom [0:15];

    initial begin
        instruction_rom[0] = 32'b00_1111_000_001_010_00000000000000000;
        instruction_rom[1] = 32'b01_1111_001_000_011_00000000000000000;
        instruction_rom[2] = 32'b10_1100_010_011_001_00000000000000000;
        instruction_rom[3] = 32'b11_0101_011_010_000_00000000000000000;
        instruction_rom[4] = 32'b00_0010_100_000_001_00000000000000000;
        instruction_rom[5] = 32'b01_0111_101_100_010_00000000000000000;
        instruction_rom[6] = 0; instruction_rom[7] = 0;
        instruction_rom[8] = 0; instruction_rom[9] = 0;
        instruction_rom[10] = 0; instruction_rom[11] = 0;
        instruction_rom[12] = 0; instruction_rom[13] = 0;
        instruction_rom[14] = 0; instruction_rom[15] = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            op <= 0; mask <= 0; dest <= 0; srcA <= 0; srcB <= 0;
        end else begin
            op   <= instruction_rom[pc][31:30];
            mask <= instruction_rom[pc][29:26];
            dest <= instruction_rom[pc][25:23];
            srcA <= instruction_rom[pc][22:20];
            srcB <= instruction_rom[pc][19:17];
        end
    end
endmodule

module simd_alu (
    input  [31:0] vec_a,
    input  [31:0] vec_b,
    input  [3:0]  mask,
    input  [1:0]  op,
    output [31:0] result
);
    function [7:0] alu_lane;
        input [7:0] a, b;
        input [1:0] op;
        begin
            case (op)
                2'b00: alu_lane = a + b;
                2'b01: alu_lane = a * b;
                2'b10: alu_lane = a & b;
                2'b11: alu_lane = a | b;
            endcase
        end
    endfunction

    wire [7:0] a0 = vec_a[7:0],   b0 = vec_b[7:0];
    wire [7:0] a1 = vec_a[15:8],  b1 = vec_b[15:8];
    wire [7:0] a2 = vec_a[23:16], b2 = vec_b[23:16];
    wire [7:0] a3 = vec_a[31:24], b3 = vec_b[31:24];

    wire [7:0] r0 = (mask[0]) ? alu_lane(a0, b0, op) : 8'd0;
    wire [7:0] r1 = (mask[1]) ? alu_lane(a1, b1, op) : 8'd0;
    wire [7:0] r2 = (mask[2]) ? alu_lane(a2, b2, op) : 8'd0;
    wire [7:0] r3 = (mask[3]) ? alu_lane(a3, b3, op) : 8'd0;

    assign result = {r3, r2, r1, r0};
endmodule

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
    reg [31:0] reg_file [0:7];
    assign vec_a = reg_file[addr_a];
    assign vec_b = reg_file[addr_b];

    initial begin
        reg_file[0] = 32'h00000000;
        reg_file[1] = 32'h01020304;
        reg_file[2] = 32'h05060708;
        reg_file[3] = 32'h0C0B0A09;
        reg_file[4] = 32'h00010002;
        reg_file[5] = 32'hFFFFFFFF;
        reg_file[6] = 32'h00000000;
        reg_file[7] = 32'hA5A5A5A5;
    end

    always @(posedge clk) begin
        if (rst) begin
            reg_file[0] <= 32'h00000000;
            reg_file[1] <= 32'h01020304;
            reg_file[2] <= 32'h05060708;
            reg_file[3] <= 32'h0C0B0A09;
            reg_file[4] <= 32'h00010002;
            reg_file[5] <= 32'hFFFFFFFF;
            reg_file[6] <= 32'h00000000;
            reg_file[7] <= 32'hA5A5A5A5;
        end else if (write_enable) begin
            reg_file[write_addr] <= write_data;
        end
    end
endmodule
