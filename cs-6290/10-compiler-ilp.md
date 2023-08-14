# Compiler ILP

## 1. Lesson Introduction

We have now completed discussion of out-of-order processors (cf. Lessons 6 through 9), which attempt to execute *more* than one instruction per cycle.

Now, in this lesson, we will discuss how the **compiler** can facilitate this process.

## 2. Can Compilers Help to Improve IPC?

<center>
<img src="./assets/10-001.png" width="650">
</center>

Can compilers help to improve **instructions per cycle (IPC)** (i.e., the number of instructions per cycle that the processor achieves)?

For this purpose, there are ***two*** particular ways in which the compiler indeed *can* facilitate IPC:
  * The instruction-level parallelism (ILP) of the program itself may be ***intrinsically limited***
    * This may be due to **dependency chains**, whereby instructions can occur in such a manner in which an inter-dependency "chain" forms (e.g., `R1` → `R2` as in the figure shown above). Such a dependency chain(s) can have a detrimental effect on ILP, as this effectively forms a single-instruction-per-cycle "bottleneck" within the program itself. 
      * As we shall see, the compiler can facilitate with resolving this issue, i.e., by eliminating such dependency chains.
  * The **hardware** itself has a limited "window" into the program
    * For example, independent instructions can occur spatiotemporally distantly from each other within the program itself, which may otherwise be amenable to improved ILP for such a program if operating on a capable/ideal processor. However, due to this "distance," a real processor may not be able to appropriately "perceive" this independence between the instructions (e.g., due to exhausted ROB-entries space prior to reaching the distant/downstream but otherwise independent instructions, for example `ADD R7, R8, R9` in the figure shown above, which is otherwise independent of the upstream instructions involving `R1` and `R2`).
      * As we shall see, The compiler can facilitate with resolving this issue, i.e., by placing such "distant" (but otherwise independent) instructions "closer" to each other, thereby achieving improved ILP (and correspondingly increased IPC, closer to the ideally achievable ILP).

## 3. Tree Height Reduction

<center>
<img src="./assets/10-002.png" width="650">
</center>

One example of a compiler-facilitated instruction-level parallelism (ILP) improvement in a program is the technique called **tree height reduction**.

Consider the following program, which computes `R8 = R2 + R3 + R4 + R5`:

```mips
ADD R8, R2, R3 # I1
ADD R8, R8, R4 # I2
ADD R8, R8, R5 # I3
```

Performing the instructions in this manner creates a dependency chain among the three instructions via `R8`, which necessarily imposes a sequential, one-instruction-per-cycle execution of the three instructions in turn.

<center>
<img src="./assets/10-003.png" width="650">
</center>

To resolve this "bottleneck," the compiler performs tree height reduction as follows. The compiler determines that instead of sequential summing the numbers (thereby creating a dependency chain), it can alternatively group the instructions' additions as pairs `(R2 + R3)` and `(R4 + R5)`, with each pair being independently determinate/computable, resulting in the following modification of the program:

```mips
ADD R8, R2, R3 # I1ʹ
ADD R7, R4, R5 # I2ʹ
ADD R8, R8, R7 # I3ʹ
```

This correspondingly allows for instructions `I1′` and `I2′` to be executed independently of each other, reducing the overall cycles requirement from `3` (strictly sequentially) to `2` (instructions `I1′` and `I2′` executing in parallel, followed by instruction `I3′`).

Note that tree height reduction is ***not*** always feasible. In this particular case, it exploits the intrinsic **associativity** of addition operations; however, ***not*** all operations are associative in this manner. Therefore, such a technique is only appropriate if it does ***not*** otherwise alter the intended/correct semantics of the (in-order-equivalent) program itself.

## 3. Tree Height Reduction Quiz and Answers

<center>
<img src="./assets/10-005A.png" width="650">
</center>

Consider the following program, which computes the arithmetic expression `R1 + R2 - R3 + R4 - R5 + R6 - R7`:

```mips
ADD R10, R1, R2  # I1
SUB R10, R10, R3 # I2
ADD R10, R10, R4 # I3
SUB R10, R10, R5 # I4
ADD R10, R10, R6 # I5
SUB R10, R10, R7 # I6
```

Observe that a dependency chain forms in this program via `R10`. Correspondingly, the instruction-level parallelism (ILP) of this program is as follows:

```
6 instructions / 6 cycles = 1 instruction/cycle
```

Perform a tree height reduction on this program, in order to improve instruction-level parallelism (ILP), and compute the correspondingly improved ILP.

***Answer and Explanation***

