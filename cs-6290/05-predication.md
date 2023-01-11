# Predication

## 1. Lesson Introduction

This lesson continues the study of control hazards. We already know about branch predictors (cf. Lesson 4), and we also know that some branches are *really* difficult to predict, even with a sophisticated branch predictor.

In this lesson, we will see how the compiler can assists with completely avoiding some of these difficult-to-predict branches.

## 2. Predication

<center>
<img src="./assets/05-001.png" width="650">
</center>

**Predication** is another method for dealing with control hazards. Unlike branch prediction, when we are really trying to guess which way the if-then-else, loop, or other branching will occur, predication is another way of dealing with control dependencies.

Branch prediction is about guessing where the program is going.
  * Usually there is no penalty for correct branch prediction; essentially, we just keep fetching as if there were no branch, and even if the branch is actual taken then we continue fetching from the correct location, thereby avoiding a penalty.
  * However, a key ***problem*** with branch prediction is that in modern processors there is a ***huge*** penalty for mispredictions.
    * Bear in mind that modern processors have a ***deep*** pipeline, with *many* stages occurring prior to encountering the missed prediction. Furthermore, each stage contains many in-progress instructions; therefore, a misprediction negates *all* of this work (typically on the order of several 10s of instructions, e.g., `48 ~ 50` instructions in a 12-stage pipeline with 4 instructions per cycle)!

Predication involves doing the work of *both* the taken and not taken directions of a branch.
  * In this manner, the waste is up to 50% of the work performed (i.e., at the position within the pipeline that the branch occurs, half of the content fetched to that point could be from one path while the other half is from the other path, with only effectively half overall being used and the other half being discarded).

So, then, what is particularly useful about predication, given the relatively low penalty potential of branch prediction vs. the inherent "wastefulness" of predication? To demonstrate this, let's consider some conditional branches that we might want to predict, as follows.

<center>
<img src="./assets/05-002.png" width="250">
</center>

For a ***loop***, usually branch prediction is preferable.
  * With loop branches, the more iterations that occur, the more predictable they are in general.
  * Conversely, with predication, in each iteration of the loop, the work is divided into two: One is for the next iteration, the other for after the loop. Therefore, with 1000 iterations, very little of the work ends up being done "correctly," i.e., the branch diverges too much (as in the figure shown above).
    * When we need to determine whether or not to stay in the loop, we start the work of both of these, with one path going off of the loop and the other going back into the loop. This proceeds similarly with subsequent branches/paths, and with all of this work occurring concurrently, a very small fraction of the work (i.e., the right-most circled in the figure shown above) results in staying in the loop itself, with the other ("non-useful") work encompassing various variants of (unnecessarily) exiting the the loop in each iteration.

For ***function calls***, a similar phenomenon occurs, i.e., branch prediction is more advantageous.
  * Here, predication is not sensible, because calls and returns always go to the return address, so the notion of "not going" there is nonsensical.

<center>
<img src="./assets/05-003.png" width="250">
</center>

Consider a ***large if-then-else***. Here, we have a decision which yields two possible paths (as in the figure shown above). Here, should we attempt to predict this decision, or to predicate (such that we do the work of both and eventually merge and re-continue through the execution path).
  * If we predict, we waste up to 50 instructions (i.e., with mispredictions), but more likely (i.e., with correct predictions) we waste nothing.
  * Conversely, if we predicate, and assuming the two branches have equal waste, then given 200 instructions we will waste 100 of them either way. Therefore, the waste is larger than the corresponding penalty of branch prediction (50). Therefore, branch prediction is also more sensible here.

<center>
<img src="./assets/05-004.png" width="250">
</center>

Now, consider a ***small if-then-else*** (as in the figure shown above). With 5 instructions apiece in the then and else paths...
  * Here, predication involves 10 instructions, followed by subsequent instructions done by the program either way (i.e., irrespectively of prediction vs. predication).
    * With 100% waste, we end up with `1.00 * 5 = 5` instructions wasted with predication.
  * With prediction, there is no penalty with correct predictions, however, mispredictions yield a waste of 50 instructions, which is substantially ***worse*** than predication.
    * With a 10% misprediction rate, we end up with `0.10 * 50 = 5` instructions wasted with prediction. Therefore, with an accuracy of 90% or better, we are better off predicting; otherwise, with a worse accuracy than this, predication is better.

