# Randomized Algorithms: Topic Introduction

## 1. Introduction

<center>
<img src="./assets/04-RA1-000-01.png" width="300">
</center>

In this lecture, we will dive into **randomized algorithms**. Hopefully by the end, the student will appreciate the beauty and power of this algorithmic tool.

Discussion begins with cryptography, examining the **RSA cryptosystem**, which is widely used. It is extremely elegant; once we examine the basic mathematics of its underlying **modular arithmetic**, you will consequently appreciate the ingenuity of the RSA protocol accordingly. From there, you will have a basis for understanding of many of today's commonly used cryptosystems.

Another useful application of randomized algorithms we will examine is **hashing**. In particular, we will study the hashing scheme known as **Bloom filters**, which is quite popular in many fields. We will examine its underlying mathematics, as well as involve some relevant probability analysis. This will conclude with a programming project which implements and studies Bloom filters accordingly.

## 2. Lecture Overview

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
