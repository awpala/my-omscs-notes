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

In this manner, one instruction per cycle is achieved. Therefore, the following **stages** of operation can be denoted on a per-cycle basis:
* 1. `FETCH` (`F`) - the PC fetches an instruction from IMEM
* 2. `READ/DECODE` (`D`) -  registers are read and decoded
* 3. `ALU` (`A`) - the ALU performs a computation/operation
* 4. `MEM` (`M`) - DMEM is accessed
* 5. `WRITE` (`W`) - registers are written to

The time to perform these successive steps may total around `20 ns` (i.e., per instruction). Therefore, to apply pipelining to this process, the idea is to "continuously fill" these five stages during operation with instructions (e.g., `I1`, `I2`, etc.), for example:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | I1 | | | | |
| C2 | I2 | I1 | | | |
| C3 | I3 | I2 | I1 | | |
| C4 | I4 | I3 | I2 | I1 | |
| C5 | I5 | I4 | I3 | I2 | I1 |

Therefore, immediately following cycle C5, instruction I1 is completed, and then each successive cycle yields an additionally complete instruction (i.e., I2, I3, etc.). Assuming that each stage takes the same time to complete, this gives `(20 ns)/(5 stages) = 4 ns/stage`, and therefore after the initial **latency** of `20 ns` to "fill" the pipeline with one complete instruction, subsequent instructions will be completed at this rate of `4 ns` per cycle, i.e., a **throughput** of `(1 instruction)/(4 ns) = 0.25 instructions/ns`.

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

## 6. Pipeline Cycles per Instruction (CPI)

<center>
<img src="./assets/03-009.png" width="650">
</center>

In principle, the **cycles per instruction** (**CPI**) should be `1` once the pipeline is filled. A typical program is composed of *billions* of instructions, so the first few cycles (i.e., to initially fill the pipeline) are effectively negligible, and therefore ***at steady state*** this suggests a CPI of `1`. However, is this necessarily true?

In fact, this is ***not*** always the case. The reasons this may not be achieved include:
  * Initial filling of the pipeline
    * However, even with the initial filling, the CPI will approach `1` as the number of instructions grows (in principle, even approaching `∞` instructions)
  * Pipeline stalls

With respect to **pipeline stalls**, consider a car production line (as in the figure shown above), comprised of the following stages:
  1. install doors
  2. install front wheels
  3. install rear wheels
  4. etc.

Now, consider the sequential assembly of a black car, purple car, green car, and blue car.
  * During the installation of the front wheels for the purple car, the machine damages the wheels. Therefore, while the black car is able to proceed to subsequent stages, the purple car is unable to proceed to the next stage (rear wheels installation), and consequently must remain in its current stage (front wheel installation) to correct the issue (i.e., install a new set of wheels).
  * Because the purple car was unable to proceed in this stage cycle, the worker who installs the rear wheels is ***idle*** for the next cycle, awaiting arrival of the purple car. Furthermore, the subsequent green car is unable to proceed onto the next stage (install front wheels) pending correction of the issue with the purple car.
  * Once the issue is corrected for the purple car, the pipeline can proceed as before (including commencing assembly on the most recently begun blue car), however, there is now an "idle gap" that propagates through the pipeline.

Therefore, a pipeline stall introduces inefficiency into pipelining. If such stalls occur regularly over the course of program execution, this can result in a steady-state `CPI > 1` (e.g., `(6 cycles)/(5 cars) = 1.2 cycles/car`), which is inefficient.

How, then, can stalling occur in a *processor pipeline* (i.e., as opposed to the car assembly analogy)? This is discussed in the next section.

## 7. Processor Pipeline Stalls

<center>
<img src="./assets/03-010.png" width="650">
</center>

Consider how a stall can occur in a five-stage processor pipeline, as in the figure shown above.

The initial state of the pipeline is as follows:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |

In this case, instruction `ADD R2, R1, 1` reads the incorrect value of the register `R1`, thereby generating a **processor stall**. The instruction must remain in the stage `D` to rectify the issue, thereby generating a "gap" in the pipeline, as follows:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |

Furthermore, several such "gaps" can occur, even when there is only a single dependency across stages (e.g., `R1`). In this case, the re-read of `R1` generates another "gap" as follows:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |

