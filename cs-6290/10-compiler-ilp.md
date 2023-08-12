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
