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

<center>
<img src="./assets/07-014.png" width="650">
</center>

The first step in Tomasulo's algorithm is the operation `Issue`. During `Issue`, the next instruction (in ***program-order***) is taken from the instruction queue (IQ). This must be done in program-order to ensure correct register renaming.

Next, it must be determined from where the inputs to the instruction originate (i.e., are they already in the register file [REGS], or rather are they pending broadcast from already in-progress instructions). Furthermore, if it is necessary to *wait* for an instruction, then which one? For this particular purpose, there will be some type of **register allocation table (RAT)** available.

Next, the next-available **reservation station (RS)** is obtained, having the appropriate type for the instruction in question (i.e., `ADD`, `MUL`, etc.). Furthermore, if all RSes are busy at this point (i.e., in use by an instruction already), then no Issue operation occurs in this particular cycle.
  * ***N.B.*** In Tomasulo's algorithm, instructions are issued *once* per cycle.

Next, the instruction is placed into the appropriate RS.

Finally, the destination register of the instruction is **tagged**, such that when the result is produced, it is sent there appropriately (i.e., for subsequent use by future instructions sharing the data in that register accordingly).

### 6. Example

Consider now a running example of how Tomasulo's algorithm works, starting with the operation `Issue`.

<center>
<img src="./assets/07-015.png" width="650">
</center>

An **issue queue (IQ)** with four instructions is given (as in the figure shown above), containing four instructions in program-order.
  * ***N.B*** Instructions here are written compactly in a high-level format for simplicity/brevity (e.g., `F2 = F4 + R1` rather than `ADD F2, F4, F1`, etc.).

Furthermore, the **floating-point registers** (denoted by `F1, F2`, etc.) are contained in the **register alias table (RAT)**, which stores the corresponding instructions producing the register in question. A blank entry in the RAT redirects to the **register file (RF)**, the latter of which in turn contains the values of the registers themselves.

Lastly, the **reservation stations (RS)** (denoted by `RS1`, `RS2`, etc.) store the operand values for the appropriate instructions.

<center>
<img src="./assets/07-016.png" width="650">
</center>

When instruction `I1` (`F2 = F4 + F1`) is issued from the IQ, it is taken from the **instruction buffer** (as in the figure shown above).

Next, the RAT is examined. Since both inputs `F1` and `F4` are available, their corresponding values from the RF are store in `RS1` (where `+` denotes the operation `ADD`), which *is* indeed a currently available RS at this point.

