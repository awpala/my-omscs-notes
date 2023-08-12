# Memory Ordering

## 1. Lesson Introduction

We have seen (cf. Lesson 8) that an out-of-order processor will track when one instruction uses a register value produced by another.

However, load and store instructions can access the *same* memory location without using the same register to perform the access; this lesson explores *how* exactly this can be done correctly in an out-of-order processor.

## 2. Memory Access Ordering

<center>
<img src="./assets/09-001.png" width="650">
</center>

We have seen (cf. Lessons 7 and 8) that reorder buffer (ROB) and Tomasulo's algorithm can be used to enforce the order of **dependencies** on registers between instructions.

However, a ***question*** still remains: What about **memory access** ordering?
  * There are load and store instructions available; do they really need to be performed *strictly* in program order, or can these be reordered, too?

So far, we have eliminated **control dependencies** using **branch prediction**.

Furthermore, we have eliminated **false dependencies** (i.e., dependencies via registers) using **register renaming**.

Next, we will see how to obey **read-after-write (RAW) register dependencies** using **Tomasulo-like scheduling**.
  * Here, we have instructions waiting in reservation stations until their dependencies have been satisfied, at which point they can proceed to execution out of program order.

Note that the data-dependency handling performed thus far (i.e., false dependencies and RAW register dependencies) only pertain to **register dependencies**, in which one instruction produces a value in a register used by another register. But what about memory dependencies?

Consider the following program:

```mips
SW R1, 0(R3)
LW R2, 0(R4)
```

Here, there may be a dependency between the memory value written by `SW` (store) and that read by `LW` (load).
  * For example, if registers `R3` and `R4` hold the ***same*** address, then `LW` must get the value from `SW`, in which case these instructions must be performed ***in order***.
  * Conversely, if `R3` and `R4` hold ***different*** addresses, then (as previously seen with registers) it is not strictly necessary to maintain program-order between these memory accesses.

Nevertheless, we have not yet seen how to handle out-of-order memory access; correspondingly, this topic will be the focal point of this lesson.

## 3. When Does Memory Write Happen?

<center>
<img src="./assets/09-002.png" width="650">
</center>

The first point we must consider is: For **store instructions**, how does the **memory write** operation actually happen? This occurs at **commit**.
  * It is necessary for write to memory to occur at commit, because it is otherwise ***unsafe*** to update memory at any point ***before*** the instruction commits.
  * Any instruction that has not yet committed is subject to being **cancelled** (e.g., due to branch misprediction or occurrence of an exception).
  * Therefore, performing a memory write prematurely may later result in a necessary memory "unaccess" (i.e., restore the old memory value), which is extremely difficult to perform. To avoid this, memory writes and stores are delayed until commit.

Does this mean that **memory load** also must wait until commit before retrieving the data (i.e., at which point only *then* is the data present in memory)? In other words, if we *write/store* instructions at commit, then where does data get *loaded* from? (Furthermore, it is desirable for loads to occur as early as possible, in order to complete these loads in order to supply the data to subsequent instructions depending on the data.)
  * For this purpose, we introduce the structure called the **load-store queue**, which maintains all of the loads and stores.

Next, we will see how loads get data from the stores in this manner.

## 4-5. Load-Store Queue (LSQ)

### 4. LSQ Part 1

Because the loads in our processor must be performed as soon as possible (i.e., for immediate availability to downstream instructions which are dependent on the data), while stores do not write to memory until commit, the **load-store queue (LSQ)** is required in order to supply the values from stores to loads.

<center>
<img src="./assets/09-003.png" width="650">
</center>

This load-store queue (LSQ) (shown in the figure above) is just like the reorder buffer (ROB), meaning that it has entries placed in order, which are subsequently removed at commit. However, in the load-store queue (LSQ), we only place load and store instructions there.
  * The bit `L/S` indicates whether the instruction is a **load** (`L`) or **store** (`S`).
  * The field `Addr` specifies which **address** the instruction is accessing.
  * The field `Val` indicates the **value** that the instruction stores or loads.
  * The field `C` indicates whether or not the instruction has been completed.

Consider the following program:

```mips
LW R1, 0(R1) # I1
SW R2, 0(R3) # I2
LW R4, 0(R4) # I3
SW R5, 0(R0) # I4
LW R5, 0(R8) # I5
```

<center>
<img src="./assets/09-004.png" width="250">
</center>

Initially, the load-store queue (LSQ) is empty, as shown above. It is subsequently populated in program-order.

<center>
<img src="./assets/09-005.png" width="350">
</center>

The first instruction (`I1`) accesses the computed memory address `104`. Because there are no previous store instructions, this instruction fetches directly from memory (`MEM`).

<center>
<img src="./assets/09-006.png" width="350">
</center>

The second instruction (`I2`) stores the value `15` at computed address of `204`. The instruction is marked in field `C`; essentially, the instruction is essentially "delayed," and therefore it remains in the load-store queue (LSQ).

<center>
<img src="./assets/09-007.png" width="450">
</center>

