# Introduction to the Work-Span Model

# 1. Introduction

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