Assuming `R1` can be read (`D`) and written (`W`) in the same cycle, the pipeline proceeds as follows:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |
| C4 | `MUL ...` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) |

Therefore, this pipeline results in a CPI of `(5 cycles)/(3 instructions) = 1.67 > 1`.

***N.B.*** Generally, processor stalls are detected by the hardware itself.

A processor pipeline may also need to be **flushed** (unlike the previously described car assembly analogy), as discussed next.

## 8. Processor Pipeline Stalls and Flushes

<center>
<img src="./assets/03-011.png" width="650">
</center>

Continuing from the example of the previous section, suppose that the next instruction is `JUMP`, as follows:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |
| C4 | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) |

Since the instruction `JUMP` is not decoded initially, the subsequent instructions are fed into the pipeline:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |
| C4 | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) |
| C5 | `SUB ...` | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | 

By cycle C6, the instruction `JUMP` is interpreted, however, the subsequent instructions are inappropriate for this instruction:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |
| C4 | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) |
| C5 | `SUB ...` | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | 
| C6 | `ADD ...` | `SUB ...` | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` |

Therefore, to rectify this, the processor **flushes** the instructions:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |
| C4 | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) |
| C5 | `SUB ...` | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | 
| C6 | (*flushed*) | (*flushed*) | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` |

Consequently, in the subsequent cycle C7, the appropriate corresponding instruction (`SHIFT ...`) is fed into the pipeline:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | `LW R1, ...` | | |
| C2 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | `LW R1, ...` | |
| C3 | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) | `LW R1, ...` |
| C4 | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | (*gap*) |
| C5 | `SUB ...` | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` | (*gap*) | 
| C6 | (*flushed*) | (*flushed*) | `JUMP` | `ADD R3, R2, 1` | `ADD R2, R1, 1` |
| C7 | `SHIFT ...` | (*flushed*) | (*flushed*) | `JUMP` | `ADD R3, R2, 1` |

This results in a CPI of `(4 cycles)/(2 instructions) = 2 > 1`.

## 9. Control Dependencies

<center>
<img src="./assets/03-012.png" width="650">
</center>

The "branch" and "jump" problems from the previous section are due to what is called a **control dependency**.

Consider the following program:
```mips
  ADD R1, R1, R2     # L1
  BEQ R1, R3, Label  # L2
  ADD R2, R3, R4     # L3
  SUB R5, R6, R8     # L4
  # ...

Label:
  MUL R5, R6, R8     # L5
  # ...
```

The instructions in lines L3 and L4 (and onwards) have a control dependency on the branch in L2, i.e., the execution of the former depends on the result of the latter. Similarly, the instruction in line L5 (and onwards) has a control dependency on the branch in L2. Essentially, once a branch occurs in the program, all subsequent instructions to be executed will have a control dependency on the branch point; therefore, it is indeterminate a priori whether or not to fetch the subsequent instructions until the branch instruction itself is known.

Consider now the effect of such control dependencies on the five-stage pipeline's CPI.
  * On average, about 20% of all instructions are branches and jumps.
  * Slightly more than 50% of branch/jump instructions are actually taken (i.e., they proceed to `Label` or similar, rather than executing the immediately succeeding instructions).

Therefore, based on these facts, the expected CPI is `1 + (0.20*0.50)*2 = 1.2` (assuming the error is caught in the third stage, resulting in `2` subsequent flushes generated by the pipeline).

With a deeper pipeline (i.e., more than five stages), this "guessing penalty" is larger, because the error will be caught in a later stage, thereby generating more upstream flushes. In fact, such a deep pipeline is typical in modern architectures.

Conversely, if we are able to make better predictions about the branching behavior, such penalties can be either reduced or largely eliminated. Later in the course, we will discuss the technique called **branch prediction**, which deals with this particular issue.

## 10. Control Dependency Quiz and Answers

Consider the following pipeline:
  * `25%` of all instructions are taken as branches/jumps
  * The pipeline has `10` stages
  * The correct target for branch/jump instructions is detected in the sixth stage
  * Everything else flows "smoothly"

What is the actual CPI for this pipeline?
  * `1 + 0.25*5 = 2.25`

The result of this suggests that branching more than *halves* the throughput of the pipeline!

## 11. Data Dependencies


