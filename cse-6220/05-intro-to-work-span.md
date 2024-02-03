# Introduction to the Work-Span Model

## 1. Introduction

<center>
<img src="./assets/05-001.png" width="350">
</center>

To design algorithms, we need an ***abstract model*** of a parallel computation, and a way to notate this algorithm. This lesson describes one such model, which is sometimes called the **dynamic multi-threading model**.

The dynamic multi-threading model is comprised of two ***parts***:
  * 1 - In the first part, the computation can be represented by a **directed acyclc graph (DAG)** (as in the figure shown above), wherein each **node** is some piece of computational work or task, and each **edge** is a dependency which indicates that a given task cannot proceed until all of its predecessors have completed (as in the figure shown above)
    * From the perspective of "exploiting parallelism," an adequate DAG is one characterized by relatively few dependencies as compared to the number of tasks.
  * 2 - After learning how to analyze abstract DAGs more precisely, discussion will proceed onto the second part of the model, which comprises a ***pseudocode notation*** (a programming model for notating the algorithm).
    * This notation will be defined such that when executing one of these algorithms, it consequently generates a computational DAG (at least conceptually).

Prior to proceeding, note the following ***caveat***: You may have done multi-threaded programming already previously (e.g., PThreads, Java threads, etc.), wherein the program explicitly creates "virtual threads" and then subsequently assigns units of work to them accordingly. For the purposes of this lesson, such a programming model must be deliberately ***ignored***.

The pseudocode notation discussed in this lesson separates how to produce work from how to schedule and execute it, rather than combining/abstracting these concepts. Correspondingly, the focus of present discussion is on creating an algorithm that has an appropriately well-defined DAG; separately from this, there will be a physical multi-core machine and run-time system that (given the DAG in question) determines how to map the DAG to the cores and correspondingly execute it.
  * ***N.B.*** There will be some ***limits*** to the kind of DAG that can be produced in this model as described, however, hopefully it will become apparent that it is still a really natural, elegant, and powerful way to express parallel algorithms for a broad class of interesting models.

## 2. The Multi-Threaded Directed Acyclic Graph (DAG) Model

<center>
<img src="./assets/05-002.png" width="450">
</center>

In the **multi-threaded directed acyclic graph (DAG) model**, a parallel computation is represented by a **directed acyclic graph (DAG)** (as in the figure shown above).
  * Each **vertex** (or **node**) represents an operation (e.g., an addition, a function call, a branch, etc.).
  * The **directed edges** indicate how operations depend on one another, whereby the downstream **sinks** depend on the corresponding upstream **sources** (e.g., vertex $c$ depends on the output/result of vertex $b$ in the figure shown above).

<center>
<img src="./assets/05-003.png" width="450">
</center>

### The Scheduling Problem

For the sake of simplicity, it will always be ***assumed*** that there is exactly ***one*** **starting vertex** (e.g., vertex $s$ in the figure shown above) and ***one*** **exit vertex** (e.g., vertex $x$ in the figure shown above).

<center>
<img src="./assets/05-004.png" width="650">
</center>

If given a DAG with no such start and exit vertices denoted, these can be determined relatively simply (as in the figure shown above).

Suppose that a **parallel random access memory (PRAM)** machine is available, intended for running the computation in question (i.e., as represented by the corresponding DAG). Proceed by searching for any operations that are ready for execution (i.e., all of their input dependencies are satisfied).

In this example (as in the figure shown above), consider the starting vertex $s$ . Since vertex $s$ can commence execution, it is assigned accordingly to any available processor (e.g., processor $3$ ), and proceeds to execute accordingly

<center>
<img src="./assets/05-005.png" width="650">
</center>

As soon as processor $3$ concludes execution (as in the figure shown above), it consequently enables any of its successors to execute. Here, since vertices $a$ and $b$ each only depend on $s$ , since vertex $s$ has concluded execution, both vertices can commence execution, and are therefore assigned to free processors accordingly (i.e., processors $1$ and $3$ , respectively)

<center>
<img src="./assets/05-006.png" width="650">
</center>

When processors $1$ and $3$ conclude their respective units of work, this in turn enables their respective successors to proceed accordingly. This sequence proceeds in this manner in turn (as in the figure shown above).

<center>
<img src="./assets/05-007.png" width="650">
</center>

Eventually, the execution reaches the exit vertex (i.e., vertex $x$ ) (as in the figure shown above).

At every step of this computation, wherein the problem arises of how to take free units of work and to assign them to processors is called a **scheduling problem**.
  * ***N.B.*** Scheduling is a vast topic, which will be covered more thoroughly subsequently in the course.

### Cost Model for the Multi-Threaded Directed Acyclic Graph (DAG) Model

