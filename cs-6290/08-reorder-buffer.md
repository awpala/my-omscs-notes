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

### 6. Part 2

## 7. Free Reservation Stations Quiz and Answers

## 8. ReOrder Buffer (ROB): Part 3
