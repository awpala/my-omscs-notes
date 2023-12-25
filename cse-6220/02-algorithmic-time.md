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

### ***Answer and Explanation***:

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

This quiz further explores the notion of a computational "speed limit."

<center>
<img src="./assets/02-004Q.png" width="350">
</center>

Consider a two-dimensional mesh of physical processors (as in the figure shown above). Imagine that such a many-core processor fits on a physical die of size $\ell  \times \ell$.

<center>
<img src="./assets/02-005Q.png" width="350">
</center>

Within the mesh, every interior point is connected to its eight nearest neighbors. Correspondingly, this means that each processing unit can communicate along diagonal routes (as in the figure shown above).

Now, consider a ***single operation*** on this mesh, defined as follows.

<center>
<img src="./assets/02-006Q.png" width="450">
</center>

The operation begins at the processing unit located at the center (as in the figure shown above).

<center>
<img src="./assets/02-007Q.png" width="450">
</center>

The operation subsequently travels as a signal to a unit at one of the corners (as in the figure shown above).

<center>
<img src="./assets/02-008Q.png" width="450">
</center>

The operation then reverses its path, making its way back to the center (as in the figure shown above).

<center>
<img src="./assets/02-009Q.png" width="450">
</center>

Finally, the operation returns back to the center (as in the figure shown above).

<center>
<img src="./assets/02-010Q.png" width="650">
</center>

Now, consider performing 3 trillion such operations per second (i.e., `3 Top/s`) in a ***sequential*** manner.
  * ***N.B.*** Recall (cf. Section 2) that `1 Top/s` is equivalent to $10^{12}$ operations per second.

If the signal travels at the speed of light, what is the maximum physical dimension of this mesh (i.e., $\ell$)? (Provide the answer in units of microns [$\mu m$], where 1 micron is $10^{-6}$ m. Round the answer to 1 significant figure.)

***N.B.*** The speed of light is approximately $3 \times 10^{8}$ `m/s`.

### ***Answer and Explanation***:

<center>
<img src="./assets/02-011A.png" width="650">
</center>

The maximum physical dimension of the mesh is $\ell \leq 70\ \mu \rm{m}$.

<center>
<img src="./assets/02-012A.png" width="650">
</center>

The path length of a single round trip is $2 \times [(\ell \sqrt{2})/2] = \ell \sqrt{2}$.

<center>
<img src="./assets/02-013A.png" width="650">
</center>

Performing 3 trillion of these round trips per second therefore implies the following:

$$
3 \times {10^{12}}{\rm{\ }}{\textstyle{{{\rm{op}}} \over {\rm{s}}}} = {\textstyle{{1{\rm{\ op}}} \over {1{\rm{\ round\ trip}}}}} \times {\textstyle{{1{\rm{\ round\ trip}}} \over {\ell \sqrt 2 }}} \times \underbrace {\left( {3 \times {{10}^8}{\rm{ }}{\textstyle{{\rm{m}} \over {\rm{s}}}}} \right)}_{{\rm{speed\ of\ light}}} \Rightarrow \ell  = 70{\rm{\ \mu m}}
$$

<center>
<img src="./assets/02-014A.png" width="650">
</center>

$70\ \rm{\mu m}$ is approximately equivalent to the width of a human hair. Therefore, the implication of this exercise is that in order to hit this computational speed target (i.e., the speed of light), assuming that the information propagates at this speed, then the corresponding processor must be ***incredibly*** small to achieve this.

## 4. Space Limits Quiz and Answers

<center>
<img src="./assets/02-015Q.png" width="650">
</center>

Consider a memory chip whose area is equivalent to the cross-sectional area of a human hair, or approximately $4900 \rm{\ \mu m}^2$.

Now, suppose it is desired to store `1 TB` of data on such a memory chip.
  * ***N.B.*** $1\ \rm{TB} = 10^{12} \rm{\ bytes}$.