<center>
<img src="./assets/05-008.png" width="650">
</center>

Given a directed acyclic graph (DAG) and a parallel random access memory (PRAM) machine, how long will it take to run the DAG on the PRAM machine? In order to answer this question, a corresponding **cost model** is required.

For present purposes, the **cost model** in question will be that which is subject to the following three ***assumptions***:
  * 1 - All processors of the PRAM run at the ***same*** speed
  * 2 - Each operation requires ***one*** unit of time
  * 3 - The constituent directed edges of the DAG do ***not*** have associated costs

Starting with these assumptions, discussion will now proceed onto applying this cost model to representative DAGs.

## 3. Example: Sequential Reduction

<center>
<img src="./assets/05-009.png" width="350">
</center>

Consider the following example program, which given an array $A$ , it computes the sum of all of its elements, returned as value $s$ :

$$
\boxed{
\begin{array}{l}
{\rm{let\ }}A \equiv {\rm{array\ of\ length\ }}n\\
{s \leftarrow 0}\\
{\rm{for\ }}i \leftarrow 1{\rm{\ to\ }}n{\rm{\ do}}\\
\ \ \ \ {s \leftarrow s + A[i]}
\end{array}
}
$$

This operation is an example of a pattern called a **reduction**.

Now, suppose that only the costs for the addition operation $+$ and for the array-access operation $A[i]$ are of concern (i.e., ***assume*** that the cost of all other operations is negligible). Subsequent discussion will examine how the DAG for this computation unfolds, subject to this assumption.

### Constructing the Directed Acyclic Graph (DAG)

<center>
<img src="./assets/05-010.png" width="550">
</center>

In the first iteration (as in the figure shown above), the addition node $+$ has a dependency (as denoted by corresponding dependence edge, denoted by solid brown arrow in the figure shown above) on the upstream load operation $A[1]$ , since the addition cannot proceed until the load operation is complete.

<center>
<img src="./assets/05-011.png" width="550">
</center>

In the second iteration (as in the figure shown above), the aforementioned process is repeated with respect to load operation $A[2]$ and corresponding addition operation $+$ . Furthermore, observe that there are ***three*** dependence edges, as follows:
  * A dependence edge from the downstream operation $+$ of node $A[2]$ itself (denoted by solid brown arrow in the figure shown above)
  * A dependence edge from the downstream operation $+$ of node $A[1]$ to the downstream operation $+$ of node $A[2]$ (denoted by solid brown arrow in the figure shown above)
  * A dependence edge from the downstream operation $+$ of node $A[1]$ (denoted by red dashed arrow in the figure shown above)
    * ***N.B.*** The code is being executed ***sequentially***, thereby introducing a corresponding **control dependency** between executions of the body of the $\rm{for}$ loop (i.e., $A[2]$ cannot execute until $A[1]$ has completed). However, for present purposes, these control dependencies will be ***ignored***.

<center>
<img src="./assets/05-012.png" width="650">
</center>

The iterations proceed in this manner through iteration $n$ (as in the figure shown above), ignoring control dependencies accordingly, yielding the corresponding final form of the DAG in question.

### Determining the Cost of the Directed Acyclic Graph (DAG)

Now, suppose that a parallel random access memory (PRAM) machine is given with corresponding $P$ processors. How long will it take the PRAM machine to execute this DAG (as denoted by $T_{P}(n)$ )?

<center>
<img src="./assets/05-013.png" width="650">
</center>

Observe that the ***load operations*** (i.e., $A[i]$ ) have no input dependencies (as in the figure shown above). Correspondingly, these can be executed as a group, assigned to corresponding processors among the available $P$ processors. Such batch execution suggests the following cost:

$$
{T_P} \ge \underbrace {\left\lceil {{n \over P}} \right\rceil }_{{\rm{loads}}}
$$

Here, $n$ load operations are divided among the $P$ processors, with each load operation requiring ***one*** unit of time; furthermore, since dealing with finite, discrete counts of processors performing discrete load operations, this implies a ceiling accordingly.

<center>
<img src="./assets/05-014.png" width="650">
</center>

With respect to the ***addition operations*** (i.e., $+$ , as in the figure shown above), observe that there are dependencies among them. Correspondingly, a given addition operation $+$ in iteration $i$ cannot proceed until the previous addition operation (i.e., that of stage $i-1$ ) has concluded, irrespectively of the number of available processors; therefore, this implies the following cost:

$$
{T_P} \ge \underbrace n_{{\rm{additions}}}
$$

<center>
<img src="./assets/05-015.png" width="650">
</center>

