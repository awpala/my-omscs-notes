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

Let us now consider a more sophisticated example of dynamic programming. The problem we will consider is the **longest increasing subsequence** (**LIS**) problem.

<center>
<img src="./assets/01-DP1-009.png" width="650">
</center>

In the longest increasing subsequence (LIS) problem, the ***input*** is $n$ numbers, denoted as follows:

$$
a_1, a_2, \dots, a_n
$$

Correspondingly, the ***goal*** is to compute the *length* of the longest increasing subsequence in these $n$ input numbers $a_1, \dots, a_n$ .
  * ***N.B.*** The objective here is only to find the *length* of this subsequence, *not* the (constituent numbers/elements of the) subsequence itself. Upon determining the length, it is relatively trivial to transform this output into the corresponding algorithm to produce the underlying subsequence itself.

Consider an example sequence as follows (where $n = 12$ ):

$$
5, 7, 4, -3, 9, 1, 10, 4, 5, 8, 9, 3
$$

Before defining the subsequence, consider the more common term substring. A **substring** is a string (i.e., consecutive set of elements) which occurs within the larger string. For example, the following are substrings of this sequence (denoted by red annotations in the figure shown above):

$$
-3, 9, 1, 10
$$

$$
4
$$

$$
9, 1, 10, 4, 5, 8, 9, 3
$$

A substring can be specified in this manner via its start and end indices; therefore, there is at most order of $O(n^2)$ such substrings accordingly.

However, the problem at hand is not defined with respect to *substrings*, but rather with respect to *subsequences*. Correspondingly, a **subsequence** is a string which can be obtained by ***deleting*** corresponding elements of the larger string (i.e., the subset of elements is ordered, but given this ordered subset, elements can be ***skipped*** accordingly, rather than being strictly consecutive). The following are representative subsequences of the sequence (denoted by green annotations in the figure shown above):

$$
4, -3, 1, 9
$$

$$
1
$$

$$
5, 7, 3
$$

In this particular problem, we are attempting to find such a subsequence which is ***increasing***, i.e., wherein each element is strictly larger than the previous.
  * In the case of $5, 7, 3$ , this is *not* an increasing subsequence, because $3 < 7$ .
  * However, representative increasing subsequences includes $4, 9, 10$ .
  * Conversely, $4, 4, 8, 9$ is also *not* a permissible subsequence under this definition, because it is not *strictly* increasing (i.e., $4 = 4$ ).

With these definitions in mind, to reiterate, the ***goal*** is to find the ***longest*** such increasing subsequence for the input array. Correspondingly, in this particular example, the longest increasing subsequence (LIS) is:

$$-3, 1, 4, 5, 8, 9$$

having a length of $6$ , with this length being the corresponding output of the algorithm. Now, let us attempt to design a dynamic programming algorithm for this purpose.

### 8-9. Attempt 1

#### 8. Sub-Problem

Now, consider a "recipe" for designing such a dynamic programming algorithm.

<center>
<img src="./assets/01-DP1-010.png" width="650">
</center>

The first step is to define the **sub-problem** in words.
  * Recalling (cf. Section 5) the example of Fibonacci numbers, $F[i]$ is defined as the $i$<sup>th</sup> Fibonacci number.

The second step is to state the **recursive relation**. Here, we want to express the solution to the $i$<sup>th</sup> sub-problem in terms of smaller sub-problems.
  * Recalling (cf. Section 5) the example of Fibonacci numbers, $F[i]$ is expressed in terms of $F[i], \dots, F[i-1]$ , where $i - 1 < i$ . In this particular algorithm, these values are stored in the corresponding array $F$ for subsequent use in computing $F[i]$ accordingly, i.e., $F[i] = F[i-1] + F[i-2]$ can be readily computed in this manner.

<center>
<img src="./assets/01-DP1-011.png" width="650">
</center>

Now, let us consider how to follow this recipe for the longest increasing subsequence (LIS) problem:
  * In the first step, let function $L(i) =$ length of longest increasing subsequence (LIS) on $a_1, a_2, \dots, a_i$ .
    * ***N.B.*** Generally, the first attempt for defining this step will *always* involve using the *identical* problem on a *prefix* of the input (i.e., in this case, the longest increasing subsequence on the first $i$ elements of the input array).
  * In the second step, we express $L(i)$ in terms of $L(1), \dots, L(i-1)$ (i.e., smaller sub-problems $1, \dots, i-1$ relative to $i$ itself). To do this, we will next revisit our earlier example to gain some intuition.

#### 9. Recurrence

Recall (cf. Section 8) that our sub-problem definition is: Let function $L(i) =$ length of longest increasing subsequence (LIS) on input array $a_1, a_2, \dots, a_i$ . The goal is then to express $L(i)$ in terms of $L(i)$ in terms of $L(1), \dots, L(i-1)$ (the solutions of smaller sub-problems).

<center>
<img src="./assets/01-DP1-012.png" width="650">
</center>

Recall (cf. Section 7) the earlier example input array as follows (with $n = 12$ ):

$$
5, 7, 4, -3, 9, 1, 10, 4, 5, 8, 9, 3
$$

