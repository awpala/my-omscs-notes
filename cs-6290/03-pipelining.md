# Pipelining

## 1. Lesson Introduction

There are several key concepts that are used in many ways in computer architecture. One of these concepts is called **pipelining**, and it used in several ways in virtually every computer nowadays.

***N.B.*** You should already be familiar with pipelining (and how it is used to improve processor performance) as a prerequisite for this course. Therefore, this lecture is provided mainly as a review of pipelining in a manner which sets the stage for more advanced topics.

## 2. Pipelining

<center>
<img src="./assets/03-001.png" width="650">
</center>

Consider discovery of oil at a distant location from a destination gas station. Transferring the oil via bucket takes `3` days to complete. It takes `4` round trips to fill the pumping station. Clearly, this approach is extremely inefficient.

<center>
<img src="./assets/03-002.png" width="650">
</center>

Alternatively, consider installing a long pipe between the oil source and the gas station. Initially, oil is pumped through the pipe from the source to the pumping station, taking `3` days for the oil to travel through and fill the entire pipe, yielding a bucket of oil at the pumping station.

<center>
<img src="./assets/03-003.png" width="650">
</center>

The latency is still `3` days; so what is the big deal, then? In this case, after filling the pipe, the subsequent buckets of oil are immediately available for filling now that the pipe is continuously "primed"/full. Therefore, after the initial latency, the rate of pumped oil will be much higher than round trips with a bucket.

Therefore, with respect to pipelining, a key idea is that while the initial latency may be long, the subsequent in-progress process will be efficiently delivered in rapid succession.

## 3. Pipelining in a Processor

<center>
<img src="./assets/03-004.png" width="650">
</center>

Now, we will apply the idea of pipelining to a processor. Traditional processors are comparatively simple by modern standards, however, they are still illustrative for the purpose of describing pipelining.

In a traditional processor, there are the following **components** (as in the figure shown above):
  * **program counter** (**PC**)
  * **instruction memory** (**IMEM**)
  * **registers** (**REGS**)
  * **arithmetic/logic unit** (**ALU**)
  * **dynamic memory** (**DMEM**)

The process flow occurs as follows:
  1. The PC accesses IMEM for the next instruction
  2. The instruction is decoded to determine the instruction type, and possibly simultaneously examining the registers
  3. Once the registers are read, they are fed into the ALU, which performs the corresponding operation (e.g., `ADD`, `SUB`, `XOR`, etc.) per the decoding logic
  4. The result of the ALU computation can be written back into the registers, or if a `LOAD` or `STORE` instruction is received then it will be used to access data memory which then provides the value to write back into the registers

***N.B.*** Additionally, there are other operations (e.g., branching) that can occur within this process flow.

In this manner, one instruction per cycle is achieved. Therefore, the following **phases** of operation can be denoted on a per-cycle basis:
* 1. `FETCH` (`F`) - the PC fetches an instruction from IMEM
* 2. `READ/DECODE` (`D`) -  registers are read and decoded
* 3. `ALU` (`A`) - the ALU performs a computation/operation
* 4. `MEM` (`M`) - DMEM is accessed
* 5. `WRITE` (`W`) - registers are written to

The time to perform these successive steps may total around `20 ns` (i.e., per instruction). Therefore, to apply pipelining to this process, the idea is to "continuously fill" these five phases during operation with instructions (e.g., `I1`, `I2`, etc.), for example:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | I1 | | | | |
| C2 | I2 | I1 | | | |
| C3 | I3 | I2 | I1 | | |
| C4 | I4 | I3 | I2 | I1 | |
| C5 | I5 | I4 | I3 | I2 | I1 |

Therefore, immediately following cycle C5, instruction I1 is completed, and then each successive cycle yields an additionally complete instruction (i.e., I2, I3, etc.). Assuming that each phase takes the same time to complete, this gives `20 ns/5 phases = 4 ns/phase`, and therefore after the initial **latency** of `20 ns` to "fill" the pipeline with one complete instruction, subsequent instructions will be completed at this rate of `4 ns` per cycle, i.e., a **throughput** of `1 instruction/4 ns = 0.25 instructions/ns`.

## 4. Laundry Pipelining Quiz and Answers

<center>
<img src="./assets/03-006A.png" width="650">
</center>

Assume the following devices are available for doing laundry:

| Device | Execution Time per Operation |
|:---:|:---:|
| Washer | `1 hr` |
| Dryer | `1 hr` |
| Folder | `1 hr` |

For `10` loads of laundry, what is the total completion time required:
  * Without pipelining?
    * `1*10 + 1*10 + 1*10 = 30 hr`
  * With pipelining?
    * `3*1 + 1*(10-1) = 12 hr`

Therefore, pipelining reduces the total completion time dramatically, by minimizing idle time on any particular device.

## 5. Instruction Pipelining Quiz and Answers

Consider a `5`-stage processor pipeline (with `1` clock cycle per stage) executing a program comprised of `10` instructions.

What is the total program execution time (in cycles):
  * Without pipelining?
    * `(5 stages/instruction)*(1 cycle/stage)*(10 instructions/program) = 50 cycles/program`
  * With pipelining?
    * `5*1*1 + 1*1*(10-1) = 14 cycles/program`

***N.B.*** As before, with pipelining, it takes a full instruction (i.e., there is latency) to fill the pipeline first.

## 6. Pipeline CPI