What is the ***physical area*** of a ***single bit*** (***not*** a byte) on such a chip? (Express the answer in units of $\rm{\ \mu m}^2/\rm{bit}$.)

### ***Answer and Explanation***:

<center>
<img src="./assets/02-016A.png" width="650">
</center>

The corresponding size of a single bit given the target capacity of `1 TB` is $6.125 \times 10^{-10}\rm{\ \mu m}^2/\rm{bit}$.

<center>
<img src="./assets/02-017A.png" width="650">
</center>

This result derives from the following:

$$
{\textstyle{{4900\;\mu {{\rm{m}}^{\rm{2}}}} \over {{{10}^{12}}\;{\rm{bytes}}}}} \times {\textstyle{{1\;{\rm{byte}}} \over {8\;{\rm{bits}}}}} = 6.125 \times {10^{ - 10}}\;\mu {{\rm{m}}^{\rm{2}}}{\rm{/bit}}
$$

Considering such a single bit (as in the figure shown above), and assuming it is a square per-bit area, this corresponds to a side length of $\sqrt {6.125 \times {{10}^{ - 10}}\;\mu {{\rm{m}}^{\rm{2}}}{\rm{/bit}}}  \approx 2.5 \times {10^{ - 11}}\;\mu {\rm{m/bit}}$, or approximately $\textstyle{1 \over 4}Å$ (angstrom) per side, which is on the order of an atomic radius.
  * ***N.B.*** A single ***classical bit*** (as opposed to a ***quantum bit***) is effectively physically constrained by this single-atom size.

Therefore, the implication of this exercise is that at a certain point of size reduction, there will be a limit to how much such "squeezing" (i.e., into a volume of physical space) can be achieved, beyond which only additional ***locality*** will provide incremental performance improvements with respect to speed.

## 5. Balance in Time Quiz and Answers

Another important trend in computing systems is the ***growing gap*** between the **compute speed** and the **communication speed**.

<center>
<img src="./assets/02-018Q.png" width="650">
</center>

Recall (cf. Lesson 1) the basic von Neumann architecture (as in the figure shown above), comprised of a **processor** and a local **fast memory**, which in turn is connected to a large but **slow memory**.

The processor can perform $R$ operations per second; it turns out that this rate is related to the **transistor density** (i.e., the number of transistors that can fit in a given area of physical space).

The "classic plot" for the trend of transistor density over time is as in the figure shown above.
  * Over the preceding 40 years or so, the transistor density has approximately doubled every `1.9 years`, with a corresponding increase by a factor of approximately $10^{6}×$ over the last 40 years.

***N.B.*** Generally speaking, as transistors decrease in size, this increases their density (for the same area), and correspondingly the signaling time between the transistors also decreases accordingly (thereby allowing faster computation time). Therefore, the plot implies that as transistor density increases, $R$ (i.e., the number of operations performed per unit time) increases proportionally accordingly.

<center>
<img src="./assets/02-019Q.png" width="650">
</center>

The other notable feature of the von Neumann computing system is the slow-fast memory transfer cost (cf. Lesson 1) (as in the figure shown above).

If the rate of data movement back and forth between the slow and fast memories is denoted by $\beta$ (having units of `words/time`), then similarly to $R$, $\beta$ also has a natural historical growth rate (as in the figure shown above).

There is a standard benchmark called the **stream**, which measures this growth rate.
  * $\beta$ has doubled approximately every `2.9 years`.

<center>
<img src="./assets/02-020Q.png" width="650">
</center>

Recall (cf. Lesson 1) that the **machine balance point** (denoted by $B$, having units of `operations/word`) is defined as follows:

$$
B\equiv {R \over \beta }
$$

***N.B.*** In this context, $B$ essentially defines the peak compute throughput divided by the peak memory bandwidth.

What is the doubling time of $B$? (Express the answer in years, rounded to 2 significant figures.)

### ***Answer and Explanation***:
