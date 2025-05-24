`timescale 1ns / 1ps

module shader_core_tb;

    // Inputs
    reg clk;
    reg rst;
    reg write_enable;
    reg [2:0] addr_a;
    reg [2:0] addr_b;
    reg [2:0] write_addr;
    reg [31:0] write_data;
    reg [1:0] op;
    reg [3:0] mask;

    // Output
    wire [31:0] result;

    // Instantiate DUT
    shader_core dut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .addr_a(addr_a),
        .addr_b(addr_b),
        .write_addr(write_addr),
        .write_data(write_data),
        .op(op),
        .mask(mask),
        .result(result)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz

    initial begin
        // Waveform
        $dumpfile("shader_core_tb.vcd");
        $dumpvars(0, shader_core_tb);
        $display("Time\tResult");

        // Initialize
        clk = 0;
        rst = 1;
        write_enable = 0;
        #10;
        rst = 0;

        // Write to register 3
        write_addr = 3;
        write_data = 32'h01020304; // a = [04,03,02,01]
        write_enable = 1;
        #10;

        // Write to register 5
        write_addr = 5;
        write_data = 32'h05060708; // b = [08,07,06,05]
        #10;
        write_enable = 0;

        // Set read addresses and ALU op
        addr_a = 3;
        addr_b = 5;
        op = 2'b00;     // ADD
        mask = 4'b1111; // All lanes active
        #10;
        $display("%0dns\t%h", $time, result);

        // Change ALU op to MUL, mask half
        op = 2'b01;
        mask = 4'b0101;
        #10;
        $display("%0dns\t%h", $time, result);

        $finish;
    end

endmodule
// End of shader_core_tb
// This testbench initializes the shader core, writes data to the vector register file,
// and performs operations using the SIMD ALU, displaying results at each step.
