# Graph Algorithms: Topic Introduction

## Introduction

![](./assets/12-GR1-000-01.png){ width=350px }

This topic discusses **graph algorithms**. The following may be familiar from previously (cf. course prerequisites):
  * **depth-first search** (**DFS**)
  * **breadth-first search** (**BFS**)
  * **Dijkstra's single-source shortest path** algorithm

First, we will begin with a brief review of how DFS is used to find the **connected components** of an *undirected* graph. From there, we will examine **connectivity** in *directed* graphs. We will use DFS to find the **strongly connected components** (**SCCs**) of directed graphs, which are analogous to connected components in undirected graphs.

Next, we will see an application of the strongly connected component (SCC) algorithm in solving the **2-SAT problem**.

Next, we will examine the **minimum spanning tree** (**MST**) problem.
  * ***N.B.*** Previously (cf. course prerequisites), you may have already seen Kruskal's and Prim's algorithms for determining the minimum spanning tree (MST) of a graph. Here, we will additionally examine the ***correctness*** of these algorithms.

Finally, we will examine the **PageRank** algorithm, which examines a web graph and assigns weights to its vertices (i.e., webpages), indicating a measure of their importance. This algorithm was devised by Brin and Page, and underlies the Google search engine. Prior to this, there will also be a brief primer on **Markov chains**, which have a corresponding relationship to strongly connected components.

## Overview

