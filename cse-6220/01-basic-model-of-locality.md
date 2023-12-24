# Basic Model of Locality

## 1. Introduction

<center>
<img src="./assets/01-001.png" width="250">
</center>

Real machines have **memory hierarchies** (as in the figure shown above). This means that in between the **processor** and the primary storage device (e.g., a **disk**), there are ***layers*** of memory in between. As the layer approaches the processor, the layer becomes correspondingly faster but smaller.
  * ***N.B.*** The difference in all of the size, latency, and bandwidth between each successive layer may be an order of magnitude.

Unfortunately, our usual model of an algorithm does ***not*** distinguish between the size and the speed of these different memory layers. Nevertheless, in order to achieve ***high performance***, then it is necessary to correspondingly ***design*** algorithms in such a manner which ***exploits*** this memory hierarchy accordingly.

Sometimes the **hardware** or **operating system** can ***manage*** these memory layers ***automatically***. However, using these memory layers ***optimally*** is nevertheless ***difficult*** to achieve in practice (particularly when using such automated approaches). Therefore, it is necessary to design algorithms appropriately for this purpose; this topic is the starting point of the lesson accordingly.

## 2. A First, Basic Model

### Two-Level Memory Hierarchies

<center>
<img src="./assets/01-002.png" width="650">
</center>

In order to design a **locality-aware algorithm**, a **machine model** is required. Consider a variation on the **von Neumann architecture** (as in the figure shown above).

<center>
<img src="./assets/01-003.png" width="650">
</center>

The von Neumann architecture has a **processor** (as in the figure shown above). The processor performs basic ***compute operations*** (e.g., addition, subtraction, branching, etc.).
  * ***N.B.*** For present purposes, assume that this processor is ***sequential***.

<center>
<img src="./assets/01-004.png" width="650">
</center>

Furthermore, the processor connects to a **main memory** (as in the figure shown above), which is nearly ***infinite*** in its capacity, however, it is very ***slow*** (relative to the processor).

<center>
<img src="./assets/01-005.png" width="650">
</center>

Lastly, between the slow main memory and the processor, there is also a **fast memory** (as in the figure shown above), which is much faster than the main memory, however, it is also much smaller in capacity by comparison.

<center>
<img src="./assets/01-006.png" width="650">
</center>

Let the size of this fast memory be denoted by $Z$, having measurement units of `words`.

<center>
<img src="./assets/01-007.png" width="650">
</center>

Such **two-level memory hierarchies** may already be familiar from previous exposure. For example, consider the Intel Ivy Bridge multi-core processor (as in the figure shown above). The fast memory is comprised of the **last-level cache (LLC)** (i.e., shared L3 cache), sitting between the slower main memory (not shown in the figure) and the processor itself.

<center>
<img src="./assets/01-008.png" width="650">
</center>

Another example is the Adapteva Parallella board (as in the figure shown above), used for hobby programming. The Parallella has a ***slow***, non-volatile SD card which behaves similarly to a disk, as well as a small amount of ***faster*** main memory (relative to the comparably much slower SD card)

### Rules for the First, Basic Model

There are two ***rules*** about how computations run in this first, basic model.

<center>
<img src="./assets/01-009.png" width="650">
</center>

The **first rule** (the **local data rule**) states that the processor ***cannot*** perform any operations unless the operands are present in the ***fast*** memory.

<center>
<img src="./assets/01-010.png" width="650">
</center>

The **second rule** (the **block transfer rule**) states that when data moves back and forth across the **channel** (denoted by brown double-arrow in the figure shown above) between slow and fast memory, it does so in **chunks** of size $L$ words.

<center>
<img src="./assets/01-011.png" width="350">
</center>

To further understand the second rule, consider the scenario whereby a word is loaded at address $x$ from main memory (as in the figure shown above). Per the block transfer rule, a ***cost*** is incurred in order to move an additional $L - 1$ nearby words.

<center>
<img src="./assets/01-012.png" width="350">
</center>

Furthermore, ***which*** particular words are transferred along with the target word $x$ depends on how the data is correspondingly ***aligned*** in the slow memory.

<center>
<img src="./assets/01-013.png" width="650">
</center>

Therefore, when designing an algorithm for this model, **data alignment** is a key ***issue*** which must be considered. Nevertheless, most real-life memory systems do indeed perform such block transfers, and therefore both multi-level memories ***and*** block transfers are indeed relevant considerations when designing **high-performance algorithms**.

