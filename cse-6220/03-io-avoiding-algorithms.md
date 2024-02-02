# I/O-Avoiding Algorithms

## 1. Introduction

Given a machine with a two-level memory hierarchy, what does an ***efficient algorithm*** look like? That is the central topic of this lesson, i.e., **input/output (I/O)-avoiding algorithms**. In this context, input/output (I/O) refers to the transfers of data between slow and fast memories.
  * In this lesson, it will be assumed that this I/O's are the dominant cost, which in turn will be attempted to be minimized.
  * Furthermore, this lesson will demonstrate examples of how to argue lower bounds on the number of I/O's, in order to determine whether a given algorithm achieves this lower bound accordingly.

## 2. A Sense of Scale Quiz and Answers

<center>
<img src="./assets/03-001Q.png" width="650">
</center>

One of the main results of this lesson is going to be a lower bound on the amount of communication needed to sort on a machine with both slow and fast memories. This lower bound is in fact the following:

$$
Q\left( {n;Z,L} \right) = \Omega \left( {{n \over L}{{\log }_{{\textstyle{Z \over L}}}}\left( {{n \over L}} \right)} \right)
$$

where:
  * $n$ → input items
  * $Z$ → fast memory size (`words`)
  * $L$ → transfer size (`words/transfer`)

***N.B.*** Here, the base of the logarithm is $Z\over{L}$, rather than the usual/assumed $2$ .

How does this function compare to the more "plain" $\Omega (n \log_2 n)$ and other quantities? That is the leading intuition for this quiz.

<center>
<img src="./assets/03-002Q.png" width="650">
</center>

Suppose that the following are given:

| Characteristic | Definition | Size | Size (bytes equivalent) |
|:--:|:--:|:--:|:--:|
| Volume of data to sort | $r \cdot n$ | $1\ \rm{PiB}$ | $2^{50}$ |
| Record (item) size | $r$ | $256\ \rm{bytes}$ | $2^{8}$ | 
| Fast memory size | $r \cdot Z$ | $64\ \rm{GiB}$ | $2^{36}$ |
| Memory transfer size | $r \cdot L$ | $32\ \rm{KiB}$ | $2^{15}$ |

  * ***N.B.*** Assume that initially, the input records/items ***all*** reside in ***slow*** memory (e.g., disk) (cf. DRAM or equivalent for the fast memory). Furthermore, the memory transfer therefore occurs between the slow and fast memories ($32\ \rm{KiB}$ is a reasonable assumption for this transfer rate accordingly).

Now, given the following algorithms performing the corresponding number of transfer operations with respect to input $n$ , evaluate the corresponding expressions (Algorithms A and C are given), in units of `Tops` (teraops, or $10^{12}$ operations) to three significant figures:

| Algorithm | Algorithmic performance | Total transfer operations (`Tops`) |
|:--:|:--:|:--:|
| A | $n\ log_2\ n$ | 185 |
| B | $n\ log_2\ {n\over{L}}$ | ? |
| C | $n$ | 4.40 |
| D | ${n\over{L}}\ log_2\ {n\over{L}}$ | ? |
| E | ${n\over{L}}\ log_2\ {n\over{Z}}$ | ? |
| F | ${{n \over L}\ {{\log }_{{\textstyle{Z \over L}}}}\left( {{n \over L}} \right)}$ | ? | 

### ***Answer and Explanation***:

<center>
<img src="./assets/03-003A.png" width="650">
</center>

The calculated results are as follows:

| Algorithm | Algorithmic performance | Total transfer operations (`Tops`) |
|:--:|:--:|:--:|
| A | $n\ log_2\ n$ | ***185***.0000 |
| B | $n\ log_2\ {n\over{L}}$ | ***154***.0000 |
| C | $n$ | 00***4***.***40***00 |
| D | ${n\over{L}}\ log_2\ {n\over{L}}$ | 00***1***.***20***00 |
| E | ${n\over{L}}\ log_2\ {n\over{Z}}$ | 000.***275***0 |
| F | ${{n \over L}\ {{\log }_{{\textstyle{Z \over L}}}}\left( {{n \over L}} \right)}$ | 000.0***523*** | 

  * ***N.B.*** In the results shown in the last column in the table above, left-padding and leading decimals/zeros are included for "visual alignment," however, only three significant figures are expressed in each result (delimited by ***bold italics***), as per the quiz prompt.

Furthermore, note that the relevant factors are determined as follows:

$$
n = {{r \cdot n} \over r} = {{{2^{50}}} \over {{2^8}}} = {2^{42}}{\rm{\ records}}
$$

$$
Z = {{r \cdot Z} \over r} = {{{2^{36}}} \over {{2^8}}} = {2^{28}}{\rm{\ records}}
$$

$$
L = {{r \cdot L} \over r} = {{{2^{15}}} \over {{2^8}}} = {2^7}{\rm{\ records}}
$$

<center>
<img src="./assets/03-004A.png" width="650">
</center>

Perhaps more interesting than the numerical results themselves are the ***relative improvements*** with respect to the baseline of $n\ log_2\ n$ (as in the figure shown above).

<center>
<img src="./assets/03-005A.png" width="650">
</center>

One major improvement arises from reducing $n$ to $n\over{L}$ . This latter factor entails ensuring that, when making a pass over the data, it is imperative to do so in transactions of size $L$ as much as possible.

Another major improvement arises from moving from a $\log$ base of $2$ to $Z\over{L}$ . This improvement involves the capacity of fast memory $Z$ ; this improvement there yields from ensuring that the algorithm utilizes the fast memory capacity $Z$ to the greatest extent possible.

***N.B.*** When dealing with a change of base, note the following rule of logarithms:

$$
{\log _{{\textstyle{Z \over L}}}}\left( x \right) = {{{{\log }_2}x} \over {{{\log }_2}{Z \over L}}}
$$

As a closing remark, note that these relative speedups are only "notional"; conversely, when performing algorithm analysis, it more typically done in an "asymptotic" sense (i.e., ignoring hidden constants). The purpose here is to build intuition about how performance changes as these "improving factors" are incorporated into the corresponding algorithm(s) in question.

