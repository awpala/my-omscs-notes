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

What, then, is required in order to perform **branch predictions** (i.e., determining whether or not a branch is taken, and if so to where)?

Branch prediction can be feasibly implemented with only the knowledge of where we fetch the current instruction from; therefore, it is necessary to guess the program counter (PC) of the next instruction to be fetched.

Therefore, branch prediction must correctly guess the following series of questions:
  1. Is this a branch?
  2. If it is a branch, is the branch taken?
  3. If the branch *is* taken, what is the target PC?

The first two questions can be combined into a single question: Is this a branch that is taken, or something else? (i.e., in either case of a non-branching instruction or a non-taken-branch instruction, we simply fetch the subsequent instruction in memory)

## 4. Branch Prediction Accuracy

<center>
<img src="./assets/04-003.png" width="650">
</center>

Consider now the effect of branch prediction accuracy on performance.

The **cycles per instruction** (**CPI**) can be expressed as follows:
```
CPI = 1 + mispredictions/instruction × penalty/misprediction
```

where:
  * `1` represents an ideal pipeline (i.e., no hazards)
  * The second term represents additional cycles added to the pipeline on average due to **branch mispredictions**
    * The factor `mispredictions/instruction` characterizes the predictor's accuracy (i.e., how often mispredictions occur)
    * The factor `penalty/misprediction` characterizes the pipeline (i.e., the incurred penalty per missed prediction); in particular, where in the pipeline occurs (i.e., at which stage) determines the severity of this penalty in a given pipeline

Consider a comparison of the following two pipelines (assume that `20%` of all instructions are branches in typical programs running on these pipelines, which is reasonable for common programs):

| Accuracy | Pipeline A - resolves `BR` in stage `3` | Pipeline B - resolves `BR` in stage `10` |
|:---:|:---:|:---:|
| `50%` for branches, `100%` for all other instructions | `CPI = 1 + [(1-0.5)*0.2]×(3-1) = 1.2` | `CPI = 1 + [(1-0.5)*0.2]×(10-1) = 1.9` |
| `90%` for branches, `100%` for all other instructions | `CPI = 1 + [(1-0.9)*0.2]×(3-1) = 1.04` | `CPI = 1 + [(1-0.9)*0.2]×(10-1) = 1.18` |

***N.B.*** Pipeline B is more representative of a modern processor.

Therefore, as these CPI comparisons suggest, a better branch prediction (e.g., `90%` vs. `50%`) will improve CPI in either a shallow or deep pipeline, but the impact of this improvement depends on the depth of the pipeline (in particular, the improvement is more pronounced for a deeper pipeline):
  * `speedup for Pipeline A = 1.2/1.04 = 1.15`
  * `speedup for Pipeline B = 1.9/1.18 = 1.61`

As a corollary: The deeper a pipeline, the more dependent it is on branch-prediction accuracy for good performance.
  * ***N.B.*** Indeed, this is why research into branch predictors continues to this day. Modern branch predictors are in fact quite good: For branching instructions, they are significantly better than even 90%!

## 5. Branch Prediction Benefit Quiz and Answers

<center>
<img src="./assets/04-005A.png" width="650">
</center>

Consider the following pipelined processor system:
  * A five-stage pipeline
  * Branches are fully resolved in the third stage (ALU), i.e., the correct PC to be fetched is determined at this point
  * Nothing is fetched until there is certainty as to what instruction to fetch
  * The program executes many iterations of the following loop:
    ```mips
    LOOP:
      ADDI R1, R1, -1
      ADD  R2, R2, R2
      BNE2 R1, LOOP
    ```

What is the speedup achieved if we have a ***perfect*** predictor (i.e., the next instruction to be fetched is always known correctly)?
  * `7/3 = 2.33` (i.e., over twice the performance compared to fetching nothing until the correct instruction to fetch can be determined)

***Explanation***:

The number of cycles spent in each instruction within the loop are as follows:
```mips
LOOP:
  ADDI R1, R1, -1  # 2 -> this instruction is determined in stage 2/`D`
  ADD  R2, R2, R2  # 2 -> this instruction is determined in stage 2/`D`
  BNE2 R1, LOOP    # 3 -> this instruction's branching behavior is indeterminate until stage 3/`A`
```

Therefore, overall, it takes `2 + 2 + 3 = 7` cycles per loop iteration to perform these instructions.

Furthermore, with a perfect predictor, the number of cycles spent in each instruction to determine the subsequent instruction are as follows:
```mips
LOOP:
  ADDI R1, R1, -1  # 1
  ADD  R2, R2, R2  # 1
  BNE2 R1, LOOP    # 1
```

Therefore, overall, it takes `1 + 1 + 1 = 3` cycles per loop iteration to determine the instructions.

## 6. Performance with Not-Taken Prediction

<center>
<img src="./assets/04-006.png" width="650">
</center>

Having examined the performance resulting from refusal to make *any* predictions, consider now the performance resulting from so-called **"not-taken" predictions** (i.e., simply fetching the next instruction as if none of the instructions were *taken* branches).

Consider the following comparisons:

| Prediction Strategy | Branch Instruction Penalty | Non-Branch Instruction Penalty |
|:---:|:---:|:---:|
| Refuse to predict | `3` cycles | `1` or `3` cycles, for "actually not taken" or "actually taken" (respectively) |
| Predict as "not taken" | `2` cycles | `1` cycle ("not taken" prediction is always correct) |

As this suggests, predicting as "not taken" is *always* better than making no prediction at all.
  * For non-branching instructions, there is never a penalty incurred by the former
  * For branching instructions, the penalty incurred by the former is either the same or less severe