To implement tree height reduction in this program, observe there are three addition operations (which *are* associative) and three subtraction operations (which are *not* associative). Correspondingly, we can reorder these operations to perform the additions first (and consequently in parallel), as well as use the distributive property with respect to the subtraction (i.e., correspondingly grouping the operands into upstream addition operations prior to subtracting), thereby transforming the target expression to the following: `((R1 + R2) + (R4 + R6)) - ((R3 + R5) + R7)`.

The resulting modified program is as follows:

```mips
ADD R10, R1, R2   # I1′
ADD R11, R4, R6   # I2′
ADD R10, R10, R11 # I3′
ADD R11, R3, R5   # I4′
ADD R11, R11, R7  # I5′
SUB R10, R10, R11 # I6′
```

The corresponding instruction-level parallelism (ILP) is as follows:
* Instructions `I1′` and `I2′` have no dependencies between them, however, instruction `I3′` depends on these upstream instructions' results.
* Instruction `I4′` has no upstream dependencies, and therefore can execute immediately on program start.
* Instruction `I5′` is dependent on the result of upstream instruction `I4′`.
* Instruction `I5′` is dependent on the results of upstream instructions `I3′` and `I5′`.

Correspondingly, these instructions can be executed as follows:

| Instruction | Earliest possible cycle of execution |
|:--:|:--:|
| `I1′` | `C1` |
| `I2′` | `C2` |
| `I3′` | `C1` |
| `I4′` | `C1` |
| `I5′` | `C2` |
| `I6′` | `C3` |

Therefore, the resulting ILP from this tree height reduction is:

```
6 instructions / 3 cycles = 2 instructions/cycle
```

Which is a 2× improvement over the original single-instruction-per-cycle (i.e., dependency-chain-limited) version of the program.

## 4. Make Independent Instructions Easier to Find

<center>
<img src="./assets/10-006.png" width="650">
</center>

In the following sections of this lesson, we will examine the **techniques** which make independent instructions within a program easier for a *real* processor to find (as opposed to an *ideal* processor, which is otherwise capable of examining an *infinite* number of instructions "ahead," unlike a real processor whose capability is limited to only a *finite* number of upcoming instructions).

This will be examined in the context of the following two techniques in particular:
  * **Instruction scheduling** for simple branch-free instruction sequences
    * This includes loop-specific techniques, such as **loop unrolling** (and in particular how these techniques interact with instruction scheduling)
  * **Trace scheduling**, an even more powerful technique

## 5. Instruction Scheduling

<center>
<img src="./assets/10-007.png" width="450">
</center>

Consider compiler-facilitated **instruction scheduling**, as per the following program (an iterative loop):

```mips
loop:
  LW   R2, 0(R1)    # I1
  ADD  R2, R2, R0   # I2
  SW   R2, 0(R1)    # I3
  ADDI R1, R1, 4    # I4
  BNE  R1, R3, Loop # I5
```

* ***N.B.*** This compiler-facilitated instruction scheduling is different/distinct from the instruction scheduling examined previously in the context of Tomasulo's algorithm (cf. Lesson 7), wherein *hardware* is used to reorder instructions in a disparate manner from the program-order initially generated by the compiler. Instead, here, the *compiler* itself will perform an analogous optimization with respect to program ordering (i.e., independently of and prior to the actual machine-code generation for subsequent hardware execution).

<center>
<img src="./assets/10-008.png" width="650">
</center>

First, consider the scenario of a ***simple processor*** (as in the figure shown above), which can only examine the very next instruction (i.e., it is not otherwise attempting to execute the program out-of-order via reservation stations or equivalent mechanism).

In this case, the program sequence occurs as follows:

<table style="width: 100%; text-align: center;">
  <tr>
    <th>Cycle</th>
    <th>Instruction Executed</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>C1</code></td>
    <td><code>I1</code></td>
    <td rowspan="2">Instruction <code>I1</code> requires two cycles to fetch the value from the cache and place it in register <code>R2</code>, thereby requiring a stall of one cycle prior to executing subsequent instruction <code>I2</code></td>
  </tr>
  <tr>
    <td><code>C2</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C3</code></td>
    <td><code>I2</code></td>
    <td rowspan="3">Instruction <code>I2</code> requires three cycles to perform the addition operation (i.e., add <code>R0</code> to <code>R2</code>, with corresponding dependency on upstream instruction <code>I1</code> with respect to operand <code>R2</code>), thereby requiring a stall of two cycle prior to executing subsequent instruction <code>I3</code></td>
  </tr>
  <tr>
    <td><code>C4</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C5</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C6</code></td>
    <td><code>I3</code></td>
    <td>Instruction <code>I3</code> can proceed in cycle <code>C6</code>, after appropriate resolution of operand <code>R2</code> via upstream instruction <code>I2</code></td>
  </tr>
  <tr>
    <td><code>C7</code></td>
    <td><code>I4</code></td>
    <td rowspan="3">Instruction <code>I4</code> can proceed in cycle <code>C7</code>, with no upstream dependencies (including instruction <code>I3</code>, which only reads mutual operand <code>R1</code>), however, this instruction introduces a two-cycle stall for its execution prior to executing subsequent instruction <code>I5</code></td>
  </tr>
  <tr>
    <td><code>C8</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C9</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C10</code></td>
    <td><code>I5</code></td>
    <td>Instruction <code>I5</code> can proceed in cycle <code>C10</code>, after appropriate resolution of operand <code>R1</code> via upstream instruction <code>I4</code></td>
  </tr>