### Costs for the First, Basic Model

Therefore, this first, basic model implies two major **costs** when designing algorithms.

<center>
<img src="./assets/01-014.png" width="650">
</center>

The first cost entails how many **operations** are required by the algorithm, i.e., what is the **computational work** (denoted $W(n)$) performed by the processor.
  * ***N.B.*** Just like there is the concept of "work" in the **work-span model** (discussed later in this course) for a parallel machine, the corresponding concept of "work" in this input/output (I/O) model will generally depend on the input size, $n$.

<center>
<img src="./assets/01-016.png" width="650">
</center>

The second cost entails how many **block transfers** are required by the algorithm (denoted by $Q(n;Z,L)$, and referred to as the algorithm's **input/output (I/O) complexity**).
  * The number of transfers depends on ***both*** the size of the fast memory ($Z$) ***and*** the block transfer size ($L$).

### Example: Reduction

<center>
<img src="./assets/01-017.png" width="650">
</center>

Consider a simple example (as in the figure shown above), whereby the elements of an array of size $n$ are summed.

In order to accomplish this, the processor must perform at least $n-1$ addition ***operations***, or asymptotically:

$$
W\left( n \right) \ge \underbrace {\Omega \left( n \right)}_{\scriptstyle n - 1 \atop 
  \scriptstyle {\rm{additions}}}
$$

<center>
<img src="./assets/01-018.png" width="650">
</center>

Furthermore, with respect to ***memory transfers***, intuitively, the data must be traversed at least once. Correspondingly, this suggests the following natural lower bound on the transfers accordingly:

$$
Q\left( {n;Z,L} \right) \ge \underbrace {\left\lceil {{n \over L}} \right\rceil }_{{\rm{transfers}}} = \Omega \left( {{n \over L}} \right)
$$

***N.B.*** The ceiling (i.e., $\left\lceil {{\textstyle{n \over L}}} \right\rceil$) accounts for the fact that if $n$ is not a multiple of $L$, then a partial-transfer cost must be incurred nevertheless.

Observe that there is ***no*** dependence by $Q$ on $Z$ (the size of the fast memory). Since it is only necessary to access each element *once*, the size of the fast memory is irrelevant (i.e., the data is ***not*** reused either way).
  * ***N.B.*** In general, not reusing data is ***undesirable***.

## 3. Two-Level Memories Quiz and Answers

<center>
<img src="./assets/01-019Q.png" width="650">
</center>

Two-level memories are very ubiquitous. Identify which of the following combinations are valid slow-fast memory pairings. (Select all that apply.)

| Slow Memory | Fast Memory |
|:--:|:--:|
| hard disk | main memory |
| L1 cache | CPU registers |
| tape storage | hard disk |
| remote server RAM | local server RAM |
| the Internet | your brain |
| (other) | (other) |

### ***Answer and Explanation***:

<center>
<img src="./assets/01-020A.png" width="650">
</center>

Indeed, all of these are valid slow-fast memory pairings.

## 4. Alignment Quiz and Answers

<center>
<img src="./assets/01-021Q.png" width="650">
</center>

Suppose the elements of an array are summed (as in the figure shown above), without any additional information regarding the array-data alignment with respect to transfer size $L$. In the ***worst case***, how many transfers are required in order to read the entire array?
  * ***N.B.*** Provide the answer ***exactly***, not asymptotically. Furthermore, if necessary, use floors and/or ceilings.

### ***Answer and Explanation***:

<center>
<img src="./assets/01-022A.png" width="650">
</center>

In the worst case, the total number of transfers is given as follows:

$$
Q\left( {n;Z,L} \right) \le \left\lceil {{n \over L}} \right\rceil  + 1
$$

<center>
<img src="./assets/01-023A.png" width="350">
</center>

To understand this more concretely, consider the example of $n = 4$ and $L = 2$ (as in the figure shown above). There are two pertinent cases for this example.

<center>
<img src="./assets/01-024A.png" width="350">
</center>

In the first case (as in the figure shown above), the array is ***aligned*** on an $L$-word boundary, thereby requiring ***exactly*** $\left\lceil {{\textstyle{n \over L}}} \right\rceil$ transferred.

<center>
<img src="./assets/01-025A.png" width="350">
</center>

Conversely, in the second case (as in the figure shown above), the array is ***not aligned***, and therefore an ***additional*** transfer is required (i.e., $\left\lceil {{\textstyle{n \over L}}} \right\rceil + 1$).

***N.B.*** The purpose of this exercise is simply for awareness of this word-alignment issue; in practice, for purposes of this course, this will be generally regarded as a "minor" detail (which is particularly negligible in the case of $n \gg L$).

## 5. Minimum Transfers to Sort Quiz and Answers

<center>
<img src="./assets/01-026Q.png" width="650">
</center>

Consider the sorting of an array of $n$ words (as in the figure shown above), using a comparison-based algorithm running on a sequential machine with a two-level memory hierarchy.
  * ***N.B.*** Recall from an introductory algorithms course that such a comparison-based sort requires at least $n\log n$ such comparisons (i.e., $W\left( n \right) = \Omega \left( {n\log n} \right)$)

What is an asymptotic ***lower bound*** on the number of slow-fast memory transfers (i.e., on $Q(n;Z,L)$)?
  * ***N.B.*** It is ***not*** necessary for this lower bound to be tight; a trivial bound is sufficient, provided it is reasonably precise. Furthermore, use floor and/or ceiling as/if necessary.

### ***Answer and Explanation***:

<center>
<img src="./assets/01-027A.png" width="650">
</center>

In this case, the trivial lower-bound solution is simply reading the array, i.e.,:

$$
Q\left( {n;Z,L} \right) = \Omega \left( {\left\lceil {{n \over L}} \right\rceil } \right)
$$

or

$$
Q\left( {n;Z,L} \right) = \Omega \left( {{n \over L}} \right)
$$

Here, $n$ indicates that it is necessary to access each word at least *once*. Furthermore, a division by $L$ implies the best-case scenario of reading each element sequentially one block at a time. Lastly, the ceiling accounts for the possibility that $L$ does not divide $n$ (however, its omissions here is sufficiently "loose"/"imprecise").

<center>
<img src="./assets/01-028A.png" width="650">
</center>

Additionally, note the following alternative lower bound:

$$
Q\left( {n;Z,L} \right) = \Omega \left( {{{{\textstyle{n \over L}}\log {\textstyle{n \over L}}} \over {\log {\textstyle{Z \over L}}}}} \right)
$$

This will be discussed later in the course.

## 6. Minimum Transfers to Multiply Matrices Quiz and Answers

<center>
<img src="./assets/01-029Q.png" width="650">
</center>

Consider a matrix-matrix multiplication performed on a machine with a two-level memory hierarchy (as in the figure shown above). Furthermore, assume that the constituent matrices $A$ and $B$ are $n \times n$ square matrices.

Ignoring the possibility of a Strassen (or faster) algorithm, then the work of the matrix multiplication is as follows:

$$
W\left( n \right) = O\left( {{n^3}} \right)
$$

In this case, what is the minimum number of transfers (i.e., $Q\left( {n;Z,L} \right)$)? (Provide an asymptotic lower bound, which is sufficiently/reasonably "tight.")

### ***Answer and Explanation***:

<center>
<img src="./assets/01-030A.png" width="650">
</center>

In this case, the trivial lower-bound solution is:

$$
Q\left( {n;Z,L} \right) = \Omega \left( {{{{n^2}} \over L}} \right)
$$

Here, $n^2$ counts the number of matrix elements, and dividing by $L$ converts $n^2$ into some number of transfers.

<center>
<img src="./assets/01-031A.png" width="650">
</center>

Additionally, a *tighter* lower bound can be specified as follows:

$$
Q\left( {n;Z,L} \right) = \Omega \left( {{{{n^3}} \over {L\sqrt Z }}} \right)
$$

This will be discussed later in the course.

## 7. I/O Example: Reduction

<center>
<img src="./assets/01-032.png" width="650">
</center>

Recall (cf. Section 2) that in the reduction example, the work is linear, i.e.,:

$$
W\left( n \right) = O\left( n \right)
$$

Furthermore, the lower bound on the number of transfers is:

$$
Q\left( {n;Z,L} \right) = \Omega \left( {{n \over L}} \right)
$$

### Sequential Algorithm

Now, consider analysis of a concrete ***algorithm*** in order to determine whether or not such a lower bound can be achieved. The algorithm in question is as follows:

$$
\boxed{
\begin{array}{l}
s \leftarrow 0\\
{\rm{for\ }}i \leftarrow 0{\rm{\ to \ }}n - 1{\rm{\ do}}\\
\ \ s \leftarrow s + X[i]
\end{array}
}
$$

This algorithm is consistent with the conventional sequential RAM model (i.e., one ***without*** the fast memory). The accumulator $s$ maintains the value, and each array element is iterated over and summed accordingly.

### Algorithm for the Two-Level Memory Model

A ***modification*** of this procedure is necessary in order to consider the ***movement*** of data between the slow and fast memories.

<center>
<img src="./assets/01-033.png" width="650">
</center>

With respect to $s$, it can be assumed that it is initialized locally (as in the figure shown above), in the fast memory, as denoted by keyword $\rm{local}$. This is fundamentally the same as any other temporary scalar or local variable in a typical imperative programming language.
  * ***N.B.*** This distinction is made in the pseudocode here for clarify, however, typically this is not a detail "of particular interest."

<center>
<img src="./assets/01-035.png" width="650">
</center>

With respect to the array $X$, ***assume*** that $n \gg Z$.

<center>
<img src="./assets/01-036.png" width="650">
</center>

Furthermore, also with respect to the array $X$, ***assume*** that it is aligned on an $L$-word boundary.

<center>
<img src="./assets/01-037.png" width="650">
</center>

Given these assumptions, the explicit slow-fast transfer operations yield the following modified pseudocode:

$$
\boxed{
\begin{array}{l}
{\rm{local\ }}s \leftarrow 0\\
{\rm{for\ }}i \leftarrow 0{\rm{\ to \ }}n - 1{\rm{\ by \ }}L{\rm{\ do}}\\
\ \ \ \ {\rm{local\ }}\widehat L \leftarrow \min \left( {n,i + L - 1} \right)\\
\ \ \ \ {\rm{local\ }}y\left[ {0:\widehat L - 1} \right] \leftarrow X\left[ {i:\left( {i + \widehat L - 1} \right)} \right]\\
\ \ \ \ {\rm{for\ }}di \leftarrow 0{\rm{\ to\ }}\widehat L - 1{\rm{\ do}}\\
\ \ \ \ \ \ \ \ s \leftarrow s + y[di]
\end{array}
}
$$

<center>
<img src="./assets/01-038.png" width="650">
</center>

In the outer loop, as in the original algorithm, there is iteration over the array's elements, however, it does so by steps of $L$-sized blocks per iteration.

<center>
<img src="./assets/01-039.png" width="650">
</center>

The computation $\widehat L$ determines whether the block that starts at position $i$ is of length $L$, or otherwise smaller than this.
  * ***N.B.*** This is a relatively "fine" detail, which will otherwise be generally ignored subsequently in the course.

<center>
<img src="./assets/01-040.png" width="650">
</center>

The assignment to $y$ is an ***explicit*** load or read operation, from slow memory to fast memory. Such a request occurs with respect to at most $L$ words, corresponding to ***one*** block transfer.

<center>
<img src="./assets/01-041.png" width="650">
</center>

Since $y$ and $s$ are both ***local*** to the fast memory, the ***processor*** itself can execute the innermost loop.

<center>
<img src="./assets/01-042.png" width="650">
</center>

So, then, what is the work and number of transfer steps for this modified algorithm?

The work is the same as in the conventional algorithm using the RAM model, i.e.,:

$$
W\left( n \right) = \Theta \left( n \right)
$$

And the number of transfer steps is:

$$
Q\left( {n;Z,L} \right) = \Theta \left( {\left\lceil {{n \over L}} \right\rceil } \right)
$$

This follows naturally from the structure of the modified algorithm/pseudocode itself.

<center>
<img src="./assets/01-043.png" width="650">
</center>

Indeed, these results agree with the lower bounds of the sequential RAM model.

### Additional Remarks

<center>
<img src="./assets/01-044.png" width="650">
</center>

Note the following ***remarks*** with respect to the aforementioned analysis:
  * Much of the detail was provided ***meticulously***; in general, subsequent analysis will use appropriate ***simplifications*** as necessary and as warranted
  * ***Caches*** do indeed exist (and are otherwise generally managed "automatically" by the hardware), however, despite their utility in these scenarios, eventually, we will see that caches are ***not*** sufficient to guarantee ***high performance in general***
    * For this reason, locality is ***explicitly*** described in this lesson accordingly.

***N.B.*** Course CS 6290 (High Performance Computer Architecture) further describes caches in detail.

## 8. Matrix-Vector Multiply Quiz and Answers

<center>
<img src="./assets/01-045Q.png" width="450">
</center>

Consider the multiplication of a ***dense*** $n \times n$ matrix by a vector $x$. Recall (cf. Section 6) that the work (ignoring any structure in matrix $A$) is proportional to $n^2$, i.e.,:

$$
W\left( n \right) = O\left( {{n^2}} \right)
$$

<center>
<img src="./assets/01-046Q.png" width="450">
</center>

Now, suppose that the matrix is stored in **column-major order** (as in the figure shown above), whereby the elements are laid out in memory column-wise, i.e., elements have consecutive addresses within a given column, and then "wraparound" to the adjacent column, and so on.

<center>
<img src="./assets/01-047Q.png" width="450">
</center>

In other words, viewing matrix $A$ as a one-dimensional array, element $a_{ij}$ is ***indexed*** as:

$$
{a_{ij}} \leftrightarrow A\left[ {i + j \cdot n} \right]
$$

Now, consider two algorithms to compute the matrix-vector product.

<center>
<img src="./assets/01-048Q.png" width="650">
</center>

**Algorithm 1** indexes rows by $i$ and columns by $j$, as follows:

$$
\boxed{
\begin{array}{l}
{\rm{for\ }}i \leftarrow 0{\rm{\ to\ }}n - 1{\rm{\ do}}\\
\ \ \ \ {\rm{for\ }}j \leftarrow 0{\rm{\ to\ }}n - 1{\rm{\ do}}\\
\ \ \ \ \ \ \ \ y\left[ i \right] += A[i,j] \cdot x[j]
\end{array}
}
$$

Here, the outer loop iterates over rows, and the inner loop iterates over columns.

<center>
<img src="./assets/01-049Q.png" width="650">
</center>

**Algorithm 2** indexes rows by $i$ and columns by $j$ (i.e., the opposite of Algorithm 1), as follows:

$$
\boxed{
\begin{array}{l}
{\rm{for\ }}j \leftarrow 0{\rm{\ to\ }}n - 1{\rm{\ do}}\\
\ \ \ \ {\rm{for\ }}i \leftarrow 0{\rm{\ to\ }}n - 1{\rm{\ do}}\\
\ \ \ \ \ \ \ \ y\left[ i \right] += A[i,j] \cdot x[j]
\end{array}
}
$$

Here, the outer loop iterates over columns, and the inner loop iterates over rows.

<center>
<img src="./assets/01-050Q.png" width="650">
</center>

In the basic RAM model, both algorithms are identical. Conversely, in the I/O model, which of these performs ***fewer*** transfers?

To assist with answering this question, consider the following additional simplifying ***assumptions***:
  * The fast memory is sufficiently large to hold two vectors and any additional/extra $L$-sized blocks, i.e., $Z = 2n + O\left( L \right)$
  * $L$ divides $n$ (i.e., $L|n$)
  * All arrays and the matrix (i.e., $x$, $y$, and $A$) are aligned on $L$-word boundaries

***N.B.*** The last two assumptions avoid the data-alignment issues encountered previously in this lesson, thereby allowing to ignore floors and ceilings accordingly.

As an additional ***hint***, from these simplifying assumptions, it is also valid to assume that the algorithm ***preloads*** $x$ and $y$ to fast memory at the very beginning, and then stores $y$ back to slow memory at the very end. This in turn implies that the number of transfers will be at least ${3n} \over L$, i.e.,:

$$
Q\left( {n;Z,L} \right) = {{3n} \over L} + ???
$$

This begs the question: How many ***total*** transfers will occur?

### ***Answer and Explanation***:

<center>
<img src="./assets/01-051A.png" width="650">
</center>

**Algorithm 2** requires ***fewer*** transfers.

<center>
<img src="./assets/01-052A.png" width="650">
</center>

In Algorithm 1, the outer loop iterates over rows (as in the figure shown above).

<center>
<img src="./assets/01-053A.png" width="650">
</center>

Within row $i$, it loops over columns $j$, starting at $0$ (as in the figure shown above). Accessing an element $x$ of row $0$ causes a block of $L - 1$ additional elements from the column to be loaded into fast memory, a direct consequence of the column-major layout.
  * ***N.B.*** In the figure shown above, this shows a representative fast-memory access pattern (as shaded in teal), however, it may not be this specific block in general.

<center>
<img src="./assets/01-054A.png" width="650">
</center>

In the subsequent iteration, a completely ***different*** block of elements must be loaded (as in the figure shown above).
  * ***N.B.*** Recall that the fast memory is assumed to only have sufficient space for two vectors plus an additional "extra," however, eventually the previous block (i.e., from iteration $0$) must be displaced.

<center>
<img src="./assets/01-055A.png" width="650">
</center>

Therefore, traversing this column-major matrix row-wise in this manner incurs block transfers for ***each*** row. Consequently, this yields the following total number of transfers (via $n^2$ required to read $A$):

$$
Q\left( {n;Z,L} \right) = {{3n} \over L} + {n^2}
$$

<center>
<img src="./assets/01-056A.png" width="650">
</center>

Conversely, in Algorithm 2, the outer loop iterates over columns (as in the figure shown above).

<center>
<img src="./assets/01-057A.png" width="650">
</center>

The inner loop traverses within a given column (as in the figure shown above).

<center>
<img src="./assets/01-058A.png" width="650">
</center>

In this case (i.e., Algorithm 2), the traversal order ***matches*** the storage format, i.e., this access pattern more optimally ***amortizes*** the cost of loading the blocks.

<center>
<img src="./assets/01-059A.png" width="650">
</center>

Consequently, this yields the following total number of transfers:

$$
Q\left( {n;Z,L} \right) = {{3n} \over L} + {{{n^2}} \over L}
$$

Therefore, for large values of $n$, it is expected that Algorithm 1 will perform $L$ more transfers in general, thereby implying a faster operation by Algorithm 2 accordingly (i.e., $L$ times faster than Algorithm 1).

The ***important*** point here is that in the sequential RAM model, these algorithms appear "identically" to each other, whereas in the simple two-level model with block transfers, they are distinctly ***different***.

<center>
<img src="./assets/01-060A.png" width="650">
</center>

As a final remark, suppose that the fast memory is a ***fully associative cache*** with capacity $Z$ words and a line size $L$ (also in words). In this case, would caches *alone* assist Algorithm 1 to match the performance of Algorithm 2 (i.e., with respect to reducing the number of transfers)?
  * ***N.B.*** This is left as an additional exercise for the student/reader.

## 9. Algorithm Design Goals

<center>
<img src="./assets/01-061.png" width="650">
</center>

An ***important question*** regarding the two-level memory model is: What are the ***design goals***? That is, with respect to the complexity measures for work ($W\left( n \right)$) and transfers ($Q \left( {n;Z,L} \right)$), what makes an algorithm "good"?

The goals to achieve this is actually rather ***simple***.

### First Goal

<center>
<img src="./assets/01-062.png" width="650">
</center>

The ***first goal*** is **work optimality**, i.e., the two-level algorithm should perform the ***same*** asymptotic work as the equivalent sequential RAM algorithm, or equivalently:

$$
W\left( n \right) = \theta \left( {{W_ * }\left( n \right)} \right)
$$

where ${W_ * }\left( n \right)$ denotes the work of the best/optimal sequential RAM algorithm (i.e., without the corresponding memory hierarchy).

***N.B.*** This statement is equivalent to what would be described with respect to parallel algorithms, i.e., do not "explode" the asymptotic work.

### Second Goal

<center>
<img src="./assets/01-063.png" width="650">
</center>

The ***second goal*** is to achieve **high computational intensity**. More formally, this entails maximizing the following quantity, $I$:

$$
I\left( {n;Z,L} \right) \equiv {{W\left( n \right)} \over {L \cdot Q\left( {n;Z,L} \right)}}
$$

Here, the **computational intensity** (or simply **intensity**) $I$ is simply the ratio of the work to the words transferred.

Intensity $I$ has units of `operations/word`. In other words, "operations per word" measures the level of ***data reuse*** in the algorithm.

If this ratio is ***large***, then ***more*** operations are being performed per word transferred to fast memory.
  * This is generally ***desirable***, however, it is ***not*** desirable to maximize this at the ***expense*** of performing sub-optimal work (i.e., per the previous/first goal).

<center>
<img src="./assets/01-064.png" width="650">
</center>

Therefore, both goals are cooperative, and are reminiscent of work and span (as discussed later in this course).

## 10. Which Is Better? Quiz and Answers
