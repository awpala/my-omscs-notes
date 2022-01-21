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

## 7. Multiple Predictions Quiz

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

## 15. BTB Quiz

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


