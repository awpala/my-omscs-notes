# Randomized Algorithms: Topic Introduction

## Introduction

<center>
<img src="./assets/04-RA1-000-01.png" width="300">
</center>

In this lecture, we will dive into **randomized algorithms**. Hopefully by the end, the student will appreciate the beauty and power of this algorithmic tool.

Discussion begins with cryptography, examining the **RSA cryptosystem**, which is widely used. It is extremely elegant; once we examine the basic mathematics of its underlying **modular arithmetic**, you will consequently appreciate the ingenuity of the RSA protocol accordingly. From there, you will have a basis for understanding of many of today's commonly used cryptosystems.

Another useful application of randomized algorithms we will examine is **hashing**. In particular, we will study the hashing scheme known as **Bloom filters**, which is quite popular in many fields. We will examine its underlying mathematics, as well as involve some relevant probability analysis. This will conclude with a programming project which implements and studies Bloom filters accordingly.

## Lecture Overview

> [!NOTE]
> ***Instructor's Note***: This topic is covered in [DPV] Chapter 1 (Algorithms with numbers), and we closely follow their presentation. For Eric's notes see [here](https://cs6505.wordpress.com/rsa-1/).

<center>
<img src="./assets/04-RA1-000-02.png" width="650">
</center>

Now, consider an ***outline*** of the topics we will study in this lecture.

The mathematics of the RSA cryptosystem are very beautiful, and fairly simple to understand with a sufficient mathematical background accordingly. Therefore, the lecture begins with a short primer on the relevant mathematical topics, which include the following:
  * **modular arithmetic**
    * ***N.B.*** This topic may be familiar from previous coursework, exposure, etc.
  * **multiplicative inverses**
  * **Euclid's greatest common divisor (GCD) algorithm**

Next, we will examine **Fermat's little theorem**, a key tool in the design of the RSA algorithm; indeed, at this point, we will be able to detail the **RSA algorithm** accordingly.

Finally, we will examine **primarily testing**, i.e., given a number, determine whether it is prime or composite (non-prime); we accomplish this using the aforementioned Fermat's little theorem. From there, we will be able to **generate random primes**, which is a key component in the RSA algorithm, thereby concluding its discussion accordingly.

We therefore next shall commence with discussion of these algorithms pertaining to the RSA algorithm.

# Randomized Algorithms 1: Modular Arithmetic

## 3. Huge Integers

Let us first consider the context for the RSA algorithm.

<center>
<img src="./assets/04-RA1-001.png" width="650">
</center>

In cryptography, we typically work with $n$-bit numbers (e.g., $x$ , $y$ , and $N$ ), where the size of constituent bits in these numbers is *huge* (i.e., with $n$ being on the order of $1024$ or $2048$ bits, representing correspondingly $2^{1024} - 1$ or $2^{2048} - 1$ distinct integers, respectively, including integer $0$ in both cases). While we typically consider arithmetic operations on hardware as $O(1)$ "fast" operations, in practice, this is only strictly the case for $n$ being a $32$- or $64$-bit number.

Therefore, let us now review exactly how "expensive" such corresponding arithmetic operations are when dealing with these large-bit numbers.

## 4-6. Modular Arithmetic Overview

### 4. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2 (Modular arithmetic).

Now, let us review **modular arithmetic**, the basic mathematics underlying the RSA algorithm.

<center>
<img src="./assets/04-RA1-002.png" width="650">
</center>

Consider the simple example $x \mod 2$ , where $x$ is an integer and $\text{mod}$ denotes the "modulo" operator. $x \mod 2$ is the ***least-significant bit*** of $x$ , which in turn indicates whether $x$ is odd or even, i.e.,:

$$
x \mod 2 = 
\begin{cases}
  {1}&{{\text{if\ }} x {\text{\ is\ odd}}}\\ 
  {0}&{{\text{if\ }} x {\text{\ is\ even}}}
\end{cases}
$$

Another way to look at this is to divide $x$ by $2$ , and examining the resulting remainder (i.e., if divisible by $2$ then the remainder is $0$ , otherwise the remainder is $1$ ).

Now, consider an arbitrary integer $N$ where $N \ge 1$ . The corresponding definition is:

> $x \mod N$ = remainder when $x$ is divided by $N$

Let us also consider some important ***notation*** for modular arithmetic. Suppose we have two numbers $x$ and $y$ , with both having the same/common $\mod N$ . These two numbers are *not* necessarily *equal*, however, they are ***congruent/equivalent***. We therefore denote this relationship as follows:

$$
x \equiv y \mod N
$$

where notation $\equiv$ is read as "is congruent to."

This means that $\frac{x}{N}$ and $\frac{y}{N}$ have the *same* remainder.

### 5. Example: $\mod 3$

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2 (Modular arithmetic).

To better understand the concept of modular arithmetic, let us consider another simple example, $\mod 3$ .

<center>
<img src="./assets/04-RA1-003.png" width="650">
</center>

When examining $\mod 3$ , there are three possible values:

$$
0, 1, 2
$$

Formally, this is defined as an **equivalence class**, i.e., $\mod 3$ has three such equivalence classes.

We can further enumerate these three (distinct) equivalence classes for $\mod 3$ as follows:

$$
\begin{matrix}
{\cdots}&{-9}&{-6}&{-3}&{0}&{3}&{6}&{9}&{\cdots}\\
{\cdots}&{-8}&{-5}&{-2}&{1}&{4}&{7}&{10}&{\cdots}\\
{\cdots}&{-7}&{-4}&{-1}&{2}&{5}&{8}&{11}&{\cdots}
\end{matrix}
$$

The first row represents the equivalence class for $0$ , e.g., $3 \mod 3 = 0$ , $3 \mod 6 = 0$ , etc.

Similarly, the second row represents the equivalence class for $1$ , e.g., $4 \mod 3 = 1$ , $7 \mod 3 = 1$ , etc.

Furthermore, the third row represents the equivalence class for $2$ , e.g., $5 \mod 3 = 2$ , $8 \mod 3 = 2$ , etc.

Note that these equivalence classes also extend into the negative integers as well. 

These equivalence classes follow directly from the following definition:

> $x \mod N = r$ if $x = qN + r$ for integers $q,r$

where $q$ is the quotient and $r$ is the remainder.

This means that there is some multiple $N$ for which $q$ such integer multiples added to $r$ reconstitutes the original number $x$ (e.g., $-2 \mod 3$ in this form is represented as $q = -1$ , $N = 3$ , and $r = 1$ which yields back $x = (-1)(3) + 1 = -2$ , with $r$ corresponding to the appropriate equivalence class $1$ and $q$ corresponding to the appropriate "offset" [from position $0$ at the centerline] $-1$ in the row representation above).

Therefore, within a given equivalence class (i.e., "row" in the representation above), the corresponding numbers are all the "same" (i.e., *congruent*) with respect to $\mod 3$ .

### 6. Basic Fact Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2 (Modular arithmetic): the substitution rule.

<center>
<img src="./assets/04-RA1-004Q.png" width="650">
</center>

A basic fact that we will use repeatedly is given as follows:

> If $x \equiv y \mod N$ and $a \equiv b \mod N$ , then $x + a \equiv y + b \mod N$ and $xa \equiv yb \mod N$

In this formalism, both $x$ and $y$ are congruent with each other, as are $a$ and $b$ . Furthermore, observe the "replacement/substitution" property exhibited in the latter expressions by virtue of this congruence.

To illustrate the utility of this fact, consider the expression $321 \times 17 \mod 320$ . We can use the given fact to simplify this computation as follows:
  * Note that $321 \equiv 1 \mod 320$
  * Hence, $321 \times 17 \equiv 1 \times 17 \equiv 17 \mod 320$

Therefore, the expression  $321 \times 17 \mod 320$ simply evaluates to $17$ .

## 7-9. Modular Exponentiation

### 7. Naive Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.2 (Modular exponentiation).

#### Introduction

Having seen basic modular arithmetic (cf. Section 4), we now shift focus to the **modular exponentiation** operation, which will be ubiquitously used in subsequent discussion.

<center>
<img src="./assets/04-RA1-006Q.png" width="650">
</center>

As before (cf. Section 3), we are given $n$-bit numbers $x$ , $y$ , and $N$ which are *huge* (i.e., with the constituent $n$ bits comprising $1024$ or $2048$ bits, correspondingly representing numbers/integers on the order of $O(2^{2^{10}}) \approx O(10^{308})$ or $O(2^{2^{11}}) \approx O(10^{616})$ , respectively). The ***goal*** is to compute the quantity $x^y /\mod N$ in an ***efficient*** manner, i.e., of order polynomial in the input size $n$ .
  * ***N.B.*** Notably, we do *not* simply require polynomial in the input numbers $x$ , $y$ , and $N$ , because these numbers are already intrinsically exponential in $n$ , giving rise to unfathomably slow running times in practice.

#### Algorithm

<center>
<img src="./assets/04-RA1-007Q.png" width="650">
</center>

First, consider a simple ***algorithm*** to perform this multiplication, outlined as follows:

$$
\begin{matrix}
{x \mod N = a_1}\\
{x^2 \equiv a_1x \mod N = a_2}\\
{x^3 \equiv a_2x \mod N = a_3}\\
{\vdots}\\
{x^y \equiv a_{y-1}x \mod N}
\end{matrix}
$$

Starting with $x \mod N = a_1$ , the result $a_1$ is then propagated forward to compute $x^2$ via $x^2 \equiv a_1x \mod N = a_2$ , which in turn is propagated forward to compute $x^3$ , and so on, until finally the target quantity $x^y$ is computed.

So, then, what is the ***running time*** for this algorithm?

In a given round, the result denoted as $a_i$ is an $n$-bit number (i.e., at most $N-1$ , as per corresponding operation $\mod N$ ), and similarly $x$ itself is also an $n$-bit number. Multiplying two such $n$-bit numbers together can be accomplished straightforwardly with basic arithmetic, correspondingly requiring $O(n^2)$ running time accordingly. Furthermore, taking $\mod N$ of this product (i.e., dividing by $N$ and taking the remainder as the result) also requires $O(n^2)$ time by similar rationale. Therefore, one such "round" requires overall $O(n^2)$ running time.

Furthermore, there are $y$ such rounds performed overall, where $y$ is at most $2^n$ bits in size (i.e., $y \le 2^n$ ).

Therefore, the overall running time is $O(n^2y) = O(n^22^n)$ , which is exponential in the input size $n$ . This is a very inefficient algorithm accordingly (i.e., even an input as small as $n = 30$ or so would fail to converge on a solution in any reasonable time).

To improve this solution, we will next utilize a technique of repeated squaring.

#### Example Quiz and Answers

As an exercise, compute the quantity $7^5 \mod 23$ using this simple/naive algorithm.

This can be accomplished as follows:

$$
\begin{matrix}
{7^1}&{\equiv}&{7}&{}&{}&{\equiv}&{7 \mod 23}\\
{7^2}&{\equiv}&{7 \times 7}&{}&{}&{\equiv}&{3 \mod 23}\\
{7^3}&{\equiv}&{3 \times 7}&{}&{}&{\equiv}&{21 \mod 23}\\
{7^4}&{\equiv}&{21 \times 7}&{\equiv}&{147}&{\equiv}&{9 \mod 23}\\
{7^5}&{\equiv}&{9 \times 7}&{\equiv}&{63}&{\equiv}&{17 \mod 23}
\end{matrix}
$$

Therefore, the expression evaluates to $17$ .

### 8. Fast Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.2 (Modular exponentiation).

#### Algorithm

<center>
<img src="./assets/04-RA1-009Q.png" width="650">
</center>

In the ***algorithm*** involving repeated squaring, we proceed similarly to before (cf. Section 7), however, with intermediate squaring across rounds, as follows:

$$
\begin{matrix}
{x \mod N = a_1}\\
{x^2 \equiv a_1^2 \mod N = a_2}\\
{x^4 \equiv (a_2)^2 \mod N = a_4}\\
{x^8 \equiv (a_4)^2 \mod N = a_8}\\
{\vdots}
\end{matrix}
$$

This results in $x^y$ where $y$ is a power of $2$ . We then examine the binary representation of $y$ to determine $x^y mod N$ via appropriate power of $2$ accordingly.

#### Example Quiz and Answers

<center>
<img src="./assets/04-RA1-010A.png" width="650">
</center>

As an exercise, compute the quantity $7^25 \mod 23$ using this fast algorithm via repeated squaring.

This can be accomplished as follows:

$$
\begin{matrix}
{7^1}&{\equiv}&{7}&{}&{}&{\equiv}&{7 \mod 23}\\
{7^2}&{\equiv}&{7^2}&{}&{}&{\equiv}&{3 \mod 23}\\
{7^4}&{\equiv}&{3^2}&{}&{}&{\equiv}&{9 \mod 23}\\
{7^8}&{\equiv}&{9^2}&{\equiv}&{81}&{\equiv}&{12 \mod 23}\\
{7^{16}}&{\equiv}&{12^2}&{\equiv}&{144}&{\equiv}&{6 \mod 23}
\end{matrix}
$$

Since $25$ in binary form is $11001_2$ (i.e., relevant factors per corresponding $1$ bits are $7^{16}$ , $7^8$ , and $7^1$ ), this gives:

$$
7^{25} \equiv 7^{16} \times 7^8 \times 7^1 \equiv 6 \times 12 \times 7 \equiv 72 \times 7 \equiv 3 \times 7 \equiv 21 \mod 23
$$

Therefore, using corresponding squares, the expression evaluates to $21$ .

### 9. Algorithm

<center>
<img src="./assets/04-RA1-011.png" width="650">
</center>

## 10-15. Multiplicative Inverse

### 10. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.5 (Modular division).

### 11. Example

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.5 (Modular division).

### 12. Existence

### 13. Terminology

### 14. Unique

### 15. Non-Existence

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.5 (Modular division).

## 16-19. Greatest Common Divisor (GCD)

### 16. Euclid's Rule

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.3 (Euclid's algorithm for greatest common divisor).

### 17-19. Euclid's Algorithm

#### 17. Pseudocode

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.3 (Euclid's algorithm for greatest common divisor).

#### 18. Base Case

#### 19. Running Time

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.3 (Euclid's algorithm for greatest common divisor).

## 20-21. Computing Inverses

### 20. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.2.5 (Modular division).

### 21. Extended Euclid Algorithm Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: See [DPV] Chapter 1.2.4 (An extension of Euclid's algorithm) for the detailed proof of correctness.

## 22. Recap

> [!NOTE]
> ***Instructor's Note***: This topic is covered in [DPV] Chapter 1 (Algorithms with numbers), and we closely follow their presentation. For Eric's notes see [here](https://cs6505.wordpress.com/rsa-1/).

# Randomized Algorithms 2: RSA

## 1-5. Fermat's Little Theorem

### 1. Introduction

> [!NOTE]
> ***Instructor's Note***: This topic is covered in [DPV] Chapter 1.3 (Primality testing), and we closely follow their presentation. For Eric's notes see [here](https://cs6505.wordpress.com/rsa-1/).

### 2-4. Proof

#### 2. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 3. Key Lemma

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 4. Finishing Up

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

## 5-7. Euler's Theorem

### 5. Introduction

### 6. Euler's Totient Function Quiz and Answers

### 7. Euler's Theorem for $N = pq$

## 8. RSA Algorithm Idea

## 9. Cryptography Setting

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.4 (Cryptography).

## 10-14. RSA Protocol

### 10. Keys

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.4.2 (RSA).

### 11. Encrypting

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.4.2 (RSA).

### 12. Pitfalls

### 13-14. Recap

#### 13. Part 1

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.4.2 (RSA).

#### 14. Part 2

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.4.2 (RSA).

## 15. RSA Exercise

## 16. Random Primes

> [!NOTE]
> ***Instructor's Note***: This topic is covered in [DPV] Chapter 1.3.1 (Generating random primes), and we closely follow their presentation. For Eric's notes see [here](https://cs6505.wordpress.com/rsa-ii/).

## 17-24. Primality

### 17-21. Fermat's Test

#### 17. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 18. Trivial Witness

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 19. Non-Trivial Witnesses

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 20. No Non-Trivial Witnesses?

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 21. Many Witnesses

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

### 22-23. Simple Primarily Test

#### 22. Introduction

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

#### 23. Analysis

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

### 24. Better Primality test

> [!NOTE]
> ***Instructor's Note***: See also [DPV] Chapter 1.3 (Primality testing).

## 25. Addendum: Pseudoprimes

> [!NOTE]
> ***Instructor's Note***: In [DPV] see the text box titled "Carmichael numbers" in Section 1.3 (p. 28 of print edition).

# Randomized Algorithms 3: Bloom Filters

## 1. Hashing Outline

> [!NOTE]
> ***Instructor's Note***: For Eric's notes, see [here](https://cs6505.wordpress.com/bloom-filters/).

## 2-9. Balls into Bins

### 2. Introduction

### 3. Probability Quiz and Answers

### 4. Analysis Setup

### 5. Max Load Quiz and Answers

### 6. Max Load Analysis

### 7-8. Best of Two Scheme

#### 7. Introduction

#### 8. Power of Two Choices

### 9. Hashing Setup

## 10. Chain Hashing

## 11. Power of Two Choices for Hashing Quiz and Answers

> [!NOTE]
> ***Instructor's Note***: Please do this on your own and watch the solution to see if you're correct.

## 12-22. Bloom Filters

### 12. Outline

### 13. Motivation

### 14. Operations

### 15. Bloom Filters

### 16. Robust Scheme

### 17. Correctness

### 18. Analysis Setup

### 19. False Positive Probability

### 20. Optimal $k$

### 21. Looking at False Positive Rate

### 22. Summary
