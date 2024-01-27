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

In this quiz, count the number of asymptotic slow-fast transfers and the number of comparisons incurred at each step (as designated with "boxes" $O(\cdots)$ in the figure shown above), as aggregated over all iterations. Express the results in terms of $n , $Z$ , $L$ , and other numeric constant (but ignoring $f$ , which is simply a "corrective" constant to ensure that the size of the input buffers fit properly into the fast memory, along with any necessary "working space").
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