</table>

<center>
<img src="./assets/10-009.png" width="450">
</center>

Now, consider the possible intervention by the compiler to improve the processor's performance with this program. Given the same processor as before, how can the compiler reduce the overall cycles per loop iteration (i.e., `10` per above analysis)?

The compiler can analyze the program as follows:
  * Since the `ADD` in instruction `I2` cannot be performed *immediately* following the `LW` in instruction `I1` (i.e., due to the two-cycle requirement for the `ADD`), it can find an alternate instruction to place in the `I2` position which does *not* depend on the corresponding `LW`.
  * The `SW` in instruction `I3` does depend on the operand of `I2` (i.e., `R2`), however, the `ADDI` in instruction `I4` does *not* have a dependency on the upstream `LW` in instruction `I1`, and therefore instruction `I4` could be placed "upstream" in the program relative to its current position, without otherwise affecting the semantics of the program itself

In performing this modification (i.e., moving `ADDI R1, R1, 4` to upstream position/instruction `I2′`), there must also be a corresponding adjustment in the offset of the `SW` in instruction `I4` to account for this (i.e., new offset `-4`, rather than `0` as before), thereby maintaining the otherwise correct value of operand `R1` for subsequent/downstream instructions.

<center>
<img src="./assets/10-010.png" width="650">
</center>

Per the modified program as follows:

```mips
loop:
  LW   R2, 0(R1)    # I1
  ADDI R1, R1, 4    # I2′
  ADD  R2, R2, R0   # I3′
  SW   R2, -4(R1)   # I4′
  BNE  R1, R3, Loop # I5
```

The corresponding cycles analysis is as follows:

<table style="width: 100%; text-align: center;">
  <tr>
    <th>Cycle</th>
    <th>Instruction Executed</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>C1</code></td>
    <td><code>I1</code></td>
    <td>Instruction <code>I1</code> requires two cycles to fetch the value from the cache and place it in register <code>R2</code></td>
  </tr>
  <tr>
    <td><code>C2</code></td>
    <td><code>I2′</code></td>
    <td>Instruction <code>I2′</code> can proceed in cycle <code>C2</code>, with no upstream dependencies (and furthermore effectively eliminating the stall introduced by upstream instruction <code>I1</code>), however, this instruction introduces a two-cycle stall for its execution prior to executing subsequent instruction <code>I5</code></td>
  </tr>
  <tr>
    <td><code>C3</code></td>
    <td><code>I3′</code></td>
    <td rowspan="3">Instruction <code>I3′</code> requires three cycles to perform the addition operation (i.e., add <code>R0</code> to <code>R2</code>, with corresponding dependency on upstream instruction <code>I1</code> with respect to operand <code>R2</code>), thereby requiring a stall of two cycle prior to executing subsequent instruction <code>I4′</code></td>
  </tr>
  <tr>
    <td><code>C4</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C5</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C6</code></td>
    <td><code>I4′</code></td>
    <td>Instruction <code>I4′</code> can proceed in cycle <code>C6</code>, after appropriate resolution of operand <code>R2</code> via upstream instruction <code>I3′</code></td>
  </tr>
  <tr>
    <td><code>C7</code></td>
    <td><code>I5</code></td>
    <td>Instruction <code>I5</code> can proceed in cycle <code>C7</code>, after appropriate resolution of operand <code>R1</code> via upstream instruction <code>I2′</code> (furthermore, there is no stalls-induced delay, as the three-cycle execution of instruction <code>I2′</code> will have already completed by the start of upstream cycle <code>C5</code>)</td>
  </tr>
</table>

In this compiler-facilitated instruction scheduling, several of the intermediate stalls have been (either explicitly or effectively) eliminated, resulting in a net reduction from `10` cycles to `7` cycles per loop iteration in this program.

