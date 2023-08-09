# Memory Ordering

## 1. Lesson Introduction

We have seen (cf. Lesson 8) that an out-of-order processor will track when one instruction uses a register value produced by another.

However, load and store instructions can access the *same* memory location without using the same register to perform the access; this lesson explores *how* exactly this can be done correctly in an out-of-order processor.

## 2. Memory Access Ordering

<center>
<img src="./assets/09-001.png" width="650">
</center>

We have seen (cf. Lessons 7 and 8) that reorder buffer (ROB) and Tomasulo's algorithm can be used to enforce the order of **dependencies** on registers between instructions.

However, a ***question*** still remains: What about **memory access** ordering?
  * There are load and store instructions available; do they really need to be performed *strictly* in program order, or can these be reordered, too?

So far, we have eliminated **control dependencies** using **branch prediction**.

Furthermore, we have eliminated **false dependencies** (i.e., dependencies via registers) using **register renaming**.

Next, we will see how to obey **read-after-write (RAW) register dependencies** using **Tomasulo-like scheduling**.
  * Here, we have instructions waiting in reservation stations until their dependencies have been satisfied, at which point they can proceed to execution out of program order.

Note that the data-dependency handling performed thus far (i.e., false dependencies and RAW register dependencies) only pertain to **register dependencies**, in which one instruction produces a value in a register used by another register. But what about memory dependencies?

Consider the following program:

```mips
SW R1, 0(R3)
LW R2, 0(R4)
```

Here, there may be a dependency between the memory value written by `SW` (store) and that read by `LW` (load).
  * For example, if registers `R3` and `R4` hold the ***same*** address, then `LW` must get the value from `SW`, in which case these instructions must be performed ***in order***.
  * Conversely, if `R3` and `R4` hold ***different*** addresses, then (as previously seen with registers) it is not strictly necessary to maintain program-order between these memory accesses.

Nevertheless, we have not yet seen how to handle out-of-order memory access; correspondingly, this topic will be the focal point of this lesson.

## 3. When Does Memory Write Happen?