Therefore, virtually every processor that has a pipeline will perform some form of branch prediction, even if the "prediction" is simply to increment the program counter (PC) to fetch the next instruction (in practice, there is no net cost incurred to perform this operation, as it does not require performing actual branch prediction and the PC must be incremented regardless as part of normal operation of the processor). 

## 7. Multiple Predictions Quiz and Answers

<center>
<img src="./assets/04-008A.png" width="650">
</center>

Assume a five-stage pipeline as before, and suppose that branches are resolve in the third stage (i.e., `A`/`ALU`). Consider the following program running on this system:
```mips
  BNE R1, R2, LABEL A  # actually taken
  BNE R1, R3, LABEL B  # actually taken
  A
  B
  C
LABEL A:
  X
  Y
LABEL B:
  Z
```

where generic instructions `A`, `B`, `C`, `X`, `Y`, and `Z` are *not* branching instructions.

If we use a "not-taken" predictor and assuming that the branching instructions *are* taken, how many cycles are wasted on mispredictions until we arrive at instruction `Y`?
  * `2` cycles

***Explanation***:

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `BNE` | `...` | `...` | `...` | `...` |
| C2 | `BNE` | `BNE` | `...` | `...` | `...` |
| C3 | `A` |  `BNE` | `BNE` | `...` | `...` |

Since branches are resolved in the third stage, the first three cycles are as in the table shown above.

| Cycle | `F` | `D` | `A` | `M` | `W` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| C1 | `BNE` | `...` | `...` | `...` | `...` |
| C2 | `BNE` | `BNE` | `...` | `...` | `...` |
| C3 | (flush) |  (flush) | `BNE` | `...` | `...` |

When `BNE R1, R2, LABEL A` is resolved in the third stage (`A`), this cancels the two upstream instructions in the pipeline, and in the next cycle the program will proceed to instruction `X` via branching. Therefore, overall, `2` cycles are wasted. Furthermore, note that this penalty is the *same* as if the second instruction `BNE` were not a branch at all (i.e., in reality, we have mispredicted *two* branches in this situation, however, this is effectively no different than had the first branching instruction been correctly predicted, as this would have jumped passed the second branching instruction anyways).

Therefore, when a branch is mispredicted, it is most important to redirect to the correct path as quickly/efficiently as possible (while incurring any necessary penalty in the process), as there is no additional penalty incurred when skipping mispredicted branching instructions that will have never been executed anyways (e.g., there is no additional `2`-cycle penalty incurred by the second instruction `BNE`, as it is flushed before reaching stage `A` to trigger its own flushes).

## 8. Predict Not-Taken

<center>
<img src="./assets/04-009.png" width="650">
</center>

Let us now consider in more detail the **"not-taken" predictor**, which is the simplest available predictor. It amounts to simply incrementing the program counter (PC). Since we know the PC from which the branch instruction is fetched and we know the size of the instruction, we can therefore increment the PC trivially based on this information alone. Furthermore, the hardware already performs this operation normally during program execution, so there is no added overhead to accomplish this.

But there is still an outstanding question: How accurate is this predictor? A couple of **rules of thumb** suggest the following:
  * Approximately `20%` of instructions are branching instructions (i.e., the naive "not-taken" predictor will be correct `80%` of the time)
  * Slightly more than half (say, `60%`) of branches *are* taken when branching instructions are encountered in the program

Combining this information suggests the following branch prediction via the "not-taken" predictor:
  * ***correct***: `80% + [(100% - 60%) * 20%] = 88%`
  * ***incorrect***: `60% * 20% = 12%`

Therefore, the resulting impact on cycles per instruction (CPI) by the "not-taken" predictor can be expressed as:
```
CPI = 1 + 0.12 × penalty
```

***N.B.*** In the five-stage pipeline, `penalty = 2`, suggesting `CPI = 1.24`.

## 9. Why Do We Need Better Prediction?

<center>
<img src="./assets/04-010.png" width="650">
</center>

We have seen that the "not-taken" predictor (which is relatively trivial to implement) is reasonably accurate: For approximately 88% of all instructions, it predicts correctly. So, then, why do we even need better predictors in the first place? After all, improving upon this will presumably require some investment in hardware and effort to improve the predictor.

To explore this question, consider the following comparisons:

| Pipeline | Branch Instruction Resolution | Misprediction Penalty | CPI for "Not-Taken" Predictor (88% Accuracy) | CPI for Better Predictor (99% Accuracy) | Speedup |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 5-Stage | Stage `3` | `2` cycles | `1 + 0.12*2 = 1.24` | `1 + 0.01*2 = 1.02` | `1.24/1.02 = 1.22` |
| 14-Stage | Stage `11` | `10` cycles | `1 + 0.12*10 = 2.2` | `1 + 0.01*10 = 1.1` | `2.2/1.1 = 2.0` |
| 14-Stage, executing `4` instructions/cycle* | Stage `11` | `4*10 = 40` cycles | `0.25 + 0.12*10 = 1.45`** | `0.25 + 0.01*10 = 0.35`** | `1.45/0.35 = 4.14` |
  * ****N.B.*** This pipeline is most representative of a modern processor.
  * *****N.B.*** The ideal CPI for this pipeline is `1/4 = 0.25`, since it executes `4` (i.e., `> 1`) instructions/cycle.

As these comparisons suggest, the better predictor gives a much better speedup/performance compared to the "not-taken" predictor. Furthermore, this improvement is even more pronounced when using a pipeline that is capable of performing `instructions/cycle > 1`.

