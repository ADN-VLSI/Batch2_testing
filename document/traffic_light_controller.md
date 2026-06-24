# Traffic Light Controller

**Author's Name:** Md. Sakib Hasan Shawon

## Overview

This repository contains a **traffic light controller for parameterized n roads** implemented in **systemverilog**.

---

### Key Features

---

- Parameterized Design (N roads)
- Priority based Round-Robin Search
- Pulse driven transition
- Traffic-dependent controlling

---

## ![Traffic light controller Block Diagram](traffic_light_controller.svg)

### Why do we need this traffic light controller?

---

### Problems:

- Tradinational controllers cycle through every road sequentially.

- Simple priority encoders always favor lower-indexed roads. e.g., if road 0 stays busy, road 7 is starved indefinitely.

- FSMs don't compute the next state until the current state ends

- Expanding a junction from 4 lanes to 6/7 or more lanes usually requires rewriting the entire state machine logic


### Solutions:

- Combinational search loops instantly skip inactive roads.

- Because of Circular Round-Robin, the controller treats every lane with the equal priority.

- The logic pre-calculates both the current next and future next states simultaneously.

- Changing a single parameter automatically scales the internal tracking widths, loop iterations and I/O ports without rewriting a line of core logic.

---

## RTL Interface (Module Header)

```systemverilog
module traffic_light_controller #(
    parameter int N = 8
)(
    input logic          clk,
    input logic          rst_n,
    input logic          ptr,
    input logic  [N-1:0] traffic,

    output logic [N-1:0] green,
    output logic [N-1:0] yellow,
    output logic [N-1:0] red
);
```
---

## Module Interface

### Parameters


| Parameter | Type | Description |
|-----------|------|-------------|
| N         | int  | Number of traffic lanes to control


### Ports

| Port Name | Direction | Type | Width |
|-----------|-----------|------|-------|
| clk       | input     | logic| 1     |
| rst_n     | input     | logic| 1     |
| ptr       | input     | loigc| 1     |
|traffic    | input     | logic|[N-1:0]|
|green      | output    | logic|[N-1:0]|
|yellow     | output    | logic|[N-1:0]|
|red        | output    | logic|[N-1:0]|

---


## Internal Signals

| Signal             | Width     | Description |
|--------------------|-----------|----------|
| IDX_W              | $clog2(N) | Number of bits required to index N roads |
| current_green      | IDX_W     | Currently active green road |
| next_green         | IDX_W     | Road that will be yellow |
| next_after_current | IDX_W     | First traffic-active road found after current_green |
| next_after_next    | IDX_W     | Second traffic-active road found after current_green |
| found1             | 1         | Indicates first valid traffic road found |
| found2             | 1         | Indicates second valid traffic road found |
| reset_state        | 1         | Reset tracking flag |

---

## Architecture

The controller is divided into four major blocks:

### 1. First Search Block

Searches for the nearest road with traffic after the currently active green road.

```text
current_green
      |
      v
[Search Next Active Road]
      |
      v
next_after_current
```

---

### 2. Second Search Block

Searches for the next active road after `next_after_current`.

```text
next_after_current
         |
         v
[Search Next Active Road]
         |
         v
next_after_next
```

---

### 3. State Update Block

Updates the currently green road and the future yellow road whenever a pulse arrives on `ptr`.

```text
ptr Pulse
    |
    v
current_green <= next_after_current
next_green    <= next_after_next
```

---

### 4. Output Generation Block

Generates Green, Yellow and Red outputs.

```text
current_green -> GREEN

next_green -> YELLOW

All others -> RED
```

---

## Functional Operation

The controller operates using a circular round-robin algorithm.

### Step 1

Identify the currently green road.

```text
current_green
```

### Step 2

Search forward and find the nearest road with traffic.

```text
next_after_current
```
If find the traffic at the immediate lane. Then, step 4.
If cannot find traffic at the immediate lane. Then, step 3.

### Step 3

Continue searching and find the next traffic-active road.

```text
next_after_next
```

### Step 4

When `ptr` becomes high:

```text
current_green <= next_after_current
next_green    <= next_after_next
```

### Step 5

Generate outputs.

```text
current_green -> Green

next_green -> Yellow

remaining roads -> Red
```

---