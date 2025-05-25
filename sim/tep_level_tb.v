`timescale 1ns / 1ps

module simd_shader_processor_tb;

    reg clk;
    reg rst;

    wire [3:0] current_pc;
    wire [31:0] current_result;
    wire [1:0] current_op;
    wire [3:0] current_mask;
    wire [31:0] reg0_value, reg1_value, reg2_value, reg3_value;

    simd_shader_processor_top dut (
        .clk(clk),
        .rst(rst),
        .current_pc(current_pc),
        .current_result(current_result),
        .current_op(current_op),
        .current_mask(current_mask),
        .reg0_value(reg0_value),
        .reg1_value(reg1_value),
        .reg2_value(reg2_value),
        .reg3_value(reg3_value)
    );

    always #5 clk = ~clk;

    function [31:0] op_name;
        input [1:0] op;
        begin
            case (op)
                2'b00: op_name = "ADD";
                2'b01: op_name = "MUL";
                2'b10: op_name = "AND";
                2'b11: op_name = "OR ";
            endcase
        end
    endfunction

    initial begin
        $dumpfile("simd_shader_processor.vcd");
        $dumpvars(0, simd_shader_processor_tb);

        $display("=================================================");
        $display("SIMD Shader Processor Simulation");
        $display("=================================================");
        $display("Time\tPC\tOp\tMask\tResult\t\tReg0\t\tReg1\t\tReg2\t\tReg3");

        clk = 0;
        rst = 1;

        #20 rst = 0;

        repeat(32) begin
            #10;
            $display("%0dns\t%0d\t%s\t%b\t%h\t%h\t%h\t%h\t%h",
                     $time, current_pc, op_name(current_op), current_mask,
                     current_result, reg0_value, reg1_value, reg2_value, reg3_value);
        end

        $display("=================================================");
        $finish;
    end
endmodule