## 6. Instruction Scheduling Quiz and Answers

<center>
<img src="./assets/10-011Q.png" width="650">
</center>

Consider the following program:

```mips
LW  R1, 0(R2)  # I1
ADD R1, R1, R3 # I2
SW  R1, 0(R2)  # I3
LW  R1, 0(R4)  # I4
ADD R1, R1, R5 # I5
SW  R1, 0(R4)  # I6
```

With respect to instructions' execution, assume the following:
  * Instruction `LW` requires `2` cycles to execute
  * Instruction `ADD` requires `1` cycle to execute
  * Instruction `SW` requires `1` cycle to execute

Furthermore, assume that the processor is characterized as before (cf. Section 5), i.e., it performs strictly `1` instruction per cycle and executes in-program-order.

How many cycles does this program require to execute as-is? How many cycles does this program require after modification via instruction scheduling in the compiler?

***Answer and Explanation***:

<center>
<img src="./assets/10-012A.png" width="650">
</center>

First, consider the as-is scenario. The corresponding per-cycle analysis is as follows:

<table style="width: 100%; text-align: center;">
  <tr>
    <th>Cycle</th>
    <th>Instruction Executed</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>C1</code></td>
    <td><code>I1</code></td>
    <td rowspan="2">Instruction <code>I1</code> requires two cycles to fetch the value from the cache and place it in register <code>R1</code>, thereby requiring a stall of one cycle prior to executing subsequent instruction <code>I2</code></td>
  </tr>
  <tr>
    <td><code>C2</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C3</code></td>
    <td><code>I2</code></td>
    <td>Instruction <code>I2</code> requires one cycle to perform the addition operation (i.e., add <code>R3</code> to <code>R1</code>, with corresponding dependency on upstream instruction <code>I1</code> with respect to operand <code>R1</code>)</td>
  </tr>
  <tr>
    <td><code>C4</code></td>
    <td><code>I3</code></td>
    <td>Instruction <code>I3</code> requires one cycle to perform the store instruction</td>
  </tr>
  <tr>
    <td><code>C5</code></td>
    <td><code>I4</code></td>
    <td rowspan="2">Instruction <code>I4</code> requires two cycles to fetch the value from the cache and place it in register <code>R1</code>, thereby requiring a stall of one cycle prior to executing subsequent instruction <code>I5</code></td>
  </tr>
  <tr>
    <td><code>C6</code></td>
    <td><code>stall</code></td>
  </tr>
  <tr>
    <td><code>C7</code></td>
    <td><code>I5</code></td>
    <td>Instruction <code>I5</code> requires one cycle to perform the addition operation (i.e., add <code>R5</code> to <code>R1</code>, with corresponding dependency on upstream instruction <code>I4</code> with respect to operand <code>R1</code>)</td>
  </tr>
  <tr>
    <td><code>C8</code></td>
    <td><code>I6</code></td>
    <td>Instruction <code>I6</code> requires one cycle to perform the store instruction</td>
  </tr>
</table>

Therefore, as-is, this program requires `8` cycles.

<center>
<img src="./assets/10-013A.png" width="650">
</center>

Now, consider the compiler-facilitated instruction scheduling scenario. To avoid the stall in cycle `C2`, we must "move up" a downstream instruction which does not otherwise depend on instruction `I1` as-is. This can be achieved by moving instruction `I5` to the second-instruction position (and correspondingly using a non-conflicting register for its target operand, i.e., from `R1` to `R10`). The updated program is thus as follows:

```mips
LW  R1, 0(R2)    # I1
LW  R10, 0(R4)   # I2′
ADD R1, R1, R3   # I3′
ADD R10, R10, R5 # I4′
SW  R1, 0(R2)    # I5′
SW  R10, 0(R4)   # I6′
```

The corresponding per-cycle analysis in the updated program is as follows:

