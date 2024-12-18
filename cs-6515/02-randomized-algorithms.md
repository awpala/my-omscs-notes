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

Consider the simple example $x \mod 2$ , where $x$ is an integer. $x \mod 2$ is the ***least-significant bit*** of $x$ , which in turn indicates whether $x$ is odd or even, i.e.,:

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

### 6. Basic Fact Quiz and Answers

## 7-9. Modular Exponentiation

### 7. Naive Quiz and Answers

### 8. Fast Quiz and Answers

### 9. Algorithm

## 10-15. Multiplicative Inverse

### 10. Introduction

### 11. Example

### 12. Existence

### 13. Terminology

### 14. Unique

### 15. Non-Existence

## 16-19. Greatest Common Divisor (GCD)

### 16. Euclid's Rule

### 17-19. Euclid's Algorithm

#### 17. Pseudocode

#### 18. Base Case

#### 19. Running Time

## 20-21. Computing Inverses

### 20. Introduction

### 21. Extended Euclid Algorithm Quiz and Answers

## 22. Recap
