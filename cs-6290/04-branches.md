# Branches

## 1. Lesson Introduction

We have seen in the previous lecture regarding pipelining that each control hazard wastes *many* cycles in a processor pipeline. Since branches and jumps are common, therefore performance will not be particularly good unless we address this issue. That is the central topic of this lecture.

## 2. Branch in a Pipeline

<center>
<img src="./assets/04-001.png" width="650">
</center>

Before discussing branch prediction in this lecture, recall what a branch does in a pipeline. Consider the following branch instruction:
```mips
BEQ R1, R2, Label
```

This instruction compares registers `R1` and `R2`, and if they are equal, then the program will jump to `Label`. This is usually implemented by storing (in the immediate part of the instruction field) the difference between the next instruction's **program counter** (**PC**) and the PC that should be at `Label`, so that (effectively) if `R1` and `R2` are equal then the branch adds this to the immediate operand to its current PC (i.e., that which it computed for the next instruction).

Therefore:
  * If the branch condition is not met (e.g., `R1 != R2`), then this simply results in an increment of the PC (i.e., `PC++`, an increment by `4` bytes).
  * If the branch condition is met (e.g., `R1 == R2`), then the branch will increment the PC as well as add the immediate value to it (i.e., `PC = PC + 4 + Imm`), in order to ensure that the next fetched instruction will be at `Label`.

Consider, then, what occurs when a branch instruction enters a pipeline (using a traditional five-stage pipeline, as before in Lecture 3).

| Cycle | `F` | `D` | `A` | `M` | `w` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `BEQ` | `...` | `...` | `...` | `...` |
| C2 | `?` | `BEQ` | `...` | `...` | `...` |

When the instruction `BEQ` reaches the stage `D` (decode) in cycle C2, it reads its operands `R1` and `R2`, but it is still unclear at this point whether or not the branch will be taken as these operands have not been compared at this point. Therefore, in the upstream stage `F` (fetch), we either will or will not fetch something, which is indeterminate a priori during this cycle.

| Cycle | `F` | `D` | `A` | `M` | `w` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `BEQ` | `...` | `...` | `...` | `...` |
| C2 | `?1` | `BEQ` | `...` | `...` | `...` |
| C3 | `?2` |  `?1` | `BEQ` | `...` | `...` |

In the next cycle C3, when the instruction `BEQ` reaches stage `A` (ALU), at the end of this cycle, it is finally determined whether or not the branch is taken. This gives rise to two possibilities:
  1. We have fetched the ***correct*** instructions in the upstream stages (i.e., `?1` and `?2`), and therefore the pipeline can proceed normally since there is no hazard introduced.
  2. We have fetched the ***incorrect*** instructions in the upstream stages, and therefore the pipeline must cancel these instructions.

| Cycle | `F` | `D` | `A` | `M` | `w` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `BEQ` | `...` | `...` | `...` | `...` |
| C2 | `?1` | `BEQ` | `...` | `...` | `...` |
| C3 | `?2` |  `?1` | `BEQ` | `...` | `...` |
| C4 | `...` | `X` |  `X` | `BEQ` | `...` |

In the next cycle C4, if the incorrect instructions were fetched previously, then they will be canceled (denoted `X` in the table above), and the subsequent instructions entering the pipeline will proceed as normally. Such a branch misprediction results in an inefficiency, since now the branch effectively takes three cycles to execute (due to cancellation of the subsequent two instructions).

Conversely, if the branch predicted correctly and the correct instructions were fetched previously, such cancellation does not occur, but rather the instructions `?1` and `?2` proceed as normally.

Therefore, in general, it is not advantageous *not* fetch a new instruction after the branching instruction (e.g., `BEQ`), because if we refrain from fetching *anything* at all, then we are *guaranteed* to have two empty instructions after the branching instruction; it is better to incur this penalty only *some* of the time rather *all* of the time.

Another thing that is important to note is that at the end of the stage `F` (fetch) (where the instruction `BEQ` is fetched), we do not know anything about this instruction yet at this point. All we have obtained is the instruction word (the 4 bytes representing the instruction), but he have not yet begun to decode the branch. Therefore, in the next cycle, we must fetch the next instruction based only on the knowledge of the branch instruction's address, but otherwise we are unaware of whether or not it is a branch instruction at this point; this means there is insufficient information to make a prediction regarding whether or not to branch.

# 3. Branch Prediction Requirements

<center>
<img src="./assets/04-002.png" width="650">
</center>

