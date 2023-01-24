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

