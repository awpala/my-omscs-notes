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

### 6. Recursive Idea

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

### 7-8. Algorithm

#### 7. Pseudocode

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

#### 8. Running Time Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).
>
> See a primer on solving recurrences, see Lecture DC3: Solving Recurrences and also [DPV] Chapter 2.2 (Recurrence relations).

## 9-12. Divide and Conquer: Improved Approach

### 9. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

### 10. Pseudocode

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).

### 11. Running Time Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 2.1 (Multiplication).
>
> For a primer on solving recurrences, see Lecture DC3: Solving Recurrences and also [DPV] Chapter 2.2 (Recurrence relations).

### 12. Summary

# Divide and Conquer 2: Linear-Time Median

## 1. Median Problem

> [!NOTE]
> ***Instructor's Note***: For the randomized approach see [DPV] Chapter 2.4 (Medians). The deterministic approach is not covered in [DPV], you can instead look at Eric's [notes](https://cs6505.wordpress.com/schedule/median/).

## 2. Basic Approach

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
