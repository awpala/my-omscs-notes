# Dynamic Programming: Topic Introduction

<center>
<img src="./assets/01-DP1-000.png" width="300">
</center>

**Dynamic programming** (**DP**) is an extremely useful technique.
  * ***N.B.*** Students often have trouble with this topic, however, with sufficient practice, it will become more intuitive and familiar. The lectures will also demonstrate illustrative examples for this purpose.

The ***key*** to mastering dynamic programming is to perform lots of practice problems. While the homeworks are a starting point, do additional textbook problems and other references (e.g., textbooks, courses, etc.) for further practice.

The ***outline*** for this section is as follows:
  * **Fibonacci numbers** → This is a "toy example" to illustrate the basic idea of dynamic programming
  * Subsequently to computing Fibonacci numbers, we will dive into a variety of example problems to get a feel for the different styles of dynamic programming algorithms, including:
    * **Longest Increasing Subsequence** (**LIS**)
    * **Longest Common Subsequence** (**LCS**)
    * **Knapsack**
    * **Chain Matrix Multiplication**
    * **Shortest Path Algorithms**

# Dynamic Programming 1: Fibonacci, Longest Increasing Subsequence (LIS), Longest Common Subsequence (LCS)

## Fibonacci Numbers

### 2. Introduction

<center>
<img src="./assets/01-DP1-001.png" width="650">
</center>

Given an integer $n$, we wil look at an algorithm for generating the corresponding $n$<sup>th</sup> Fibonacci number. This is a very simple algorithm, but it will illustrate the idea of dynamic programming; later we will examine dynamic programming more generally (i.e., techniques for designing a dynamic programming algorithm, as well as more sophisticated examples).

Recall that the Fibonacci numbers are the following sequence:

$$0, 1, 1, 2, 3, 5, 8, 13, 21, 34, \dots$$

There is a simple recursive formula that defines the Fibonacci numbers as follows:

$$
\boxed{
\begin{array}{l}
{F_{0} = 0,\ F_{1} = 1}\\
{\rm{for}\ n > 1:}\\
\ \ \ \ {F_{n} = F_{n-1} + F_{n-2}}
\end{array}
}
$$

Furthermore:
  * ***Input***: integer $n \ge 0$
  * ***Output***: $n$<sup>th</sup> Fibonacci number

We want an ***efficient*** algorithm to achieve this goal/output. Therefore, we are aiming for a ***running time*** which is ***polynomial*** in $n$ .

Since the Fibonacci numbers are defined by this simple recursive formula, we might therefore think that a recursive algorithm is a natural algorithm for this particular problem. We will look at this recursive algorithm next, as well as analyze it accordingly.

### 3. Recursive Algorithm

#### Algorithm

Let us now examine the natural recursive algorithm for computing the $n$<sup>th</sup> Fibonacci number.

<center>
<img src="./assets/01-DP1-002.png" width="650">
</center>

Recall (cf. Section 2) that the recursive formula for the $n$<sup>th</sup> Fibonacci number is the sum of the previous two Fibonacci numbers, i.e.,:

$$
{\rm{for\ }}n > 1:\ F_n = F_{n-1} + F_{n-2}
$$

The recursive algorithm ($\rm{Fib1}(n)$ ) can be specified in more detail as follows:

$$
\boxed{
\begin{array}{l}
{{\rm{Fib1}}(n):}\\
\ \ \ \ {{\rm{input:\ integer\ }} n \ge 0}\\
\ \ \ \ {{\rm{output:\ }}{F_{n}}}\\
\ \ \ \ {{\rm{if\ }}n = 0,\ {\rm{return\ }} (0)}\\
\ \ \ \ {{\rm{if\ }}n = 1,\ {\rm{return\ }} (1)}\\
\ \ \ \ {{\rm{return\ }} ({\rm{Fib1}}(n-1) + {\rm{Fib1}}(n-2))}
\end{array}
}
$$

In the ***base cases***, the Fibonacci numbers $0$ and $1$ are simply returned.

In the more general ***recursive cases***, the previous two Fibonacci numbers are computed and returned recursively as a sum.

This completes the definition of the recursive algorithm.

#### Analysis

Let us now consider the ***running time*** of this recursive algorithm.

<center>
<img src="./assets/01-DP1-003.png" width="650">
</center>

To analyze this algorithm, let us create a function $T(n)$ which denotes the number of steps in the algorithm (i.e., $\rm{Fib1}(n)$ ), given an input size of $n$ .

The two base cases each require $O(1)$ time.

The two recursive calls require time $T(n-1) + T(n-2)$ .

Combining these two gives the following general formula:

$$
T(n) \le O(1) + T(n-1) + T(n-2)
$$

This formula may be familiar: It resembles the Fibonacci numbers themselves!
  * ***N.B.*** cf. $F_{n} = F_{n-1} + F_{n-2}$ from previously in this section. Furthermore, the constant term $O(1)$ is dominated by the other two terms as $n$ increases.

Therefore, in general:

$$
T(n) \ge F_{n}
$$

Unfortunately, the Fibonacci numbers grow exponentially in $n$ , i.e.,:

$$
T(n) \ge F_{n} \approx {\phi^{n}  \over {\sqrt 5 }}
$$

where the constant $\phi$ is called the **golden ratio**, defined as:

$$
\phi = {{1 + \sqrt{5}} \over {2}} \approx 1.618
$$

Therefore, since the runtime grows ***exponentially*** in $n$ for this recursive algorithm $\rm{Fib1}(n)$ , it is a *terrible* algorithm with respect to performance. Let us examine *why* the running time is so terrible next (which in turn will inform the design of a more efficient algorithm to rectify this).

