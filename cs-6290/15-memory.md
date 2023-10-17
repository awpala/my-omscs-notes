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

First, consider one memory bit in **static random access memory (SRAM)**.

<center>
<img src="./assets/15-003.png" width="650">
</center>

The **bit** sits at the intersection of a **wordline** (which traverses many such bits) and the corresponding **bitlines** (which also in turn traverse many such bits); effectively, the memory is a ***matrix*** of such memory cells.
  * ***N.B.*** Dynamic random access memory (DRAM) similarly is comprised of intersecting wordlines and bitlines (as will be discussed shortly, in the next subsection).

<center>
<img src="./assets/15-004.png" width="150">
</center>

The **wordline** controls a transistor (as in the figure shown above), which in turn closes or opens to correspondingly connect the bitline to the wordline.

<center>
<img src="./assets/15-005.png" width="200">
</center>

Therefore, to access the corresponding **memory cell** (as in the figure shown above), the wordline is activated to correspondingly open the transistor, thereby connecting the memory cell to the bitline. Consequently:
  * To ***write*** data to the memory cell, the bitline is set to the appropriate value (e.g., $b$), which in turn is stored in the memory cell
  * To ***read*** data from the memory cell, the bitline is "released," and consequently the memory cell "emits" its data value which in turn is "detected" by the bitline

In static random access memory (SRAM), the memory cell itself consists of two complementary ***inverters***, with each inverter in turn composed of two constituent transistors (which are necessary to create an inverting gate).
  * With respect to ***reading*** data from the memory cell:
    * If a signal `1` is fed into the memory cell from the transistor, then the top inverter flips it and outputs `0`, which in turn is similarly inverted back to `1` in its corresponding output.
    * Once the transistor signal is disconnected (sending corresponding signal `0`), the memory cell consequently will ***retain*** this value (i.e., similarly inverting `0` to `1`, and then inverting back to `0`).
      * This ***feedback loop*** is essentially ***amplified*** by the inverters at any given time.
  * Conversely, with respect to ***writing*** data to the memory cell:
    * If a signal `1` is sent to the memory cell, the bottom inverter effectively works "against" this signal, because it is attempting to invert this signal to `0`.
    * However, by connecting the memory cell to the bitline (i.e., via its other terminal/connector), if a ***stronger*** signal `1` is received via the connected bitline (as compared to the relatively smaller/weaker inverters), this correspondingly "overpowers" the inverters and "forces" the intended state (i.e., signal `1`) on the memory cell accordingly.

<center>
<img src="./assets/15-006.png" width="300">
</center>

To further enhance this "reinforcement" effect, typically two such transistors are connected to the ***same*** memory cell (as in the figure shown above), with their non-memory-cell-connected terminals connected to bitlines having complementary bit values (i.e., $b$ and $\bar b$).
  * For example, with a bitline signals of $b = 1$ and complement $\bar b = 0$, this further "overwhelms"/"coerces" the memory cell into having a value ***written*** to it.
  * Similarly, if connecting both bitlines for ***reading***, the corresponding complementary pair will be read out to the respective bitlines (i.e., $b$ and $\bar b$). Furthermore, the difference between the bitlines can be examined to more quickly detect the target data value being read from the memory cell accordingly.

To reiterate, by virtue of the ***weak*** constituent transistors of the inverters, connection of the bitlines will generally dictate the behavior of the inverters, and correspondingly examination of the ***difference*** between the (complementary) bitlines (i.e., in particular, in which "direction" this difference moves towards) is sufficient for reliable reading and writing operations with respect to a given memory cell (i.e., as opposed to having to examine ***each*** individual bitline's crossing across a threshold).
  * By initializing the bitlines near the midpoint between `1` and `0`, on activation of the wordline, this in turn initiates the action of the memory cell to "push"/"pull" against the bitlines to quickly converge towards a stable, detectable "difference" between the bitlines accordingly.

### 5. One Memory Bit: DRAM