The third instruction (`I3`) accesses the computed memory address `204`. In general, for every load instruction, the load-store queue (LSQ) is checked to determine if any (upstream) instruction matches the computed address.
  * If there is ***no*** matching store instruction for that address (e.g., as seen previously for instruction `I1`), then the load proceeds to access memory (`MEM`) directly.
  * Conversely, if there ***is*** a matching store instruction for that address, memory (`MEM`) is *not* directly access, but rather **store-to-load forwarding** is performed (i.e., as in this case for instruction `I3`), whereby the corresponding ***value*** from the previous store instruction (i.e., `15` in the case of instruction `I2` forwarded to `I3`) is also produced by the current load instruction in question, *without* a corresponding memory (`MEM`) access.

***N.B.*** Store-to-load forwarding assumes that at the time of the load instruction, the upstream store instruction(s) has/have already been completed, and therefore the computed addresses are known/available at the point of the load instruction.

### 5. LSQ Part 2

<center>
<img src="./assets/09-008.png" width="450">
</center>

Proceeding similarly to the subsequent instructions (i.e., `I4` and `I5`), observe that it is entirely possible for the store instruction (`I4`) to *not* have a computed address available at the point at which the load instruction (`I5`) produces its own computed address (e.g., `174`).

The possible resolution **options** in such a scenario are as follows:
  * 1 - **in-order** execution of load and store (i.e., the load instruction is not allowed to execute until all previous instructions have been completed).
    * This guarantees that at the point of execution of the load instruction, all of the store addresses and values are available.
    * However, in reality, loads cannot proceed without resolved upstream stores. For example, if the load instruction in `I1` were a cache miss (requiring a corresponding resolution to proceed), then all of the downstream instructions would have to ***wait*** for this resolution to occur. 
  * 2 - Such ***waiting*** can be reduced by not simply waiting for *all* upstream instructions to resolve, but rather simply waiting for only all previous **stored addresses** to become known/computed.
    * Once all stored addresses are known, the load address can be compared, and the instruction can be consequently determined (i.e., either memory [`MEM`] is accessed if nothing matches, the value is retrieved from the corresponding store if it is available, or we wait for the store to produce the value if the address matches but the store has not yet computed the value).
  * 3 - Alternatively, the *most aggressive* option is to simply **proceed** with the load instruction anyways.

<center>
<img src="./assets/09-009.png" width="450">
</center>

Following the third option, once the address is computed for the load instruction (e.g., `174`), the computed addresses of the previous store instructions are checked as follows:
  * If one if the store instructions matches, then we ***wait*** for it (i.e., clearly, fetching from memory [`MEM`] is inappropriate in this case).
  * Otherwise, if none of the store instructions match, then we ***ignore*** the fact that some of them might match once their addresses are resolved; in this case, the load instruction will fetch from memory (`MEM`) (denoted by red arrow in the figure shown above). At this point, one of two things can occur:
    * 1 - The store instruction resolves to an address (e.g., `74`, denoted by green font in the figure shown above), in which case we confirm that the load instruction was correspondingly completed.
    * 2 - The store instruction computes the same address (i.e., `174`, denoted by magenta font in the figure shown above), in which case the load instruction has loaded the ***incorrect*** value from memory; in this case, we must **recover** accordingly (i.e., the load instruction loaded the incorrect value, thereby possibly inadvertently supplying it to other downstream instructions).
      * In this case, when the store instructions produce an address, we then check whether any of the downstream load instructions match the address and have subsequently completed execution; if so, then the load instruction is requested to be "redone" (and correspondingly for the downstream instructions), thereby resolving the issue of the load instruction loading the incorrect value.