Therefore, in general, the smaller the if-then-else, the stronger the bias towards predication and away from prediction (barring high prediction accuracy).

## 3. If Conversion

<center>
<img src="./assets/05-005.png" width="650">
</center>

Before discussing how predication works in hardware, first consider the technique called **if conversion**, which is how the compiler creates the code that will be executed along both paths.

```c
if (cond) {
  x = arr[i];
  y = y + 1;
} else {
  x = arr[j];
  y = y - 1;
}
```

Consider the relatively small if-then-else code fragment, as shown above. If conversion transforms this code into the work of both paths, followed by a selection of some sort between the results of these two paths, as follows:

```c
x1 = arr[i];
x2 = arr[j];
y1 = y + 1;
y2 = y - 1;
x = cond ? x1 : x2;
y = cond ? y1 : y2;
```

But a question still remains: How is this done?

```mips
BEQ ...,
  MOV x, x2
  B Done

MOV x, x1
⋮
```

If we convert statement `x = cond ? x1 : x2;` (as shown above) into a conditional expression  that still branches based on the condition and then performs the move of `x2` into `x` or otherwise moves `x` into `x1`, then we haven't really done much; we have simply converted one branch into another, and now we have this branch twice (unless we have some sort of correlating predictor, such as the global history predictor), resulting in possibly *two* missed predictions, rather than only the *one* that could have resulted.

<center>
<img src="./assets/05-006.png" width="450">
</center>

Therefore, if this is the *only* possibility, then  if conversion is simply ***not*** performed.


In order for if conversion to work here, what is need is an instruction such as `MOV x, x1, cond` via flag `cond` indicating `true`.

## 4. Conditional Move

<center>
<img src="./assets/05-007.png" width="650">
</center>

Therefore, the simplest form of predication supporting hardware is a **conditional move** instruction.

In the MIPS instruction set:
  * The instruction `MOVZ` takes two sources (`Rs`, `Rt`) and a destination register (`Rd`).
    * It compares `Rt` to `0`...
      * If `Rt` is `0`, then `Rd` is set to `Rs`.
      * Otherwise, `Rd` is unchanged.
    * Consequently, there is no branch anymore, as there is only a single instruction.
  * The instruction `MOVN` works similarly to `MOVZ`, except that it moves `Rs` into `Rd` only if `Rt` is *not* `0`.

```mips
R3 = cond
R1 = ... x1 ...
R2 = ... x2 ...
MOVN x, R1, R3
MOVZ x, R2, R3
```
 
Therefore, to implement `x = cond ? x1 : x2;` using MIPS, this could be done as shown above. The result places one of `R1` or `R2` into `x`, depending on whether `R3` is `true` or `false` (i.e., depending on the condition `cond`).

```c
if (cc)
  Dst = src;
```

Similarly, the x86 instruction set has a set of `CMOV` instructions (e.g., `CMOVZ`, `CMOVNZ`, `CMOVGT`, etc.), wherein the condition is determined by the flags. All of these instructions effectively implement the shown above (where `cc` denotes the condition code, and `Dst` and `src` represent the destination and source registers, respectively). The corresponding implementation would be similar to that shown previously for MIPS, with the inclusion of `R3 = cond` being unnecessary here (but rather supplanted with a corresponding `CMOV` instruction instead).

## 5. `MOVZ`/`MOVN` Quiz and Answers

<center>
<img src="./assets/05-009A.png" width="650">
</center>

Consider how conditional move instruction are used, given the following MIPS code:
```mips
  BEQZ R1, Else
  ADDI R2, R2, 1
  B    End
Else:
  ADDI R3, R3, 1
End:
```
After if conversion, the result is as follows:
```mips
ADDI R4, R2, 1
ADDI R5, R3, 1
# ?
# ?
```

What are instructions (`?`) required to perform the if conversion?

***Answer and Explanation***

```mips
ADDI R4, R2, 1
ADDI R5, R3, 1
MOVN R2, R4, R1 # answer
MOVZ R3, R5, R1 # answer
```

