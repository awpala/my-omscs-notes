# Instruction-Level Parallelism (ILP)

## 1. Lesson Introduction

Recall that branch prediction (cf. Lesson 4) and if conversion (cf. Lesson 5) help to eliminate most of the pipeline issues caused by control hazards. But **data dependencies** can also prevent the finishing of one instruction in every single cycle; so, then, what can be done about data dependencies? And why stop at only *one* instruction per cycle, for that matter?

In this lesson, we will learn about **instruction-level parallelism (ILP)**, which indicates how many instructions could be *possibly* executed.

## 2. *All* Instructions in the *Same* Cycle

<center>
<img src="./assets/06-001.png" width="650">
</center>

In the most ***ideal*** situation, all instructions pending execution simply go through the pipeline all in the *same* stage (i.e., all executing simultaneously in the *same* cycle).

| Instruction* | C1 | C2 | C3 | C4 | C5 |
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

As seen previously (cf. Section 2), an issue arises when multiple instructions execute in the *same* cycle dealing with the *same* data/register(s) (e.g., having to read registers *before* the previous instruction has written to them). In particular, this problem occurs in the stage `E` (execute), due to operation there on an ***invalid*** value by that point.

<center>
<img src="./assets/06-003.png" width="450">
</center>

Consider **forwading** in the stage `E` as a potential resolution measure for this issue. Recall (cf. Lesson 3) that forwarding feeds the value(s) from the previous instruction into the subsequent instruction *before* the value(s) has been written to the register(s).

Returning to the example from the previous section, and focusing on the stage `E` (as in the figure shown above), recall that there is a dependency between instructions `I1` and `I2`. Here, `I1` executes, and then subsequently `I2` also executes in the *same* cycle.

The ***problem*** with forwarding here is that while forwarding from `I1` to `I2` *could* resolve the issue with respect to the latter in the *next* cycle, it does *not* resolve the matter with respect to the *same*/*current* cycle.
  * Examining the timeline for the cycle (relative to the beginning of stage `E`), the result from `I1` is only available at the *end* of `I1` (which is the only point where forwarding to `I2` would be beneficial), but the point at which the value is *necessary* for use in `I2` is in the *beginning* of the *same* cycle; this would essentially (unrealistically) require "backwards time travel"

<center>
<img src="./assets/06-004.png" width="450">
</center>

In reality, to resolve this matter, it is necessary to **stall** in `I2` during this cycle, pending completion of `I1`'s execution, thereby delaying execution of `I2` in the current/same cycle, only executing in the subsequent cycle (i.e., concurrently with `I3`).

If there are *no* dependencies among subsequent instructions `I3`, `I4`, and/or `I5` with respect to `I1`, then the former can all still proceed with execution uninterruptedly in the same cycle. This yields the following (ignoring transient effects such as initial filling of the pipeline, etc. for simplicity):

```
CPI = 2 cycles / 5 instructions = 0.4
```

This is a slight deviation from the ideal of `1 cycle / 5 instructions = 0.2`, however, as this analysis suggests, many such dependencies (which *do* occur in practice) will further exacerbate this problem (i.e., deviating/increasing away from `0` cycles per instruction).

## 4. RAW Dependencies

As we have just seen (cf. Section 3), even the ideal processor (i.e., that which can execute *all* instructions per cycle) still must obey **RAW (read-after-write) dependencies**, i.e., it must still wait for results to be produced in order to be used by subsequent instructions requiring those results. This in turn generates inherent ***delays*** which will occur even in such an ideal processor, and therefore the instruction-level parallelism (ILP) is not `0`, but rather something larger than that.

<center>
<img src="./assets/06-005.png" width="450">
</center>

Consider the instructions in the figure shown above. RAW dependencies are denoted by green curved arrows. Here, there are three downstream RAW dependencies (`I2`, `I4`, and `I5`), while `I1` and `I3` can execute normally. Therefore, in the ideal situation:

```
CPI = 3 cycles / 5 instructions = 0.6
```

Additionally, with an added dependency between `I2` and `I3` (denoted by red in the figure shown above), there is now full RAW dependency across all five instructions (i.e,. all five cycles are required to perform all five instructions), resulting in the following:

```
CPI = 5 cycles / 5 instructions = 1
```

Therefore, in general, the RAW dependencies will dictate the lower limit of the possible CPI (i.e., somewhere between `0` and `1`), even with an ideal processor (i.e., one which can otherwise efficiently fetch all instructions, decode/read arbitrarily many registers simultaneously, etc.--but still *cannot* provide time travel!).

### 5. WAW Dependencies