<table style="width: 100%; text-align: center;">
  <tr>
    <th>Cycle</th>
    <th>Instruction Executed</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>C1</code></td>
    <td><code>I1</code></td>
    <td>Instruction <code>I1</code> requires two cycles to fetch the value from the cache and place it in register <code>R1</code></td>
  </tr>
  <tr>
    <td><code>C2</code></td>
    <td><code>I2′</code></td>
    <td>Instruction <code>I2′</code> requires two cycles to fetch the value from the cache and place it in register <code>R10</code></td>
  </tr>
  <tr>
    <td><code>C3</code></td>
    <td><code>I3′</code></td>
    <td>Instruction <code>I3′</code> requires one cycle to perform the addition operation (i.e., add <code>R3</code> to <code>R1</code>, with corresponding dependency on upstream instruction <code>I1</code> with respect to operand <code>R1</code>), however, there is no stalls-induced delay, as the two-cycle execution of instruction <code>I1</code> will have already completed by the start of cycle <code>C3</code></td>
  </tr>
  <tr>
    <td><code>C4</code></td>
    <td><code>I4′</code></td>
    <td>Instruction <code>I4′</code> requires one cycle to perform the addition operation (i.e., add <code>R5</code> to <code>R10</code>, with corresponding dependency on upstream instruction <code>I2′</code> with respect to operand <code>R10</code>), however, there is no stalls-induced delay, as the two-cycle execution of instruction <code>I2′</code> will have already completed by the start of cycle <code>C4</code></td>
  </tr>
  <tr>
    <td><code>C5</code></td>
    <td><code>I5′</code></td>
    <td>Instruction <code>I5′</code> requires one cycle to perform the store instruction</td>
  </tr>
  <tr>
    <td><code>C6</code></td>
    <td><code>I6′</code></td>
    <td>Instruction <code>I6′</code> requires one cycle to perform the store instruction</td>
  </tr>
</table>

In this compiler-facilitated instruction scheduling, *both* of the intermediate stalls have been eliminated, resulting in a net reduction from `8` cycles to `6` cycles.

## 7. Scheduling and If Conversion

<center>
<img src="./assets/10-014.png" width="650">
</center>

Having seen how compiler-facilitated instruction scheduling works, now consider how such compiler optimization interacts with **if conversion**.

Recall (cf. Lesson 5) that if conversion transforms branching code as in the left portion of the figure shown above (where orange is the `if` branch, and green is the `else` branch).
  * Before performing the if conversion, the code section upstream of the if-converted branches (uncolored in the figure shown above) can be ***easily*** rescheduled. Similarly, *within* the branched code sections (i.e., orange and green per the figure shown above) rescheduling can be performed easily, as well as in the code section downstream of the branches (uncolored in the figure shown above).
  * However, rescheduling in if schedule becomes ***challenging*** for instructions spanning ***across*** the if-converted branches to the downstream code section (e.g., if the downstream code section contains an instruction to fill a store in the green section, then if branching ultimately directs to the orange section, then ultimately this downstream instruction is never executed).

After if conversion is performed (as in the right portion of the figure shown above), the post-transformation code is effectively "inlined" into a branch-free sequence. Consequently, *all* of the instructions execute in turn, with appropriate predication applied. In this manner, instructions can "cross" the code sections readily without issue (e.g., green section to orange section, downstream section to green section, orange section to upstream section, and even downstream section up to upstream section).

Therefore, overall, if conversion introduces many more opportunities for replacing stall cycles with useful instructions, thereby improving compiler-facilitated instruction scheduling in addition to the aforementioned (cf. Lesson 5) benefit with respect to branch prediction (i.e., avoiding otherwise unnecessary branch instructions).

## 8. If Conversion for a Loop

<center>
<img src="./assets/10-015.png" width="650">
</center>

Having seen the performance improvement provided by if conversion, can this technique also be useful in a loop? Recall the loop program from Section 5, as in the figure shown above. Assume that each instruction requires `2` cycles to execute.
  * Before the compiler-facilitated instruction scheduling (left side of the figure shown above), there are three stall cycles (denoted by left-directed magenta arrows in the figure shown above).
  * After the compiler-facilitated instruction scheduling (right side of the figure shown above), there is still a necessary stall cycle, since the store instruction `SW` must be performed before the branching instruction `BNE`, and furthermore the instruction `SW` has an upstream dependency (`ADD R2, R2,  R3`, via operand `R2`) which introduces the necessary stall accordingly (i.e., to complete the instruction `ADD`).

Examining the right-side code, in principle, if conversion would allow to perform the branching code immediately following the branching instruction `BNE`, thereby eliminating the branch via predication, possibly further eliminating the remaining stall. However, in such a scenario, a loop is ***not*** amenable to if conversion because for every subsequent iteration of the loop, it would be necessary to produce a new predicate, which in turn would add this additional overhead *per loop iteration*, with the resulting new predicates only becoming useful/relevant when the predicate is actually true. This in turn would have an adverse impact on performance (e.g., a million-iterations loop with only *one* predicate actually being true).

Therefore, an alternative to if conversion for loops (i.e., moving things "upstream" from "future" iterations) with a similar synergistic improvement on compiler-facilitated instruction scheduling is desirable. This improvement *does* in fact exist: It is called **loop unrolling**, which is discussed next.

## 9. Loop Unrolling Benefits