Further simplification for expressing the cost is possible. Since $P$ is at least $1$ (i.e., the machine is comprised of at least one processor), then this strictly implies that $\left\lceil {{n \over P}} \right\rceil  \le n$ , and therefore the overall cost becomes:

$$
{T_P} \ge n
$$

In conclusion, a single reduction requires $n$ total operations, even when executed on a PRAM.

## 4. A Reduction Tree Quiz and Answers

<center>
<img src="./assets/05-016Q.png" width="650">
</center>

Suppose that the directed acyclic graph (DAG) for the reduction (cf. Section 3) were instead organized as a tree (as in the figure shown above).

Furthermore, let us make the technical ***assumption*** of **associativity**, whereby the following property holds with respect to the addition operations:

$$
a + (b + c) = (a + b) + c
$$

As this property implies, parenthesization is effectively "arbitrary" (with respect to affecting the resulting computation).

To build this tree representation for the DAG in question, first consider the (level $0$ , at the "top" level in the figure shown above) load operations $A[1]$ , $A[2]$ , ..., $A[n-1]$ , $A[n]$ as before (cf. Section 3). Next, add pairs of inputs (thereby forming the next level of the tree). Such intermediate results are subsequently paired in a similar manner, until the final intermediate-results pair is added to give the overall result (at the "height" level of the tree, at the "bottom" level in the figure shown above).

Given a parallel random access memory (PRAM) machine with $P = n$ processors, what is the minimum time required to execute this DAG on the PRAM machine? (Select the appropriate choice.)
  * $O(1)$
  * $O(\log n)$
  * $O(n)$
  * $O(n \log n)$
  * $O(n^2)$

### ***Answer and Explanation***:

<center>
<img src="./assets/05-017A.png" width="650">
</center>

The minimum required execution time is as follows:

$$
O(\log n)
$$

<center>
<img src="./assets/05-018A.png" width="650">
</center>

First, consider the load operations (as in the figure shown above). There are no input dependencies, and there are $n$ such load operations, therefore the required execution time is as follows:

$$
{T_P} \ge \left\lceil {{n \over P}} \right\rceil \underbrace  = _{{\rm{given\ }}n = P}1
$$

<center>
<img src="./assets/05-019A.png" width="650">
</center>

With respect to the addition operations (as in the figure shown above), at the first level, there are $N\over{2}$ nodes and $N$ available processors (i.e., a sufficient quantity of processors to execute all addition operations simultaneously), therefore the corresponding execution time is as follows:

$$
{T_P} = O(1)
$$

<center>
<img src="./assets/05-020A.png" width="650">
</center>

Furthermore, generalizing in this manner for the subsequent downstream addition operations (as in the figure shown above), this similarly implies a per-level execution time as follows:

$$
{T_P} = O(1)
$$

Essentially, the DAG is executed on a level-by-level basis, with each level requiring constant time of execution. Therefore, the total execution time across all such levels is given by the height of the (binary) tree, i.e.,:

$$
{T_P} = O(\log n)
$$

## 5. Work and Span

<center>
<img src="./assets/05-021.png" width="650">
</center>

Given the directed acyclic graphs (DAGs) as in the figure shown above (both of which compute reductions), which one is better?

The sequential/linear DAG has a sequential chain of dependencies, and therefore it is fundamentally incapable of using more than one processor at a time, aside from the load operations.

Conversely, the tree-based DAG can utilize parallelism at every level of computation.

Correspondingly the respective execution times are as follows:

| DAG for performing reduction | Execution time |
|:--:|:--:|
| Sequential/linear | $O(n)$ |
| Tree-based | $O(\log n)$ |

Intuitively, given two DAGs both computing the same operations, then generally the DAG performing more parallelism is preferable (all else equal).

However, is this the only principal concern? Are there any other relevant factors of considerations? These questions (and others) are addressed in the remainder of this section via the formalism known as **work-span analysis**.

### Work-Span Analysis

<center>
<img src="./assets/05-023.png" width="450">
</center>

Given a directed acyclic graph (DAG) as in the figure shown above, two ***questions*** are of particular interest:
  * 1 - How many ***vertices*** does the DAG contain in total? → This is called **work**, denoted by $W(n)$ (i.e., the total number of operations generally depends on the size of the input, $n$ )
  * 2 - How long is the ***longest path*** (called the **critical path**) through the DAG? → This is called **span**, denoted by $D(n)$
    * The longest path is denoted in yellow outline in the figure shown above.
    * ***N.B.*** As a historical aside, the length of this critical path (or span) was historically called the **depth** (and hence denoted by symbol $D$ accordingly).

<center>
<img src="./assets/05-024.png" width="650">
</center>

