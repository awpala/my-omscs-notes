# ReOrder Buffer (ROB)

## 1. Lesson Introduction

We have seen (cf. Lesson 7) that processor performance can be improved substantially by reordering instructions. However, this is not always straightforward to accomplish in practice.

In real programs, **exceptions** can occur (e.g., divide by zero), which can disrupt program operation if the instructions are not executed exactly in program-order.

This lesson explains how to resolve these reordering issues when such exceptions do occur.

## 2. Exceptions in Out-of-Order Execution

Consider **exceptions** occurring in out-of-order execution, which as noted previously (cf. Lesson 7) is a limitation of Tomasulo's algorithm, insofar as its application to modern processors is concerned.

<center>
<img src="./assets/08-001.png" width="650">
</center>

| Instruction Label | Instruction | Cycle of `Issue` | Cycle of `Dispatch` | Cycle of `Write Result` |
|:--:|:--:|:--:|:--:|:--:|
| `I1` | `DIV  F10, F0, F6` | `C1` | `C2` | `C42` |
| `I2` | `L.D F2, 45(R3)` | `C2` | `C3` | `C13` |
| `I3` | `MUL F0, F2, F4` | `C3` | `C14` | `C19` |
| `I4` | `SUB F8, F2, F6` | `C4` | `C14` | `C15` |

(***N.B.*** Assume here that operation `DIV` requires `40` cycles to execute, operation `L.D` requires `10` cycles to execute, operation `MUL` requires `5` cycles to execute, and operation `SUB` requires `1` cycle to execute.)

Consider the four instructions along with their corresponding timing analysis, as shown above.
  * By inspection, the instructions can issue in successive cycles (i.e., `C1`, `C2`, etc.)
  * Instruction `I1` dispatches in cycle `C2`, and then executes in cycle `C42`.
  * Instruction `I2` dispatches in cycle `C3`, and then executes in cycle `C13`.
  * Instruction `I3` is dependent on operand `F2` (via instruction `I2`) and therefore cannot dispatch until cycle `C14` (following write result of instruction `I2`), and then executes in cycle `C19`.
  * Instruction `I4` is dependent on operand `F2` (via instruction `I2`) and therefore cannot dispatch until cycle `C14` (following write result of instruction `I2`), and then executes in cycle `C15`.

