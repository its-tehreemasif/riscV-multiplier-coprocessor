# riscV-multiplier-coprocessor
A complete RV32I RISC-V processor system integrated with a custom hardware multiplier co-processor designed for efficient integer multiplication. The multiplier is fully interfaced with the processor core and implemented in SystemVerilog, ensuring seamless integration, correct operation, and verified functional performance.
Here is your **upgraded professional GitHub README.md** with **badges + clean FYP formatting + top-tier structure**:

---

# RV32I Multiplier Co-Processor Processor Design

## 🏷️ Badges

[SystemVerilog]
[Vivado]
[RISC--V]
[Status]

---

## 📌 Introduction

Multipliers are essential hardware units in digital systems, enabling fast arithmetic operations required in DSP, graphics, cryptography, machine learning, and scientific computing.

Software-based multiplication is slow and inefficient compared to hardware implementation. Therefore, integrating a hardware multiplier improves performance, reduces latency, and enhances overall processor efficiency.

---

## ❗ Problem Statement

Design a hardware co-processor for multiplication in an integer-only RISC-V (RV32I) core.

### Requirements:

* Design and verify a hardware multiplier co-processor
* Integrate it into an existing RV32I processor
* Ensure clean interfacing with datapath and control unit

### Deliverables:

* Hardware architecture of multiplier
* Design & implementation report
* Full SystemVerilog code
* Example instruction set

---

## 🎯 Objectives

* Design a signed integer hardware multiplier
* Integrate multiplier into RV32I processor datapath
* Support multi-cycle multiplication with proper stalling
* Ensure safe communication between processor and multiplier
* Correct write-back after multiplication completion
* Prevent invalid memory/register updates during execution
* Verify system using simulation
* Demonstrate using test RISC-V programs

---

## 🧠 Project Overview

This project enhances an RV32I processor by integrating a custom hardware multiplier co-processor.

The multiplier operates as a **multi-cycle unit**, meaning it takes multiple clock cycles to complete execution. During this process:

* The processor stalls execution
* Program Counter is frozen
* Memory and register writes are disabled

Once multiplication is complete:

* Result is written back to the register file
* Normal execution resumes

All RV32I base instructions (ALU, branch, load/store, jump) remain fully functional.

---

## 🏗 Project Architecture

### 🔷 Top Module

Integrates all components:

* PC
* Instruction Memory
* Control Unit
* Register File
* ALU
* Data Memory
* Multiplier Unit

Handles:

* Stalling logic
* Write-back selection

---

### 🔷 Program Counter (PC)

* Tracks instruction address
* Supports sequential execution
* Stalls during multiplication

---

### 🔷 Instruction Memory

* Stores program instructions
* Initialized via `.mem` files

---

### 🔷 Control Unit

Generates control signals:

* RegWrite
* MemRead
* MemWrite
* ALUSrc
* ALUOp

---

### 🔷 Register File

* 32 general-purpose registers
* 2 read ports, 1 write port
* Write-back controlled during multiplication

---

### 🔷 Immediate Generator

* Supports I, S, B, J formats
* Extracts immediate values

---

### 🔷 ALU & ALU Control

* Performs arithmetic & logic operations
* Controlled based on instruction type

---

### 🔷 Branch Unit

* Evaluates branch conditions
* Updates PC when required

---

### 🔷 Data Memory

* Handles load/store operations
* Disabled during multiplication

---

### 🔷 Multiplier Co-Processor

* Multi-cycle signed integer multiplier
* Uses start/busy/done handshake
* Returns result after completion

---

### 🔷 Memory Files (.mem)

* Used for instruction & data initialization
* Allows flexible test programs

---

### 🔷 Testbench

* Generates clock & reset
* Monitors:

  * PC
  * Instructions
  * ALU output
  * Write-back data
* Validates multiplication + stall behavior
  
🔷 System Architecture

The following block diagram shows the complete RV32I processor integrated with the hardware multiplier co-processor:
---

                 +----------------------+
                 |   Instruction Memory |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |   Program Counter    |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |   Control Unit (CU)  |
                 +----------+-----------+
                            |
     +----------------------+----------------------+
     |                                             |
     v                                             v
+------------+                            +----------------+
| Register    |                            | Immediate      |
| File (RF)   |                            | Generator      |
+------+------|                            +----------------+
       |                                              
       |                                              
       v                                              
+----------------------+                +----------------------+
|        ALU           |                |   Multiplier         |
| (Arithmetic/Logic)   |                |   Co-Processor       |
+----------+-----------+                +----------+-----------+
           |                                       |
           |                                       |
           v                                       v
+----------------------+                +----------------------+
|     Data Memory      |                |   Result / Writeback |
+----------+-----------+                +----------+-----------+
           |                                       |
           +----------------------+----------------+
                                  |
                                  v
                         +----------------+
                         | Register Write |
                         +----------------+
## 🚀 Key Feature

✔ Fully functional RV32I processor
✔ Integrated hardware multiplier co-processor
✔ Multi-cycle execution support
✔ Clean datapath integration
✔ Verified using SystemVerilog simulation

---

## 📂 Tools Used

* SystemVerilog
* Xilinx Vivado
* Simulation (XSim)