Most modern processors today use the third option ("go anyway") because it yields the ***best performance***. In practice, if we permit the load instructions to proceed without otherwise waiting for the store instructions, it turns out that most of the time this results in the ***correct*** instructions being executed, achieving a net speedup in performance (i.e., less overall "downtime" due to waiting on store instructions, despite the occasionally incurred cost of recovery in the case of an invalid assumption regarding the validity of the upstream store instruction's address).
  * Furthermore, there are also entire schemes around attempting to predict when such an incorrect assumption will occur, thereby proceeding with load instructions only if this occurrence is unlikely.

## 6. Out-of-Order Load-Store Execution

<center>
<img src="./assets/09-010.png" width="450">
</center>

Now, consider what occurs with out-of-order execution of load and store instructions, following the "aggressive" approach of load instructions fetching from memory as soon as their computed address is known, if there is no preceding store instruction that has also computed the same address at the point of execution (which later turns out to resolve to the same address after all).

Consider the following example program, a sequence of instructions in the load-store queue (LSQ):

```mips
LOAD  R3 = 0(R6)   # I1
ADD   R7 = R3 + R9 # I2
STORE R4 → 0(R7)   # I3
SUB   R1 = R1 - R2 # I4
LOAD  R8 = 0(R1)   # I5
```

In an out-of-order processor, when attempting to execute these instructions, the following might occur. (Assume for purposes of discussion that all of these instructions have already been fetched, decoded, etc.)

<center>
<img src="./assets/09-011.png" width="450">
</center>

For instruction `I1` (as in the figure shown above), because the `LOAD` only depends on `R6` (which is not otherwise produced by any other instructions), it can ***dispatch***. Therefore, it fetches from memory, and eventually returns the corresponding value for `R3`.

However, in this scenario, there is a ***cache miss***. Consequently, the `LOAD` instruction will be delayed, pending reconciliation of the correct memory value, and therefore instruction `I1` *cannot* be dispatched until this occurs, thereby impacting the execution of downstream instructions `I2` and `I3` (via corresponding dependency on `R3`).

<center>
<img src="./assets/09-012.png" width="450">
</center>

Meanwhile, instruction `I4` *can* be dispatched (as in the figure shown above), thereby producing `R1` very quickly.

<center>
<img src="./assets/09-013.png" width="450">
</center>

At this point, `I5` *can* also subsequently dispatch (as in the figure shown above), which in this scenario results in a ***cache hit***. Consequently, the `LOAD` instruction is able to produce `R8` very quickly, thereby supplying it to downstream instructions accordingly.

<center>
<img src="./assets/09-014.png" width="450">
</center>

At this point in the program (as in the figure shown above):
  * Instructions `I4` and `I5` have completed, and are pending commits
  * Meanwhile, upstream instructions `I1`, `I2`, and `I3` are still pending execution, waiting on the instruction `LOAD` (`I1`) to complete 

<center>
<img src="./assets/09-015.png" width="550">
</center>

Eventually, the instruction `LOAD` (`I1`), completes (as in the figure shown above). The resulting value `R3` is subsequently fed into instruction `I2` (which in turn completes execution promptly thereafter), and similarly `R7` is fed from instruction `I2` to `I3` for its subsequent execution.

Assuming the resulting address from instruction `I5` was `X`, then let's also assume in this scenario that the resulting address from instruction `X` is *not* `X` (i.e., the address addressed by `R7` in instruction `I3` is *different* from the address addressed by `R1` in downstream instruction `I5`). In this case, there will be *no* issue/conflict, since the instruction `STORE` in `I3` stores a different/unrelated address.

<center>
<img src="./assets/09-016.png" width="550">
</center>

Conversely, consider the situation in which instruction `I3` *does* compute the value `X` for `R7` (as in the figure shown above). In this case, the value stored in `R4` in instruction `I3` is the value which downstream instruction `I5` *should* actually be using (i.e., in operand `R1`), however, `I5` has already executed by this point, using a ***stale*** value loaded from memory.

We will next discuss the resolution measures for this scenario.

## 7. In-Order Load-Store Execution

<center>
<img src="./assets/09-017.png" width="550">
</center>

The first solution to the problem encountered in the previous section is to simply avoid the strategy of out-of-order load-store execution altogether, and instead perform **in-order load-store execution**.

<center>
<img src="./assets/09-018.png" width="350">
</center>

In the case of in-order load-store execution (as in the figure shown above):
  * The `LOAD` in instruction `I1` is a ***cache miss***, resulting in a stall of the subsequent two instructions (`ADD`/`I2` and `STORE`/`I3`, respectively) pending completion of instruction `I1`.
  * The `SUB` in instruction `I4` completes, providing the address `R1` for subsequent `LOAD` in instruction `I5`. At this point, the load-store queue checks to determine whether any preceding instructions might resolve to the same address; or, even worse, whether *all* of the preceding instructions have even completed in the first place (i.e., if this is *not* the case, then the downstream `LOAD` will be stalled anyhow, pending completion of the upstream instructions). Consequently, the `LOAD` in instruction `I5` does ***not*** fetch from memory, despite having a resolved address available (i.e., `R1`).

<center>
<img src="./assets/09-019.png" width="450">
</center>

Eventually, the cache miss in instruction `I1` is resolved, and the instruction `LOAD` is able to proceed (as in the figure shown above). Consequently, instruction `I2` is able to computed `R7` promptly thereafter, and similarly instruction `I3` can now perform its corresponding instruction `STORE`. Furthermore, as instruction `I1` completes, instruction `I4` completes subsequently thereafter.

<center>
<img src="./assets/09-020.png" width="450">
</center>

Note that the `STORE` in instruction `I3` is not considered "completed" when it commits, but rather when its address operand `R7`becomes known, as well as computing the target address (i.e., `R4`); only at this point can the `LOAD` in instruction `I5` proceed, by checking the preceding instructions to determine whether any `STORE`s produced the necessary operand values (i.e., `R1`). Therefore, instruction `I5` can only execute after `I3`, which in turn only completes execution *after* the `LOAD` in instruction `I1` is completed.

Effectively, most of the instructions are executed *out-of-order*, however, load and store instructions still proceed in-order. Of course, it is readily apparent that this is suboptimal if *different*/*distinct* addresses are involved among the load and store instructions, as this introduces otherwise unnecessary execution delays for downstream instructions not otherwise dependent on the upstream instructions' resolved addresses. This problem is further exacerbated if in addition to this delay, the downstream load instructions (e.g., `I5`) result in cache misses, thereby introducing additional execution delays.

Therefore, this strictly in-order load-store execution is *not* a very high-performance resolution strategy, however, it does ensure program correctness.

## 8. Memory Ordering Quiz and Answers