> [!NOTE]
> ***Instructor's Note***: See [DPV] Chapter 3 (Decompositions of graphs) and Eric's [notes](https://cs6505.wordpress.com/schedule/scc/).

![](./assets/12-GR1-000-02.png){ width=650px }

In this topic, we will examine ***connectivity*** algorithms using algorithms based on **depth-first search** (**DFS**).

We will begin by reviewing depth-first search (DFS) for **undirected graphs**, and examine the algorithm for determining **connected components** in such undirected graphs.
  * ***N.B.*** This algorithm is likely familiar already (cf. course prerequisites).

Next, we will examine depth-first search (DFS) for **directed graphs**. The goal here is to determine the analog of connected components for such directed graphs.
  * We will begin by examining **directed acyclic graphs** (**DAGS**), which are characterized by ***no*** cycles (i.e., "acyclic")
    * We will also examine how to **topologically sort** such directed acyclic graphs (DAGs), i.e., with vertices being ordered, the edges will follow the corresponding order as well (i.e., left-to-right, or equivalent).
      * ***N.B.*** This algorithm may be familiar already (cf. course prerequisites), however, it will be useful for deriving some additional intuition for more sophisticated algorithms on directed graphs more generally.
  * Next, for general directed graphs, we will examine how to find the **strongly connected components** (**SCCs**), the analog to connected components in undirected graphs.
    * As it turns out, the algorithm for identifying these strongly connected components (SCCs) is simply comprised of two depth-first searches (DFSs), which will become more apparent/straightforward with the intuition gained by this point.

# Graph Algorithms 1: Strongly Connected Components

## 3-4. Undirected Graphs

### 3. Introduction

For a given **undirected graph** $G$ , how do we find its constituent **connected components**?

![](./assets/12-GR1-001.png){ width=650px }

To find the connected components, we simply run the **depth-first search** (**DFS**) algorithm on undirected graph $G$ and keep track of the resulting number of components (with each vertex being designated by number in this manner accordingly).

Recall (cf. course prerequisites) the pseudocode for algorithm $\text{DFS}$ as follows:

$$
\boxed{
\begin{array}{l}
{{\text{DFS}}(G):}\\
\ \ \ \ {{\text{input:\ }} G(V,E) {\text{\ in\ adjacency\ list\ representation}}}\\
\ \ \ \ {{\text{output:\ }} {\text{vertices\ labeled\ by\ connected\ components}}}\\
\\
\ \ \ \ {{\text{cc}} = 0}\\
\ \ \ \ {{\text{for\ all\ }} v \in V {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{visited}}(v) = {\text{FALSE}}}\\
\ \ \ \ {{\text{for\ all\ }} v \in V {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{if\ not\ }} {\text{visited}(v) {\text{,\ then:}}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{cc++}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{Explore}}(v)}
\end{array}
}
$$

***N.B.*** We will make further modifications to this algorithm over the course of this lecture.

For now, we take ***input*** graph $G$ as an *undirected* graph, given in adjacency list representation. (Later, we will run the same algorithm on a *directed* graph.)

The ***output*** is the vertices of undirected graph $G$ , now labeled by a connected component number.

The counter ${\text{cc}}$ tracks the current connected component number. Furthermore, the array ${\text{visited}}$ tracks whether or not a given vertex $v$ has been visited yet.

The array ${\text{visited}}$ is initialized to all vertices' entries being set to ${\text{FALSE}}$.

Next, the vertices are iteratively traversed in arbitrary order. If a not-yet-visited vertex is encountered, then we have identified a *new* connected component. Correspondingly, ${\text{cc}}$ is incremented and we further explore from this vertex, as discussed in the next section.

### 4. Exploring Undirected Graphs

#### Pseudocode

![](./assets/12-GR1-002.png){ width=650px }

The pseudocode for the previously encountered (cf. Section 3) subroutine ${\text{Explore}}$ is given as follows:

$$
\boxed{
\begin{array}{l}
{{\text{Explore}}(z):}\\
\ \ \ \ {{\text{ccnum}}(z) = {\text{cc}}}\\
\ \ \ \ {{\text{visited}}(z) = {\text{TRUE}}}\\
\ \ \ \ {{\text{for\ all\ }} (z, w) \in E {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{if\ not\ }} {\text{visited}(w) {\text{,\ then:}}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{Explore}}(w)}
\end{array}
}
$$

Given ***input*** vertex $z$ , on initial encounter, its connected component number ${\text{cc}}$ is stored as ${\text{ccnum}}$ , the current count for the connected components.

Next, we set ${{\text{visited}}(z) = {\text{TRUE}}}$ (i.e., vertex $z$ has now been visited.)

Finally, we explore all edges $E$ from vertex $z$ , where the vertex information is readily available via the (linked-list) adjacency list representation of input graph $G$ to upstream caller ${\text{DFS}}$ (cf. Section 3). For a particular neighbor $w$ , if the neighbor has not yet been visited up to this point, then we recursively explore from $w$ accordingly (i.e., ${\text{Explore}}(w)$ ).

We repeat this process until all vertices in the graph have been visited/explored in this manner.

#### Running Time

What, then, is the overall running time for algorithm ${\text{DFS}}$ ?

You might recall (cf. course prerequisites) that algorithm ${\text{DFS}}$ has an overall linear running time when run on an undirected graph. More specifically, the overall running time is characterized as follows:

$$
O(n + m)
$$

where $n = |V|$ and $m = |E|$ .

This algorithm provides the ability to identify the connected components of the input undirected graph $G$ . Next, we will examine *directed* graphs, which will require obtaining additional information via depth-first search in order to obtain the appropriate connectivity information accordingly.

## 5-7. Depth First Search (DFS)

### 5. Paths

Recall (cf. Section 4) that the depth-first search (DFS) algorithm can be used to identify connected components in an *undirected* graph. Before proceeding onto a similar analysis of *directed* graphs, let us first glean some additional information from the depth-first search (DFS) algorithm.

![](./assets/12-GR1-003.png){ width=650px }

In particular, suppose we are given a pair of vertices $(v, w)$ which reside in the *same* connected component. How to find a **path** between these **connected vertices**? To accomplish this, we must track the **predecessor vertex** when initially visiting a given vertex.

Recall (cf. Section 4) the depth-first search (DFS) algorithm for finding connected components on an undirected graph. Similarly to Dijkstra's algorithm (discussed later), we now additionally use the array ${\text{prev}}$ to track the predecessor vertex. The corresponding modification to the pseudocode is as follows:

$$
\boxed{
\begin{array}{l}
{{\text{DFS}}(G):}\\
\ \ \ \ {{\text{input:\ }} G(V,E) {\text{\ in\ adjacency\ list\ representation}}}\\
\ \ \ \ {{\text{output:\ }} {\text{vertices\ labeled\ by\ connected\ components}}}\\
\\
\ \ \ \ {{\text{cc}} = 0}\\
\ \ \ \ {{\text{for\ all\ }} v \in V {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{visited}}(v) = {\text{FALSE}}}\\
\ \ \ \ \ \ \ \ {{\text{prev}}(v) = {\text{NULL}}}\\
\ \ \ \ {{\text{for\ all\ }} v \in V {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{if\ not\ }} {\text{visited}(v) {\text{,\ then:}}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{cc++}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{Explore}}(v)}
\end{array}
}
$$

$$
\boxed{
\begin{array}{l}
{{\text{Explore}}(z):}\\
\ \ \ \ {{\text{ccnum}}(z) = {\text{cc}}}\\
\ \ \ \ {{\text{visited}}(z) = {\text{TRUE}}}\\
\ \ \ \ {{\text{for\ all\ }} (z, w) \in E {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{if\ not\ }} {\text{visited}(w) {\text{,\ then:}}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{Explore}}(w)}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{prev}}(w) = z}
\end{array}
}
$$