Furthermore, assume that `F6` contains `0`, resulting in a **divide-by-zero** exception/error, which is detected in cycle `C40`.
  * In this scenario, what *should* happen is that the processor will save the program counter (PC) for this instruction, and then jump to an **exception handler**; if this exception handler comes back, then the program should return to this instruction and commence execution from there.
  * However, in *reality*, execution of the subsequent instructions (`I2`, `I3`, and `I4`) has already been performed by this point, with the results being written back accordingly (i.e., only instruction `I1`'s result `F10` is still indeterminate at this point). By this point (i.e., cycle `C40`), if jumping to the exception handler, then upon its return, the operand register `F0` of instruction `I1` will already have the corresponding value produced by (downstream) instruction `I3`; therefore, even with a handled error for `F6`, the resulting computation of the result `F10` will be (semantically) ***invalid***.

A similar issue can occur if a load instruction (e.g., instruction `I2`) encounters a **page fault**: The page is paged back from the disk, but upon returning to execute the load instruction itself, subsequent instructions may have already completed execution, thereby precluding the ability to proceed with the program properly.

Therefore, this ***issue*** of handling exceptions precisely is a fundamental flaw in Tomasulo's algorithm (at least as originally implemented).

## 3. Branch Misprediction in Out-of-Order Execution

Another ***issue*** with Tomasulo's algorithm is the occurrence of **branch mispredictions**. How, then, can recovery from branch predictions be achieved?

<center>
<img src="./assets/08-002.png" width="650">
</center>

```mips
  DIV R1, R3, R4    # I1 - DIV requires 40 cycle
  BEQ R1, R2, Label # I2
  ADD R3, R4, R5    # I3
  ⋮
```

Consider the program shown above. Here, the branch `BEQ ...` in instruction `I2` *can* be predicted, however, it takes a long time (i.e., `40` cycles) to detect a misprediction. In the meantime, instruction `I3` is fetched as usual (i.e., the branch is taken), and intruction `I3` subsequently completes execution; in this case, register `R3`'s result is already written.

However, once a misprediction of the branch is detected (i.e., `40` to` 50` cycles later), the expected behavior of the program is such as if the instruction `I3` were never executed in the first place, but rather commence with fetching instructions beginning from `Label` (i.e., `DIV`). But that becomes impossible, because `R3` has already been updated by that point, and therefore instruction `I1` is using the unintended/incorrect value for its operand `R3`.

Observe that the issue described here is reminiscent of that described previously for exceptions (cf. Section 2): An instruction can complete execution and write its result to a register *before* preceding (program-order) instructions have been fully ***verified*** (and in the case of branching, before it is even determined whether or not the instruction should have actually been executed in the first place).

```mips
  DIV R1, R3, R4    # I1 - DIV requires 40 cycle
  BEQ R1, R2, Label # I2
  ADD R3, R4, R5    # I3
  ⋮
  DIV ...
```

A final issue arises due to so-called **phantom exceptions**. Consider the same program as shown above, with an additional downstream instruction `DIV ...` (still within the same branch). Assume there is a misprediction resulting in instruction `I3` *not* being executed (i.e., branch *not* taken). An issue arises if the downstream instruction `DIV ...` generates an exception, the the exception is indeed triggered irrespectively of the fact that it was not supposed to be executed (i.e., due to this branch not being taken). Therefore, this unnecessary exception-handling overhead will be incurred, without realizing it before its too late to detect in the normal program execution.

To reiterate, a ***key concern*** with exception handling is that there must be certainty that an exception is in fact necessary prior to executing it.

## 4. Correct Out-of-Order Execution

<center>
<img src="./assets/08-003.png" width="650">
</center>

Now, consider how **out-of-order execution** *should* be performed appropriately.
  * The program itself should be executed ***out-of-order*** (i.e., in intended program-order).
  * Results should be broadcasted ***out-of-order***.
  * Values should be deposited to registers ***in-order***.
    * This is ***necessary***, because if register values are deposited out-of-order, then if it is subsequently discovered that one of the earlier instructions should *not* have been performed (e.g., it generates an exception, it has a branch misprediction, etc.), then this instruction has already deposited the value to the register previously when it should not have; therefore, by depositing in-order, this situation is prevented. By implication, by the time of depositing the value, all previous instructions have already finished successfully and there is no disruption to the program's semantics.
    * In Tomasulo's algorithm, values are *not* deposited to registers in-order, and therefore the aforementioned issues arise accordingly.

In order to resolve this issue, a structure called the **reorder buffer (ROB)** is used, characterized as follows:
  * Even after the instruction is issued, the ROB ***remembers*** the program-order.
  * The ROB ***retains*** the results of the instructions until they are safe to write to their respective registers.

Therefore, rather than simply writing to registers on an ad hoc basis immediately following production of the results/values, the results first enter the ROB. The ROB in turn is reviewed in-order, with results correspondingly deposited into their respective registers appropriately. Once the result is deposited from the ROB, only then is the instruction's execution completed.

## 5-6. ReOrder Buffer (ROB): Parts 1-2

### 5. Part 1

Now that we know that the reorder buffer (ROB) is *needed* in order to hold instructions until they are ready to execute in program-order, consider now how the ROB itself is structured.

<center>
<img src="./assets/08-004.png" width="450">
</center>

The ROB is a table of entries, as in the figure shown above. Each entry records at least three fields:
  * `VAL` → the value produced by the instruction (i.e., not the value written to the actual register, but rather upon completed execution of the instruction, the ROB's `VAL` is the target of the corresponding broadcast operation)
  * `DONE` → a bit to record whether or not the value `VAL` is valid
    * The ROB entry for the instruction is received *before* the result is actually written to the target register, therefore this must be tracked accordingly
  * `REG` → by the end of execution, the result itself must be written to an actual target register, which is recorded in this field correspondingly

The ROB in the figure shown above can hold up to eight instructions. Furthermore, the instructions are maintained in the ROB in ***program-order***. Correspondingly, two pointers are required:
  * `Issue` → indicates where the next instruction will be placed upon the next-occurring issue operation
  * `Commit` → what is the next-executable instruction in program-order 

Therefore, in the ROB in the figure shown above, the valid (i.e., in program-order) instructions are `I1` (oldest) through `I5` (newest), while newer instructions are added to `I6` and `I7`.

### 6. Part 2

Now that the structure of the reorder buffer (ROB) is more familiar, consider now how its actually ***used***.

<center>
<img src="./assets/08-005.png" width="650">
</center>

Consider the configuration as in the figure shown above. There is an instruction `R1 = R2 + R3` currently in the instruction queue (IQ). Here, we will analyze what occurs with this instruction, from its issuing from the IQ up through its eventual commit to the ROB (in such a processor having the ROB available).

On instruction ***issue***:
  * Retrieve an available reservation station (RS) and place the instruction into it (denoted by green arrow in the figure shown above)
  * The instruction is placed into the ROB, at the position of the pointer `Issue` (i.e., at index `6`)

<center>
<img src="./assets/08-006.png" width="650">
</center>

Upon placement of the instruction into the ROB, the pointer `Issue` is advanced by one position, as in the figure shown above.

Furthermore, as per Tomasulo's algorithm, the register allocation table (RAT) is updated accordingly with the entry for the instruction. However, rather than pointing to the RS itself, the RAT instead records the entry of the ROB `ROB6` (as denoted by purple arrow in the figure shown above).

<center>
<img src="./assets/08-007.png" width="650">
</center>

The RS is correspondingly populated with the values of its operand, including the entry `ROB6` via the ROB (as in the figure shown above). Furthermore, the entry `ROB6` records the target register `R1`, and designates the bit `Done` as `0` (i.e., instruction is still pending execution).

Now, the instruction `ADD` waits on its operands (i.e,. pending capture/latch, for subsequent dispatch to the execution unit `ADD`), as previously demonstrated with respect to Tomasulo's algorithm (cf. Lesson 7).

Eventually, once the instruction `ADD` is able to ***dispatch***, this occurs as follows:
  * Once the operands are ready, send to the execution unit (i.e., `ADD`)
  * Furthermore, free the RS upon dispatch
    * ***N.B.*** Previously, with Tomasulo's algorithm (i.e., without ROB), it was necessary to *wait* for the RS to release all the way until the instruction result is broadcasted (i.e., due to the RS serving as the tag for the result); however, this is obviated by the ROB entry itself, which instead provides this same feature, without otherwise encumbering the RS. In this manner, the RS is relieved of this additional tagging responsibility, now only serving in its primary role of capturing in-progress operands and determining when/which instructions to dispatch at the appropriate times.

Therefore, on instruction execuction via the execution unit `ADD`, the instruction `ADD` carries the tag `ROB6` for subsequent broadcast.

## 7. Free Reservation Stations Quiz and Answers

<center>
<img src="./assets/08-009A.png" width="650">
</center>

We have seen that the reorder buffer (ROB) changes when a reservation station (RS) is made available. Now, suppose an instruction *cannot* issue because there is no available RS for it. In which of the following configurations is the more likely? (Select one.)
  * Configuration 1 - `CORRECT`
    * No ROB available (but otherwise following Tomasulo's algorithm)
    * Two `ADD` and two `MUL` RSes available
  * Configuration 2
    * Has ROB available
    * Two `ADD` and two `MUL` RSes available

***Explanation***:

If the instruction cannot issue due to no available RSes, this means that all of the RSes are currently busy. Therefore, with a processor *lacking* a ROB, the RSes are retained from the time of instruction issue until the instruction broadcasts its result. Consequently, issuing of an instruction once the RSes are busy will necessitate waiting until the next instruction broadcast the result.

Conversely, in a ROB-based processor, all else equal (i.e., otherwise with the same number and types of RSes available), the RSes are occupied simultaneously with instruction issue, but then correspondingly freed simultaneously with dispatch of the instructions for execution (i.e., the RSes are freed relatively sooner compared to the non-ROB-based processor, all else equal). This in turn allows the next-available instruction to occupy the next-available RS.

## 8. ReOrder Buffer (ROB): Part 3

<center>
<img src="./assets/08-010.png" width="650">
</center>

Eventually, the execution unit `ADD` produces a result which is subsequently ***broadcasted***, as in the figure shown above. This operation broadcast occurs exactly as described previously in Tomasulo's algorithm (cf. Lesson 7), except that the associated tag (i.e., `(ROB6)`) is that of the reorder buffer (ROB) entry, rather than of the reservation station (RS) (which has already been freed by this point).

Upon broadcasting of the tagged value (i.e., `(ROB6) 15`), it is fed back to the corresponding RSes (which they capture/latch), just as before with Tomasulo's algorithm.

*Without* the ROB, it would also be necessary to capture the result in a register (i.e., via REGS), and correspondingly updating (i.e., writing back to) the register allocation table (RAT) to point to this register.

<center>
<img src="./assets/08-011.png" width="650">
</center>

Conversely, with a ROB, there is no such write back operation to REGS at this point yet, but rather the write occurs to the ROB (i.e., with a corresponding update to the DONE bit set to `1`), as in the figure shown above. Furthermore, the RAT retains the value of the ROB entry (i.e., rather than updating the RAT to point to REGS).

<center>
<img src="./assets/08-012.png" width="650">
</center>

With the ROB, there is still a pending matter: While the result has been logged and the computation has been completed at this point, it has not yet been deposited into REGS; therefore, this is the last-remaining step, as in the figure shown above.

This additional step comprises the operation `Commit`. Here, all of the previous instructions are first committed, i.e., in each cycle, it is tested whether the next instruction at the pointer `Commit` (e.g., at index `1` of the ROB per the figure shown above) is completed, and if so, the pointer `Commit` is repositioned accordingly (i.e., at index `6`), and determining whether the instruction in question there is `Done` (i.e., it *is* in this case, via the corresponding bit set to `1`).

Upon this determination, the operation `Commit` itself involves taking the stored value (i.e., `15`) and writing it to the corresponding register in REGS (i.e., `R1`). Furthermore, the RAT is correspondingly updated to now reflect the updated entry in REGS (i.e., rather than pointing to the ROB); effectively, the process of updating the RAT is now moved from the operation `Broadcast` to that of `Commit`. Lastly, upon committing the instruction, the pointer `Commit` is updated the corresponding position (i.e., index `7`, as denoted by the purple arrow in the figure shown above).

That concludes the step-by-step examination of the ROB for one instruction. As is readily apparent, many of the same steps are reminiscent of those in Tomasulo's algorithm (cf. Lesson 7), with minor ***variations***, recapped as follows:
  * Pointing the RAT to the ROB entry rather than to the RS
  * Writing to the ROB on broadcast rather than directly to REGS
  * The RS is freed on dispatch rather than on broadcast
  * Additional operation `Commit` is included to coordinate between the ROB, RAT, and REGS

## 9. Hardware Organization with ROB

<center>
<img src="./assets/08-013.png" width="650">
</center>

Consider now what ***hardware structures*** exist within the reorder buffer (ROB) itself, as in the figure shown above.
  * As before, there is an **instruction queue (IQ)**, from which instructions are dispatched into corresponding **reservation stations (RS)**
  * As before, there is a **register allocation table (RAT)**, which can point to either a **register file (RF)** or to a renamed/tagged version of the instruction within the RS (i.e., pending corresponding write to the RF)

<center>
<img src="./assets/08-014.png" width="650">
</center>

Following Tomasulo'a algorithm from before (cf. Lesson 7), RAT entries *not* pointing to the RF would otherwise point to the corresponding RSes; however, with ROB, there is the new additional structure of the **reorder buffer (ROB)** itself present, as in the figure shown above.
  * The pointers `HEAD` (where the next instruction that issues is stored) and `TAIL` (the last instruction designated for commit) delimit the range within the ROB corresponding to currently-executing instructions.
  * Furthermore, the RAT entries which are not currently pointing to the RF are instead correspondingly pointing to the entries in the ROB (as designated by purple arrows in the figure shown above) for the instructions that produce the corresponding values in question.

## 10. ROB Quiz and Answers

<center>
<img src="./assets/08-016A.png" width="650">
</center>

The reorder buffer (ROB) is required in order to (Select all applicable choices):
  * Remember the program order
    * `APPLIES` → The ROB is the only intermediary between issue (which is performed in program-order) and commit (which is also performed in program-order) which preserves program-order (whereas other intermediate steps between these generally occur out-of-order)
  * Temporarily store the instruction's result
    * `APPLIES` → The ROB stores the instruction's result between the time when the instruction is produced (i.e., when a broadcast occurs on the bust) and the time when the instruction's result is committed to the register file.
  * Serve as the name (tag) for the result
    * `APPLIES` → With Tomasulo's algorithm, the reservation station served this role; however, with a ROB configuration, the ROB entry is the one performing this role instead
  * Store source operands until dispatch
    * `DOES NOT APPLY` → This role is still performed by the reservation station, even with the ROB configuration
  * Determine which instruction goes to which execution unit
    * `DOES NOT APPLY` → The ROB is typically unified (i.e., *all* instructions go to the ROB, but they generally receive different/distinct entries in the ROB itself); therefore, it is evident/unambiguous which execution unit the instructions are directed to, because different execution units have distinct/dedicated reservation stations, and thus when an instruction is issued, it is sent to the *intended* set of reservations stations (which in turn dictate the corresponding execution unit)

## 11. Branch Misprediction Recovery

Recall that the reorder buffer (ROB) is necessary in order to have precise exceptions, as well as to facilitate recovery from branch mispredictions; the latter is the topic of section.

<center>
<img src="./assets/08-017.png" width="650">
</center>

Consider the following program (as in the figure shown above, which includes the corresponding hardware configurations):
```mips
LD  R1, 0(R1)
BNE R1, R2, Label # <- Misprediction occurs via `R1 == R2` (branch not taken)
ADD R2, R1, R1    # <- Assume the program proceeds here due to misprediction
MUL R3, R3, R4
DIV R2, R3, R7
```

Assume that the program has a branch misprediction, whereby the subsequent instructions (denoted by red in the figure shown above) are executed despite an actual branching (i.e., to `Label`) being intended.

Immediately prior to the first instruction, the hardware state is as in the figure shown above, with the pointers `Issue` and `Commit` of the ROB being co-located. Furthermore, both the register file (REGS) and register allocation table (RAT) are empty.

<center>
<img src="./assets/08-018.png" width="650">
</center>

First, the instruction `LD` is issued, as in the figure shown above.
  * In the ROB, the pointer `Issue` is advanced by a position, and the result `R1` for this instruction is placed in the corresponding ROB entry
  * The RAT is updated with the corresponding ROB entry `ROB1`

<center>
<img src="./assets/08-019.png" width="650">
</center>

Next, the instruction `BNE` is issued, as in the figure shown above.
  * In the ROB, the pointer `Issue` is advanced by a position, and since there is no output/result from this instruction, the ROB records a null entry (denoted by `/` in the figure shown above)
  * There is no corresponding update in the RAT (i.e., no pending result to record)

<center>
<img src="./assets/08-020.png" width="650">
</center>

Next, instructions which should *not* have been issued (i.e., due to branch misprediction) are issued, starting with `ADD`, as in the figure shown above.
  * The result `R2` for this instruction is placed in the corresponding ROB entry
  * The RAT is updated with the corresponding ROB entry `ROB3`

<center>
<img src="./assets/08-021.png" width="650">
</center>

Next, the instruction `MUL` is issued, as in the figure shown above.
  * The result `R3` for this instruction is placed in the corresponding ROB entry
  * The RAT is updated with the corresponding ROB entry `ROB4`

<center>
<img src="./assets/08-022.png" width="650">
</center>

Next, the instruction `DIV` is issued, as in the figure shown above.
  *  In the ROB, the pointer `Issue` is advanced by a position, and the result `R2` for this instruction is placed in the corresponding ROB entry
  * The RAT is updated with the corresponding ROB entry `ROB5`, which overwrites the previous entry for `R2` (cf. instruction `ADD`)

<center>
<img src="./assets/08-023.png" width="650">
</center>

Now, suppose that the initial instruction `LD` takes a long time to produce a value (e.g., due to a cache miss). The branch (i.e., via instruction `BNE`) cannot complete until the `LD` is completed, and correspondingly the mispredicted instruction `ADD` is similarly "bottlenecked" by `LD`; however, the instruction `MUL` *can* complete because its operands (`R3` and `R4`) are not produced by any of the aforementioned upstream instructions.

Therefore, the instruction `MUL` might produce a value (e.g., `15`, as in the figure shown above), which it *is* otherwise capable of writing to REGS; however, once it is discovered that the branch is mispredicted, this would necessitate somehow "undoing" this operation `MUL`. Correspondingly, in a ROB-based processor, this result is instead recorded in the ROB entry, with a corresponding setting of the `Done` bit.

<center>
<img src="./assets/08-024.png" width="650">
</center>

Similarly, the instruction `DIV` may eventually proceed, generating a corresponding result (e.g., `2`), which it records in the ROB accordingly (as in the figure shown above). As with the instruction `MUL`, this obviates an unintended "premature write" to REGS, given that this instruction results from a misprediction.

<center>
<img src="./assets/08-025.png" width="650">
</center>

Eventually, the instruction `LD` completes, yielding a result (i.e., `700`), as in the figure shown above. Correspondingly, the value is recorded in the ROB and the bit `Done` is set accordingly. Consequently, the pointer `Commit` is advanced, and the result is written to REGS, thereby updating the RAT accordingly (i.e., to point to the REGS entry).

<center>
<img src="./assets/08-026.png" width="650">
</center>

Now, suppose that the instruction `BNE` takes longer to produce a result than is required for `ADD`, as in the figure shown above. Consequently, instruction `ADD` produces a result (i.e., `3`) and updates the ROB entry and corresponding `Done` bit accordingly. However, here, this result is *not* written to REGS (nor would this have been done if following Tomasulo's algorithm without a ROB), due to the renaming of `R2` in RAT (i.e., as `ROB5` in the ROB configuration, or equivalent tagging in non-ROB-based Tomasulo's algorithm).

Eventually, the branch is resolved, and it is determined that a misprediction has occurred, as in the figure shown above. Correspondingly, the instruction `BNE` is marked as `Done` in the ROB, with the program proceeding with fetching instructions correctly in program-order (i.e., taking the corresponding branch, as designated by `Label`).

<center>
<img src="./assets/08-027.png" width="650">
</center>

However, the question still remains: How do we remove the incorrect instructions (i.e., those produced from the branch misprediction, as denoted by red in the figure shown above)?

To address this matter, the ROB entry is annotated accordingly (i.e., via `!`, as in the figure shown above). Furthermore, rather than "fixing" the in-progress entries in the ROB, we proceed by simply fetching these "wrong" instructions, as it is still uncertain how to eliminate these instructions until the pointer `Commit` reaches the branch point.

Finally, upon committing the instruction `BNE`, it is determined that the wrong instructions have been fetched (i.e., the program counter [PC] that *should* have been created by the branch differs from the PC that was actually used, resulting in the misprediction). Consequently, the pointer `Commit` is advanced (as in the figure shown above), which does *not* result in any writing to REGS, however, due to the misprediction, the **recovery** is commenced *prior* to restarting the fetch from the correct place (i.e., in a manner ensuring in program-order).

<center>
<img src="./assets/08-028.png" width="650">
</center>

To perform this **recovery** operation, in a ROB-based processor, at the point at which the operation `Commit` has reached the branch instruction (i.e., `BNE`), REGS contains *exactly* the values that are required immediately prior to entering the branch instruction (as in the figure shown above), i.e., all of the corresponding instructions prior to the branch have been committed accordingly (with their updates reflected in REGS), while the same has *not* been done for the mispredicted instructions yet by this point.

Therefore, to ***undo*** the incorrect/mispredicted instructions, there are two necessary resolution measures.
  * Reverse the issuing of these instructions by simply making the ROB empty at these points (i.e., the pointer `Issue` is moved to the location of pointer `Commit`, as in the figure shown above), with corresponding undoing of the `Done` bits to invalidate these entries in the ROB.
  * Furthermore, REGS is updated accordingly with the preexisting values in the RAT. The ROB entries in the RAT are invalidated accordingly, with the RAT entries instead pointing directly to REGS (recall that the state of REGS immediately prior to entering the branch is *correct*).

Effectively, the current state is such that the mispredicted instructions have never occurred in the first place, and the program can now proceed with fetching instructions correctly (i.e., in program-order).

As is readily apparent, with a ROB-based processor, out-of-order instruction execution can be achieved in such a manner that correct in-program-order execution is still maintained.

Overall, the **recovery** in a ROB-based processor consists of the following features:
  * Making the RAT entries point to the corresponding REGS entries, thereby erasing/invalidating the renaming in the RAT resulting from mispredicted/incorrect instructions
  * Emptying out the mispredicted/incorrect ROB entries in the ROB after committing (i.e., via corresponding relocation of the pointer `Issue`)
  * Emptying out mispredicted/incorrect instructions in their respective reservation stations and correspondingly preventing execution units (e.g., `ALU`, etc.) from broadcasting results in the future

## 12. ROB and Exceptions
