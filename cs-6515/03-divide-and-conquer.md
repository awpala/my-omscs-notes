# Divide and Conquer: Topic Introduction

## Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2 (Divide-and-conquer algorithms).

![](./assets/07-DC1-000-01.png){ width=650px }

**Divide and conquer algorithms** (or **recursive algorithms**) are one of the first algorithmic tools that have been likely encountered (e.g., via binary search, mergesort, and similar).

To see the power of divide and conquer, we will first examine a fundamental problem: **multiplying** two $n$-bit numbers, where the operands are assumed to be very large (i.e., $n$ on the order of $10^3$ ), as utilized in algorithms such as RSA (cf. Topic 2, Randomized Algorithms).
  * Since these $n$-bit numbers are so large, we can no longer rely on the corresponding hardware implementation (i.e., for trivial $O(1)$ multiplication operations).

Next, we will examine a clever divide and conquer algorithm which is ***faster*** than the standard approach to multiplication.

Another fundamental problem we will examine is given $n$ numbers, determine the **median** element.
  * The given numbers are *unsorted* (i.e., in arbitrary order). This corresponding divide and conquer technique cleverly determines this *without* otherwise requiring to first sort the list (and incurring the corresponding running time penalty accordingly).

Finally, we will examine the **fast Fourier transform** (**FFT**) algorithm, which occurs ubiquitously in many fields (e.g., signal processing) and constitutes a "masterpiece" demonstration of the divide and conquer technique.
  * The FFT algorithm was deemed "the most important numerical algorithm of our lifetime" as of 1994.
  * An understanding of the FFT algorithm will require some additional background in **complex numbers**, which in turn will inform the **recursive approach** of the FFT algorithm itself.

## Overview

> [!NOTE]
> ***Instructor's Note***: We closely follow the presentation in [DPV] Chapter 2.1 (Multiplication). For Eric's notes, see[here](https://cs6505.wordpress.com/fast-multiplication/).
> 
> Review topics: for a discussion on the MergeSort algorithm see [DPV] Chapter 2.3 (Mergesort). For a primer on solving recurrences, see Lecture DC3: Solving Recurrences and also [DPV] Chapter 2.2 (Recurrence relations).

![](./assets/07-DC1-000-02.png){ width=650px }

We have previously seen simple applications of the divide and conquer technique, as follows:
  * fast modular exponentiation algorithm, utilizing the notion of "repeated squaring" (cf. Topic 2, Randomized Algorithms)
  * Euclid's greatest common divisor algorithm (cf. Topic 2, Randomized Algorithms)

In the opening of this topic, we will examine more sophisticated divide and conquer algorithms, starting with multiplication of $n$-bit integers.
  * This multiplication technique is particularly useful in the RSA algorithm (cf. Topic 2, Randomized Algorithms), where $n$ is typically $1024$ or $2048$ bits (i.e., beyond the straightforward capabilities of typical modern hardware).

In the multiplication of $n$-bit integers, we are ***given*** two $n$-bit integers $x$ and $y$ as inputs, with the ***goal*** of computing their product $z = xy$ . Furthermore, we analyze the corresponding running time of the algorithm as a function of the $n$-bit inputs.

Recall (cf. Topic 2, Randomized Algorithms) that the naive algorithm for computing this product $z = xy$ has a running time of $O(n^2)$ . Now, the objective is to ***improve*** this running time performance (i.e., a running time which is ***faster*** than $O(n^2)$ ), using a more sophisticated divide and conquer scheme.

Next, we will examine how to compute the median of (unsorted) $n$ input integers in *linear* time (i.e., $O(n)$ for $n$ such inputs).

Finally, we will examine the fast Fourier transform (FFT).

***N.B.*** It is assumed that divide and conquer is already familiar from previously (i.e., course prerequisites), via representative examples including mergesort (which sorts $n$ integers with running time $O(n \log n)$ ). Furthermore, it is assumed that solving recurrences is a familiar technique as well. For additional reference, the course textbook *Algorithms* by Dasgupta et al. discusses these topics as well.

# Divide and Conquer 1: Fast Integer Multiplication

## 3-4. Multiplying Complex Numbers

### 3. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

Before considering the example of multiplying two $n$-bit integers, we begin with a brief digression into a clever idea from Gauss. At the outset, its utility may not be immediately apparently, however, we will later see how it *is* indeed useful in the context of such $n$-bit integer multiplication.

![](./assets/07-DC1-001.png){ width=650px }

Consider the general setting/context here with respect to the constituent operations:
  * Multiplication is relatively ***expensive*** (i.e., goal is to minimize these operations), i.e., $O(n^2)$ for $n$-bit input integers
  * Addition/subtraction relatively ***cheap***, i.e., $O(1)$ for $n$-bit input integers

Therefore, it stands to reason that increasing addition/subtraction operations are a worthwhile "concession" in order to correspondingly reduce multiplication operations.
  * ***N.B.*** This characterization is generally true, including in the case of multiplying two $n$-bit integers.

Now, consider **complex numbers**, which have two components, real and imaginary. Two such complex numbers are:

$$
a + bi
$$

$$
c + di
$$

where the real components are $a$ and $c$ (respectively) and the imaginary components are $b$ and $d$ (respectively).

The goal is therefore to compute the corresponding product, i.e.,:

$$
(a + bi)(c + di)
$$

To accomplish this, we can distribute the factors (i.e., via FOIL method or equivalent) to yield the following general expression:

$$
ac - bd + (bc + ad)i
$$

Therefore, in order to compute this product, this requires computing the following ***four*** factors (along with corresponding three addition/subtraction operations):
  * $ac$
  * $bd$
  * $bc$
  * $ad$

where each factor corresponds to a real number multiplication.

However, given that multiplication operations are relatively expensive, we would like to minimize these operations accordingly, even if this comes at the "expense" of performing additional (comparatively cheaper) addition/subtraction operations.

So, then, is is possible to reduce the amount of these multiplication operations? Indeed, this *is* possible: We can reduce this down to ***three*** multiplication operations by computing the expression $bc + ad$ directly (i.e., rather than the individual factors $bc$ and $ad$ ). We discuss this improvement next.

### 4. Improved Approach

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

![](./assets/07-DC1-002.png){ width=450px }

To recap (cf. Section 3), we are given two complex numbers $a + bi$ and $c + di$ , with the goal of computing their product using the minimum-possible multiplication operations. Furthermore, the naive approach requires *four* such multiplications, for constituent real-numbers products $ac$ , $bd$ , $bc$ , and $ad$ .

However, in order to reduce this to only *three* multiplication operations, we will compute the expression $bc + ad$ directly (i.e., *without* otherwise computing constituent products $bc$ and $ad$ individually).

![](./assets/07-DC1-003.png){ width=650px }

In order to accomplish this reduced multiplication, observe that expression $bc + ad$ has a cross-product-like nature via constituents $a$ , $b$ , $c$ , and $d$ , i.e.,:

$$
(a + b)(c + d) = ac + bd + (bc + ad)
$$

Observe that the term $(bc + ad)$ is the target expression in question. Furthermore, $ac$ and $bd$ are also familiar from previously (however, here, $bd$ is added rather than subtracted).

Algebraically rearranging the previous expression yields the following:

$$
(bc + ad) = (a + b)(c + d) - ac - bd
$$

With this rearrangement, observe that there are now *three* distinct multiplication operations:
  * $ac$
  * $bd$
  * $(a + b)(c + d)$

From this, we can therefore reconstitute the equivalent overall product as follows:

$$
(a + bi)(c + di) = ac - bd + (bc + ad)i = ac - bd + [(a + b)(c + d) - ac - bd]i
$$

where the three distinct products are used, along with correspondingly "increased" addition/subtraction operations as necessary (which, again, is a "useful" tradeoff/concession here accordingly, since multiplication operations are comparatively much more expensive).

As a representative example, given complex numbers $5 + 3i$ and $7 - 6i$ , the corresponding "third product" term is:

$$
(5 + 3)(7 - 1) = 8 \times 1 = 8
$$

***N.B.*** Observe that this is indeed a clever reduction, and perhaps not immediately obvious/intuitive (and hence one of many demonstrations of Gauss' brilliance accordingly)!

Next, we will utilize this idea in order to compute the product of two $n-bit$ integers with a running time which is *faster* than $O(n^2)$ (i.e., via equivalent naive approach).

## 5-8. Divide and Conquer: Naive Approach

### 5. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

Returning to the original problem of multiplying two $n$-bit numbers (cf. Section 3), let us first consider the straightforward divide and conquer approach for this problem.

![](./assets/07-DC1-004.png){ width=650px }

The ***input*** to the problem is two $n$-bit integers $x$ and $y$ , which we assume for simplicity that $n$ is a power of $2$ for both integer inputs.
  * ***N.B.*** This is a ***common assumption*** for divide and conquer algorithms, which allows to eliminate floors and ceilings in descriptions of the resulting algorithms and their corresponding running time analysis.

The ***goal*** is to compute the product $z = xy$ , with the corresponding running time expressed in terms of $n$ (i.e., bits, the corresponding memory/space required to hold these respective integers).

Here, a standard "divide and conquer idea" (cf. mergesort) is to split the input into two halves. From there, we recursively solve the problem on the two halves until eventually converging on the base case, and then correspondingly combining/merging the results to yield the overall solution.

In this particular problem, we can split both $x$ and $y$ individually into two halves (i.e., with respect to their constituent $n$ bits), which we denote as follows:
  * $x$ is split into halves $x_L$ and $x_R$ , where each half is of size $\frac{n}{2}$ bits
  * similarly, $y$ is split into halves $y_L$ and $y_R$ , where each half is of size $\frac{n}{2}$ bits

![](./assets/07-DC1-005.png){ width=650px }

Let us consider a specific example to examine such partitions. The decimal number (subscript $_{10}$ ) $182_{10}$ can be represented in binary (subscript $_2$ ) as follows:

$$
x = 182_{10} = 10110110_2
$$

Therefore, we can designate the respective halves as follows:

$$
x_L = 1011_2 = 11_{10}
$$

$$
x_R = 0110_2 = 6_{10}
$$

Furthermore, note the relationship among these as follows:

$$
182_{10} = 11_{10} \times {2_{10}}^4 + 6_{10}
$$

More generally, this relationship can be described by the following:

$$
x = x_L \times 2^{n/2} + x_R
$$

where $2^{n/2}$ is effectively a bit-shift operation (i.e., shifting the bit positions over by $\frac{n}{2}$ bits, which is typically an $O(1)$ operation on modern hardware).

### 6. Recursive Idea

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

Now, let us outline the recursive idea for the algorithm.

![](./assets/07-DC1-006.png){ width=650px }

Recall (cf. Section 5) that the idea is to split the input integers $x$ and $y$ of size $n$ bits into two halves (i.e., paired halves $x_L$ and $x_R$ , and $y_L$ and $y_R$ , respectively), each of corresponding size $\frac{n}{2}$ bits.

Furthermore, recall (cf. Section 5) the corresponding relationships between these paired halves as follows:

$$
x = x_L \times 2^{n/2} + x_R
$$

$$
y = y_L \times 2^{n/2} + y_R
$$

where factor $2^{n/2}$ corresponds to an equivalent bit-shifting operation (i.e., by $\frac{n}{2}$ bit positions).

Therefore, with the goal of computing product $xy$ , this yields the following:

$$
xy = (x_L \times 2^{n/2} + x_R)(y_L \times 2^{n/2} + y_R) = 2^nx_Ly_L + 2^{n/2}(x_Ly_R + x_Ry_L) + x_Ry_R
$$

This gives rise to a naturally recursive algorithm, i.e., computation of the corresponding $\frac{n}{2}$-bit products in the right-hand expression:
  * $x_Ly_L$
  * $x_Ly_R$
  * $x_Ry_L$
  * $x_Ry_R$

Next, we will detail this algorithm more formally.

### 7-8. Algorithm

#### 7. Pseudocode

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

![](./assets/07-DC1-007.png){ width=650px }

The pseudocode for the algorithm is given as follows:

$$
\boxed{
\begin{array}{l}
{{\text{EasyMultiply}}(x,y):}\\
\ \ \ \ {{\text{input:\ }} n{\text{-bit\ integers\ }} x {\text{\ and\ }} y {\text{,\ where\ }} n = 2^k}\\
\ \ \ \ {{\text{output:\ }} z = xy}\\
\\
\ \ \ \ {x_L = {\text{first\ }} \frac{n}{2} {\text{bits\ of\ }} x {\text{,\ }} x_R = {\text{last\ }} \frac{n}{2} {\text{bits\ of\ }} x}\\
\ \ \ \ {y_L = {\text{first\ }} \frac{n}{2} {\text{bits\ of\ }} y {\text{,\ }} y_R = {\text{last\ }} \frac{n}{2} {\text{bits\ of\ }} y}\\
\ \ \ \ {A = {\text{EasyMultiply}}(x_L, y_L)}\\
\ \ \ \ {B = {\text{EasyMultiply}}(x_R, y_R)}\\
\ \ \ \ {C = {\text{EasyMultiply}}(x_L, y_R)}\\
\ \ \ \ {D = {\text{EasyMultiply}}(x_R, y_L)}\\
\ \ \ \ {z = 2^n \times A + 2^{n/2}(C + D) + B}\\
\ \ \ \ {{\text{return\ }} (z)}
\end{array}
}
$$

The ***input*** to the algorithm is the two $n$-bit integers $x$ and $y$ , where $n = 2^k$ is assumed (i.e., $n$ is a power of $2$ ) for some non-negative integer $k$ .

The ***output*** is the product of these integers, $z = xy$ .

First, the algorithm splits the input integers $x$ and $y$ into constituent halves/pairs $x_L$ and $x_R$ and $y_L$ and $y_R$ (respectively), where each half is of size $\frac{n}{2}$ . Furthermore, since $n$ is a power of $2$ , these pairs generally divide evenly (thereby obviating the need to include floors and/or ceilings in the representation of the terms accordingly).

Next, we compute the products of these $\frac{n}{2}$-bit pairs recursively, with these corresponding products represented respectively as $A$ , $B$ , $C$ , and $D$ .

Now, given these product quantities, we can compute the overall product $z$ as follows:

$$
z = 2^n \times A + 2^{n/2}(C + D) + B
$$

***N.B.*** cf. Section 7 for the derivation of the right-hand expression.

Furthermore, this product is the correspondingly ***returned*** value/output from the algorithm.

Next, we consider the running time for this algorithm.

#### 8. Running Time Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).
>
> See a primer on solving recurrences, see Lecture DC3: Solving Recurrences and also [DPV] Chapter 2.2 (Recurrence relations).

Which of the following is the running time for the algorithm $\text{EasyMultiply}$ (cf. Section 7)?
  * $O(n)$
  * $O(n \log n)$
  * $O(n^{3/2})$
  * $O(n^2)$
  * $O(n^3)$

![](./assets/07-DC1-008A.png){ width=650px }

The initial partitioning steps to generate halves $x_L$ , $x_R$ , $y_L$ , and $y_R$ require a running time of $O(n)$ (for each of $x$ and $y$ in turn).

In the subsequent recursive calls to $\text{EasyMultiply}$ , if we let $T(n)$ denote the worst-case running time in the worst case scenario of an input of size $n$ bits , then *each* recursive call requires a running time of $T(\frac{n}{2})$ , or equivalently as follows:

$$
4T\bigg(\frac{n}{2}\bigg)
$$

Finally, to compute the final product given as follows :

$$
z = 2^n \times A + 2^{n/2}(C + D) + B
$$

this correspondingly requires $O(n)$ running time, since each single-bit-shift operation can be performed in $O(1)$ running time, i.e., this is equivalent to straightforward $n$-bit multiplication by a power of $2$ (via corresponding factors $2^n$ and $2^{n/2}$ , in order to shift $A$ by $n$ bit positions and $(C + D)$ by $\frac{n}{2}$ bit positions, respectively, with the former dominating the running time in this operation).

Therefore, the overall running time for this algorithm is:

$$
O(n) + 4T\bigg(\frac{n}{2}\bigg) + O(n)
$$

![](./assets/07-DC1-009A.png){ width=650px }

Furthermore, let $T(n)$ denote the worst-case running time of $\text{EasyMultiply}$ on an input of size $n$ bits. This gives:

$$
T(n) = 4T\bigg(\frac{n}{2}\bigg) + O(n)
$$

We can solve this recurrence to give the following:

$$
T(n) = O(n^2)
$$

***N.B.*** Solving recurrences should be familiar from previously; this result follows from direct application of the Master Theorem. Furthermore, it is also covered/reviewed later in this lecture (cf. Divide and Conquer 3).

Therefore, the running time of this algorithm is the *same* as the naive/straightforward multiplication algorithm (cf. Section 3).

Can we improve this approach (e.g., reducing from $4$ recursive operations down to $3$ )? We explore this next, revisiting Gauss's idea/improvement (cf. Section 4) in the process.

## 9-12. Divide and Conquer: Improved Approach

### 9. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

Now, consider an improvement to the multiplication (i.e., relative to a running time of $O(n^2)$ with respect to $n-bit integer inputs).

![](./assets/07-DC1-010.png){ width=650px }

Recall (cf. Section 6) the following key expression:

$$
xy = 2^nx_Ly_L + 2^{n/2}(x_Ly_R + x_Ry_L) + x_Ry_R
$$

Furthermore, recall (cf. Section 7) that the straightforward divide and conquer approach computes the following four products in this expression:
  * $x_Ly_L$
  * $x_Ly_R$
  * $x_Ry_L$
  * $x_Ry_R$

This in turn gives rise to an overall running time of $O(n^2)$ (cf. Section 8).

Now, the objective is to reduce the number of subproblems from $4$ to $3$ . Recalling (cf. Section 4) Gauss's idea, we can correspondingly compute the expression $x_Ly_R + x_Ry_L$ without computing the individual products as follows (i.e., via analogous cross-multiplication-form as before):

$$
x_Ly_R + x_Ry_L = (x_L + x_R)(y_L + y_R) - x_Ly_L - x_Ry_R
$$

Analogously to before (cf. Section 4), with this rearrangement, observe that there are now *three* distinct multiplication operations:
  * $x_Ly_L$
  * $x_Ry_R$
  * $(x_L + x_R)(y_L + y_R)$

Furthermore, recall (cf. Section 7) that the first two of these products were represented as quantities $A$ and $B$ (respectively). Similarly, we can designate the third product as $C$ (which in turn supplants the previous *distinct* products $C$ and $D$ ).

Therefore, the corresponding equivalent product now becomes:

$$
xy = 2^nA + 2^{n/2}(C - A - B) + B
$$

where we have now (as before) net decreased by one multiplication operation, while incurring some net-increased addition/subtraction operations (a useful tradeoff here nonetheless). Correspondingly, we have now reduced the subproblems from $4$ to $3$ accordingly.

Next, we detail this algorithm more formally.

### 10. Pseudocode

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

![](./assets/07-DC1-011.png){ width=650px }

![](./assets/07-DC1-012.png){ width=650px }

The pseudocode for the improved algorithm is given as follows:

$$
\boxed{
\begin{array}{l}
{{\text{FastMultiply}}(x,y):}\\
\ \ \ \ {{\text{input:\ }} n{\text{-bit\ integers\ }} x {\text{\ and\ }} y {\text{,\ where\ }} n = 2^k}\\
\ \ \ \ {{\text{output:\ }} z = xy}\\
\\
\ \ \ \ {x_L = {\text{first\ }} \frac{n}{2} {\text{bits\ of\ }} x {\text{,\ }} x_R = {\text{last\ }} \frac{n}{2} {\text{bits\ of\ }} x}\\
\ \ \ \ {y_L = {\text{first\ }} \frac{n}{2} {\text{bits\ of\ }} y {\text{,\ }} y_R = {\text{last\ }} \frac{n}{2} {\text{bits\ of\ }} y}\\
\ \ \ \ {A = {\text{FastMultiply}}(x_L, y_L)}\\
\ \ \ \ {B = {\text{FastMultiply}}(x_R, y_R)}\\
\ \ \ \ {C = {\text{FastMultiply}}(x_L + x_R, y_L + y_R)}\\
\ \ \ \ {z = 2^n \times A + 2^{n/2}(C - A - B) + B}\\
\ \ \ \ {{\text{return\ }} (z)}
\end{array}
}
$$

This algorithm is similar to the straightforward divide and conquer algorithm $\text{EasyMultiply}$ (cf. Section 7), however, after partitioning $x$ and $y$ , here, we have now reduced to $3$ recursive subproblems (cf. $4$ previously).

Furthermore, with these updated subproblems, the corresponding overall product is now computed as follows:

$$
z = 2^n \times A + 2^{n/2}(C - A - B) + B
$$

### 11. Running Time Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).
>
> For a primer on solving recurrences, see Lecture DC3: Solving Recurrences and also [DPV] Chapter 2.2 (Recurrence relations).

Which of the following is the running time for the algorithm $\text{FastMultiply}$ (cf. Section 10)?
  * $O(n)$
  * $O(n \log n)$
  * $O(n^{3/2})$
  * $O(n^{\log _3 2})$
  * $O(n^{\log _2 3})$
  * $O(n^2)$

![](./assets/07-DC1-013A.png){ width=650px }

In the improved algorithm (cf. Section 10), we now have only $3$ recursive subproblems giving rise to analogous (cf. 8) recurrence relation as follows:

$$
T(n) = 3T\bigg(\frac{n}{2}\bigg) + O(n)
$$

where (as before) $T(n)$ denotes the worst-case running time of $\text{FastMultiply}$ on an input of size $n$ bits.

To solve this recurrence, we first upper-bound via $cn$ as follows:

$$
3T\bigg(\frac{n}{2}\bigg) + O(n) \le cn + 3T\bigg(\frac{n}{2}\bigg)
$$

Furthermore, we can substitute for $T(\frac{n}{2})$ on the right-hand side as follows:

$$
3T\bigg(\frac{n}{2}\bigg) + O(n) \le cn + 3T\bigg( c \frac{n}{2} + 3T\bigg( \frac{n}{2^2} \bigg) \bigg)
$$

Simplifying algebraically on the right-hand side and simultaneously similarly substituting further yields:

$$
3T\bigg(\frac{n}{2}\bigg) + O(n) \le cn \bigg( 1 + \frac{3}{2} \bigg) + 3^2 T\bigg( \frac{cn}{2^2} + 3T\bigg( \frac{n}{2^3} \bigg) \bigg)
$$

Expanding the right-hand side in this manner yields the following:

$$
3T\bigg(\frac{n}{2}\bigg) + O(n) \le cn \bigg[ 1 + \frac{3}{2} + \bigg({\frac{3}{2}}\bigg)^2 + \bigg({\frac{3}{2}}\bigg)^3 + \cdots + \bigg({\frac{3}{2}}\bigg)^{\log _2 n} \bigg]
$$

where the expansion proceeds accordingly until the final term (i.e., of general form $T(\frac{n}{2^k})$ ) is eventually a constant.

In the resulting geometric series, we consider the following cases:
  * the terms are equal $\rightarrow$ no
  * the series is decreasing (i.e., first term dominates) $\rightarrow$ no
  * the series is increasing (i.e., last term dominates, via $\frac{3}{2} > 1$ ) $\rightarrow$ yes

Therefore, since the last term dominates (and with $n$ such terms in the worst case), the overall running time is characterized as:

$$
T(n) \le O \bigg( n \times \bigg(\frac{3}{2}\bigg)^{\log _2 n} \bigg)
$$

Furthermore, simplifying algebraically yields the following:

$$
O \bigg( n \times \bigg(\frac{3}{2}\bigg)^{\log _2 n} \bigg) = O(3^{\log _2 n}) = O(n^{\log _2 3})
$$

***N.B.*** In the first simplification/arrangement, $2^{\log _2 n} = n$ . Furthermore, the second simplification/rearrangement follows directly from rules of logarithms (i.e., $3 = 2^{\log_2 3} \implies 3^{\log _2 n} = (2^{log _2 3})^{\log_2 n} = (2^{log _2 n})^{\log_2 3} = n^{\log_2 3}$ ).

![](./assets/07-DC1-014A.png){ width=650px }

Note that the constant value $\log _2 3 \approx 1.59$ , which is indeed an improvement over factor $2$ (i.e., $\log _2 3 \approx 1.59 < 2$ ).

Furthermore, we can improve this factor to approach arbitrarily close to $1$ , however, there is a corresponding cost for this: The *constant factor* which is omitted in the big-O notation grows as the exponent (i.e., $\log _2 3$ ) decreases (i.e., rather than splitting into only two halves, there is increasingly such splitting, which correspondingly requires additional work to later recombine into the resulting overall product).

### 12. Summary

This concludes the description of the multiplication algorithm.

![](./assets/07-DC1-015.png){ width=650px }

Before proceeding, let us highlight the cleverness of the described approach. Consider the following input integers:

$$
x = 182_{10} = 10110110_2
$$

$$
y = 154_{10} = 10011010_2
$$

Our approach begins by splitting these inputs into their constituent $\frac{n}{2}$ halves, i.e.,:
  * $x_L = 1011_2 = 11_{10}$
  * $x_R = 0110_2 = 6_{10}$
  * $y_L = 1001_2 = 9_{10}$
  * $y_R = 1010_2 = 10_{10}$

Correspondingly, the algorithm (cf. Section 10) first computes the following three products:
  * $11_{10} \times 9_{10} = 99_{10}$
  * $6_{10} \times 10_{10} = 60_{10}$
  * $(11_{10} + 6_{10}) \times (9_{10} + 10_{10}) = 323_{10}$

We then compute the overall product as follows:

$$
182_{10} \times 154_{10} = 99_{10} \times 256_{10} + (323_{10} - 99_{10} -60_{10}) \times 16_{10} + 60_{10} = 28,028_{10}
$$

***N.B.*** The final result here is calculated directly (i.e., via calculator or equivalent).

It is indeed quite fascinating (and perhaps non-intuitive) that eventually proceeding in this manner converges on the correct result!

***N.B.*** A similar idea exists for matrix multiplication, via an analogous technique called **Strassen's algorithm**. Consult the course textbook *Algorithms* by Dasgupta et al. (or equivalent sources) for additional information.

Next, we examine the linear-time median, another clever divide and conquer approach.

# Divide and Conquer 2: Linear-Time Median

## 1. Median Problem

> [!NOTE]
> ***Instructor's Note***: For the randomized approach see [DPV] Chapter 2.4 (Medians). The deterministic approach is not covered in [DPV], you can instead look at Eric's [notes](https://cs6505.wordpress.com/schedule/median/).

Consider another example of a divide and conquer algorithm, which entails finding the median of $n$ numbers.

![](./assets/08-DC2-001.png){ width=650px }

In this algorithm, the ***input*** is an *unsorted* list/array $A = [a_1, \dots, a_n]$ of $n$ numbers.

The ***goal*** is to determine the *median* of $A$ (i.e., the middle element in equivalent-sorted order).

More formally, we can define the median as the $\lfloor \frac{n}{2} \rfloor$<sup>th</sup> smallest element in $A$ . For odd $n$ , $n = 2 \ell + 1$ (with respect to length/size $\ell$ of $A$ ), and therefore the median is the $(\ell + 1)$<sup>st</sup> element in $A$ .

![](./assets/08-DC2-002.png){ width=650px }

It is also useful to solve a more general problem: Find the $k$<sup>th</sup> element of an input list $A$ .

More specifically, we can define this more general problem as follows:

> Given unsorted $A$ and integer $k$ where $1 \le k \le n$ , find the $k$<sup>th</sup> smallest element of $A$

where $k = \frac{n}{2}$ is the special case of the median.

If we ***sort*** the list, then this gives rise to a relatively trivial algorithm: Given unsorted $A$ , we sort $A$ and then simply output the $k$<sup>th</sup> element directly.
  * Using mergesort, this sorting has an overall running time of $O(n \log n)$ . Furthermore, this also generally the fastest possible sort if using similar comparison sorts.

However, is it possible to achieve a better running time, by obviating the need to first sort $A$ ? Indeed, this is possible, and we will examine the corresponding algorithm having overall running time $O(n)$ (i.e., linear) next. This is a clever divide and conquer algorithm, devised in 1973 by Blum, Floyd, Pratt, Rivest, and Tarjan.

## 2. Basic Approach

![](./assets/08-DC2-003.png){ width=650px }

The basic approach for finding the $k$<sup>th</sup> smallest element in unsorted array $A$ is a divide and conquer technique which is reminiscent of the quicksort algorithm.

Let us first review the quicksort algorithm, and make appropriate modifications to highlight the corresponding approach.

When running quicksort on a list of numbers $A$ , the following steps are performed:
  * 1 - Choose a pivot $p$
  * 2 - Partition $A$ into $A < p$ , $A = p$ , and $A < p$
  * 3 - Recursively sort via quicksort on partitions $A < p$ and $A > p$

Proceeding in this manner, the final output is the sorted list comprised of the "smallest" elements, followed by the "equal" elements, and then finally followed by the "largest" elements (respectively).

The ***key challenge*** in quicksort is judicious selection of an effective pivot $p$ . For example, selection of the largest element as the pivot makes a trivial reduction in the subproblem by only one element, thereby degenerating the overall running time for sorting to $O(n^2)$ .

So, then, what constitutes such an "effective" pivot? This is accomplished via the ***median*** element (or within this vicinity). This pivot selection in turn is relevant to the current problem at hand (i.e., linear-time median computation). Furthermore, while quicksort has a running time of $O(n \log n)$ , while our target algorithm has a running time of $O(n)$ . However, the key distinction in the latter is the fact that we do *not* have to consider both cases $A < p$ *and* $A > p$ , but rather it is only strictly necessarily to reduce to a search subproblem comprised of only *one* of these sub-lists.

Next, we will demonstrate an example of this search process.

## 3. Search Example

## 4. QuickSelect

## 5. Simple Recurrence Quiz and Answers

## 6-11. Divide and Conquer High-Level Idea

### 6. Introduction

### 7. Goal: Good Pivot

### 8. Random Pivot

### 9. Recursive Pivot

### 10. Representative Sample

### 11. Recursive Representative Sample

## 12-14. Median

### 12. Pseudocode

### 13. Running Time

### 14. Linear-Time Correctness

## 15. Addendum: Homework Question

# Divide and Conquer 3: Solving Recurrences

## 1. Solving Recurrences

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.2 (Recurrence relations).

## 2-3. Example 1

### 2. Introduction

### 3. Expanding Out

## 4. Geometric Series

## 5. Manipulating Polynomials

## 6. Example 2

## 7. General Recurrence

> [!NOTE]
> ***Instructor's Note***: See [DPV] Chapter 2.2 (Recurrence relations) for the more general form of the Master Theorem.

# Divide and Conquer 4: Fast Fourier Transform (FFT) - Part 1

## 1-3. Polynomial Multiplication

### 1. Introduction

> [!NOTE]
> ***Instructor's Note***: We closely follow the presentation in [DPV] Chapter 2.6 (The fast Fourier transform).

### 2. Example Quiz and Answers

### 3. General Problem

## 4. Convolution Applications

## 5. Polynomial Basics

## 6. Multiplying Polynomials: Values

## 7-12. Fast Fourier Transform (FFT)

### 7. Opposites

### 8. Splitting $A(x)$

### 9. Even and Odd

### 10. Recursion

### 11. Summary

### 12. Recursive Problem

## 13-19. Review: Complex Numbers

### 13. Introduction

### 14. Multiplying in Polar

### 15-19. Complex Roots

#### 15. Introduction

#### 16. Graphical View

#### 17. Notation

#### 18. Examples

#### 19. Practice Quiz and Answers

##### Question 1

##### Question 2

##### Question 3

##### Question 4

##### Question 5

### 20-21. Key Properties

#### 20. Opposites

#### 21. Squares

# Divide and Conquer 5: Fast Fourier Transform (FFT) - Part 2

## 1-5. Fast Fourier Transform (FFT)

### 1. High-Level Introduction

### 2-4. Pseudocode

#### 2. Introduction

#### 3. Core

#### 4. Concise

### 5. Running Time

## 6. Polynomial Multiplication Using Fast Fourier Transform (FFT)

## 7-9. Linear Algebra View

### 7. Introduction

### 8. Linear Algebra View of Fast Fourier Transform (FFT)

### 9. Linear Algebra for Inverse Fast Fourier Transform (FFT)

## 10-11. Inverse Fast Fourier Transform (FFT)

### 10. Introduction

### 11. Inverse Fast Fourier Transform (FFT) via FFT

## 12. Inverses Quiz and Answers

## 13-14. Sum of Roots

### 13. Introduction Quiz and Answers

### 14. Proof of Claim

## 15-17. Proof of Lemma

### 15. Introduction

### 16. Diagonal Entries

### 17. Off-Diagonal Entries

## 18. Back to Polynomial Multiplication
