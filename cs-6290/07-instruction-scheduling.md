# Instruction Scheduling

## 1. Lesson Introduction

In this lesson, we will see how **instruction scheduling** allows us to execute programs faster, even when these programs have data dependencies; and how to execute more than one instruction every cycle.

## 2. Improving IPC

This lesson will examine how to improve the instructions per cycle (IPC) using out-of-order execution, as well as how to design *actual* hardware to accomplish this.

<center>
<img src="./assets/07-001.png" width="650">
</center>

With respect to improving the IPC, we have seen (cf. Lesson 6) that **instruction level parallelism (ILP)** can be good (i.e., `>> 1`, typically larger than `4` or so).

However, in order to achieve performance approaching ILP, it is necessary to handle the **control dependencies**. To this end, we have seen (cf. Lesson 6) how branch prediction can help to eliminate control dependencies if **branch prediction** is correct.
  * If the branch prediction is *very good* (which on modern machines, it typically *is*), then insofar as control dependencies are concerned, the IPC will approach ILP.

Additionally, it is necessary to consider the data dependencies **write-after-read (WAR)** and **write-after-write (WAW)**, also called **false dependencies**. **Register renaming** provides a resolution measure to completely eliminate these false dependencies, such that they cease to exist in the program anymore, thereby removing their deleterious effect on IPC.

Furthermore, **read-after-write (RAW)** dependencies (also called **true dependencies**) must also be resolved. For this, recall (cf. Lesson 6) that **out-of-order execution** (i.e., not strictly following the sequential program instructions, but rather immediately executing instructions whose inputs are executable in any given cycle) provides a resolution measure for eliminating RAW dependencies, thereby improving IPC.

Finally, **structural dependencies** arise when instructions cannot be executed due to lack of available resources in the processor in a given cycle. To provide a resolution measure for eliminating structural dependencies, use a **wider-issue** processor (i.e., one which can handle many instructions in each cycle, thereby minimizing the need to delay instructions due to lack of available resources).

Among these resolution measures, it remains to be determined how these can be performed. Initially, this lesson will focus on register renaming and out-of-order execution, in particular, implementing these resolution measures in a manner which is amenable to actual hardware implementation in a processor (i.e., beyond simply "on paper").

## 3. Tomasulo's Algorithm

<center>
<img src="./assets/07-002.png" width="650">
</center>

The first technique for improving processor instructions per cycle (IPC) is called **Tomasulo's algorithm**, which is a 40+ year old technique for out-of-order execution. This algorithm was used in older IBM 360 machines.

Tomasulo's algorithm determines which instructions have inputs that are currently ready for execution in the next/upcoming cycle, as well as those instructions which still must wait for their inputs to be produced. Tomasulo's algorithm also includes a form of register renaming. Furthermore, Tomasulo's algorithm is surprisingly similar to what is still in current use on modern processors with respect to out-of-order execution.

Therefore, Tomasulo's algorithm is a useful case study in a still-applicable approach to this problem (albeit with more complexity in implementation on modern machines).

| Characteristic | Tomasulo's Algorithm | Modern Machines |
|:--:|:--:|:--:|
| Applicable instructions | Only for floating point instructions | For *all* instructions |
| Scope of examined "window" (i.e., near-future/upcoming-cycle instructions) | Only examined relatively *few* instructions within the  window | Examine *hundreds* of instructions within the window  |
| Exception handling | Rudimentary exception handling, since floating-point instructions are a relatively small scope, only applying to relatively niche programs (e.g., those involving intensive floating-point calculations) and in simple configurations (e.g., only running one program at a time, for which exceptions could be handled relatively simply on an ad hoc basis) | Include extensive, explicit hardware support for exception handling, as will be discussed later |

The ***differences*** between Tomasulo's algorithm and modern machines are as in the table shown above.

We will first begin with examining Tomasulo's algorithm itself, and then contrast with modern machines subsequently thereafter.

## 4. Tomasulo's Algorithm - The Big Picture

Before examining Tomasulo's algorithm in detail, here we will first consider an overview of how it works (i.e., the underlying hardware structure).

<center>
<img src="./assets/07-003.png" width="650">
</center>

The first component is the **instruction queue (IQ)**, as in the figure shown above. The instructions are repeatedly fetched in the order they are received from the **Fetch** unit, and queued appropriately (i.e., in a ***first-in, first-out*** manner); in the case of Tomasulo's algorithm, recall that these are restricted to floating-point instruction.

