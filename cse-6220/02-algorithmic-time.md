# Algorithmic Time: Energy and Power

## 1. Introduction

At the Massachusetts Institute of Technology (MIT) in the early 1980s, Danny Hillis attempted to build a new supercomputer, called a **connection machine**, characterized by lights blinking according to where communication was occurring within the system.

Hillis' consequent PhD dissertation on this work subsequently won the doctoral dissertation award from the Association of Computing Machinery (ACM) in 1985, one of the highest honors in the field of computer science.

This award was conferred despite the dismal title of its concluding chapter:

> Chapter 7: New Computer Architectures and Their Relationship to Physics or, Why Computer Science is ***No Good***

Hillis was critiquing parallel algorithms research at the time. Hillis argued that, ultimately, an algorithm must run on a ***physical machine***, subject to the constraints of the laws of physics. In this vein, Hillis contended that algorithms researchers were "overly generously" abstracting away too many such (arguably non-trivial) details regarding the ***physical costs*** of computation.
  * In particular, Hillis was concerned with the speed of light, which fundamentally limits how fast information can travel.

Whether such physical costs ***can*** indeed be "reasonably ignored" is still an open question. However, there is nevertheless merit to Hillis' assertion that, at a minimum, such physical costs are at least "relevant considerations."

This lesson will begin from this line of thinking, and poses the following question accordingly:

> What would it mean to consider the ***physical costs*** in designing an algorithm?

## 2. Speed Trends Quiz and Answers

This lesson will proceed through a series of calculations, partly inspired by Danny Hillis' PhD thesis, in order to draw conclusions regarding the physical limits of computation.

<center>
<img src="./assets/02-001Q.png" width="650">
</center>

Consider the quad-core Intel Ivy Bridge processor from 2015 (as in the figure shown above).

In the best case, this processor executes approximately 100 billion operations per second, or equivalently `100 Gops/s` (where `1 Gop/s` [gigaop] is $10^{11}$ operations per second).

Roughly speaking, this rate of throughput doubles approximately every 2 years.

Given this information, how fast will a comparable processor be in 10 years (i.e., 2025)? (Express the answer in units of `Gop/s`.)

### Answer and Explanation:

<center>
<img src="./assets/02-002A.png" width="650">
</center>

In 2025, an equivalent processor will perform `3200 Gop/s` (or equivalently `3.2 Top/s`).

<center>
<img src="./assets/02-003A.png" width="650">
</center>

In 10 years, there will be `5` doublings, implying a performance speedup of $2^5 = 32$. Therefore, relative to a 2015 processor, a 2025 processor will run at $100 \times 32 = 3200$ `Gop/s` (or equivalently `3.2 Top/s`).

***N.B.*** Even in 2015, there are specialized processors capable of achieving on the order of trillions of operations per second. Nevertheless, the purpose of this exercise is to give an intuitive feel for peak performance and the corresponding rate of growth that exponential trends bring.

## 3. Speed Limits Quiz and Answers
