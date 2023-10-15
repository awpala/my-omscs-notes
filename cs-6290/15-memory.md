# Memory

## 1. Lesson Introduction

This lesson will discuss how different types of memory work, as well as why we cannot have memory that is simultaneously large, fast, *and* cheap.

This lesson will also describe how memory chips can pack so many bits in such a relatively small physical space.

## 2. How Memory Works

<center>
<img src="./assets/15-001.png" width="650">
</center>

This lesson will examine how memory works, and with particular focus on the following topics:
  * Memory technology - SRAM and DRAM (i.e., what do these mean, and how do they work)
  * Why is main memory so slow?
  * Why not simply use cache-like memory in place of main memory in order to improve its speed?
  * What occurs on cache miss and consequent main-memory access?
  * How can main memory be made to be faster (i.e., reducing the latency resulting from a cache miss)?

## 3-5. Memory Technology: SRAM and DRAM

### 3. Introduction

<center>
<img src="./assets/15-002.png" width="650">
</center>

There are two principal memory technologies, defined as follows:
  * ***static* random access memory (SRAM)**
  * ***dynamic* random access memory (DRAM)**

***N.B.*** In both types of memory, **random** access refers to the fact that any memory location can be accessed arbitrarily/randomly by address, without otherwise requiring full traversal of all memory locations to reach a given address. Conversely, **sequential** access (e.g., tape) requires scanning through the entire memory in order to reach a given address.

The key ***differences** between static and dynamic random access memories is with respect to this static vs. dynamic behavior, which is characterized as follows:

| Random Access Memory Type | Data Retention* | Transistors per Bit | Overall Speed |
|:--:|:--:|:--:|:--:|
| Static (SRAM) | The data is ***retained*** as long as power is supplied | Requires ***several*** transistors per memory bit | Generally ***faster*** |
| Dynamic (DRAM) | The data is ***lost*** (i.e., even if power is supplied), unless the data is refreshed periodically (i.e., read out and write back in on a regular basis) | Only requires ***one*** transistor per memory bit | Generally ***slower*** |
* ****N.B.*** Both types of random access memory ***lose*** data when power is ***not*** supplied.

Therefore, the corresponding trade-offs are with respect to speed and simplicity vs. cost, i.e.,:
  * SRAM is more expensive and more complex to implement, but provides better speed
  * DRAM is less expensive and simpler to implement, but is slower

Next, we wil consider what ***one*** memory bit looks like in the context of these respective memory types.

### 4. One Memory Bit: SRAM

### 5. One Memory Bit: DRAM