<center>
<img src="./assets/07-004.png" width="650">
</center>

The next-available instruction in the IQ is placed into one of the available **reservation stations (RS)**, as in the figure shown above. The RSes are essentially "on standby" in this manner, waiting to receive the next instruction.

<center>
<img src="./assets/07-005.png" width="650">
</center>

Additionally, there is a **floating-point registers file (REGS)** (as in the figure shown above), which contains the floating point registers themselves. When an instruction is inserted into the RS, the values already present in the REGS (i.e,. those which are *currently* available for execution) are simply inserted into the RS appropriately.

<center>
<img src="./assets/07-006.png" width="650">
</center>

Once the instruction is ready to execute, it is sent to the corresponding **execution unit**, as in the figure shown above. Different types of execution units are present (e.g., `ADD`, `MUL`, etc.) for the appropriate instruction/computation required. Furthermore, each execution unit has a separate, dedicated RS, into which the appropriate upstream instructions queue/wait for.

<center>
<img src="./assets/07-007.png" width="650">
</center>

Once such a unit (e.g., `ADD`, per the figure shown above) has produced a result, the result is **broadcasted** on the **common data bus (CDB)**, as in the figure shown above (denoted by purple arrows and lines). This result is fed back into the REGS (i.e., all current results are available/up-to-date accordingly in REGS, ready for use by subsequent instructions).

<center>
<img src="./assets/07-008.png" width="650">
</center>

Furthermore, the results are broadcasted to the RSes as well, as in the figure shown above. This is to ensure current data is relayed to instructions which are in queue within the RSes, pending execution. Therefore, at any given time, a given RS is synchronizing values which are either known and/or pending update.

In the figure shown above, there are *two* feedback lines (shown in purple) per RS, to emphasize the fact that a typical instruction has *two* inputs (e.g., operands for either operation `ADD` or `MUL`); correspondingly, subsequent post-result broadcast of the result can impact either of these two values (e.g., possibly latching into multiple RSes).

<center>
<img src="./assets/07-009.png" width="650">
</center>

Finally, if the instruction is *not* an arithmetic instruction (e.g., but rather a `LOAD`, `STORE`, etc. via REGS), then it is instead sent to the **address generation unit (ADDR)**, as in the figure shown above. From there, the instruction is inserted into the appropriate **buffer** (i.e., load buffer, store buffer, etc., respectively), from which the instruction is subsequently queued up for going into **memory (MEM)**.

<center>
<img src="./assets/07-010.png" width="650">
</center>

As in the figure shown above, the **load buffer (LB)** provides only the specifically requested data, while the the **store buffer (SB)** provides *both* the address *and* the data to MEM.

<center>
<img src="./assets/07-011.png" width="650">
</center>

When the loaded data is returned from MEM, it is similarly ***broadcasted*** via the CDB, targeting the appropriate register in REGS, as in the figure shown above.

<center>
<img src="./assets/07-012.png" width="650">
</center>

Furthermore, the loaded data from MEM is additionally ***broadcasted*** back to the SB, so that the current values are available there for subsequent placement into MEM, i.e., the corresponding value is only placed into MEM once it becomes available.

Therefore, unlike arithmetic instructions (which can be executed out-of-order), inputs to load and store instructions are only made available in the store/load buffers in an ***in-order*** manner.
  * ***N.B.*** The manner in which this in-ordering is achieved will be discussed later (in particular, modern processors are in fact capable of performing load and store operations *out*-of-order).

<center>
<img src="./assets/07-013.png" width="650">
</center>

Before proceeding further with additional details regarding Tomasulo's algorithm, consider some additional nomenclature (as in the figure shown above, denoted in red).
  * The **issue** is the section which coordinates sending of the instructions from IQ to RS or ADDR.
  * When the instruction is finally sent from a RS to the corresponding execution unit, this action is called a **dispatch**.
  * When the executed by the execution unit and subsequently broadcasted, this operation is called **write result** (or **broadcast**).

Next, we will examine what occurs subsequently to performing these successive operations (i.e., issue, dispatch, and broadcast).

## 5-6. Tomasulo's Algorithm - Operation `Issue`

### 5. Introduction


### 6. Example