## 10. Predictor Impact Quiz and Answers

<center>
<img src="./assets/04-012A.png" width="650">
</center>

Consider the Intel Pentium 4 "Prescott" processor, which has the following specifications:
  * Performs a `FETCH` operation, then a subsequent `29` stages, and then it resolves branches at stage `31`
  * Uses branch prediction
  * Executes multiple instructions per cycle

Furthermore, a program is given with the following attributes:
  * `20%` of the instructions are branches
  * `1%` of branches are mispredicted
  * `CPI = 0.5`

If a slightly worse predictor is used, which instead mispredicts `2%` of branches, how would this change the CPI?
  * `0.44 + 0.2*0.02*(31-1) = 0.56`

***Explanation***:

Given an overall CPI of `0.5`, this is comprised of the following components (where `X` is unknown):
```
0.5 = X + 0.2*0.01*(31-1)
```

Solving for `X`, this suggests an ideal CPI (i.e., with a perfect branch predictor) of `X = 0.5 - 0.06 = 0.44` for this processor pipeline.

## 11. Why Do We Need Better Prediction? (Part 2)

<center>
<img src="./assets/04-013.png" width="650">
</center>

Previously (cf. Section 9), examined how better prediction improves performance (i.e., CPI) in a pipelined processor.

Additionally, another consideration for why better prediction is useful is to examine waste/inefficiency resulting from misprediction. In general, the deeper the pipeline, the more inefficiency that is introduced by misprediction. For example:

| Pipeline | Branch Instruction Resolution | Misprediction Penalty |
|:---:|:---:|:---:|
| 5-Stage | Stage `3` | `2` cycles | 
| 14-Stage | Stage `11` | `10` cycles |
| 14-Stage, executing `4` instructions/cycle | Stage `11` | `4*10 = 40` cycles |

In particular, for a parallel processor (executing `instructions/cycle > 1`), this can lead to ***many*** wasted cycles. Therefore, correct branch prediction is even more consequential in such systems.

## 12. Better Prediction: How?

<center>
<img src="./assets/04-014.png" width="650">
</center>

So, then, how can such a "better predictor" be achieved?

The "not-taken" predictor determines the next program counter (PC) value based on the current value, i.e., `PC`<sub>`NEXT`</sub>` = f(PC`<sub>`NOW`</sub>`)`. Specifically, this is accomplished by simply incrementing the value `PC`<sub>`NOW`</sub>.

If all that is known is `PC`<sub>`NOW`</sub>, is there a better function we could use to form a better prediction of `PC`<sub>`NEXT`</sub>? In this case, the answer is no. However, there is some additional information that can assist with this goal, for example:
  * Is the current instruction a branch?
  * If the current instruction *is* a branch, will it be taken?
  * What is the offset field of the instruction? (i.e., for a branch instruction, this can be added to the PC accordingly to determine the appropriate target if the branch is taken)

Unfortunately, none of this information is generally available a priori. 
However, there is still a way to achieve better prediction: This can be accomplished by examining the past behavior of the branch in `PC`<sub>`NOW`</sub> as a heuristic, i.e., `PC`<sub>`NEXT`</sub>` = f(PC`<sub>`NOW`</sub>`, HISTORY(PC`<sub>`NOW`</sub>`))`. This approach is useful because branches tend to behave in repeated, predictable patterns, which is advantageous for improving the prediction accordingly.

## 13. Branch Target Buffer (BTB)

<center>
<img src="./assets/04-015.png" width="650">
</center>

The simplest predictor that uses branch history information is called the **branch target buffer** (**BTB**). The BTB predictor takes the current program counter (PC) of the branch and uses it to index into a table (appropriately called the BTB), and from this table we read out the best guess for the value of `PC`<sub>`NEW`</sub> (i.e., the predicted next instruction).