With this modification, in algorithm ${\text{DFS}}$ , the predecessors array is initialized as ${\text{prev}}(v) = {\text{NULL}}$ with respect to each vertex, i.e., an empty array.

Furthermore, on recursive call of subroutine ${\text{Explore}}$ , we additionally set ${\text{prev}}(w) = z$ , indicating that a predecessor vertex now exists with respect to candidate vertex $w$ .

Upon running this algorithm, we can now use the predecessors array ${\text{prev}}(v)$ to **backtrack**, in order to identify a corresponding **path** between a pair of connected vertices.

This concludes the discussion of the depth-first search (DFS) algorithm on *undirected* graphs. Next, we discuss depth-first search (DFS) on *directed* graphs.

### 6-7. Depth-First Search (DFS) on Directed Graphs

#### 6. Introduction

Having seen (cf. Section 4) how to determine connected components in an *undirected* graph, now consider how to determine connected components in a ***directed*** graph.

![](./assets/12-GR1-004.png){ width=650px }

![](./assets/12-GR1-005.png){ width=650px }

To accomplish this, in a directed graph $G$ , we similarly use depth-first search (DFS), however, we now consider some additional information: The **preorder** or **postorder** numbers for the **tree** (or **forest**) of the explored edges. The corresponding modification of the previous (cf. Section 4) pseudocode is as follows:

$$
\boxed{
\begin{array}{l}
{{\text{DFS}}(G):}\\
\ \ \ \ {{\text{input:\ }} G(V,E) {\text{\ in\ adjacency\ list\ representation}}}\\
\ \ \ \ {{\text{output:\ }} {\text{vertices\ labeled\ by\ connected\ components}}}\\
\\
\ \ \ \ {{\text{clock}} = 1}\\
\ \ \ \ {{\text{for\ all\ }} v \in V {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{visited}}(v) = {\text{FALSE}}}\\
\ \ \ \ {{\text{for\ all\ }} v \in V {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{if\ not\ }} {\text{visited}(v) {\text{,\ then:}}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{Explore}}(v)}
\end{array}
}
$$

$$
\boxed{
\begin{array}{l}
{{\text{Explore}}(z):}\\
\ \ \ \ {{\text{pre}}(z) = {\text{clock}}}\\
\ \ \ \ {{\text{clock++}}}\\
\ \ \ \ {{\text{visited}}(z) = {\text{TRUE}}}\\
\ \ \ \ {{\text{for\ all\ }} (z, w) \in E {\text{:}}}\\
\ \ \ \ \ \ \ \ {{\text{if\ not\ }} {\text{visited}(w) {\text{,\ then:}}}}\\
\ \ \ \ \ \ \ \ \ \ \ \ {{\text{Explore}}(w)}\\
\ \ \ \ {{\text{post}}(z) = {\text{clock}}}\\
\ \ \ \ {{\text{clock++}}}
\end{array}
}
$$

Here, we no longer require tracking of the connected component number (via corresponding variables ${\text{cc}}$ and ${\text{ccnum}}$ ). Instead, we now track the preorder and postorder numbers, via arrays ${\text{pre}}$ and ${\text{post}}$ (respectively).

Furthermore, to accomplish the corresponding tracking, we add variable ${\text{clock}}$ , which in subroutine ${\text{Explore}}$ is initialized to the value immediately prior to the first visit/traversal of vertex $z$ , and then subsequently incremented immediately following exploration of vertex $z$ (i.e., via the corresponding edges $(z, w) \in E$ ). Correspondingly, these values are stored in arrays ${\text{pre}}$ and ${\text{post}}$ (respectively), along with accompanying increments of variable ${\text{clock}}$ upon this storage to record it accordingly (i.e., ${\text{clock++}}$ ).

For determining the connectivity of the vertices, we can then examine the array ${\text{post}}$ .
  * ***N.B.*** The preorder array ${\text{pre}}$ is tracked in this canonical formulation of the algorithm, however, as a practical matter, it does not provide any useful information with respect to determining the connected vertices themselves.

#### 7. Example

![](./assets/12-GR1-006.png){ width=650px }

Consider a specific directed graph comprised of eight vertices, as in the figure shown above. Now, let us run the depth-first search (DFS) algorithm (cf. Section 6) on this graph, starting at vertex $B$ . Furthermore, for concreteness, we assume that the linked-list representation of vertices is stored in alphabetical order with respect to a given vertex's neighboring vertices (e.g., the neighbors of vertex $B$ are represented as list $[A, C, E]$ ).