With respect to work $W(n)$ and span $D(n)$ , what can be said about the time ($T_P$ ) to execute the DAG on a parallel random access memory (PRAM) machine with $P$ processors? Observe the following:
  * If all of the operations have a ***unit cost***, then the time to execute this DAG using only ***one*** processor should be exactly the work, i.e., $T_{1}(n) = W(n)$ .
  * Conversely, if given an ***infinite*** number of processors executing corresponding unit-cost operations, then the time to execute this DAG using these infinite processors is still constrained by the critical path, i.e., $T_{\infty} = D(n)$ .

These two observations provide a useful set of heuristics, however, more discussion is necessary to further elucidate this work-span analysis, as discussed subsequently in this lesson.

## 6. Work and Span Quiz and Answers

Before proceeding further with work-span analysis, consider a review (cf. Section 5) of the basic definitions for work and span.

<center>
<img src="./assets/05-025Q.png" width="650">
</center>

Given the directed acyclic graph (DAG) as in the figure shown above, what is the corresponding work $W(n)$ and span $D(n)$ ? (Provide integer/non-symbolic answers.)

### ***Answer and Explanation***:

<center>
<img src="./assets/05-026A.png" width="650">
</center>

The corresponding work and span are (respectively) as follows:

$$
W(n) = 16
$$

$$
D(n) = 7
$$

The work $W(n)$ is simply the total count of vertices. Furthermore, the span $D(n)$ constitutes the longest path from start to finish (as denoted by yellow outline in the figure shown above).
  * ***N.B.*** In this particular DAG, by symmetry, all paths have the same span (i.e., $7$ vertices total); the figure shown above outlines one such representative critical path.

## 7. Work and Span for Reduction Quiz and Answers

Now, consider the application of work and span in a more abstract setting.

<center>
<img src="./assets/05-027Q.png" width="650">
</center>

Recall (cf. Section 5) the two directed acyclic graphs (DAGs) for the reduction example (as in the figure shown above).

What are the respective spans $D(n)$ for each DAG? (Select one choice for each DAG among the following for choices.)
  * $O(1)$
  * $O(\log n)$
  * $O(n)$
  * $O(n \log n)$

### ***Answer and Explanation***:

<center>
<img src="./assets/05-028A.png" width="650">
</center>

For the sequential/linear DAG, the critical path traverses all of the addition operations, and since there are $n$ such addition operations, this suggests the following:

$$
D(n) = O(n)
$$

For the tree-based DAG, all paths include at least one vertex from each level, and since there are $\log n$ levels in the tree, this suggests the following:

$$
D(n) = O(\log n)
$$

## 8. Basic Work-Span Laws

<center>
<img src="./assets/05-029.png" width="650">
</center>

To further develop intuition, consider the directed acyclic graph (DAG) as in the figure shown above, comprised of work $W(n)$ and span $D(n)$ . Their ratio is as follows:

$$
W(n) \over D(n)
$$

This ratio has a special ***interpretation***: It measures the amount of work per critical-path vertex. Accordingly, at every critical path, there is an average amount of work. Therefore, this ratio indicates the **average available parallelism** in the DAG.

<center>
<img src="./assets/05-030.png" width="650">
</center>

Consider a given critical-path vertex (as denoted by goldenrod arrow in the figure shown above). When this critical-path vertex executes, there is corresponding work performed, the average of which is characterized by $\approx {W \over D}$ .

The implications of this is that given a parallel random access memory (PRAM) machine with $P$ processors, presumably $P \approx {W \over D}$ available processors would be ideal in this scenario, thereby ensuring that the processors are fully utilized on average at any given time.

<center>
<img src="./assets/05-031.png" width="650">
</center>

Work and span provide additional insight into this. Firstly, recall (cf. Section 5) that span is the lower bound on execution time, i.e.,:

$$
T_p(n) \ge D(n)
$$

This is called the **span law**.

Additionally, besides a lower bound on the span, there is also a lower bound on the work itself, whereby if there is no distinct critical path (within the scope of the overall work to be performed), then all of the work can be divided evenly among the $P$ processors, i.e.,:

$$
{T_p}(n) \ge \left\lceil {{{W(n)} \over P}} \right\rceil
$$

This is called the **work law**.

<center>
<img src="./assets/05-032.png" width="650">
</center>

Furthermore, since both laws hold in general (and simultaneously), then these can be combined into the **(combined) work-span law** as follows:

$$
{T_p}(n) \ge \max \left\{ {D(n),\left\lceil {{{W(n)} \over P}} \right\rceil } \right\}
$$

To summarize, the averaged available parallelism in the DAG is characterized by $W(n) \over {D(n)}$ , whereas the work-span law describes the lower bound with respect to $P$ available processors running the overall work of the DAG.

## 9. Brent's Theorem, Part 1 (Setup)