Lastly, for purposes of register renaming, since the result will now originate from `RS1`, the corresponding entry is updated in the RAT to reflect this (i.e., future instructions will now read `F2` via `RS1`'s pending result, rather than via the RF). Furthermore, the instruction will be removed from the IQ, thereby shifting down the upstream instructions accordingly (in the figure, this is denoted by crossing out with purple line in the IQ, but otherwise for simplicity without corresponding redrawing of the IQ itself).

<center>
<img src="./assets/07-017.png" width="650">
</center>

Next, instruction `I2` (`F1 = F2 / F3`) is taken from the IQ (as in the figure shown above).

The operation `DIV` (denoted `/` in the figure shown above) is sent to the next-available RS associated with the execution unit `MUL`. Since operand `F2` is used, it cannot be read directly from the RF now (i.e., due to the aforementioned upstream use by `I1`), but rather this value must ***wait*** on `RS1`.

Correspondingly, instruction `I2` is removed from the issue queue, and the RAT is correspondingly updated for `F1` via `RS4`.

<center>
<img src="./assets/07-018.png" width="650">
</center>

Next, instruction `I3` (`F4 = F1 - F2`) is taken from the IQ (as in the figure shown above). In this case, neither operand values can be read directly from the corresponding RF entries, but rather both are ***waiting*** on the RAT (i.e., `F1` via `RS4`, and `F2` via `RS1`). Furthermore, the RAT is updated accordingly (i.e., `F4` via `RS2`). 

<center>
<img src="./assets/07-019.png" width="650">
</center>

***N.B.*** At this point (i.e., immediately following instruction `I3`), if there were *no* `RS3`present, the execution unit `ADD` would be currently *full*, and therefore instruction `I4` would have to wait to be removed from the IQ in the next cycle, pending execution of at least one of instructions `I1` or `I3` first.

Lasty, instruction `I4` (`F1 = F2 + F3`) is taken from the IQ (as in the figure shown above). Here, operand `F3` is taken directly from the RF, whereas operand `F1` is taken from the RAT (via `RS4`).

However, note that here there is a ***collision*** with respect to RAT entry for `F1` (i.e., the result of previous instruction `I2` vs. that of the current instruction `I4`). To resolve this, the existing entry (i.e., `RS4`) is ***overwritten*** by this more-recent result (i.e., `RS3`). Furthermore, as before, instruction `I4` is removed from the IQ.

***N.B.*** In a real processor, *one* instruction is issued per cycle, with these inter-dependent instructions having been executed (i.e., providing corresponding results) by the time the next instruction is removed from the IQ.

## 7. `Issue` Quiz and Answers

<center>
<img src="./assets/07-020Q.png" width="650">
</center>

Consider the operation `Issue` as in the figure shown above. Two instructions are already present in the register stations (RS) immediately prior to execution of the next instruction in the instruction queue (IQ).

From here, perform the `Issue` operation on the next two instructions, or otherwise describe what occurs if the instruction cannot be issued. (For simplicity, do not consider execution of in-progress instructions in the other RSes, but rather simply issue with respect to the next-in-line instructions.)

***Answer and Explanation***:

<center>
<img src="./assets/07-021A.png" width="650">
</center>

The next instruction to be issued from the IQ is instruction `I1` (`F4 = F1 / F2`), which is issued to `RS5`, with corresponding register alias table (RAT) entry being set to `RS5`. Furthermore, note that both operands of `I1` depend on the in-progress instructions existing prior to this cycle (i.e., `F1` and `F2` via `RS4` and `RS1`, respectively).

The next instruction in the IQ after instruction `I1` is instruction `I2` (`F4 = F3 × F4`). This instruction *cannot* be issued in the current cycle, due to the RSes for the execution unit `MUL` being currently *full*. Therefore, the operation issue is currently stalled, pending availability of the next-available RS.

## 8-9. Tomasulo's Algorithm - Operation `Dispatch`

### 8. Introduction

Now, consider the operation `Dispatch`.

<center>
<img src="./assets/07-022.png" width="650">
</center>

Consider the configuration as in the figure shown above. In a given cycle, the operation dispatch must consider the **latching** of operations/results that are produced, as well as  determine which instructions are ready to execute; in a given cycle, both of these determinations occur *simultaneously*.

In the configuration shown, there is a new cycle beginning; by the end of this cycle, the next instruction to execute will be determined. At the beginning of the cycle, none of the instructions are ready for execution (i.e., there is nothing to dispatch yet).

<center>
<img src="./assets/07-023.png" width="650">
</center>

On initial broadcast of the result from register station `RS1` post-execution (i.e., in an upstream cycle), its result is received in the corresponding RSes, including `RS1` itself (which is now available following the aforementioned upstream-cycle execution using its results).

<center>
<img src="./assets/07-024.png" width="650">
</center>

Next, post-broadcast, the tag `RS1` is matched into respective operands waiting on its result. In this case, the corresponding value (`-0.29`) is replaced in the operands of `RS2`, `RS3`, and `RS4`, all of which are pending this updated result.

At this point, it is determined which RSes have sufficient information (i.e., fully populated operand values) to proceed with execution. In this case, `RS2` is still pending an operand value (`RS4`), whereas both `RS3` and `RS4` have sufficient information available now to execute. Correspondingly, the latter are sent to their respective execution units (assuming both can execute on this particular processor at this point). Upon completion of the execution, the results will be broadcasted, and this process repeats accordingly.

### 9. More than One Instruction Is Ready

During operation `Dispatch`, we have not yet considered what occurs if *more* than one instruction is ready to execute.

<center>
<img src="./assets/07-025.png" width="650">
</center>

Consider the configuration in the figure shown, wherein a broadcast (via value `-0.29` via tag `RS1`) is occurring, leading into the next cycle.

<center>
<img src="./assets/07-026.png" width="650">
</center>

As before (cf. Section 8), `RS1` is now available following previous execution, and the broadcasted value is correspondingly updated/latched (i.e., in the correspondingly pending operands of `RS2`, `RS3`, and `RS4`).

Here, `RS4` is the unambiguous candidate for the execution unit `MUL`. However, with respect to execution unit `ADD`, it is unclear which instruction to dispatch, as there are two available (`RS2` and `RS3`) but only one execution unit. (Here, we are assuming that the execution unit `ADD` can only handle one instruction per cycle.)

Ideally, the instruction should be selected such that it allows the earliest-possible execution of future instructions (thereby yielding the highest performance); however, as a practical matter, this requires *knowledge* of the future, which is not strictly feasible (and this is not particularly something that hardware is adept at, for that matter, inasmuch as hardware is only capable of analyzing the current instruction as well as perhaps a best-case "look-ahead" of 1-2 instructions in the instruction queue; but, in general, the currently queued instructions have many indeterminate results dependencies in any given cycle).

So, then, what is the appropriate manner in which to make this determination of which instruction to dispatch next? The following **heuristics** are available for this purpose:
  * ***oldest first*** - select whichever instruction has been in the corresponding RS the longest
    * All else equal, there is a relatively high probability that this instruction will provide a result that is "currently blocking / pending update"
  * ***most dependencies first*** - select whichever instruction has the most dependencies
    * This one is sensible from a "maximizing of unblocking" standpoint, however, it is also practically least feasible, as it requires searching through a lot of information (thereby requiring intensive resources, etc.)
  * ***random*** - select the next instruction randomly

Among these heuristics, ***oldest first*** is the most common/optimal.
  * Note that if the oldest is *not* sent first, then eventually executable instructions will be depleted (i.e., the remaining ones will increasingly depend more on the oldest instruction[s]). Therefore, it's not a matter of *correctness* insofar as selecting an alternate strategy to oldest first is concerned, but rather that oldest first is an effective strategy *in practice* (in particular with releasing instructions that are "blocking"). In this manner, oldest first balances out the volume of information reviewed (and corresponding resource requirements to achieve this) against critical unblocking of instructions, providing a "compromise" between the other strategies (i.e., random and most dependencies first).

## 10. `Dispatch` Quiz and Answers

<center>
<img src="./assets/07-028A.png" width="650">
</center>

Consider the configuration in the figure shown above, immediately prior to a `Dispatch` operation. Why has not `RS3` (which already has executable operand values) dispatched already prior to reaching this cycle? (Select all valid possibilities.)
  * `RS3` was issued in the previous cycle.
    * `APPLIES` - If `RS3` were indeed issued in the previous cycle (i.e., it arrived within the reservation station), then depending on when instructions for execution are selected (e.g., towards the end of the cycle), there may be a temporal "mismatch" (i.e., the next-available instruction was not ready yet at that point)
  * Another instruction was dispatched to the execution unit `ADD`.
    * `APPLIES` - This is possible, for example, if `RS1` wAas sent in the previous cycle to the execution unit; in that case, the execution unit (assumed here to only execute one instruction per cycle) would be "occupied" and therefore unable to execute `RS3`.
  * `RS2` is older than `RS3` (i.e., `RS2` precedes `RS3` in program-order), so `RS3` cannot dispatch until `RS2` does.
    * `DOES NOT APPLY` - In an out-of-order algorithm (which Tomasulo's algorithm *is* characterized by), there *is* a dispatch of an instruction as soon as its operands are ready. If this factor were of concerned, then the dispatch of the instruction could simply be delayed (i.e., even if the operands *are* ready at this point); however, note that this would yield an in-order processor, which is not desirable here (i.e., due to sub-optimal performance). In fact, the reason why this is an out-of-order processor is precisely because instructions such as `R3` *can* execute even if they are *not* the oldest one in the reservation stations.

## 11-13. Tomasulo's Algorithm - Operation `Write Result` (or `Broadcast`)

### 11. Introduction

