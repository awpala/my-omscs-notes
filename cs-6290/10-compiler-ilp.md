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
    <th>Cycle(s)</th>
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
    <td rowspan="3">Instruction <code>I2</code> requires three cycles perform the addition operation (i.e., add <code>R0</code> to <code>R2</code>, with corresponding dependency on upstream instruction <code>I1</code> with respect to operand <code>R2</code>), thereby requiring a stall of two cycle prior to executing subsequent instruction <code>I3</code></td>
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

Now, consider the possible intervention by the compiler to improve the processor's performance with this program.