So, then, how do we populate the BTB table? *Both* `PC`<sub>`NOW`</sub> *and* `PC`<sub>`NEW`</sub> are tracked via the BTB table throughout the pipeline. During the operation `FETCH`, the ***predicted*** value of `PC`<sub>`NEW`</sub> is fetched. Then, subsequently in the pipeline, the ***actual***/***correct*** value of `PC`<sub>`NEW`</sub> is fetched, and compared with the predicted value. If the values disagree, this is treated as a misprediction, and correspondingly the branch instruction's own value `PC`<sub>`NOW`</sub> is used again to re-index into the BTB table to update the corresponding value of `PC`<sub>`NEW`</sub> with the actual value, for use in subsequent prediction.

<center>
<img src="./assets/04-016.png" width="650">
</center>

There is still an unresolved matter with respect to the BTB table, however: How large should the table be?
  * It requires at least a `1` cycle latency to account for the prediction of `PC`<sub>`NEW`</sub> from `PC`<sub>`NOW`</sub>, but ideally no more than this
    * This requires a ***small*** table size
  * Additionally, it must be wide enough to store an entire instruction address (e.g., with 64-bit addressing, each table entry is `8 bytes` in size), as well as large enough to store at least `1` table entry for each PC address in the program
    * This requires a ***large*** table size (the memory requirements to achieve this for a typical program would be demanding!)

These requirements pose conflicting requirements: Practically speaking, we cannot have a dedicated entry in the BTB table for *every* possible PC address. So, then, how can we resolve this conflict? That is discussed in the next section.

## 14. Realistic Branch Target Buffer (BTB)

<center>
<img src="./assets/04-017.png" width="650">
</center>

To resolve the issue with respect to the branch target buffer (BTB) table size (as described at the end of the previous section), it is firstly important to note that in practice it is not necessary to have an entry in the BTB table for *every* possible program counter (PC) address value; instead, it is sufficient to have just the entries for those instructions which are most likely to execute in the near future.

For example, consider a loop composed of `100` program instructions. To account for this loop, it is only necessary for the BTB table to correspondingly store approximately `100` entries. After the first iteration of the loop, the BTB table will be populated with these instructions, which will then become available for subsequent iterations of the loop.

<center>
<img src="./assets/04-018.png" width="650">
</center>

Now that the BTB table is populated, consider the performance of timing experiments, which determine that only `1024` entries can be accessed in one cycle. This gives rise to the following question: Since there are many possible PC address values, how do we map *each* PC address value to an entry in the BTB table in a manner which avoids conflicts among different PC address values mapping to the *same* table entry? Furthermore, note that the mapping function must be relatively simple, because any additional delay/overhead incurred from computing the mapping function will further constrain the possible size for the BTB table (i.e., to ensure that the operation will still complete in one cycle).

To achieve this objective, consider the composition of the 64-bit input address `PC`<sub>`NOW`</sub>. `log`<sub>`2`</sub>`(1024) = 10` bits are required to index into the BTB table. Therefore, we can dedicate the 10 least-significant bits (LSBs) to store the index into the BTB table. Such a mapping function is very fast, as it involves a simple/direct indexing into the table via the LSBs.
  * ***N.B.*** Here, we are using the least-significant bits (LSBs) rather than the most-significant bits (MSBs) because the MSBs typically resemble each other, particularly within the same part of a given program (e.g., within a loop), for example *`0x24`*`AC` (`ADD`), *`0x24`*`B0` (`MUL`), etc. This in turn would give rise to ambiguous inputs with respect to mapping into the BTB table (i.e., resulting in unintended conflicts/overwrites of existing values). Conversely, LSBs will generally be more dissimilar, even among "nearby" instructions within the program.

## 15. BTB Quiz and Answers

<center>
<img src="./assets/04-020A.png" width="650">
</center>

Consider a system comprised of the following:
  * A BTB table with `1024` entries, which are zero-indexed (i.e., `0, 1, ..., 1023`).
  * The system architecture uses fixed-size `4`-byte instructions which must be **word-aligned** (i.e., each instruction must begin at an address that is divisible by `4`).
  * The program counter (PC) is a `32`-bit register (i.e., the processor uses `32`-bit addresses)

Which BTB table entry should be used for address value `PC = 0x0000AB0C`?
  * `0x2C3`

***Explanation***:

While it may seem as trivially simple as using the 10 least-significant bits (LSBs) of the given PC address value, it is not so simple; this is due to the constraint of fixed-size 4-byte instructions which are word-aligned (i.e., this constraint will not be *generally* satisfied by the 10 LSBs). Therefore, in general, only addresses `0x0`, `0x4`, `0x8`, etc. (but *not* `0x1`, `0x2`, `0x3`, etc.) are suitable candidates for BTB table entries.

Therefore, a more general approach would be to use BTB table entry values having the general form `...00` to ensure that this constraint is satisfied. Furthermore, we can offset by these two positions and use the offset-by-two 10 LSBs (i.e., right-padded with `00`) as follows:
```
      A---B---0---C---
  ... 1010101100001100
          |        |^^
```
***N.B.*** `^` denotes the padding `0`s.

This gives the value (denoted by `|...|` above) `1011000011`<sub>`2`</sub>, or equivalently `0x2C3` or `707`<sub>`10`</sub>.

## 16. Direction Predictor

<center>
<img src="./assets/04-021.png" width="650">
</center>

So, then, how to accomplish **direction prediction**? To do this, we use a table called the **branch history table** (**BHT**), which takes the least significant bits (LSBs) of `PC`<sub>`NOW`</sub> as input indices, similarly to indexing into the branch target buffer (BTB) table.

However, the entry in the BHT is much smaller: The simplest predictor will have a single bit indicating `0` (branch is *not* taken, therefore increment the program counter) vs. `1` (the branch is taken, therefore use the BTB table).

As is done for the BTB table, the BHT entry can be similarly updated (if necessary) once the actual branch instruction is resolved.

Because an entry into the BHT can be a single bit, this allows for a potentially large BHT, which can accommodate many instructions and avoid conflicts among executing instructions, while still maintaining a relatively small corresponding BTB table (i.e., containing entries for only those instructions which *do* take branches).

## 17-21. BTB and BHT Quizzes and Answers

### Problem Statement

Consider the following program:
```mips
      MOV R2, 100       # 0xC000
      MOV R1, 0         # 0xC004
Loop: BEQ R1, R2, Done  # 0xC008
      ADD R4, R3, R1    # 0xC00C 
      LW  R4, 0(R4)     # 0xC010
      ADD R5, R5, R4    # 0xC014
      ADD R1, R1, 1     # 0xC018
      B   Loop          # 0xC01C
Done:                   # 0xC020
```

***N.B.*** Observe that each program instruction address is 4 bytes in size.

Suppose we are given the following:
  * A branch history table (BHT) having `16` entries and which makes perfect branch predictions
  * A branch target buffer (BTB) table having `4` entries which that makes perfect branch predictions 

### 17. Quiz 1 and Answers

<center>
<img src="./assets/04-023A.png" width="650">
</center>

How many times do we access the BHT for *each* instruction?

| Instruction Address | Instruction | Number of BHT Accesses |
|:---:|:---:|:---:|
| `0xC000` | `MOV R2, 100` | `1` |
| `0xC004` | `MOV R1, 0` | `1` |
| `0xC008` | (`Loop:`) `BEQ R1, R2, Done` | `1` |
| `0xC00C` | `ADD R4, R3, R1` | `101` |
| `0xC010` | `LW R4, 0(R4)` | `100` |
| `0xC014` | `ADD R5, R5, R4` | `100` |
| `0xC018` | `ADD R1, R1, 1` | `100` |
| `0xC01C` | `B Loop` | `100` |

***Explanation***:

The BHT is accessed in order to determine whether a given instruction is a taken branch; this is done every time we fetch an instruction, and because we have perfect prediction (for both the BTB table and the BHB), this implies that we will never fetch any instruction that will not actually execute.

The first two instructions at addresses `0xC000` and `0xC004` execute only once. The third instruction at address `0xC008` is the branch instruction, which only executes once and causes entry into the loop/branching logic (denoted by label `Loop`).

The loop executes as long as `R1` and `R2` are not equal, which are initialized by the first two instructions to values `0` and `100` (respectively). The last two instructions of the `Loop` segment increment `R1` by `1` and then jump back to `Loop`. Therefore, this proceeds for 100 iterations, until `R1` and `R2` are equal (i.e., both equaling `100`, which occurs on the 101st iteration), at which point the loop is exited and the program proceeds to label `Done` (i.e., at this point in the program, the branch is *taken* to `Done`).

### 18. Quiz 2 and Answers

<center>
<img src="./assets/04-025A.png" width="650">
</center>

Which branch history table (BHT) entry do we access for each instruction?

| Instruction Address | Instruction | BHT Entry |
|:---:|:---:|:---:|
| `0xC000` | `MOV R2, 100` | `0` |
| `0xC004` | `MOV R1, 0` | `1` |
| `0xC008` | (`Loop:`) `BEQ R1, R2, Done` | `2` |
| `0xC00C` | `ADD R4, R3, R1` | `3` |
| `0xC010` | `LW R4, 0(R4)` | `4` |
| `0xC014` | `ADD R5, R5, R4` | `5` |
| `0xC018` | `ADD R1, R1, 1` | `6` |
| `0xC01C` | `B Loop` | `7` |

***Explanation***:

There are `16` entries in the BHT, which can be accessed via the offset least-significant bits (LSBs) of the corresponding instruction addresses. Therefore:

| Instruction Address | BHT Entry |
|:---:|:---:|
| `0xC000` (`1100 0000 00\|00 00\|00`) | `0` |
| `0xC004` (`1100 0000 00\|00 01\|00`) | `1` |
| `0xC008` (`1100 0000 00\|00 10\|00`) | `2` |
| `0xC00C` (`1100 0000 00\|00 11\|00`) | `3` |
| `0xC010` (`1100 0000 00\|01 00\|00`) | `4` |
| `0xC014` (`1100 0000 00\|01 01\|00`) | `5` |
| `0xC018` (`1100 0000 00\|01 10\|00`) | `6` |
| `0xC01C` (`1100 0000 00\|01 11\|00`) | `7` |

***N.B.*** If `15` were reached in this manner, the subsequent instruction would result in a wraparound back to `0`, however, this does not occur in this particular program.

## 19. BTB and BHT 3 Quiz and Answers

<center>
<img src="./assets/04-027A.png" width="650">
</center>

How many times do we access the branch target buffer (BTB) table for each instruction?

| Instruction Address | Instruction | Number of BTB Table Accesses |
|:---:|:---:|:---:|
| `0xC000` | `MOV R2, 100` | `0` |
| `0xC004` | `MOV R1, 0` | `0` |
| `0xC008` | (`Loop:`) `BEQ R1, R2, Done` | `1` |
| `0xC00C` | `ADD R4, R3, R1` | `0` |
| `0xC010` | `LW R4, 0(R4)` | `0` |
| `0xC014` | `ADD R5, R5, R4` | `0` |
| `0xC018` | `ADD R1, R1, 1` | `0` |
| `0xC01C` | `B Loop` | `100` |

***Explanation***:

The BTB table is only accessed if the branch history table (BHT) indicates to take the branch (recall that we assume both tables predict perfectly); otherwise, if the branch is *not* taken, then we simply increment the program counter (PC) without accessing the BTB table at all.

Therefore, by inspection, all non-branching instructions do not access the BTB table at all. The instruction `B Loop` at instruction `0xC01C` is *always* taken, and this occurs `100` times in the program loop. Furthermore, with respect to the instruction `BEQ R1, R2, Done` at instruction address `0xC008`, in every iteration that stays in the loop (i.e., when `R1` and `R2` are not equal, which occurs for `100` iterations, as per the quiz in Section 17), the branch is not taken and therefore the BTB table is not accessed; conversely, when `R1` and `R2` become equal (i.e., both having the value `100`, which occurs once in the final iteration), this causes an access of the BTB table (and consequent branch to `Done`).

## 20. Quiz 4 and Answers

<center>
<img src="./assets/04-029A.png" width="650">
</center>

Which branch target buffer (BTB) table entry do we use for each instruction? (Leave blank if no entry is used.)

| Instruction Address | Instruction | BHT Entry |
|:---:|:---:|:---:|
| `0xC000` | `MOV R2, 100` | |
| `0xC004` | `MOV R1, 0` | |
| `0xC008` (`1100 0000 0000 \|10\|00`) | (`Loop:`) `BEQ R1, R2, Done` | `2` |
| `0xC00C` | `ADD R4, R3, R1` | |
| `0xC010` | `LW R4, 0(R4)` | |
| `0xC014` | `ADD R5, R5, R4` | |
| `0xC018` | `ADD R1, R1, 1` | |
| `0xC01C` (`1100 0000 0001 \|11\|00`) | `B Loop` | `3` |

***Explanation***:

Recall from the previous quiz (cf. Section 19) that only the branching instructions will access the BTB table; therefore, for the remaining non-branching instructions, by inspection, there are no corresponding BHT entries.

To determine the BHT entries of the branching instructions, this can be achieved by examining their instruction addresses. Since the BTB table has `4` entries, we use the four least-significant bits (LSBs) offset by two bits (i.e., `00`, which is are common to all of the instructions).

## 21. Quiz 5 and Answers

<center>
<img src="./assets/04-031A.png" width="650">
</center>

Consider the same system as before, however, with the following slight modification:
  * A branch history table (BHT) having `16` entries, with each entry being a `1`-bit predictor and initialized to value `0` (i.e., all predict "not taken")
    * This is ***different*** from the initial system, which made perfect branch predictions
  * A branch target buffer (BTB) table having `4` entries which that makes perfect branch predictions 
    * This is the ***same*** as before

How many mispredictions occur for each instruction during program execution?

| Instruction Address | Instruction | Number of Mispredictions |
|:---:|:---:|:---:|
| `0xC000` | `MOV R2, 100` | `0` |
| `0xC004` | `MOV R1, 0` | `0` |
| `0xC008` | (`Loop:`) `BEQ R1, R2, Done` | `1` |
| `0xC00C` | `ADD R4, R3, R1` | `0` |
| `0xC010` | `LW R4, 0(R4)` | `0` |
| `0xC014` | `ADD R5, R5, R4` | `0` |
| `0xC018` | `ADD R1, R1, 1` | `0` |
| `0xC01C` | `B Loop` | `1` |

***Explanation***:

Recall (cf. Section 18, Quiz 2) that each BHT entry is unique in this program, therefore, none of the instructions will generate collisions in the BTB table.

By inspection, the first two (non-branching) instructions generate `0` mispredictions.

Upon entry into the loop, the first iteration is as follows:
  * The branching instruction `BEQ R1, R2, Done` at instruction address `0xC008` is *not* taken, which is a correct prediction (because the BHT entries are initialized to `0`).
  * The subsequent (non-branching) instructions are *not* taken, which is similarly a correct prediction.
  * The tail-end branching instruction `B Loop` at address `0xC01C` *is* taken, and this is an *misprediction*, since the BHT entry is initialized to `0`, thereby contradictorily suggesting the branch would *not* be taken. Consequently, the BHT entry is updated to `1`.

In subsequent loop iterations, the program proceeds similarly; furthermore, with the tail-end instruction's BHT entry set to `1` in the first iteration, this is no longer a misprediction in these iterations.

In the final loop iteration (for which the values `R1` and `R2` both become equal to `100`, i.e., on the 101st iteration), the branching instruction `BEQ R1, R2, Done` at instruction address `0xC008` is now *taken*, and this is a *misprediction* since the BHT entry (initialized to `0`) suggests otherwise. Consequently, the BHT entry is updated to `1` and the program takes the branch to label `Done`.

As these results suggest, over the course of the program, the prediction is very accurate (i.e., only 2 mispredictions out of hundreds of executed instructions!).
  * ***N.B.*** As demonstrated here, 1-bit predictors are effective for iterative constructs such as loops. However, as we will see later, 1-bit predictors are not as effective when dealing with other constructs (e.g., those which do not have many iterations and/or those which do not have many if-else statements).

## 22. Issues with 1-Bit Prediction

<center>
<img src="./assets/04-032.png" width="650">
</center>

As demonstrated in the previous section, the 1-bit predictor works reasonably well for loops having many iterations. However, there are some **issues** that arise when using a 1-bit predictor, which have ultimately led to development of other, better predictors.

The 1-bit predictor performs prediction ***well*** in the following cases:
  * Branches that are either always taken, or always not taken
    * Even if the initial guess is incorrect, the cost for this misprediction penalty is eventually amortized over subsequent iterations
  * The number of times that the branches are taken vastly outnumber the branches not being taken, or the number of times the branches are not taken vastly outnumber the branches being taken
    * Similarly, the mispredictions will be relatively rare and therefore their cost is amortized over the course of the program's execution 

The latter case is demonstrative for why the 1-bit predictor can be problematic. Consider the following situation, wherein there are many more branches that are taken rather than not taken:
```
T T T T NT T T T
√ √ √ √ X  X √ √
```

In such a scenario, a misprediction (`X`) is a relatively rare anomaly; however, observe that *each* such misprediction will necessarily generate *two* mispredictions (i.e., the initial incorrect prediction followed by the subsequent correction).

Therefore, the 1-bit predictor will generally perform ***poorly*** in the following cases:
  * There is a comparable number of branches taken vs. branches not taken (i.e., in these cases, there will be many such anomalies occurring during program execution)
  * Short loops, which are insufficient to adequately amortize the misprediction cost over the course of its (relatively few) iterations
    * The prediction is generally only correct while the program remains in the loop; as soon as it exits, a misprediction penalty is incurred

<center>
<img src="./assets/04-033.png" width="650">
</center>

In the most extreme case, the 1-bit predictor will perform the ***worst*** when the number of branches taken vs. not taken are approximately equal.

Next, we will consider improving prediction in the case of "poor" 1-bit predictor performance.

## 23. 2-Bit Predictor

<center>
<img src="./assets/04-034.png" width="650">
</center

The predictor that fixes the aforementioned issue of two mispredictions per anomaly (in the 1-bit predictor) is called a **2-bit predictor** (**2BP**), or a **2-bit counter** (**2BC**).

The two bits are defined as follows:
  * **prediction bit** -The most-significant bit (MSB), which indicates what the prediction should be, similarly to the single bit of the 1-bit predictor
  * **hysteresis bit** (or **conviction bit**) - The least significant bit (LSB), which indicates the certainty of the prediction bit

The 2BP has the following possible state values:
  * `00` - strong not-taken
  * `01` - weak not-taken
  * `10` - weak taken
  * `11` - strong taken

Per the corresponding state diagrams (as in the figure shown above):
  * In the 1-bit predictor, one outcome completely "changes our mind completely" about what to do with the branch, which results in *two* mispredictions per anomaly.
  * Conversely, in the 2-bit predictor, there is only *one* misprediction per anomaly, as incorrect guesses do not incur an additional penalty to return to the correct prediction state.
    * In general, the state will reside in either "strong" state, and only transition through the "weak" zone periodically. Only in this transition through the "weak" zone will a two-mispredictions penalty be incurred.

The behavior is the 2-bit predictor is simple enough to implement, while providing more effective (i.e., less penalty-incurring) performance.

## 24. 2-Bit Predictor Initialization

<center>
<img src="./assets/04-035.png" width="650">
</center

Given that there are four possible states for the 2-bit predictor, consider: Does it matter in which state the predictor starts off? 

Starting in a ***strong*** state suggests the following possible prediction behaviors:
```
00 00 00
NT NT NT
√  √  √ 
```
  * An initial *correct* prediction remains in the strong state
```
00 01 10 11
T  T  T  T
X  X  √  √
```
  * An initial *incorrect* prediction incurs ***two*** penalties before predicting correctly

Starting in a ***weak*** state suggests the following possible prediction behaviors:
```
01 00 00
NT NT NT
√  √  √ 
```
  * An initial *correct* prediction transitions to the strong state
```
01 10 11 11
T  T  T  T
X  √  √  √
```
  * An initial *incorrect* prediction incurs ***one*** penalty before predicting correctly

These comparisons therefore suggest it is advantageous to initialize in a ***weak*** state.

However, consider the situation where the branching behavior changes frequently:

(*start in strong state*)
```
00 01 00 01
T  NT T  NT
X  √  X  √
```
(*start in weak state*)
```
01 10 01 10
T  NT T  NT
X  X  X  X
```

Therefore, in the worst case, starting in a weak state results in *always* mispredicting when branching is frequent.

However, in practice, it is more common to have more stable branching behavior, therefore, the suggestion of starting in a weak state will be generally advantageous. Furthermore, even an initial misprediction is generally inconsequential to performance over the lifetime of the program (i.e., the misprediction penalty is amortized relatively quickly), so it also just as valid to simply (somewhat arbitrarily) start in state `00`, which is relatively simple to do.

## 25. 2-Bit Predictor (2BT) Quiz and Answers

<center>
<img src="./assets/04-037A.png" width="650">
</center

Consider a 2-bit predictor having the four states as described previously (cf. Section 24), defined as follows:

| State | Bit Pattern |
|:---:|:---:|
| Strong Not-Taken (SN) | `00` |
| Weak Not-Taken (WN) | `01` |
| Weak Taken (WT) | `10` |
| Strong Taken (ST) | `11` |

Assume we start at state `00` (Strong Not-Taken).

Is there a sequence of branch outcomes that results in ***never*** predicting correctly? If so, indicate the first five steps of the state transitions sequence.
  * `Yes`: `T` → `T` → `NT` → `T` → `NT`

***Explanation***:
```
SN WN WT WN WT ...
00 01 10 01 10 ...
T  T  NT T  NT ...
X  X  X  X  X  ...
```

***N.B.*** It is possible to change this particular predictor such that this behavior does not result in 100% misprediction, however, in general, ***every*** predictor inherently has the possible worst-case scenario of 100% misprediction; it is merely a matter of how likely such a sequence will occur in practice (a good predictor ensures this is exceedingly rare).

## 26. 1-Bit Predictor to 2-Bit Predictor Improvements

<center>
<img src="./assets/04-038.png" width="650">
</center

As we have seen, moving from a 1-bit predictor to a 2-bit predictor improves prediction behavior, primarily because one-off occurrences of the other branching behavior does not completely change the prediction decision.

Therefore, a natural question arises: Would adding more bits (e.g., 3-bit predictor, 4-bit predictor, etc.) further improve prediction performance?
  * The ***drawback*** of using more bits is cost, which increases in proportion to the number of bits used for prediction
  * * The ***benefit*** of using more bits is that when anomalous outcomes occur in sequential "streaks," this increases hysteresis (i.e., remaining longer in the "original" behavior prediction before transitioning to the "other" behavior) which may be more appropriate for reducing penalty incurrence

However, in practice, it is not often that such "anomalous streaks" occur in a program. Therefore, additional bits are generally of marginal benefit beyond 2-bit predictors (maybe 3-bit predictors may be useful, however, 4-bit predictors and beyond are typically impractical).

So, then, if adding more bits does not provide additional benefits beyond a certain point, how do we further improve prediction (i.e., beyond the 2-bit predictor)? In particular, as we have seen, neither the 1-bit predictor nor the 2-bit predictor are effective in the case of frequent switching in the branching behavior. This topic is discussed next.

## 27. History-Based Predictors

<center>
<img src="./assets/04-039.png" width="650">
</center

**History-based predictors** attempt to predict patterns with frequent changes in branching behavior, with changes occurring in a repeated pattern (as in the figure shown above). Such patterns are therefore ***predictable***, however, they are ineffectively predicted by *n*-bit predictors.

To solve this issue, history-based predictors "learn the pattern" over time. To accomplish this, rather than focusing solely on the "majority" outcome, history-based predictors examine the ***branch history*** as the program executes (as in the figure shown above). This history in turn refines the predictive pattern in response the *current* branching behavior, until the prediction eventually becomes accurate for the inherent underlying branching pattern (which may involve more complex "mappings", e.g., `NT NT` predicts `T`, `T NT` predicts `NT`, etc.).

## 28. 1-Bit History Predictor with 2-Bit Counters

<center>
<img src="./assets/04-040.png" width="650">
</center

As a more concrete example, consider a history-based predictor comprised of a 1-bit history with two 2-bit counters (one for each history state). The general approach to this branch predictor is similar to before (as in the figure shown above): The program counter (PC) indexes into the branch history table (BHT). However, here, rather than having a 1-bit (or 2-bit) counter in each entry, instead we have a 1-bit history (H) and a pair of 2-bit counters (2BC) (one for when the state is `0`, and the other for when the state is `1`).

Consider the following sequence:

| Sequence | Predictor State | Prediction | Actual Branch Outcome | Correct Prediction? |
|:---:|:---:|:---:|:---:|:---:|
| S1 | `(0, SN, SN)` | `NT` | `T` | `X` |
| S2 | `(1, WN, SN)` | `NT` | `NT` | `√` |
| S3 | `(0, WN, SN)` | `NT` | `T` | `X` |
| S4 | `(1, WT, SN)` | `NT` | `NT` | `√` |
| S5 | `(0, WT, SN)` | `T` | `T` | `√` |
| S6 | `(1, ST, SN)` | `NT` | `NT` | `√` |
| S7 | `(0, ST, SN)` | `T` | `T` | `√` |

In the initial state (`(0, SN, SN)`, sequence S1), the history bit `0` indicates to use the *first* 2-bit predictor (`SN`), resulting in a prediction of `NT` (not taken). However, since this differs from the actual branch outcome (`T`/taken), there is a misprediction. Since the prediction is incorrect, the history bit indexes into the first 2-bit predictor and changes it to `WN`, and then also flips itself to `1` (i.e., the actual outcome, `T`).

In the next prediction (`(1, WN, SN)`, sequence S2), the history bit `1` indicates to use the *second* 2-bit predictor (`SN`), resulting in a prediction of `NT`, which is correct. Therefore, the 2-bit predictors remain unchanged. Furthermore, the history bit is changed to `0`, consistently with the actual branch outcome (`NT`).

In the next prediction (`(0, WN, SN)`, sequence S3), the history bit `0` indicates to use the *first* 2-bit predictor (`WN`), resulting in a prediction of `NT`, which is incorrect. Since the prediction is incorrect, the history bit indexes into the first 2-bit predictor and changes it to `WT`, and then also flips itself to `1` (i.e., the actual outcome, `T`).

In the next prediction (`(1, WT, SN)`, sequence S4), the history bit `1` indicates to use the *second* 2-bit predictor (`SN`), resulting in a prediction of `NT`, which is correct. Therefore, the 2-bit predictors remain unchanged. Furthermore, the history bit is changed to `0`, consistently with the actual branch outcome (`NT`).

In the next prediction (`(0, WT, SN)`, sequence S5), the history bit `0` indicates to use the *first* 2-bit predictor (`WT`), resulting in a prediction of `T`, which is correct. Since the prediction is correct, the history bit indexes into the first 2-bit predictor and changes it to `ST`, and then also flips itself to `1` (i.e., the actual outcome, `T`).

From this point on, there is perfect prediction, with the 2-bit predictors set to "strong" states, and the history bit flipping accordingly with the actual branch outcome to reference the appropriate 2-bit predictor. Therefore, at this point, the branching pattern has been "learned" by the predictor.

## 29. 1-Bit History Predictor Quiz and Answers

<center>
<img src="./assets/04-042A.png" width="650">
</center

Consider the following system:
  * 1-bit history, initialized to `0`
  * 2-bit predictor per each history state, both initialized to `SN` (Strong Not-Taken)

Furthermore, the pattern to predict is `(NNT)*`

After `100` repetitions of the pattern (i.e., 300 total outcomes), what is the overall number of mispredictions that occur?
  * `100`

***Explanation***:

Consider the corresponding sequence as follows:

| Sequence | Predictor State | Prediction | Actual Branch Outcome | Correct Prediction? |
|:---:|:---:|:---:|:---:|:---:|
| S1 | `(0, SN, SN)` | `N` | `N` | `√` |
| S2 | `(0, SN, SN)` | `N` | `N` | `√` |
| S3 | `(0, SN, SN)` | `N` | `T` | `X` |
| S4 | `(1, WN, SN)` | `N` | `N` | `√` |
| S5 | `(0, WN, SN)` | `N` | `N` | `√` |
| S6 | `(0, SN, SN)` | `N` | `T` | `X` |
| S7 | `(0, SN, SN)` | `N` | `N` | `√` |

Since sequence S7 has the same state and prediction behavior as the initial state (i.e., sequence S1), it can be inferred by inspection that this pattern will continue. Therefore, in the overall `300` sequences, a third of these will be incorrect predictions (i.e., each third of the triplets, e.g., `S3` in `S1` to `S3`, `S6` in `S4` to `S6`, etc.), or `100` total. Therefore, a 1-bit history predictor is not particularly effective for this pattern.

## 30. 2-Bit History Predictor


