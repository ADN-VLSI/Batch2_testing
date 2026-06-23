# khalid_interrupt_controller

## Overview

A dual-core interrupt controller with 8 interrupt sources, configurable per-core enable masks, and priority-based interrupt ID generation.

## Block Diagram

![khalid_interrupt_controller](khalid_interrupt_controlle.svg)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ADDR_WIDTH` | `int` | `3` | Address bus width for register access |
| `DATA_WIDTH` | `int` | `8` | Data bus width for register access |

## Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | Input | 1 | Clock signal (positive edge triggered) |
| `arst_ni` | Input | 1 | Active-low asynchronous reset |
| `addr_i` | Input | `ADDR_WIDTH` | Register address for read/write operations |
| `wdata_i` | Input | `DATA_WIDTH` | Write data bus |
| `we_i` | Input | 1 | Write enable (active high) |
| `rdata_o` | Output | `DATA_WIDTH` | Read data bus |
| `ci` | Input | 8 | 8 interrupt source inputs |
| `core0_id` | Output | 3 | Interrupt ID for Core 0 (0-7) |
| `core0_valid` | Output | 1 | Valid interrupt flag for Core 0 |
| `core1_id` | Output | 3 | Interrupt ID for Core 1 (0-7) |
| `core1_valid` | Output | 1 | Valid interrupt flag for Core 1 |

## Register Map

| Address | Register | Access | Description |
|---------|----------|--------|-------------|
| `0x0` | `core_0_src_en` | R/W | Core 0 interrupt source enable mask (8-bit, 1 bit per source) |
| `0x4` | `core_1_src_en` | R/W | Core 1 interrupt source enable mask (8-bit, 1 bit per source) |

## Architecture

The controller consists of three main functional blocks:

### 1. Register Interface (Write/Read)
- **Write**: On `posedge clk_i`, if `we_i` is high and `arst_ni` is deasserted, `wdata_i` is written to `core_0_src_en` (addr=0x0) or `core_1_src_en` (addr=0x4).
- **Read**: Combinational read via multiplexer returning `core_0_src_en`, `core_1_src_en`, or `0` based on `addr_i`.
- **Reset**: Asynchronous active-low reset clears both enable registers to `8'b0`.

### 2. Interrupt Masking
Each core has an independent 8-bit mask applied to the incoming `ci` vector:
- `masked_i_core0 = ci & core_0_src_en`
- `masked_i_core1 = ci & core_1_src_en`

### 3. Priority Encoder (per core)
Fixed priority encoding (source 0 highest, source 7 lowest). Generates:
- `coreX_valid`: High if any masked interrupt is active (`masked_i_coreX != 0`)
- `coreX_id`: 3-bit ID of the highest-priority active interrupt

## Priority Scheme

| Priority | Interrupt Source | `coreX_id` |
|----------|------------------|------------|
| Highest (0) | `ci[0]` | `3'd0` |
| 1 | `ci[1]` | `3'd1` |
| 2 | `ci[2]` | `3'd2` |
| 3 | `ci[3]` | `3'd3` |
| 4 | `ci[4]` | `3'd4` |
| 5 | `ci[5]` | `3'd5` |
| 6 | `ci[6]` | `3'd6` |
| Lowest (7) | `ci[7]` | `3'd7` |

## Usage Example

```systemverilog
khalid_interrupt_controller #(
    .ADDR_WIDTH(3),
    .DATA_WIDTH(8)
) u_int_ctrl (
    .clk_i      (clk),
    .arst_ni    (rst_n),
    .addr_i     (cpu_addr[2:0]),
    .wdata_i    (cpu_wdata),
    .we_i       (cpu_we),
    .rdata_o    (cpu_rdata),
    .ci         (interrupt_sources),
    .core0_id   (core0_irq_id),
    .core0_valid(core0_irq_valid),
    .core1_id   (core1_irq_id),
    .core1_valid(core1_irq_valid)
);