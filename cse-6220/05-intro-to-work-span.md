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