### 4. Exponential Running Time

Let us now consider the ***recursive*** nature of this recursive algorithm.

<center>
<img src="./assets/01-DP1-004.png" width="650">
</center>

At the top level of the recursion, the $n$<sup>th</sup> Fibonacci number is computed. From there, recursive sub-calls are made to compute the $n-1$ and $n-2$ Fibonacci numbers. The recursive calls similarly proceed in this manner.

Observe that several of the sub-calls are computed *multiple* times (e.g., $n-4$ ). In fact, these "redundant sub-computations" increase exponentially with $n$ ; indeed, this is the root cause of the inefficiency in this recursive algorithm (i.e., repeated computation of the smaller sub-problems).

<center>
<img src="./assets/01-DP1-005.png" width="650">
</center>

To resolve this inefficiency (i.e., redundant computations), the algorithm will be "flipped on its head": We will compute the *smallest* sub-problems *first*, and then proceed in this manner up to the larger sub-problems (until reaching $n$ ).

To accomplish this, an ***array*** $F$ is defined, where $F_i$ denotes the $i$<sup>th</sup> Fibonacci number. Correspondingly, starting at index $i = 0$ , the first Fibonacci number is recorded as $0$ . Proceeding in this manner yields the following:

| $i$ | $F[i]$ |
|:--:|:--:|
| $0$ | $0$ |
| $1$ | $1$ |
| $2$ | $1$ |
| $3$ | $2$ |
| $\vdots$ | $\vdots$ |
| $n$ | $F[n]$ |

where in general $F[i] = F[i-1] + F[i-2]$ (i.e., until reaching $F[i] = F[n]$ accordingly).

This constitutes the corresponding ***dynamic programming algorithm*** in question, which will be defined more precisely next.

### 5. Dynamic Programming Algorithm

#### Algorithm

Now, let us detail our dynamic programming algorithm for computing the $n$<sup>th</sup> Fibonacci number.

<center>
<img src="./assets/01-DP1-006.png" width="650">
</center>

The second attempt (cf. Section 3 for the first) at computing the $n$<sup>th</spu> Fibonacci number is as follows:

$$
\boxed{
\begin{array}{l}
{{\rm{Fib2}}(n):}\\
\ \ \ \ {F[0]=0}\\
\ \ \ \ {F[1]=1}\\
\ \ \ \ {{\rm{for\ }} i=2 \to n:}\\
\ \ \ \ \ \ \ \ {F[i] = F[i-1] + F[i-2]}\\
\ \ \ \ {{\rm{return\ }} (F[n])}\\
\end{array}
}
$$

Recall (cf. Section 4) that the array $F$ stores the Fibonacci numbers.

At the first two indices (i.e., $0$ and $1$ ), the two **base cases** are stored (i.e., $0$ and $1$ , respectively).

From there, the **subsequent iterations** are handled via corresponding $\rm{for}$ loop, which is the sum of the previous two array elements (which in turn are already stored in the array, and readily available, rather than requiring recomputation at this point).

Finally, the $n$<sup>th</sup> Fibonacci number is simply returned as the value $F[n]$ , the last index in the array.

This completes the definition of the algorithm. Observe that there is ***no*** recursion present in this algorithm.
  * ***N.B.*** A *recursive formula* is used to define $F[i]$ , however, there is *no* corresponding recursive call (i.e., to ${\rm{Fib2}}(i)$ itself) here.

#### Analysis

Let us now analyze the runtime of this algorithm, ${\rm{Fib2}}(i)$ .

<center>
<img src="./assets/01-DP1-007.png" width="650">
</center>

As before (cf. Section 3), the base cases have a runtime of $O(1)$ apiece.

With respect to the subsequent iterations, there is a $\rm{for}$ loop of size $O(n)$ , which in turn iterates on $O(1)$ steps. Correspondingly, the total runtime for the $\rm{for}$ loop is $O(n)$ .

Therefore, the total runtime for this algorithm is $O(n)$ total time. This completes the algorithm, and gives a glimpse of a dynamic programming algorithm.

### 6. Dynamic Programming Recap

<center>
<img src="./assets/01-DP1-008.png" width="650">
</center>

Before moving onto a more sophisticated example, let us recap a few ***key issues***.

One important point must be stressed regarding dynamic programming algorithms: There is ***no*** recursion within the algorithm itself.
  * ***N.B.*** While the recursive nature of a given problem can be used to design the corresponding dynamic programming algorithm, the algorithm itself has *no* such recursion in its own definition.

***N.B.*** There is an alternative approach to dynamic programming called **memoization**, whereby a hash table (or other similar structure) is used to maintain the sub-problems solved at a given point, in order to avoid their recomputation. However, this technique will ***not*** be used in this course. The purpose for its omission is due to the larger goal of learning dynamic programming; to avoid confusion, a "no recursion in our algorithms" policy will be enforced for present purposes. Along these lines, dynamic programming has several advantages over memoization (and other similar techniques): Some may say that the algorithms themselves are "more beautiful" (they are certainly faster, due to less overhead incurred by avoiding recursion altogether), but beyond this, it is much more simple and straightforward to analyze the running time of dynamic programming algorithms.

Dynamic programming is widely used. At first, students often find it challenging; however, with sufficient practice, the dynamic programming algorithms will become increasingly more resembling of each other, at which point, more intuition/insight will be gained into how to devise such algorithms accordingly. Therefore, achieving this point requires practice, practice, practice!

## Longest Increasing Subsequence (LIS)

### 7. Introduction

