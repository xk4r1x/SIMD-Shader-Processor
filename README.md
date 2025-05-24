# SIMD Shader Processor (Makari Green)

A 4-lane vector processor core implemented in Verilog. Supports vector arithmetic and logic operations with per-lane masking and a custom instruction format.

## Features
- 4-lane 8-bit SIMD ALU
- Supports ADD, MUL, AND, OR (2-bit op)
- 4-bit lane-level masking
- 8-entry vector register file
- Custom 32-bit instruction format
- Instruction ROM with shader-style vector programs
- Simple pipeline: Fetch → Decode → Execute → Writeback
- Testbench with clock, reset, and waveform dump

## Instruction Format (32 bits)
| Bits     | Field     | Description                        |
|----------|-----------|------------------------------------|
| [31:30]  | `op`      | ALU operation (00=ADD, 01=MUL...)  |
| [29:26]  | `mask`    | SIMD lane mask (4 bits)            |
| [25:23]  | `dest`    | Destination register address       |
| [22:20]  | `srcA`    | Source A register address          |
| [19:17]  | `srcB`    | Source B register address          |
| [16:0]   | Reserved  | Not used                           |

## Test Cases
The testbench simulates instruction execution and shows register values cycle-by-cycle.

```
PC = 0
Register[0] = ...
Register[1] = ...
...
```

## Files
- `simd_alu.v` – SIMD arithmetic and logic unit
- `vector_register_file.v` – 8x32-bit register file
- `shader_program.v` – ROM with hardcoded instructions
- `shader_pipeline.v` – Full pipeline controller
- `shader_pipeline_tb.v` – Simulation testbench

## Waveform Output
Use GTKWave with `shader_pipeline_tb.vcd` to view simulation.

## Author
Makari Green  
```verilog
Author: Makari Green
```
