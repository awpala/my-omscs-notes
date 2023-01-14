# Instruction-Level Parallelism (ILP)

## 1. Lesson Introduction

Recall that branch prediction (cf. Lesson 4) and if conversion (cf. Lesson 5) help to eliminate most of the pipeline issues caused by control hazards. But **data dependencies** can also prevent the finishing of one instruction in every single cycle; so, then, what can be done about data dependencies? And why stop at only *one* instruction per cycle, for that matter?

In this lesson, we will learn about **instruction-level parallelism (ILP)**, which indicates how many instructions could be *possibly* executed.

## 2. *All* Instructions in the *Same* Cycle

<center>
<img src="./assets/06-001.png" width="650">
</center>

In the most ***ideal*** situation, all instructions pending execution simply go through the pipeline all in the *same* stage (i.e., all executing simultaneously in the *same* cycle).

| Instructions* | C1 | C2 | C3 | C4 | C5 |
|:--:|:--:|:--:|:--:|:--:|:--:|
| `R1 = R2 + R3` | `F` | `D` | `E` | `⋯` | `WB` |
| `R4 = R1 - R5` | `F` | `D` | `E` | `⋯` | `WB` |
| `R6 = R7 ⨁ R8` (XOR) | `F` | `D` | `E` | `⋯` | `WB` |
| `R5 = R8 × R9` | `F` | `D` | `E` | `⋯` | `WB` |
| `R4 = R8 + R9` | `F` | `D` | `E` | `⋯` | `WB` |

****N.B.*** Using simplified high-level-language-like notation here instead of opcodes (i.e., assembly-style notation) for brevity.

Consider the five-stage-pipeline example shown above. Eventually, in the last stage of the pipeline, the results are written. Furthermore, even with additional instructions beyond those shown above, all would be completed within five cycles. Therefore, with increasing number of instructions, the following holds:

```
CPI = 5/∞ = 0
```

<center>
<img src="./assets/06-002.png" width="650">
</center>

While a CPI of `0` is "ideal on paper," there are inherent **issues** here. For example, the first two instructions *both* read/decode register `R1`, therefore, upon execution of the respective instructions, the first instruction is writing to `R1` while next instruction is simultaneously reading `R1`. Correspondingly, this error propagates downstream in subsequent instructions.

Therefore, necessarily, such instructions *cannot* execute in the *same* cycle; instead, some type of resolution measure is necessary for managing such instructions' respective executions.

## 3. The `Execute` Stage