Starting with vertex $B$ , we initially traverse/explore the directed graph $G$ as follows:

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |

Now, since $G$ does not have any remaining vertices to explore, we finish exploring $G$ , assign ${\text{post}}(G) = 6$ , and return to vertex $E$ . Furthermore, observe that exploration from $E$ proceeds back to $A$ , which has already been explored/visited by this point.
  * ***N.B.*** We do not subsequently "re-explore" from vertex $A$ as a result of this (i.e., this does not yield a corresponding "newly included edge" in the resulting depth-first search tree), however, visually we have still denoted this "check" with teal arrow in the figure shown above for additional reference (i.e., as distinguished from the "included edges" denoted in black in the built-out search tree).

The resulting updates are therefore as follows:

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |
| $6$ | $G$ | $5$ | $6$ |
| $7$ | $E$ | $5$ | $7$ |

Proceeding similarly, we now examine vertex $D$ , yielding the following:

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |
| $6$ | $G$ | $5$ | $6$ |
| $7$ | $E$ | $4$ | $7$ |
| $8$ | $H$ | $8$ | ${\text{NULL}}$ |
| $9$ | $H$ | $8$ | $9$ |
| $10$ | $D$ | $3$ | $10$ |

Here, exploring from vertex $D$ , we ultimately encounter already explored vertex $E$ (noted accordingly via ${\text{post}}(E) = 7$ ), as well as similarly terminating exploration of vertices (immediately unexplored) $H$ and (currently explored) $D$ itself.

We then proceed similarly "back up" through to vertices $A$ and $B$ , yielding the following:

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |
| $6$ | $G$ | $5$ | $6$ |
| $7$ | $E$ | $4$ | $7$ |
| $8$ | $H$ | $8$ | ${\text{NULL}}$ |
| $9$ | $H$ | $8$ | $9$ |
| $10$ | $D$ | $3$ | $10$ |
| $11$ | $A$ | $2$ | $11$ |

From vertex $B$ , we now explore vertex $C$ , i.e.,:

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |
| $6$ | $G$ | $5$ | $6$ |
| $7$ | $E$ | $4$ | $7$ |
| $8$ | $H$ | $8$ | ${\text{NULL}}$ |
| $9$ | $H$ | $8$ | $9$ |
| $10$ | $D$ | $3$ | $10$ |
| $11$ | $A$ | $2$ | $11$ |
| $12$ | $C$ | $12$ | ${\text{NULL}}$ |

This in turn results in exploration of vertex $F$ , i.e.,:

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |
| $6$ | $G$ | $5$ | $6$ |
| $7$ | $E$ | $4$ | $7$ |
| $8$ | $H$ | $8$ | ${\text{NULL}}$ |
| $9$ | $H$ | $8$ | $9$ |
| $10$ | $D$ | $3$ | $10$ |
| $11$ | $A$ | $2$ | $11$ |
| $12$ | $C$ | $12$ | ${\text{NULL}}$ |
| $13$ | $F$ | $13$ | ${\text{NULL}}$ |

Since vertex $F$ is neighboring with (at this point) already explored neighbors $B$ and $H$ , we similarly "back up" as before, yielding the following final overall result (with overall exploration correspondingly terminated at originating vertex $B$ ):

| ${\text{clock}}$ | Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|:--:|
| $1$ | $B$ | $1$ | ${\text{NULL}}$ |
| $2$ | $A$ | $2$ | ${\text{NULL}}$ |
| $3$ | $D$ | $3$ | ${\text{NULL}}$ |
| $4$ | $E$ | $4$ | ${\text{NULL}}$ |
| $5$ | $G$ | $5$ | ${\text{NULL}}$ |
| $6$ | $G$ | $5$ | $6$ |
| $7$ | $E$ | $4$ | $7$ |
| $8$ | $H$ | $8$ | ${\text{NULL}}$ |
| $9$ | $H$ | $8$ | $9$ |
| $10$ | $D$ | $3$ | $10$ |
| $11$ | $A$ | $2$ | $11$ |
| $12$ | $C$ | $12$ | ${\text{NULL}}$ |
| $13$ | $F$ | $13$ | ${\text{NULL}}$ |
| $14$ | $F$ | $13$ | $14$ |
| $15$ | $C$ | $12$ | $15$ |
| $16$ | $B$ | $1$ | $16$ |

with corresponding final state of the resulting search tree as follows:

| Vertex $v$ | ${\text{pre}}(v)$ | ${\text{post}}(v)$ |
|:--:|:--:|:--:|
| $B$ | $1$ | $16$ |
| $A$ | $2$ | $11$ |
| $D$ | $3$ | $10$ |
| $E$ | $4$ | $7$ |
| $G$ | $5$ | $6$ |
| $H$ | $8$ | $9$ |
| $C$ | $12$ | $15$ |
| $F$ | $13$ | $14$ |

## 8-9. Types of Edges

### 8. Introduction

### 9. Cycles

## 10-12. Topological Sorting

### 10. Introduction

### 11. Topological Ordering Quiz and Answers

### 12. Directed Acyclic Graph (DAG) Structure

## 13. Outline Review

## 14. Connectivity in Directed Graphs

## 15-23. Strongly Connected Components (SCC)

### 15. Examples Quiz and Answers

### 16. Graph of Strongly Connected Components (SCC)

### 17-22. Strongly Connected Component (SCC) Algorithm

#### 17. Algorithm Idea

#### 18. Vertex in Sink Strongly Connected Component (SCC)

#### 19. Finding Sink Strongly Connected Component (SCC)

#### 20. Example

> [!NOTE]
> ***Instructor's Note***: Typo: The preorder number of $D$ and the postorder number of $C$ are both $12$ . The preorder number of $D$ should be $13$ and all preorder/postorder numbers from $13$ onwards should be incremented by $1$ . The resulting order on the postorder numbers does not change.

#### 21. Algorithm

##### Pseudocode

##### Running Time Quiz and Answers

### 22-23. Proof of Key Strongly Connected Component (SCC) Fact

#### 22. Introduction

#### 23. Simpler Claim

## 24. Comparison: Depth-First Search (DFS), Breadth-First Search (BFS), and Dijkstra's Algorithm

# Graph Algorithms 2: 2-Satisfiability

## 1-4. Satisfiability (SAT)

### 1. Notation

> [!NOTE]
> ***Instructor's Note***: For Eric's notes see [here](https://cs6505.wordpress.com/schedule/2-sat/).

### 2-3. Satisfiability (SAT) Problem

#### 2. Introduction

#### 3. Quiz and Answers

#### Question 1

#### Question 2

#### Question 3

### 4. $k$-SAT

## 5. Simplifying Input

## 6. Graph of Implications

## 7. Graph Properties

## 8. Strongly Connected Components (SCC)

## 9-10. Algorithm Idea

### 9. Approach 1

### 10. Approach 2

## 11. 2SAT Algorithm

## 12-13. Proof of Key Fact

### 12. Introduction

### 13. Rest of Proof

## 14. Proof of Claim

# Graph Algorithms 3: Minimum Spanning Tree

## 1. Greedy Approach

## 2. Minimum Spanning Tree (MST) Problem

> [!NOTE]
> ***Instructor's Note***: See [DPV] Chapter 5.1 (Minimum Spanning Trees) and Eric's [notes](https://cs6505.wordpress.com/schedule/mst/).

## 3. Tree Properties

## 4. Greedy Approach for Minimum Spanning Tree (MST)

## 5-6. Kruskal's Algorithm

### 5. Pseudocode

### 6. Analysis

### 7. Correctness

## 8. Cuts

## 9-10. Cut Property

### 9. Introduction

### 10. Kruskal's Algorithm

## 11-14. Proof

### 11. Outline

### 12. Constructing $T$

### 13. $T$ Is a Tree

### 14. $T$ Is a Minimum Spanning Tree (MST)

## 15. Prim's Algorithm

# Graph Algorithms 4: Markov Chains and PageRank

## 1. Outline

## 2-13. Markov Chains

### 2. Example

### 3. General

### 4. 2-Step Transitions

### 5. $k$-Step Transitions

### 6. Big $k$ for 6210 Example

### 7. Infinite Time

### 8. Linear Algebra View

### 9. Stationary Distribution

### 10. Bipartite Markov Chain

### 11. Multiple Strongly Connected Components (SCC)

### 12. Ergodic Markov Chain

### 13. What is $\pi$?

## 14-28. PageRank

### 14. Introduction

### 15. Webgraph

### 16-17. First Idea

#### 16. Introduction

#### 17. Problem 1

### 18-19. Second Idea

#### 18. Introduction

#### 19. Problem 2

### 20. Rank Definition

### 21. Random Walk

### 22-23. Stationary Distribution

#### 22. Introduction

#### 23. Problems

### 24-27. Random Surfer

#### 24. Introduction

#### 25. Transition Matrix

#### 26. Sink Nodes

#### 27. Ergodic

### 28. Finding $\pi$