### Instructor's Note

The answer for (E) should be $0.481$ and the answer for (F) should be $0.0573$ (i.e., indicated ***incorrectly*** in the slides/discussion above, per original version's corresponding errata).

## 3. External Memory Merge Sort

<center>
<img src="./assets/03-006.png" width="450">
</center>

Consider the problem of sorting $n$ elements in a two-level memory hierarchy (as in the figure shown above).

Initially, assume that the processor is ***sequential***.

Now, consider a natural scheme based on the merge sort idea.

### Merge Sort Phase 1

<center>
<img src="./assets/03-007.png" width="650">
</center>

Start by logically dividing the input into chunks of size proportional to (but no greater than) $Z$ (as in the figure shown above), such that a single such chunk fits into fast memory--i.e., $n\over{f \cdot Z}$ chunks, where $f \in [0,1)$ .

<center>
<img src="./assets/03-008.png" width="650">
</center>

Next, read one such chunk of input from slow memory into fast memory (as in the figure shown above).

<center>
<img src="./assets/03-009.png" width="650">
</center>

After reading the chunk into fast memory, ***sort*** this chunk (as in the figure shown above).
  * ***N.B.*** Such a "sorted output" sitting in fast memory will be referred to as a ***sorted run***, or simply ***run*** for short. Furthermore, the mnemonic of a left-to-right arrow (as in the figure shown above) indicates that the chunk in question is sorted in this manner.

<center>
<img src="./assets/03-010.png" width="650">
</center>

Since the run is now sorted, it is written back into slow memory (as in the figure shown above).

<center>
<img src="./assets/03-011.png" width="650">
</center>

The aforementioned process is repeated on each input chunk of size $f \cdot Z$ (as in the figure shown above), until all $n\over{f \cdot Z}$ chunks are sorted runs.

<center>
<img src="./assets/03-012.png" width="650">
</center>

The aforementioned process is referred to as **Phase 1** of the procedure, summarized as follows:

$$
\boxed{
\begin{array}{l}
{\rm{partition\ input\ into\ }}{n \over {f \cdot Z}}{\rm{\ chunks}}\\
{\rm{foreach\ chunk\ }}i \leftarrow 1{\rm{\ to\ }}{n \over {f \cdot Z}}{\rm{\ do}}\\
\ \ \ \ {\rm{read\ chunk\ }}i\\
\ \ \ \ {{\rm{sort\ chunk\ }} i {\rm{\ into\ a\ (sorted)\ run}}}\\
\ \ \ \ {\rm{write\ run\ }}i
\end{array}
}
$$

### Merge Sort Phase 2

<center>
<img src="./assets/03-013.png" width="650">
</center>

Following the merge sort idea, in **Phase 2**, all of the sorted runs are merged into a single, final sorted run, i.e.,:

$$
\boxed{
\begin{array}{l}
{{\rm{merge\ the\ }}{n \over {f \cdot Z}}{\rm{\ runs\ into\ a\ single\ run}}}
\end{array}
}
$$

Before discussing Phase 2 further, let us first consider Phase 1 (partitioned sorting) in more detail (as discussed next via quiz section).

## 4. Partitioned Sorting Step Analysis Quiz and Answers

<center>
<img src="./assets/03-014Q.png" width="650">
</center>

Recall Phase 1 of the external-memory merge sort scheme (cf. Section 3), as follows:

$$
\boxed{
\begin{array}{l}
{\rm{partition\ input\ into\ }}{n \over {f \cdot Z}}{\rm{\ chunks}}\\
{\rm{foreach\ chunk\ }}i \leftarrow 1{\rm{\ to\ }}{n \over {f \cdot Z}}{\rm{\ do}}\\
\ \ \ \ {\rm{read\ chunk\ }}i\\
\ \ \ \ {{\rm{sort\ chunk\ }} i {\rm{\ into\ a\ (sorted)\ run}}}\\
\ \ \ \ {\rm{write\ run\ }}i
\end{array}
}
$$

In this quiz, count the number of asymptotic slow-fast transfers and the number of comparisons incurred at each step (as designated with "boxes" $O(\cdots)$ in the figure shown above), as aggregated over all iterations. Express the results in terms of $n$ , $Z$ , $L$ , and other numeric constant (but ignoring $f$ , which is simply a "corrective" constant to ensure that the size of the input buffers fit properly into the fast memory, along with any necessary "working space").
  * Furthermore, express the answer with respect to ***totals*** taken overall $n\over{Z}$ iterations.
  * Also, assume that everything divides "everything else" (i.e., $L|(f \cdot Z)$ and $(f \cdot Z)|L$ ), and assume that any local sort is an ***optimal*** comparison-based sort

### ***Answer and Explanation***:

<center>
<img src="./assets/03-015A.png" width="650">
</center>

The iteration-wise counts are as follows:

| Instruction | Asymptotic count | Count type
|:--|:--:|:--:|
| ${\rm{read\ chunk\ }}i$ | $O(n/L)$ | transfers |
| ${{\rm{sort\ chunk\ }} i {\rm{\ into\ a\ (sorted)\ run}}}$ | $O(n \log Z)$ | comparisons |
| ${\rm{write\ run\ }}i$ | $O(n/L)$ | transfers |

<center>
<img src="./assets/03-016A.png" width="650">
</center>

With respect to the transfers (as in the figure shown above), the read and write operations involve around $Z/L$ transfers each, repeated for all iterations, i.e.,:

$$
\underbrace {\left( {{\bcancel{f \cdot Z} \over L}} \right)}_{{\rm{transfers\ per\ operation}}} \times \underbrace {\left( {{n \over \bcancel{f \cdot Z}}} \right)}_{{\rm{total\ operations}}} = O\left( {{n \over L}} \right)
$$

<center>
<img src="./assets/03-017A.png" width="650">
</center>

Furthermore, with respect to the comparisons (as in the figure shown above), an optimal comparison-based sort incurs around $Z \log Z$ comparisons, repeated for all iterations, i.e.,:

$$
\underbrace {\left( {\bcancel{f \cdot Z} \log \left( {f \cdot Z} \right)} \right)}_{{\rm{comparisons\ per\ operation}}} \times \underbrace {\left( {{n \over \bcancel{f \cdot Z}}} \right)}_{{\rm{total\ operations}}} = O\left( {n\log \left( {f \cdot Z} \right)} \right)
$$

Observe that, in general, this algorithmic scheme is yielding behavior which is proportional to $n/L$ transactions, i.e., there *is* indeed utilization on a per-transaction basis.

## 5. Two-Way External Memory Merging

<center>
<img src="./assets/03-018.png" width="650">
</center>

Suppose there are $m$ sorted runs present in slow memory, where each run is of size $s$ items (as in the figure shown above).
  * Here, the total number of items is defined as $n \equiv m \cdot s$ .

The corresponding goal, then, is to ***merge*** all of these sorted runs into a ***single*** sorted run, thereby completing the merge sort algorithm.

<center>
<img src="./assets/03-019.png" width="650">
</center>

An easy scheme, based on the classical merge sort idea, is to merge pairs of runs successively, until a single, final run results (as in the figure shown above).

Observe the trend with respect to each successive level (for $k$ total levels):

| Level | Run size |
|:--:|:--:|
| $0$ | $s$ |
| $1$ | $2 \cdot s$ |
| $\vdots$ | $\vdots$ |
| $k-1$ | $2^{k-1} \cdot s$ |
| $k$ | $2^{k} \cdot s$ |

Let us now examine these steps in further detail.

<center>
<img src="./assets/03-020.png" width="650">
</center>

First, consider a pair of runs, each of size $2^{k-1} \cdot s$ items, denoted by A and B (as in the figure shown above). Initially, A and B both reside in slow memory.

The goal is to produce a merged run C (i.e., $C \leftarrow {\rm{merge}}(A,B)$ ), which will hold $2^{k} \cdot s$ items, as held in corresponding output buffer C.

In order to execute this merge, three buffers are maintained in fast memory, designated $\hat{A}$ , $\hat{B}$ , and $\hat{C}$ (respectively), each holding $L$ elements (corresponding to the transaction size).
  * Two of the buffers ($\hat{A}$ and $\hat{B}$ ) are used for storing elements from A and B (respectively).
  * The other buffer ($\hat{C}$ ) is used for storing the elements of the output.

<center>
<img src="./assets/03-021.png" width="650">
</center>

<center>
<img src="./assets/03-022.png" width="650">
</center>

To perform the merge, start by reading one $L$-sized block from each of $A$ and $B$ into $\hat{A}$ and $\hat{B}$ (respectively) (as in the figures shown above), thereby moving them from slow memory to fast memory, i.e.,:

$$
\boxed{
\begin{array}{l}
{{\rm{read\ }}L{\rm{-sized\ blocks\ of\ }}A,B \to \hat A,\hat B}
\end{array}
}
$$

<center>
<img src="./assets/03-023.png" width="650">
</center>

Subsequently, the following sequence is performed:

$$
\boxed{
\begin{array}{l}
{\rm{while\ any\ unmerged\ items\ in\ }}A{\rm{\ or\ }}B{\rm{\ do}}\\
\ \ \ \ {\rm{merge\ }}\hat A,\hat B \to \hat C{\rm{\ as\ possible}}\\
\ \ \ \ {\rm{if\ }}\hat A{\rm{\ or\ }}\hat B{\rm{\ empty\ then\ read\ more}}\\
\ \ \ \ {\rm{if\ }}\hat C{\rm{\ full\ then\ flush}}
\end{array}
}
$$

Here, iteration is performed until either all of $A$ or all of $B$ is read. Then, elements from $\hat{A}$ and $\hat{B}$ are merged into $\hat{C}$ , until elements from either $\hat{A}$ or $\hat{B}$ are exhausted (in which case additional elements are read from slow memory) or until the output buffer of $\hat{C}$ becomes full (in which case the memory is flushed).

<center>
<img src="./assets/03-024.png" width="650">
</center>

Finally, when either $A$ or $B$ is exhausted, the remaining elements are copied accordingly, i.e.,:

$$
\boxed{
\begin{array}{l}
{{\rm{flush\ any\ unmerged\ in\ }}A{\rm{\ or\ }}B}
\end{array}
}
$$

<center>
<img src="./assets/03-025.png" width="650">
</center>

What is the corresponding cost to merge the pair of runs $A$ and $B$ ?

This scheme only ever ***loads*** elements from A or B from slow memory ***once***, and it only ***writes*** a given output block ***once***, i.e.,:

```latex
\underbrace{{\frac{{2^{k - 1} \cdot s}}{{L}}}}_{{\text{{loads}}}} + \underbrace{{\frac{{2^{k - 1} \cdot s}}{{L}}}}_{{\text{{writes}}}}
```

<center>
<img src="./assets/03-026.png" width="650">
</center>

Furthermore, this scheme only ever ***writes*** a given output block $C$ ***once***, i.e.,:

$$
\underbrace {{{{2^{k}} \cdot s} \over L}}_{{\rm{writes}}}
$$

<center>
<img src="./assets/03-027.png" width="650">
</center>

Therefore, this cumulatively yields a total number of transfers as follows:

$$
\underbrace {{{{2^{k - 1}} \cdot s} \over L}}_{{\rm{loads}}} + \underbrace {{{{2^{k - 1}} \cdot s} \over L}}_{{\rm{writes}}} + \underbrace {{{{2^{k}} \cdot s} \over L}}_{{\rm{writes}}} = {{{{2^{k+1}} \cdot s} \over L}}
$$

Furthermore, with respect to comparisons, this is also linear in $s$ , i.e.,:

$$
\Theta(2^{k} \cdot s)
$$

<center>
<img src="./assets/03-028.png" width="650">
</center>

Note that the aforementioned is for merging only ***one*** pair $A$ and $B$ ; returning to the original tree (as in the figure shown above), at each level, the number of pairs can be counted accordingly, i.e., the pairs merged at level $k$ is $n \over{2^{k} \cdot s}$  . Furthermore, the total number of levels is $\log_2 {n \over{s}}$.

<center>
<img src="./assets/03-029.png" width="650">
</center>

Therefore, combining across all levels yields the following:

| Measurement | Total size |
|:--:|:--:|
| Transfers | ${{{2^{\bcancel{k} + 1}} \cdot \bcancel{s}} \over L} \times \underbrace {{n \over {\bcancel{{2^k} \cdot s}}} \times {\log_2}{n \over s}}_{{\rm{total\ pairs}}} = 2{n \over L}{\log_2}{n \over s}$ |
| Comparisons | $\Theta (\bcancel{{2^k} \cdot s}) \times \underbrace {{n \over {\bcancel{{2^k} \cdot s}}} \times {\log_2}{n \over s}}_{{\rm{total\ pairs}}} = \Theta (n{\log_2}{n \over s})$ |

This begs the question: Is this performance *good* or *bad*?

## 6. External Memory Merge Sort with a Two-Way Merge Step Quiz and Answers

<center>
<img src="./assets/03-030Q.png" width="650">
</center>

Recall (cf. Section 3) the overall template for a merge sort on a two-level-memory-hierarchy machine, abbreviated as follows:

$$
\boxed{
\begin{array}{l}
{\rm{Phase\ 1:}}\\
\ \ \ \ {\rm{partition\ input\ into\ }}\Theta \left( {{n \over Z}} \right){\rm{ chunks}}\\
\ \ \ \ {\rm{sort\ each\ chunk,\ producing\ }}\Theta \left( {{n \over Z}} \right){\rm{\ runs\ of\ size\ }}Z{\rm{\ each}}\\
{\rm{Phase\ 2:}}\\
\ \ \ \ {\rm{merge\ all\ runs}}
\end{array}
}
$$

Here, Phase 1 produces several sorted chunks (or runs). The goal of Phase 2 is then to merge all of these runs.

<center>
<img src="./assets/03-031Q.png" width="650">
</center>

Now, suppose that Phase 2 is implemented using the two-way merge scheme, i.e.,:

$$
\boxed{
\begin{array}{l}
{\rm{Phase\ 1:}}\\
\ \ \ \ {\rm{partition\ input\ into\ }}\Theta \left( {{n \over Z}} \right){\rm{ chunks}}\\
\ \ \ \ {\rm{sort\ each\ chunk,\ producing\ }}\Theta \left( {{n \over Z}} \right){\rm{\ runs\ of\ size\ }}Z{\rm{\ each}}\\
{\rm{Phase\ 2:}}\\
\ \ \ \ {\rm{merge\ all\ runs\ using\ two-way\ merge}}
\end{array}
}
$$

With this modification, what is the corresponding overall asymptotic cost of the entire merge sort with respect to comparisons and transfers? (Express this symbolically in terms of $n$ , $Z$ , and $L$ .)
  * ***N.B.*** The usual assumptions also hold here as before (i.e., quantities divide evenly, use convenient powers of $2$ , etc.)

### ***Answer and Explanation***:

<center>
<img src="./assets/03-032A.png" width="650">
</center>

Phases 1 and 2 were analyzed previously (cf. Sections 4 and 5), summarized as follows:

| Phase | Comparisons | Transfers |
|:--:|:--:|:--:|
| $1$ | $O(n \log_2 Z)$ | $O({n\over{L}})$ |
| $2$ | $O(n \log_2 {n\over{Z}})$ | $O({n\over{L}}{\log_2 {n\over{Z}}})$ |

Combining these gives the following:

| Operation | Asymptotic cost |
|:--:|:--:|
| Comparisons | $\underbrace {O(n{\log_2}Z)}_{{\rm{Phase\ 1}}} + \underbrace {O\left( n{\log_2 {n \over Z}} \right)}_{{\rm{Phase\ 2}}} = O\left(\bcancel{n \log_2 Z} + n \log_2 n - \bcancel{n \log_2 Z} \right) = O(n\log_2n)$ |
| Transfers | $\underbrace {O\left( {{n \over L}} \right)}_{{\rm{Phase\ 1}}} + \underbrace {O\left( {{n \over L}{\log_2 n \over Z}} \right)}_{{\rm{Phase\ 2}}} = O\left( {{n \over L}\left( {1 + {\log_2 n \over Z}} \right)} \right)\underbrace  \approx _{1 \ll {\log_2 n \over Z}{\rm{\ as\ }}n \to \infty }O\left( {{n \over L}{\log_2 n \over Z}} \right)$ |

As these results suggest, merge sort is optimal with respect to comparisons (relative to any other comparison-based algorithm). Furthermore, with respect to memory transfers, Phase 2 dominates the total asymptotic cost.

As it turns out, the known lower bound for the transfer operations is as follows:

$$
{n\over{L}}\log_{Z\over{L}}{n\over{L}}
$$

***N.B.*** Demonstration of this is left as an exercise to the reader.

## 7. What Is Wrong with Two-Way Merging? Quiz and Answers

<center>
<img src="./assets/03-033Q.png" width="650">
</center>

Performing a merge sort with two-way merging is relatively performant with respect to the number of slow-fast memory transfers, which recall (cf. Section 6) is as follows:

$$
Q(n;Z,L) = O\left( {{n \over L}{{\log }_2}{n \over Z}} \right) = O\left( {{n \over L}\left[ {{{\log }_2}{{(n/L)} \over {(Z/L)}}} \right]} \right) = O\left( {{n \over L}\left[ {{{\log }_2}{n \over L} - {{\log }_2}{Z \over L}} \right]} \right)
$$

However, this is still not optimal with respect to the known lower bound, as follows:

$$
Q(n;Z,L) = \Omega \left( {{n \over L}{{\log }_{{Z \over L}}}{n \over L}} \right) = \Omega \left( {{n \over L} \cdot {{{{\log }_2}{n \over L}} \over {{{\log }_2}{Z \over L}}}} \right)
$$

Combining, the resulting net difference (i.e., sub-optimal margin) is therefore:

$$
O\left( {{{\log }_2}{Z \over L} \cdot \left[ {{\mathop{\rm l}\nolimits}  - {{{{\log }_2}{Z \over L}} \over {{{\log }_2}{n \over L}}}} \right]} \right)
$$

This factor of $\log_2 {Z \over{L}}$ is actually fairly substantial; for typical adjacent levels of the memory hierarchy on a real machine (e.g., disk and main memory, or main memory and the last-level cache), this can correspond to a factor of roughly $10$ to $100$ .

So, then, why does two-way merge sort ***not*** achieve this lower bound?
  * ***N.B.*** This question is posed here in an "open-ended" manner.

### ***Answer and Explanation***:

<center>
<img src="./assets/03-034A.png" width="650">
</center>

Two-way merge sort ***under-utilizes*** the fast-memory capacity, $Z$ .
  * Note that the merging procedure only works on pairs of arrays at a time, and it only requires ***one*** block of size $L$ of fast memory per pair. Therefore, merging in this manner is very sensitive to $L$ , but it is not at all sensitive to $Z$ .

## 8. Multi-Way Merging

<center>
<img src="./assets/03-035.png" width="650">
</center>

Recall (cf. Section 5) two-way merge, whereby $m$ input runs of size $s$ (each sorted in ascending order) are combined in such a manner which produces a ***single*** sorted output (as in the figure shown above).

Correspondingly, a natural scheme (based on the classical merge sort idea) is to take pairs of runs and to combine them in a tree-like fashion, yielding the following asymptotic performance:

$$
{Q_{{\rm{2-way}}}}(n;Z,L) = O\left( {{n \over L}{{\log }_2}{n \over Z}} \right)
$$

A distinct ***problem*** with two-way merging is that it does not utilize fast memory to its fullest potential.

<center>
<img src="./assets/03-036.png" width="650">
</center>

Recall (cf. Section 5) that at any given time, two-way merging uses very little of the available fast-memory space (i.e., only three such $L$-sized blocks, for two inputs $\hat{A}$ and $\hat{B}$ one output $\hat{C}$ , as in the figure shown above).

### Multi-Way Merging of $k$ Input Items

<center>
<img src="./assets/03-037.png" width="650">
</center>

In an attempt to improve the performance, a natural idea is to merge not only ***two*** runs at a time, but rather $k$ such runs (as in the figure shown above).

<center>
<img src="./assets/03-038.png" width="650">
</center>

Consider one such merge (as in the figure shown above).

Given is a set of $k$ inputs, each of size $s$ , and assume they start in slow memory and are sorted in ascending order. Furthermore, suppose that $k$ is chosen such that at least $k + 1$ blocks of size $L$ will fit in fast memory. 

Note that the choice of $k$ here is ***not*** arbitrary. Suppose that $k$ is selected such that $(k + 1)L \le Z$ (thereby allowing sufficient fast-memory allocation for all $k$ inputs, as well as one additional memory block for the output).

<center>
<img src="./assets/03-039.png" width="650">
</center>

Initially, the inputs are filled with blocks of the input runs (as in the figure shown above).

<center>
<img src="./assets/03-040.png" width="650">
</center>

At each step of the local merge (as in the figure shown above), it is necessary to know which of the $k$ input blocks has the next-smallest item.

<center>
<img src="./assets/03-041.png" width="650">
</center>

Suppose that the shaded items in the figure shown above are the next ones under consideration from each of the $k$ input blocks. Of these, it is somehow necessary to determine the smallest value.

<center>
<img src="./assets/03-042.png" width="650">
</center>

Suppose that the smallest-value block is identified (as in the figure shown above).
  * ***N.B.*** The matter of making this determination will be revisited momentarily.

<center>
<img src="./assets/03-043.png" width="650">
</center>

The identified smallest-value block can be consequently moved into the output buffer (as in the figure shown above).

<center>
<img src="./assets/03-044.png" width="650">
</center>

Furthermore, the next item from the source buffer now becomes active (as in the figure shown above).

<center>
<img src="./assets/03-045.png" width="650">
</center>

<center>
<img src="./assets/03-046.png" width="650">
</center>

This process is subsequently repeated (as in the figures shown above).

<center>
<img src="./assets/03-047.png" width="650">
</center>

As with two-way merge, eventually the output block becomes full (as in the figure shown above).

<center>
<img src="./assets/03-048.png" width="650">
</center>

At this point, it is necessary to flush the output block (as in the figure shown above).

<center>
<img src="./assets/03-049.png" width="650">
</center>

Similarly, eventually, one of the input buffers will be exhausted in this manner, thereby necessitating a corresponding flush as well (as in the figure shown above).

<center>
<img src="./assets/03-050.png" width="650">
</center>

Furthermore, if there are any unread blocks of the input remaining, then these are simply refilled accordingly (as in the figures shown above).

### Selecting the Next-Smallest Item from the Input Frontier via Min-Heap

<center>
<img src="./assets/03-051.png" width="650">
</center>

Now, consider again: How to determine the next-smallest item from the input frontier?

There are several natural options. One simple way is to perform a linear scan. This yields generally acceptable performance for an input size of small $k$ .

However, if $k$ is relatively large, then a ***priority-queue-like*** data structure is useful, e.g., a **min-heap**, comprised of the following operations:

| Min-heap operation | Asymptotic performance |
|:--:|:--:|
| $\rm{build}$ | $O(k)$ |
| $\rm{extract\ min}$ | $O(\log k)$ |
| $\rm{insert}$ | $O(\log k)$ |

After loading the first $k$ blocks via $\rm{build}$ (cost $O(k)$ ), then anytime the next item to merge is sought, $\rm{extract\ min}$ would be used (cost $O(\log k)$ ). Furthermore, after extracting this item, it may be subsequently replaced via $\rm{insert}$ (cost $O(\log k)$ ).
  * ***N.B.*** These are all ***fast-memory operations***, therefore when considering these costs, they will be simply counted as comparisons accordingly.

### Cost of a Single $k$-Way Merge via Min-Heap

<center>
<img src="./assets/03-052.png" width="650">
</center>

Now, assuming a min-heap-based implementation, what is the corresponding cost of a ***single*** $k$-way merge?

With respect to slow-fast memory transfer operations, since the distinct input blocks are only read ***once***, and similarly writing distinct output blocks only occurs ***once*** as well, this yields the following ***per-merge*** transfer cost:

$$
{2ks}\over{L}
$$

Furthermore, with respect to comparisons, there is an initial $\rm{build}$ , followed by a subsequent $\rm{extract\ min}$ or $\rm{insert}$ on a ***per-merge*** basis (with respect to each of the $k \cdot s$ input items), i.e.,: 

$$
O( {\underbrace k_{{\rm{build}}} + \underbrace {ks\log k}_{{\rm{extract\ min\ or\ insert}}}} )
$$

Before considering the ***full*** $k$-way merge tree, consider some additional information with respect to this ***single*** $k$-way merge (as discussed in the following section).

## 9. Cost of Multi-Way Merge Quiz and Answers

<center>
<img src="./assets/03-053Q.png" width="650">
</center>

Recall (cf. Section 8) the merge tree for a multi-way merge, comprised of $n$ input elements (as in the figure shown above). At the very start (at the top of the tree), the input is divided into $k \cdot s$ sorted runs. Furthermore, suppose that each such run is comprised of $Z$ items (i.e., $\Theta (Z)$ ), perhaps some constant fraction of this (it would probably be some constant fraction of $Z$ less than $1$ , to allow to perform the initial sorting step in order to produce the runs themselves).

<center>
<img src="./assets/03-054Q.png" width="650">
</center>

Now, suppose that $k$-way merging are performed. The total number of comparisons, as it turns out, is $n \log n$ , which matches the expected performance for any comparison-based sort.

<center>
<img src="./assets/03-055Q.png" width="650">
</center>

So, then, what is the total number of asymptotic memory transfers?
  * Assume that $k = \Theta({Z\over{L}}) < {Z\over{L}}$ (thereby ensuring the ability to perform a $k$-way merge in fast memory).

***N.B.*** As an additional hint, note that the maximum number of levels $\ell$ in the merge tree is constrained to $\ell  = \Theta \left( {{\log_{Z \over L}}{n \over L}} \right)$ .

### ***Answer and Explanation***:

<center>
<img src="./assets/03-056A.png" width="650">
</center>

The total number of asymptotic memory transfers is:

$$
O\left( {{n \over L}{{\log }_{{Z \over L}}}{n \over L}} \right)
$$

<center>
<img src="./assets/03-057A.png" width="650">
</center>

Consider a given run produced at some level $i$ in the merge tree (as in the figure shown above).

At the previous level $i - 1$ , each run contains $k^{i-1}s$ items (that is assuming that at the very top of the merge tree, each run had $s$ items).

The corresponding size of the output run is therefore $k^{i}s$ items.

Now, recall (cf. Section 8) that the number of memory transfers required to produce just this ***one*** run at level $i$ is $\Theta \left( {k^{i}s}\over{L} \right)$ (i.e., proportional to the size of the run $k^{i}s$ ). Furthermore, at level $i$ , there are ${n}\over{k^{i}s}$ such runs (i.e., the length of an input divided by the length of any given run).

Therefore, at level $i$ , the total number of transfers is as follows:

$$
\Theta \left( {{\bcancel{{k^i}s} \over L}} \right) \times {n \over \bcancel{{k^i}s}} = \Theta \left( {{n \over L}} \right)
$$

***N.B.*** Observe that this quantity is independent of the level $i$ itself.

Furthermore, given the number (cf. given "hint" from previously in this section), this yields a total number of asymptotic memory transfers of:

$$
\Theta \left( {{n \over L}} \right) \times \underbrace {\Theta \left( {{{\log }_{{Z \over L}}}{n \over L}} \right)}_\ell  = \Theta \left( {{n \over L}{{\log }_{{Z \over L}}}{n \over L}} \right)
$$

## 10. A Lower Bound on External Memory Sorting

<center>
<img src="./assets/03-058.png" width="650">
</center>

Recall (cf. Section 9) that a merge sort based on multi-way merging has a memory-transfer complexity as follows:

$$
Q(n;Z,L) = \Theta \left( {{n \over L}{{\log }_{{Z \over L}}}{n \over L}} \right)
$$

As it turns out, this is the optimal asymptotic performance possible for a comparison-based sort. This section will explore why this is the case.

<center>
<img src="./assets/03-059.png" width="650">
</center>

Consider $n$ input items (for simplicity, assume that each is unique/distinct). Initially, none of the input have been observed; therefore, there are $n!$ possible orderings of this data.

Of these $n!$ orderings, the goal of sorting is to find a ***specific*** sorting for which all items are in a specified (e.g., ascending) order.

<center>
<img src="./assets/03-060.png" width="650">
</center>

From this point of view, the following discussion is a sketch of one way to determine a lower bound.

### Determining a Lower Bound

<center>
<img src="./assets/03-061.png" width="650">
</center>

Suppose that some data is read from slow memory (as in the figure shown above). From this data, a fact is learned which reduces the number of possible ordering.

<center>
<img src="./assets/03-062.png" width="650">
</center>

To express this more precisely, suppose that there have been $t-1$ transfers. Let $K(t-1)$ denote the number of possible orderings that remain.
  * ***N.B.*** Recall that initially there are $K(0) \equiv n!$ such orderings.

<center>
<img src="./assets/03-063.png" width="650">
</center>

Now, suppose that after performing $t-1$ such reads, another read of block size $L$ from slow memory to fast memory is performed. If these items have not yet been observed, then there are $L!$ ways in which these items can be ordered.

<center>
<img src="./assets/03-064.png" width="650">
</center>

If there are any other items in fast memory already, suppose that there relative ordering is already known. Given this, how many ways can you order up to $Z-L$ old items, plus the $L$ new items? The number of ways to order these items in fast memory is at most $\le {Z \choose {L}} L!$ . This is the factor by which the number of possible orderings might *decrease*.

<center>
<img src="./assets/03-065.png" width="650">
</center>

<center>
<img src="./assets/03-066.png" width="450">
</center>

Subsequently, after $t$ reads are performed, the lower bound on possible orderings is as follows:

$$
K(t) \ge {{K(t - 1)} \over {{Z \choose {L}}L!}} = {{n!} \over {{{\left[ {{Z \choose {L}}L!} \right]}^t}}}
$$

***N.B.*** This count is more conservative than necessary, as the factor $L!$ assumes that the order of the $L$ read items is unknown (however, if the $L$ items have been read before, then this will not strictly be the case).

<center>
<img src="./assets/03-067.png" width="650">
</center>

<center>
<img src="./assets/03-068.png" width="650">
</center>

It is only possible to perform $\le {n\over{L}}$ reads of items that never been read together before. This in turn allows refinement of the estimate of the lower bound on $K(t)$ as follows:

$$
K(t) \ge {{n!} \over {{{Z \choose {L}}^t} \cdot {{\left( {L!} \right)}^t}}}
$$

This begs the question: When does the right-hand-side expression become equal to $1$ (i.e., when does only ***one*** ordering remain)?

<center>
<img src="./assets/03-069.png" width="650">
</center>

The smallest value of $t$ for which this equality holds is the lower bound on the number of transfers; this critical value is as follows:

$$
t \ge {n\over{L}}\log_{Z\over{L}}{n\over{L}}
$$

To obtain this result, it is necessary to use two common ***approximation identities*** (along with corresponding algebra), given as follows:
  * (a) **Stirling's approximation** states that $\log(x!) \approx x \log x$
  * (b) $\log {a\choose b} \approx b \log {a\over b}$

## 11. How Many Transfers in Binary Search Quiz and Answers

<center>
<img src="./assets/03-070Q.png" width="650">
</center>

Consider the algorithm for binary search (as in the figure shown above). Given a sorted array $A$ and target value $v$ , the goal is to find largest $i$ such that $A[i] \le v$ .

<center>
<img src="./assets/03-071Q.png" width="650">
</center>

For example, consider the configuration as in the figure shown above, which attempts to find the position of target value $f$ in the array $A$ .

The standard binary search algorithm begins with the median element of $A$ (i.e., value $j$ at index $5$ ), comparing target value $f$ to it accordingly.

<center>
<img src="./assets/03-072Q.png" width="650">
</center>

<center>
<img src="./assets/03-073Q.png" width="650">
</center>

This process repeats in the left and right halves (as in the figures shown above), depending on whether the target value is less than or greater than the median.

<center>
<img src="./assets/03-074Q.png" width="650">
</center>

Suppose that $A$ resides entirely in slow memory (as in the figure shown above). How many asymptotic transfers might this algorithm incur?
  * ***N.B.*** The usual simplifying assumptions apply (i.e., $L | n$ , $A$ is word-aligned, and constituent quantities $n$ , $L$ , and $Z$ are all powers of $2$ .)

### ***Answer and Explanation***:

<center>
<img src="./assets/03-075A.png" width="650">
</center>

The asymptotic transfers for this binary search algorithm are as follows:

$$
Q(n;Z,L) = O \left( \log_2{n\over{L}} \right)
$$

<center>
<img src="./assets/03-076A.png" width="650">
</center>

During the search, at some point, all of the elements being considered all fall within the ***same*** block of size $L$ (as in the figure shown above).

At this point, the current worst-case behavior is as follows:

<math display='block'>
 <mi>Q</mi><mo stretchy='false'>(</mo><mi>n</mi><mo>;</mo><mi>Z</mi><mo>,</mo><mi>L</mi><mo stretchy='false'>)</mo><mo>=</mo><mrow><mo>{</mo> <mrow>
  <mtable columnalign='left'>
   <mtr columnalign='left'>
    <mtd columnalign='left'>
     <mrow>
      <mn>1</mn><mo>+</mo><mi>Q</mi><mrow><mo>(</mo>
       <mrow>
        <mfrac>
         <mi>n</mi>
         <mn>2</mn>
        </mfrac>
        <mo>;</mo><mi>Z</mi><mo>,</mo><mi>L</mi></mrow>
      <mo>)</mo></mrow></mrow>
    </mtd>
    <mtd columnalign='left'>
     <mrow>
      <mo>,</mo><mtext>&#x00A0;</mtext><mi>n</mi><mo>&#x003E;</mo><mi>L</mi></mrow>
    </mtd>
   </mtr>
   <mtr columnalign='left'>
    <mtd columnalign='left'>
     <mn>1</mn>
    </mtd>
    <mtd columnalign='left'>
     <mrow>
      <mo>,</mo><mtext>&#x00A0;</mtext><mi>n</mi><mo>&#x2264;</mo><mi>L</mi></mrow>
    </mtd>
   </mtr>
  </mtable></mrow> </mrow>
</math>

While the size of the interval $n$ is $n > L$ , a new transfer is incurred, followed by a recursion. Otherwise, once the interval size falls to smaller than this (i.e., $n \le L$ ), only *one* transfer is required to process the entire block.

Therefore, this simplifies to:

$$
Q(n;Z,L) = O \left( \log_2{n\over{L}} \right)
$$

A more interesting question is: Can this be improved?

## 12. Lower Bounds for Search Quiz and Answers

This quiz section will explore a technique for considering lower bounds on memory transfer, which is inspired by information theory.

<center>
<img src="./assets/03-077Q.png" width="650">
</center>

Consider again (cf. Section 11) the problem of search, given an ordered collection (as in the figure shown above). Here, a sorted array $A$ containing $n$ unique elements is given. The objective is to find the ***largest*** index $i$ such that $A[i] \le v$ .

Recall (cf. Section 11) that the standard binary search algorithm performs $Q(n;Z,L) = O \left( \log_2{n\over{L}} \right)$ transfers in the worst case.

<center>
<img src="./assets/03-078Q.png" width="650">
</center>

Now, reconsider the problem in a different manner: To store the index $i$ , this requires around $\left\lfloor {\log n} \right\rfloor  + 1 = O(\log n)$ bits.

Furthermore, when reading a block of $i$ elements from $A$ , you learn at most $x$ bits of information about this index. If $x$ can be provided an upper bound, then a lower bound on the number of $i$'s during the search can be defined accordingly, i.e., let $x(L)$ be defined as the maximum number of bits "learned" per $L$-sized read.

Correspondingly, the lower bound on search is therefore:

$$
Q_{\rm{search}}(n;Z,L) = \Omega \left( {{{\log n} \over {x(L)}}} \right)
$$

This corresponds to the ratio of the bits attempted to learn, to bits learned on each $L$-sized read.

Given this formulation, what is an asymptotic upper bound on $x(L)$ ?

### ***Answer and Explanation***:

<center>
<img src="./assets/03-079A.png" width="650">
</center>

The asymptotic upper bound on $x(L)$ is as follows:

$$
x(L) = {\log _2}L
$$

<center>
<img src="./assets/03-080A.png" width="650">
</center>

Analogously to the size of the index itself, read $L$ words should reveal approximately $log L$ bits of information.

Consider such a block of $L$ words (as in the figure shown above). The key value searches among the word in question, or otherwise to its left or to its right. Therefore, this reveals $log L$ bits of the index, i.e.,:

$$
{Q_{{\rm{search}}}}(n;Z,L) = \Omega \left( {{{\log n} \over {\log L}}} \right) = \Omega \left( {{{\log }_L}n} \right)
$$

<center>
<img src="./assets/03-081A.png" width="650">
</center>

Comparing this lower bound against the lower bound for naive binary search (cf. Section 11), the latter of which being as follows:

$$
Q(n;Z,L) = O \left( {\log {n \over {L}}} \right) = O \left( \log n - \log L \right)
$$

Therefore, there is a corresponding "net speed" by a factor of approximately $O(\log L)$ accordingly.

## 13. I/O-Efficient Data Structures Quiz and Answers

<center>
<img src="./assets/03-082Q.png" width="650">
</center>

Consider the problem of searching in an ***ordered collection*** (as in the figures shown above).

<center>
<img src="./assets/03-083Q.png" width="650">
</center>


 Representative classical ***data structures*** (as in the figure shown above) used for storing the collection (i.e., besides a sorted array) include the following:
  * doubly-linked list (ordered)
  * binary search tree
    * ***N.B.*** The sorted array $A$ is the net result if performing an in-order traversal of a binary search tree, while otherwise disregarding the left- and right-child pointers
  * skip list
  * B-tree

Which of these classical data structures, if any, attain the aforementioned (cf. Section 12) lower bound? (Select all that apply, or none.)
  * ***N.B.*** This quiz will address this topic "lazily" (i.e., not otherwise "comprehensively" with respect to each data structure in question here; that is left as an exercise to the reader).

### ***Answer and Explanation***:

<center>
<img src="./assets/03-084A.png" width="650">
</center>

As given, among the available choices here, only a ***B-tree*** can attain the lower bound, i.e.,:

$$
{Q_{{\rm{search}}}}(n;Z,L) = \Omega \left( {{{\log }_L}n} \right)
$$

***N.B.*** This section will primarily focus on why a B-tree *can* be I/O-efficient, rather than comprehensively describing why the other data structures *cannot*.

<center>
<img src="./assets/03-085A.png" width="650">
</center>

A **B-tree** is a tree structure comprised of **nodes**, whereby each node contains a set of **keys** and a set of **child pointers** (as in the figure shown above).

Furthermore, the **branching factor** at each node can vary, but must otherwise lie within a specific ***range***.

<center>
<img src="./assets/03-086A.png" width="650">
</center>

The keys within a given node are ***sorted*** (as in the figure shown above).

<center>
<img src="./assets/03-087A.png" width="650">
</center>

Examining a given node (as in the figure shown above), designated as $x$ , the corresponding branching factor lies within a specific interval, defined as ${n_x} \in [B + 1,2B - 1]$ for some $B \ge 2$ , where $B$ is a user-defined parameter.


<center>
<img src="./assets/03-088A.png" width="650">
</center>

Now, consider the $i\rm{th}$ key of value $x$ (as in the figure shown above); let this **key** be denoted as $k_i$ . Furthermore, consider any key within the subtree rooted at the $i\rm{th}$ child of $x$ , denoted as $c_i$ .

A B-tree data structure maintains the following ***invariant***:

$$
{c_1} \le {k_1} \le {c_2} \le  \cdots {c_i} \le {k_i} \le {c_{i + 1}} \le  \cdots  \le {k_n} \le {c_{n + 1}}
$$

i.e., $k_i$ lies between the key values of its children to its left and to its right.

<center>
<img src="./assets/03-089A.png" width="650">
</center>

Given this invariant, it can be readily shown (as in the figure shown above) that the **height** of this B-tree is therefore the following:

$$
O(\log_{B} n)
$$

Therefore, in order for search of the B-tree to attain the lower bound on slow-fast memory transfers, this simply requires appropriate judicious selection of branching-factor size $B$ accordingly for ***I/O optimality***; namely, select $B$ in the following manner:

$$
B = \Theta (L)
$$

Note that a ***key point*** here is that a B-tree can be made I/O-optimal, but ***only*** if the branching factor $B$ is chosen appropriately; in particular, this branching factor must be ***specific to the machine***.
  * ***N.B.*** Later, the notion of "algorithmic portability" in this context will be revisited.

## 14. Conclusion

I/O-avoiding algorithms *can* be "messy" (i.e., much more comparatively so to their conventional serial-RAM counterparts). Nevertheless, this lesson started by attempting to argue that this effort *can* be worthwhile.

<center>
<img src="./assets/03-090.png" width="450">
</center>

Recall (cf. Section 2) that indeed a potential reduction in I/O's is possible, given realistic memory hierarchy parameters, thereby making corresponding computations much faster. Furthermore, note that this would occur *if* memory accesses can be made contiguous while also exploiting fast-memory capacity to the greatest extent possible; indeed, these optimizations can occur even if the factors of improvement are only on the order of $\log L$ (or $\log Z$ , in the case of merge sort).

In closing this lesson, consider the following ***meta-comment***: Our model assumes that the time spent moving the data from slow to fast memories dominates, suggesting that optimization lies within reducing I/O operations. However, how can we be certain whether data movement does indeed dominate?
  * ***N.B.*** In considering this latter question, revisit pertinent high-level concepts (e.g., computational intensity and machine balance).