Initially, with respect to the one-element sub-array $5$ (i.e., the first element), the longest increasing subsequence (LIS) has corresponding length $1$ accordingly. Similarly, the two-element sub-array $5, 7$ has a longest increasing subsequence (LIS) of length $2$ .

Proceeding in this manner yields the following:

| $i$ | $a_i$ | $L(i)$ | LIS |
|:--:|:--:|:--:|:--:|
| $0$ | $5$ | $1$ | $5$ |
| $1$ | $7$ | $2$ | $5, 7$ |
| $2$ | $4$ | $2$ | $5, 7$ |
| $3$ | $-3$ | $2$ | $5, 7$ |
| $4$ | $9$ | $3$ | $5, 7, 9$ |
| $5$ | $1$ | $3$ | $5, 7, 9$ |
| $6$ | $10$ | $4$ | $5, 7, 9, 10$ |
| $7$ | $4$ | $4$ | $5, 7, 9, 10$ |
| $8$ | $5$ | $4$ | $5, 7, 9, 10$ |
| $9$ | $8$ | $4$ | $5, 7, 9, 10$ |

Let us pay special attention to the case of $i = 9$ . While we can append $8$ to gives subsequence $5, 7, 9, 10$ (as shown provisionally in the table above), there is in fact *another* possible solution: $-3, 1, 4, 5, 8$ .

The problem, then, is as follows: How can we compute $L(9)$ using $L(1), \dots, L(8)$ ? In particular, how do we know whether or not we can append $8$ to the current solution at that point, if we do not otherwise maintain the current solution explicitly (but even if we were, how would we know to append $8$ at the end of it)?
  * In particular, for the solution $5, 7, 9, 10$ , it is *not* appropriate to append $8$ , however, for the solution $-3, 1, 4, 5$ it *is* appropriate to append $8$ .

So, then, suppose we did keep track of the current solution; in that case, what do we need to know? What we need to know is the *ending* element of the current solution (e.g., $10$ or $5$ in this case). Correspondingly, the ***key fact*** here is knowing the longest increasing subsequence with the *minimum* such element (e.g., $5$ in this case). Given the minimum such element, this yields the *most* corresponding opportunities to append an additional element onto the end of the subsequence.

Therefore, in this case, in order to compute $L(9)$ using $L(1), \dots, L(8)$ , we need to keep track of the longest increasing subsequence solution with the minimum ending element (e.g., $5$ , which consequently allows to append $8$ to the end of the subsequence, thereby increasing the corresponding solution length from $4$ to $5$ accordingly).

<center>
<img src="./assets/01-DP1-013.png" width="650">
</center>

Let us return to $i = 8$ and see the subsequent complication in ths solution. At this point, our previous solution was $5, 7, 9, 10$ . However, with our *new* formulation, we want to maintain $-3, 1, 4, 5$ , since it is also of length $4$ while additionally ending in a smaller element (i.e., $5 < 10$ ).

<center>
<img src="./assets/01-DP1-014.png" width="650">
</center>

Similarly, let us now return to $i = 7$ . At this point, the longest increasing subsequence is $5, 7, 9, 10$ . However, note that at this point, we need to have sequence $-3, 1, 4$ , which at this point is sub-optimal, but nevertheless we need to maintain it in order to later obtain the solution $-3, 1, 4, 5$ of length $4$ .

So, then, how do we maintain such a "sub-optimal" solution? The ***key*** is that for every possible ending element (e.g., $10$ in subsequence $5, 7, 9, 10$ , and $4$ in subsequence $-3, 1, 4$ ), we want to maintain the longest increasing solution with that ending character.

<center>
<img src="./assets/01-DP1-015.png" width="650">
</center>

Therefore, we need to know the length fo the longest increasing subsequence for every possible ending element. If we know every possible ending element, then upon examining a new element (e.g., $5$ ) we can correspondingly match this against the previous ending elements to determine the appropriate current solution accordingly.

This begs the question: How many possible ending elements exist at any given solution point, and what are they? Necessarily, one of the ending elements must be an earlier element in the input array, therefore the potential candidates are finite (i.e., at most $i - 1$ such possible candidates).

This, then, gives an idea of how to modify our sub-problem formulation accordingly: We want to know the length of the longest increasing subsequence (LIS) for every possible ending element, subject to the constraint that this will exist within the previous $i - 1$ elements. Therefore, we want to maintain the longest increasing subsequence (LIS) for every element of the array.

To accomplish this, we will modify the definition of the sub-problem accordingly as follows: Let function $L(i) =$ length of longest increasing subsequence (LIS) on input array $a_1, a_2, \dots, a_i$ ***and*** includes $a_i$ .
  * This in turn will give the longest increasing subsequence (LIS) which ends at the $i$<sup>th</sup> element of the array (i.e., $a_i$ ), e.g., ending at $5$ for $i = 8$ . By maintaining this from $i = 0$ through $i - 1$ , this can be used consequently to determine the longest increasing subsequence (LIS) at $i$ itself.

We will next formulate this restated sub-problem more precisely, and then subsequently examine the corresponding recurrence.

### 10-11. Attempt 2

#### 10. Sub-Problem


#### 11. Recurrence