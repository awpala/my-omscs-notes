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

## 3. External Memory Mergesort
