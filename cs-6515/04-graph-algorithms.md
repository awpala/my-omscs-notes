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
  * We will begin by examining **directed acyclic graphs** (**DAGs**), which are characterized by ***no*** cycles (i.e., "acyclic")
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

![](./assets/12-GR1-007.png){ width=650px }

Consider a specific **edge** from the directed graph in the previous example (cf. Section 7), e.g., $z \to w$ . Furthermore, let us consider whether this is an explored edge in the resulting depth-first search (DFS) tree (where in the figure shown above, black edges denote such explored edges, whereas teal edges denoted other "re-explored neighbors" edges during the course of running the algorithm, as discussed previously in Section 7).

The **tree edges** are those which are included in the corresponding depth-first search (DFS) tree upon completion of the algorithm. Examples of such edges in this graph include $B \to A$ and $A \to D$ .
  * ***N.B.*** In this particular example, the resulting tree edges formed a connected **tree**, whereby each vertex is reachable from the start vertex (i.e., vertex $B$ ). More generally, a non-connected **forest** can also result from running this algorithm, whereby multiple groups of such connected trees result from the algorithm. However, for simplicity, here, we will simply use the semantics of a "tree edge," as opposed to a more general "forest edge."

Consider the properties of the post-order numbering in these tree edges. In general, the following property holds:

$$
{\text{post}}(z) > {\text{post}}(w)
$$

i.e., the post-order numbering of the "head" edge is generally "later" than that of the "tail" edge, when exploring in this depth-first search manner.

Now, let us consider the other "non-tree" edges (as denoted by teal in the figure shown above). Among these, there are three distinct ***types***, characterized as follows:

| Edge Type | Description | Relationship of post-order numbering | Examples |
|:--:|:--:|:--:|:--:|
| **Back** | From descendent vertex $w$ to ancestor vertex $z$ | ${\text{post}}(z) < {\text{post}}(w)$ | $E \to A$ , $F \to B$ |
| **Forward** | From ancestor vertex $z$ to descendent vertex $w$ | ${\text{post}}(z) > {\text{post}}(w)$ | $D \to G$ , $B \to E$ |
| **Cross** | No ancestor/descendent relationship among vertices $z$ and $w$ | ${\text{post}}(z) > {\text{post}}(w)$ | $F \to H$ , $H \to G$ |

In particular, observe that back edges have a ***smaller*** post-numbering of the descendent vertex $w$ relative to its ancestor vertex $z$ (i.e., the "head" vertex is "ahead of" the "tail" vertex). This constitutes a ***key property*** for post-order numbering accordingly (i.e., back edges behave differently from the other types of edges).

Otherwise, forward and cross edges have the same/analogous property as the tree edges themselves.
  * In the case of forward edges, they are similarly "moving down" the tree as tree edges, but simply doing so by more than one vertex (i.e., past the neighboring vertex).
  * In the case of cross edges, generally the edge of the relatively first-explored vertex $w$ will receive the lower/"earlier" post-order numbering (otherwise, there would have been an ancestor/descendent "sub-tree" relationship between the vertices).

### 9. Cycles

Now, let us examine properties of the directed graph $G$ , and how these properties manifest themselves in the resulting depth-first search (DFS) tree.

![](./assets/12-GR1-008.png){ width=650px }

Consider the property of a **cycle**. How does a cycle manifest itself in the resulting depth-first search (DFS) tree of a directed graph? This key property emerges as follows:

> Directed graph $G$ has a **cycle** if and only if its depth-first search (DFS) tree contains a ***back edge***

***N.B.*** This property holds for the graph irrespectively of which starting vertex is used to produce the depth-first search (DFS) tree. Furthermore, the ordering of the vertices in the adjacency-list representation of the graph similarly does not impact the resulting presence (or absence) of a back edge, thereby indicating the presence (or absence, respectively) cycle in the graph.

#### Proof

Let us consider the proof for why this property holds. Since this is an equivalence relation (i.e., $\iff$ ), we examine the two implications in turn.

##### Forward Implication

Consider the forward implication ($\Rightarrow$ ), given as follows:

> The depth-first search (DFS) tree contains a back edge if directed graph $G$ has a cycle

Here, we suppose that directed graph $G$ has a cycle. We now examine how such a back edge will appear. Let us denote this cycle as $a \to b \to c \to \cdots \to j \to a$ , where vertex $j$ "cycles" back to vertex $a$ .

Necessarily, at least one of these vertices is always explored *first*. Let us denote this first-explored vertex as vertex $i$ . What does this indicate about the resulting sub-tree originating from vertex $i$ ? Since all of the vertices are reachable from $i$ in this sub-tree, then these vertices are correspondingly contained in the subtree as constituent vertices $a, \dots, i-1$ and $i + 1, \dots, j$ .

Among these constituent vertices, at least one has a common edge with $i$ . More specifically, in this case, we know that vertex $i-1$ has a common edge with $i$ ; furthermore, this edge is indeed a back edge.

##### Reverse Implication

Now, consider the reverse implication ($\Leftarrow$ ), given as follows:

> Directed graph $G$ has a cycle if its depth-first search (DFS) tree contains a back edge

Here, we suppose that the resulting depth-first search (DFS) tree contains a back edge. Let us denote this back edge as $a \leftarrow b$ .

We know that vertex $a$ is a descendent of corresponding ancestor vertex $b$ . However, we also know that there are corresponding "intermediate neighbors" edges between vertices $a$ and $b$ . Collectively, this indeed constitutes a cycle, i.e., $b \to \cdots a \to b$ , where the latter edge $a \to b$ is the corresponding back edge in question.

Therefore, this proves that the property holds in general via the forward and reverse implications.

## 10-12. Topological Sorting

### 10. Introduction

Now, consider a **directed acyclic graph** (**DAG**), which are characterized by ***no*** cycles (i.e., "acyclic").

![](./assets/12-GR1-009.png){ width=650px }

Recall (cf. Section 9) that the implication of such a directed acyclic graph (DAG) is that there are correspondingly ***no*** back edges present in the resulting depth-first search (DFS) tree.

Furthermore, consider how to **topologically sort** such a directed acyclic graph, such that the vertices in the resulting depth-first search (DFS) tree are strictly ordered from lower to higher (with respect to their post-order numbering).

To accomplish this, we first run the depth-first search algorithm (cf. Section 6) on the directed acyclic graph (DAG) $G$ in order to produce the corresponding tree. Recall (cf. Section 8) that in such a graph without cycles, without back edges being present, the post-order numbering is strictly increasing (cf. back edges are characterized by a corresponding strictly decreasing ordering in the post-order numbering), i.e.,:

> For all $z \to w$ , ${\text{post}(z)}$ > ${\text{post}(w)}$

Therefore, in order to topologically sort the vertices, we simply start from the highest-post-order-number vertex and then proceed towards the lowest-post-numbered vertex, i.e., in decreasing post-order numbering direction.

In order to actually "sort" the vertices in this manner, note that this is not a simple running time of $O(n \log n)$ , but rather this requires a running time of:

$$
O(n + m)
$$

where $n = |V|$ and $m = |E|$ .

To understand this running time, consider the range of potential post-order numberings. In the algorithm ${\text{DFS}}$ (cf. Section 6), ${\text{clock}}$ is initialized to $1$ , the lowest possible value for the post-order numbering. Furthermore, th largest possible value for the post-order numbering is $2n$ (i.e., a fully connected graph).

Utilizing a corresponding array of length $2n$ to track these post-order numberings, we can assign vertex-wise post-order numberings among these array elements upon iterative exploration of the vertices, and then finally traverse this array from the largest to the lowest element/index, outputting the corresponding vertices as they are encountered in this traversal (i.e., decreasing order of post-order numbering).

Therefore, the overall running time is comprised of $O(m + n)$ to run the depth-first search (DFS) algorithm (cf. Section 6), followed by $O(2n) = O(n)$ to perform this subsequent sorting (i.e., depth-first search is the dominating step in this overall sequence).

### 11. Topological Ordering Quiz and Answers

![](./assets/12-GR1-010Q.png){ width=450px }

Consider the graph in the figure shown above. Provide a topological ordering of its five constituent vertices. Furthermore, how many distinct/valid such topical orderings are present in this graph?

![](./assets/12-GR1-011A.png){ width=450px }

One such valid topological ordering is given by inspection as follows:

$$
X \to Y \to Z \to U \to W
$$

where the corresponding edges are in strictly increasing order with respect to post-order numbering (i.e., depicted/oriented as "left-to-right" in the figure shown above).

With respect to the number of distinct such topological orderings, the position of vertex $U$ can assume any of the last three positions. After this is specified, there is consequently only one possible (strict) ordering of edge $Z \to W$ . Therefore, in total there are $3$ distinct topological orderings in total.

### 12. Directed Acyclic Graph (DAG) Structure

Let us now consider some additional properties of a directed acyclic graph (DAG) which derive from topological ordering (cf. Section 10).

![](./assets/12-GR1-012.png){ width=650px }

In general, there are two distinct ***types*** of vertices of note:
  * **source vertex**, which has *no* ***incoming*** edges (i.e., neighboring edges are strictly directed "away" from the vertex)
  * **sink vertex**, which has *no* ***outgoing*** edges (i.e., neighboring edges are strictly directed "into" the vertex)

A directed acyclic graph (DAG) *always* contains at least one source vertex and one sink vertex (furthermore, in general, it can also contain multiple source vertices and/or multiple sink vertices).

How do we know there is always a source vertex in a given directed acyclic graph (DAG)? Taking the topological ordering, the first vertex is always a source vertex (e.g., vertex $X$ in the figure shown above). Furthermore, this is the vertex with the highest post-order numbering via depth-first search (DFS).
  * ***N.B.*** If there are multiple source vertices in the directed acyclic graph (DAG), then the corresponding multiple distinct topological orderings will correspondingly place these respective source vertices at this first position. However, in either case, this first-position index will be comprised of such a source vertex.

Complementarily to this, taking the topological ordering, the last vertex is similarly always a sink vertex (e.g., vertices $U$ and $W$ in the figure shown above). Furthermore, this is the vertex with the lowest post-order numbering via depth-first search.
  * ***N.B.*** Furthermore, there may be multiple such last vertex sinks, if the directed acyclic graph (DAG) yields multiple distinct topological orderings (i.e., which place these distinct sink vertices in the last position accordingly).

![](./assets/12-GR1-013.png){ width=650px }

Now, consider an ***alternative*** topological sorting algorithm, defined as follows:
  * (1) - Find a sink vertex, output it, and delete it
  * (2) - Repeat (1) until the graph is empty

***N.B.*** This alternative algorithm is not particularly useful for directed acyclic graphs (DAGs), however, it will become much more useful when we later examine more general (i.e., possibly cyclic) directed graphs.

Since we know that in a topological ordering the last vertex is necessarily a sink vertex, we can readily begin at this point, and proceed back towards the starting vertex accordingly. When the starting vertex is reached in this manner, immediately prior to terminating the algorithm, the resulting graph is effectively now a sink vertex in this intermediate graph of current size $1$ ; therefore, now it only remains to eliminate this element to yield an empty graph, thereby terminating the algorithm.

The net result is an output of the vertices in the order from "last" to "first," thereby yielding a valid topological sorting.

However, this begs the question: How to find such a sink vertex a priori in the first place? We will consider this matter more comprehensively in the next section, in the context of the more general notion of "connectivity in directed graphs."

## 13. Outline Review

![](./assets/12-GR1-014.png){ width=650px }

We have now seen how to find connected components in undirected graphs (cf. Section 4), as well as how to topologically sort a directed acyclic graph (DAG) (cf. Section 10). Both of the underlying algorithms involved a *single* run of (correspondingly modified versions of) the depth-first search (DFS) algorithm.

In a more general directed graph (potentially containing cycles), the corresponding analog of connected component is **strongly connected components** (**SCCs**). Next, we will examine strongly connected components (SCCs) of such a general directed graph more thoroughly, which will culminate in a corresponding algorithm to find such strongly connected components (SCCs) using *two* runs of the (appropriately modified) depth-first search (DFS) algorithm.

## 14. Connectivity in Directed Graphs

In the remainder of this topic (i.e., Graph Algorithms 1), we will focus on ***directed*** graphs. However, let us first consider the notion of **connectivity** in directed graphs.

![](./assets/12-GR1-015.png){ width=650px }

Given a pair of vertices $v$ and $w$ in a directed graph, we formally define **strong connectivity** as follows:

> Vertices $v$ and $w$ are **strongly connected** if there is a pair of complementary **paths** $v \rightsquigarrow w$ and $w \rightsquigarrow v$

where in general the paths $\rightsquigarrow$ may be comprised of multiple intermediate vertices, and furthermore these two paths may intersect at some intermediate point(s).

![](./assets/12-GR1-016.png){ width=650px }

In the context of *directed* graphs, we can characterize **strongly connected components** (**SCCs**) comprised of such vertices (cf. *undirected* graphs are comprised of analogous connected components, as discussed previously in Section 5).

Furthermore, in directed graphs, strongly connected components (SCCs) comprise the ***maximal*** set of strongly connected vertices (cf. the connected components *undirected* graphs are comprised of the maximal set of connected vertices), i.e., the vertices are progressively added to the set until the graph has been fully iterated upon.

Next, we will further discuss the notion of strongly connected components (SCCs), with an opening example to motivate this definition and subsequent discussion.

## 15-23. Strongly Connected Components (SCC)

### 15. Examples Quiz and Answers

![](./assets/12-GR1-017Q.png){ width=650px }

Consider the directed graph comprised of 12 vertices, as in the figure shown above. How many total strongly connected components (SCCs) are present in this graph? Furthermore, identify these strongly connected components (SCCs) accordingly.

![](./assets/12-GR1-018A.png){ width=650px }

This graph is comprised of $5$ total strongly connected components (SCCs), as denoted in purple in the figure shown above. Furthermore, the corresponding sets are the following:

$$
\{ A \}
$$

$$
\{ B, E \}
$$

$$
\{ C, F, G \}
$$

$$
\{ D \}
$$

$$
\{ H, I, J, K, L \}
$$

Within a given strongly connected component (SCC), each constituent vertex is mutually path-reachable from every other vertex, however, this "mutual reachability" does *not* generally hold *across* strongly connected components.

Given these $5$ strongly connected components (SCCs), we can further consider a graph comprised of five "meta-vertices," which each such "meta-vertex" representing its corresponding strongly connected component (SCC). When examining in this manner, there are edges which "cross" the corresponding "meta-vertex boundaries" (e.g., "meta-vertex" $A$ has an outbound edge to "meta-vertex" $B$ ).

Next, we will examine this notion of a graph on "meta-vertices" in this manner, which in turn will reveal some interesting properties.

### 16. Graph of Strongly Connected Components (SCC)

Now, consider the **meta-graph** on the strongly connected components (SCCs) from the previous example (cf. Section 15).

![](./assets/12-GR1-019.png){ width=650px }

In such a **meta-graph**, each strongly connected component (SCC) is represented by a corresponding "composite" vertex (i.e., a "meta-vertex"), as denoted by red in the figure shown above, and summarized as follows:

$$
\{ A \}
$$

$$
\{ B, E \}
$$

$$
\{ C, F, G \}
$$

$$
\{ D \}
$$

$$
\{ H, I, J, K, L \}
$$

Furthermore, the edges between these vertices can also be represented, as in the figure shown above (bottom section).

Observe that in this **meta-graph** representation of the strongly connected components (SCCs) (via their corresponding vertices), in general, the resulting meta-graph can be a **multi-graph** (e.g., adding an edge from vertex $G$ to vertex $J$ adds a corresponding edge to the meta-graph, as denoted by teal edge in the figure shown above). However, in general, this multiplicity (i.e., of edges) is not significant with respect to the representation of this meta-graph; indeed, for purposes of the current discussion, we will generally *avoid* such multiple (redundant) edges.

![](./assets/12-GR1-020.png){ width=650px }

So, then, what is a ***key property*** on such a meta-graph of strongly connected components (SCCs)? Observe that there are ***no*** cycles present, i.e., the meta-graph itself is a **directed acyclic graph** (**DAG**). In fact, this is generally *always* the case.

Why are there no cycles in the meta-graph? Suppose there are two strongly connected components $S$ and $S'$ which constitute a cycle (as in the figure shown above). That means that there is a pair of complementary paths $S \rightsquigarrow S'$ and $S' \rightsquigarrow S$ . We know that every vertex within $S$ is connected to each other (i.e., by definition of a strongly connected component), and similarly within $S'$ as well. Therefore, every vertex in $S$ can reach $S'$ via path $S \rightsquigarrow S'$ , and similarly every vertex in $S'$ can reach $S$ via path $S' \rightsquigarrow S$ , and correspondingly $S \cup S'$ is itself a strongly connected component (SCC). Furthermore, note that these strongly connected components (SCCs) are defined to be ***maximal*** sets of strongly connected vertices, resulting in a contradiction: $S \cup S'$ must hold, rather than (separate/disjoint) sets $S$ and $S'$ , i.e., if such a cycle were otherwise present in the meta-graph, then we could simply merge the strongly connected components (SCCs) to form a larger/"composite" strongly connected component (SCC).

Therefore, there cannot be any cycles present in the meta-graph, and thus the meta-graph itself is a directed acyclic graph (DAG).

![](./assets/12-GR1-021.png){ width=650px }

As a consequence of this key property, since a meta-graph is a directed acyclic graph (DAG) of its constituent strongly connected components (SCCs), we can correspondingly break up such a directed graph into its constituent components, and then order them into a topological ordering (by simple virtue of the meta-graph itself being a directed acyclic graph). Thus, even such an arbitrarily complex directed acyclic graph (DAG) can nonetheless be decomposed into such a relatively simple structure which is intrinsic to it.

Next, we will describe an algorithm which finds these strongly connected components (SCCs), with this search itself resulting in a specific order (i.e., topological ordering). Furthermore, as it turns out, this can be accomplish relatively straightforwardly by two simple applications of depth-first search (DFS).

### 17-22. Strongly Connected Component (SCC) Algorithm

#### 17. Algorithm Idea

Now, consider the main idea for the algorithm to identify the strongly connected components (SCC) in a meta-graph. Furthermore, these strongly connected components (SCCs) will be found in topological ordering as the algorithm proceeds.

![](./assets/12-GR1-022.png){ width=650px }

Consider the topological ordering of a directed acyclic graph (DAG), where vertex $v$ is the "first"/"left-most" and vertex $w$ is the "last"/"right-most," as in the figure shown above.

We know that vertex $w$ must be a **sink vertex**, i.e., only edges which go "in" but no edges that go "out." This is due to the nature of the ordering itself (i.e., edges can't go "back" in "reverse order").

Analogously, vertex $v$ must be a **source vertex**, i.e., only edges which go "out" but no edges that go "in."

Furthermore, this gives rise to a natural search algorithm, given these properties: We begin with finding the sink vertex, and then progress in this manner "backwards" towards the source vertex, outputting the intermediate sink vertices encountered in this manner along the way.

Analogously, we can also find the source vertex, and proceed in the "forward" direction towards the sink vertex (via intermediate source vertices) as well.

![](./assets/12-GR1-023.png){ width=650px }

We will therefore use an analogous method, however, rather than finding a sink vertex, instead, we will find a ***sink*** strongly connected component (SCC), i.e., an analogous sink vertex in the meta-graph on the constituent strongly connected components (SCCs).

Once this sink meta-vertex is found (which is present at the "end" of the topological ordering), we output it, and then remove it from the meta-graph and then repeat in this manner, until the meta-graph is eventually empty.

![](./assets/12-GR1-024.png){ width=650px }

This begs the question: Why the *sink* strongly connected component (SCC) (i.e., as opposed to the *source*)?

With respect to the topological ordering of the directed acyclic graph (DAG) itself, the choice itself is arbitrary. However, with respect to strongly connected components (SCCs), the decision is in fact consequential: Sinks are more straightforward to work with.

Why is it the case that sinks strongly connected components (SCCs) are "easier" to work with? Take any vertex $v \in S$ , where $S$ is a sink strongly connected component (SCC) in the meta-graph, and then run the procedure ${\text{Explore}(v)}$ (cf. Section 6) on it. When exploring from $v$ in this manner, which vertices are actually explored?

Consider the strongly connected component (SCC) from previously (cf. Section 16) comprised of the following vertices:

$$
\{ H, I, J, K, L \}
$$

Here, we will explore *all* of these vertices in this sink strongly connected component (SCC), however, we will *not* consequently explore any other vertices in the process, since the latter are not reachable.

Therefore, exploring $S$ results in visiting ***all*** of the vertices of $S$ , and ***nothing*** else!

Therefore, if we find such a vertex $v$ which is guaranteed to be in such a sink strongly connected component (SCC), then we can run procedure ${\text{Explore}(v)}$ , which will correspondingly explore within the scope of this sink strongly connected component (SCC). Correspondingly, this is a ***key property*** of such sink strongly connected components (SCCs). Once we have marked all of this sink strongly connected component's vertices as visited, we can remove them accordingly and proceed onto the next sink strongly connected component (SCC) in this manner.

Now, consider if we find vertex $A$ in a source strongly connected component (SCC). When we run procedure ${\text{Explore}(A)}$ , all we know is that we can reach many vertices, given that $A$ is a source vertex (in fact, we can reach the *entire* graph from vertex $A$ ). Therefore, given that the *entire* graph can be potentially explored in this manner, there is no straightforward way to mark intermediate vertices which reside within the source strongly connected component (SCC) vs. in other intermediate strongly connected components (SCCs). Conversely, this issue does *not* generally result when exploring in this manner starting at a *sink* strongly connected component (SCC), which otherwise guarantees exploration of only the constituent vertices within this sink strongly connected component (SCC) in any given iteration of the exploration, and nothing else.

![](./assets/12-GR1-025.png){ width=650px }

So, then, how do we identify such a vertex $v$ which is *guaranteed* to reside within a sink strongly connected component (SCC)? This is the ***key task*** which will be explored in the subsequent sections.

#### 18. Vertex in Sink Strongly Connected Component (SCC)

![](./assets/12-GR1-026.png){ width=650px }

Recall (cf. Section 12) that in a directed acyclic graph (DAG), the vertex with the ***lowest*** postorder number is a ***sink***.

Now, consider a more general directed graph $G$ (which may contain cycles). If we run depth first search (DFS) on such a general directed graph, is there some corresponding property with respect to postorder numbers which can analogously guarantee the presence of a vertex residing within a sink strongly connected component (SCC)?

In such a general directed graph, we might postulate that perhaps vertex $v$ with the lowest postorder numbering *always* lies within a sink strongly connected component (SCC). If this were indeed the case, then, as before (cf. Section 17), we would simply run the algorithm straightforwardly from this sink strongly connected component (SCC). However, unfortunately, this property does ***not*** generally hold for such a general directed graph.

As a counter-example, consider the graph comprised of vertices $B$ , $A$ , and $C$ , as in the figure shown above (as depicted in green), with vertices $B$ and $A$ forming a strongly connected component (SCC), and vertex $C$ constituting a separate strongly connected component (SCC). If we run depth first search (DFS) starting from vertex $A$ (as depicted in purple in the figure shown above), the resulting postorder numbering is as follows:

| Vertex | Postorder numbering |
|:--:|:--:|
| $A$ | $1, 6$ |
| $B$ | $2, 3$ |
| $C$ | $4, 5$ |

Here, the vertex with the *lowest* postorder numbering is vertex $B$ . However, vertex $B$ resides in the strongly connected component (SCC) which is ***not*** a *sink* strongly connected component (SCC), but rather a *source* strongly connected component (SCC).

Now, consider reformulating as follows:

> In a directed acyclic graph (DAG), the vertex with ***highest*** postorder number is a ***source***

And correspondingly, with respect to a more general directed graph:

> In a general directed graph $G$ , the vertex $v$ with ***highest*** postorder number ***always*** lies in a ***source*** strongly connected component (SCC)

We will later prove more thoroughly that this latter formulation does indeed hold in general. Next, we will first utilize this key property to devise the corresponding algorithm for eventually finding a *sink* strongly connected component (SCC) in a general directed graph, as desired (i.e., for corresponding topological ordering).

#### 19. Finding Sink Strongly Connected Component (SCC)

![](./assets/12-GR1-027.png){ width=650px }

Recall (cf. Section 18) the following property, which is generally true for a general directed graph (i.e., which may otherwise contain cycles):

> In a general directed graph $G$ , the vertex $v$ with ***highest*** postorder number ***always*** lies in a ***source*** strongly connected component (SCC)

Given this property, how do we then find a vertex $w$ residing in a corresponding ***sink*** strongly connected component (SCC)?

We can accomplish this straightforwardly by simply "reversing" the constituent edges of the graph. Consequently, the former "sink" strongly connected component (SCC) becomes a "source" strongly connected component (SCC), and vice versa. More formally:

> For directed graph $G = (V, E)$ , examine the reverse graph $G^{R} = (V, E^{R})$

where the reverse edges set $E^{R}$ in the latter is defined as:

$$
E^{R} = \{ \vec{wv}: \vec{vw} \in E  \}
$$

i.e., every edge in graph $G^{R}$ is the reverse of every edge in graph $G$ .

Therefore, when we examine graph $G^{R}$ , the corresponding source and sink strongly connected components (SCCs) are similarly "reversed" relative to the original graph $G$ . Nevertheless, the strongly connected components (SCCs) still remain as such in ***both*** graphs (i.e., with respect to the constituent vertex-pairs in the respective graphs).

Furthermore, with respect to the resulting directed acyclic meta-graph of these strongly connected components (SCCs), the corresponding topological ordering in the meta-graph of the reverse graph is effectively "reversed," i.e., from "last"/"right-most" to "first"/"left-most." Correspondingly, a ***source*** strongly connected component (SCC) in graph $G$ is now a ***sink*** strongly connected component (SCC) in graph $G^{R}$ ; and similarly a ***sink*** strongly connected component (SCC) in graph $G$ is now a ***source*** strongly connected component (SCC) in graph $G^{R}$ .

Now, returning to the original problem at hand, how do we find vertex $w$ residing in a *sink* strongly connected component (SCC) with respect to directed graph $G$ ? If we take the directed graph $G$ as the input, we can construct reverse directed graph $G^{R}$ from it, and then take the vertex with the *highest* postorder number in the latter, which is guaranteed to be a *source* strongly connected component (SCC) in directed graph $G^{R}$ , but then also correspondingly/complementarily a *sink* strongly connected component (SCC) in the original directed graph $G$ itself. Therefore, this constitutes the desired algorithm in question accordingly: We have now successfully identified the sink strongly connected component (SCC) in directed graph $G$ (i.e., in intended topological ordering)!

#### 20. Example

> [!NOTE]
> ***Instructor's Note***: Typo: The preorder number of $D$ and the postorder number of $C$ are both $12$ . The preorder number of $D$ should be $13$ and all preorder/postorder numbers from $13$ onwards should be incremented by $1$ . The resulting order on the postorder numbers does not change.

To illustrate the algorithm for finding a sink strongly connected component (SCC) in a general directed graph, we will do so using the example graph from previously (cf. Section 15).

![](./assets/12-GR1-028.png){ width=550px }

In this graph, there are two sink strongly connected components (SCCs) (as denoted by red in the figure shown above), i.e.,:

$$
\{ D \}
$$

and

$$
\{ H, I, J, K, L \}
$$

Recall (cf. Section 17) that if we run depth first search (DFS) from a vertex residing in either of these sink strongly connected components (SCCs) (e.g., vertex $K$ ), then no other vertices are visited besides those of the sink strongly connected component (SCC) itself. Once we have fully explored such a sink strongly connected component (SCC), we can designate it accordingly as visited (e.g., $1$ in the figure shown above) and then proceed onto the next sink strongly connected component (SCC) via corresponding topological ordering (e.g., $\{ D \}$ in the figure shown above), proceeding in this manner until the entire graph has been explored.

![](./assets/12-GR1-029.png){ width=650px }

Furthermore, to identify such a sink strongly connected component (SCC) in the input directed graph $G$ , we first examine the complementary reverse graph $G^{R}$ (as in the figure shown above), comprised of the same vertex set but with every edge being reversed. In the latter graph, recall (cf. Section 19) that the vertex with the *highest* postorder numbering will now reside in a *source* strongly connected component (SCC) with respect to graph $G^{R}$ ; these *source* strongly connected components (SCCs) are in fact the complementary ones relative to the aforementioned *sink* strongly connected components (SCCs) in original input graph $G$ (as denoted by red in the figure shown above).

![](./assets/12-GR1-030.png){ width=650px }

Now, consider a run of depth first search (DFS) on the reverse directed graph $G^{R}$ . Here, for simplicity, we wil make arbitrary choices with respect to the ordering of vertices and visited neighbors (this choice is inconsequential to the algorithm itself).

Consider a run of depth first search (DFS) starting at vertex $C$ . The corresponding exploration yields the following postorder numberings:

(*source strongly connected component 1*)

| Vertex | Postorder numbering |
|:--:|:--:|
| $C$ | $1, 12$ |
| $G$ | $2, 5$ |
| $F$ | $3, 4$ |
| $B$ | $6, 11$ |
| $A$ | $7, 8$ |
| $E$ | $9, 10$ |

(*source strongly connected component 2*)

| Vertex | Postorder numbering |
|:--:|:--:|
| $D$ | $12, 13$ |

(*source strongly connected component 3*)

| Vertex | Postorder numbering |
|:--:|:--:|
| $L$ | $14, 23$ |
| $K$ | $15, 22$ |
| $J$ | $16, 21$ |
| $H$ | $17, 18$ |
| $I$ | $19, 20$ |

Observe that in any given strongly connected component (SCC), the *highest* postnumber ordered vertex resides within a *source* strongly connected component (SCC).
  * ***N.B.*** This particular ordering arose by virtue of the arbitrary choice of strongly connected components' vertices traversal (i.e., starting with vertex $C$ in this particular case). Strictly speaking, other resulting exploration trees are also possible, however, in general, this particular graph contains two distinct source strongly connected components (SCCs), i.e., one comprised of $\{ D }\$ and the other comprised of the other vertices (which in turn form a "composite" strongly connected component per appropriate traversal, e.g., if starting from vertex $K$ , then *two* such trees would result, rather than three as resulting from a start at vertex $C$ ).

Based on this run of depth first search (DFS), now consider the overall ordering with respect to decreasing postorder numbering (i.e., from highest to lowest), as follows:

$$
L, K, J, I, H, D, C, B, E, A, G, F
$$

***N.B.*** This ordering will facilitate determining the vertex with the *highest* postorder numbering of the remaining vertices when we subsequently explore the constituent vertices in the respective strongly connected components (SCCs) of the original input directed graph $G$ .

![](./assets/12-GR1-031.png){ width=650px }

Now, returning to the original input directed graph $G$ , we run depth first search (DFS), starting with vertex $L$ residing in its *sink* strongly connected component (SCC).

Visiting the corresponding vertices of this strongly connected component, we "mark off" in turn, and assign a corresponding number for this strongly connected component (i.e., $1$ in the figure shown above), comprised of the following vertices:

$$
\{ L, K, J, I, H \}
$$

Next, we proceed onto vertex $D$ , which has the next-highest postorder numbering (via graph $G^{R}$ ) at this point among the remaining vertices. Exploring similarly yields the following strongly connected component (i.e., $2$ in the figure shown above):

$$
\{ D \}
$$

Further proceeding in this manner, strongly connected components (SCCs) $3$ , $4$ , and $5$ arise respectively as follows:

$$
\{ C, G, F \}
$$

$$
\{ B, E \}
$$

$$
\{ A \}
$$

Now, we have our strongly connected components (SCCs) fully identified, as well as numbered accordingly (i.e., with respect to topological ordering), as in the figure shown above. Furthermore, observe that these meta-vertices direct accordingly from "last"/"right-most" to "first"/"left-most" (i.e., reverse topological ordering). Furthermore, note that we have accomplished this with *two* runs of depth first search (DFS): Firstly on the reverse directed graph $G^{R}$ , followed by a subsequent run on the original input directed graph $G$ . In the process of this, we have identified *both* the strongly connected components (SCCs) *and* their output in (reverse) topological ordering. Note that this generally holds for any such general directed graph.

Next, we will formalize this algorithm, as well as analyze its corresponding running time.

#### 21. Algorithm

##### Pseudocode

![](./assets/12-GR1-032.png){ width=650px }

The pseudocode for finding strongly connected components (SCCs) in topological ordering in a general directed graph (i.e., potentially containing cycles) is given as follows:

$$
\boxed{
\begin{array}{l}
{{\text{DFS}}(G):}\\
\ \ \ \ {{\text{input:\ }} {\text{general\ directed\ graph\ }} G(V,E) {\text{\ in\ adjacency\ list\ representation}}}\\
\ \ \ \ {{\text{output:\ }} {\text{meta-vertices\ labeled\ by\ strongly\ connected\ components}}}\\
\\
\ \ \ \ {{\text{1.\ }} {\text{Construct\ }} G^{R}}\\
\ \ \ \ {{\text{2.\ }} {\text{Run\ DFS\ on\ }} G^{R}}\\
\ \ \ \ {{\text{3.\ }} {\text{Order\ }} V {\text{by\ decreasing\ postorder numbering}}}\\
\ \ \ \ {{\text{4.\ }} {\text{Run\ undirected\ connected\ components\ algorithm\ on\ }} G}
\end{array}
}
$$

In the first step, we construct the reverse graph $G^{R}$ .

In the second step, we run algorithm ${\text{DFS}}$ (cf. Section 6) on graph $G^{R}$ .
  * ***N.B.*** Recall (cf. Section 20) that the *highest* postorder numbered vertex from this run of ${\text{DFS}}$ is guaranteed to reside in a *source* strongly connected component (SCC) in graph $G^{R}$ , and therefore complementarily in a *sink* strongly connected component (SCC) in original input graph $G$ . Therefore, it now simply remains to explore from this vertex accordingly.

In the third step, we order the vertices set $V$ by ***decreasing*** postorder numbering with respect to $G^{R}$ (i.e., as obtained in the previous step).
  * ***N.B.*** This is analogous to ordering with respect to topological order in the corresponding algorithm for directed acyclic graphs (cf. Section 10).

In the fourth/final step, we now run algorithm ${\text{DFS}}$ (cf. Section 4) on graph $G$ .
  * ***N.B.*** In this step, we run the version of ${\text{DFS}}$ for ***undirected*** connected components. This version of the algorithm numbers the connected components upon traversal/exploration, which in turn will yield a topological ordering of the corresponding strongly connected components (SCCs) comprising the "meta-vertices" of the input directed graph.

##### Running Time Quiz and Answers

![](./assets/12-GR1-033Q.png){ width=650px }

Recalling (cf. Section 4) the corresponding pseudocode for the undirected connected components (as in the figure shown above), what is the overall running time for the algorithm to find strongly connected components (SCCs) in topological ordering in a general directed graph as the input?

The corresponding overall running time for this algorithm is:

$$
O(n + m)
$$

where $n = |V|$ and $m = |E|$ . 

Overall, this algorithm comprises of two runs of the depth first search algorithm, with each run of depth first search requiring $O(n + m)$ (cf. Section 4), i.e., $O(2 \times (n + m)) = O(n + m)$ .

### 22-23. Proof of Key Strongly Connected Component (SCC) Fact

#### 22. Introduction

![](./assets/12-GR1-034.png){ width=650px }

Recall (cf. Section 18) that in the formulation of for finding strongly connected components (SCCs) in topological ordering in a general directed graph, we took the following fact for granted as a "given":

> In a general directed graph $G$ , the vertex $v$ with ***highest*** postorder number ***always*** lies in a ***source*** strongly connected component (SCC)

In order to prove this fact more formally, let us first examine the following *simpler* claim:

> For strongly connected components $S$ and $S'$ , if $v \in S \rightarrow w \in S'$ (i.e., vertices $v$ and $w$ have a common connecting edge between their respective strongly connected components), then the maximum postorder numbering in $S$ is (strictly) ***greater*** than the maximum postorder numbering in $S'$

This simpler claim provides the ability to topologically sort these respective strongly connected components (SCCs). To accomplish this, we topologically sort the constituent vertices in these respective strongly connected components (SCCs), taking the corresponding maximum postorder numbering as the representative of the given strongly connected component (SCC).

Next, we sort these strongly connected components (SCCs) (i.e., comprising "meta-vertices" with respect to their constituent vertices) by decreasing postorder numbering. Per the claim, this implies that the maximum postorder numbering achieved in this manner for strongly connected component (SCC) $S$ will be generally higher than that of $S'$ .

Furthermore, generalizing this comparison, the strongly connected component (SCC) with the *highest* postorder numbering among these component-wise maxima will correspondingly yield the ***source*** strongly connected component (SCC), occurring at the "first"/"left-most" such strongly connected component (SCC) in the corresponding topological ordering.

Therefore, by proving this simpler claim (i.e., topologically sorting by maximum postorder numbering of the respective strongly connected components), then by direct corollary, we correspondingly arrive at the original key claim/fact that the vertex with the highest postorder numbering lies in a source strongly connected component (SCC) accordingly.

#### 23. Simpler Claim

![](./assets/12-GR1-035.png){ width=650px }

To prove the following simpler claim (cf. Section 22):

> For strongly connected components $S$ and $S'$ , if $v \in S \rightarrow w \in S'$ (i.e., vertices $v$ and $w$ have a common connecting edge between their respective strongly connected components), then the maximum postorder numbering in $S$ is (strictly) ***greater*** than the maximum postorder numbering in $S'$

consider two such strongly connected components $S$ and $S'$ (as in the figure shown above, as depicted by purple), containing vertices $v$ and $w$ (respectively) connected by edge $\vec{vw}$ .

Note the following observation with respect to this graph:

> There is no path $S' \rightsquigarrow S$

This is necessarily true, because, by definition (cf. Section 16), there are *no* cycles among any two such strongly connected components (SCCs).

Now, consider a run of depth first search on this graph. Initially, all vertices in the graph are not visited. Eventually, some vertex $z$ in the (super)set $S \cup S'$ must be visited prior to termination of the algorithm. Furthermore, let us assume that vertex $z$ is visited *first* in this manner (i.e., upon exploring $S \cup S'$ ). This gives rise to exactly two possibilities:
  * $z \in S'$ (i.e., $z \notin S$ ), or
  * $z \in S$ (i.e., $z \notin S'$ )

##### First Case: $z \in S'$

In the first case, $z \in S'$ . Here, when we run ${\text{Explore}(z)}$ , we consequently visit *all* vertices in $S'$ , but *none* of the vertices in $S$ , i.e., all of the vertices in $S'$ will be assigned postorder numberings before *any* of the vertices in $S$ . Therefore, in this case, the following holds in general:

> All postorder numberings in $S'$ are (strictly) ***less*** than all postorder numberings in $S$

Correspondingly, the vertex with the maximum postorder numbering in $S'$ is strictly smaller than that of $S$ , thereby proving the claim.

##### Second Case: $z \in S$

![](./assets/12-GR1-036.png){ width=650px }

In the first case, $z \in S$ . Initially, all of the vertices in $S$ and $S'$ are not visited. Here, when we run ${\text{Explore}(z)}$ , we consequently visit *all* vertices in $S$ , *and* all of the vertices in $S'$ (i.e., via correspondingly connecting edge $\vec{vw}$ across the respective strongly connected components).

Correspondingly, the resulting search tree is comprised of vertex $z$ at the root, as well as the remaining vertices in $S \cup S'$ in its corresponding subtree. Furthermore, given that vertex $z$ is in this root position, it also correspondingly receives the ***maximum*** postorder numbering upon corresponding completion of the depth first search traversal (i.e., it is necessarily true that traversal of the descendent vertices will conclude prior to terminating on this root vertex).

Therefore, since vertex $z$ resides in strongly connected component (SCC) $S$ , this in turn proves the claim as intended, i.e.,:

> For strongly connected components $S$ and $S'$ , if $v \in S \rightarrow w \in S'$ (i.e., vertices $v$ and $w$ have a common connecting edge between their respective strongly connected components), then the maximum postorder numbering in $S$ is (strictly) ***greater*** than the maximum postorder numbering in $S'$

This concludes the proof of the simpler claim, and by extension/corollary also proves the key fact/claim (cf. ) which depends on this simpler claim, i.e.,:

> In a general directed graph $G$ , the vertex $v$ with ***highest*** postorder number ***always*** lies in a ***source*** strongly connected component (SCC)

## 24. Comparison: Depth-First Search (DFS), Breadth-First Search (BFS), and Dijkstra's Algorithm

![](./assets/12-GR1-037.png){ width=650px }

We have now seen how to use the depth first search (DFS) algorithm to solve connectivity problems in both undirected and directed graphs.

As a review, let us also briefly examine some other common algorithms used to explore graphs.

As opposed to depth first search (DFS), **breadth first search** (**BFS**) explores the graph in "layers."
  * The ***input*** to the algorithm is similarly a graph $G = (V, E)$ (which can be either undirected or directed), given in adjacency-list representation, as well as a starting vertex $s \in V$ .
  * As an ***output***, breadth first search (BFS) the distance $\text{dist}(v)$ for every vertex $v \in V$ in the graph $G$ . Since the graph $G$ is otherwise ***unweighted***, $\text{dist}(v)$ is simply defined as the minimum number of edges from (starting) vertex $s$ to (ending) vertex $v$ (if no such path exists, then this distance is defined as $\infty$ ). In order to determine this distance, breadth first search (BFS) similarly tracks array $\text{prev}(v)$ , which correspondingly enables construction of the path of minimum length from $s$ to $v$ .
  * Like depth first search (DFS), breadth first search (BFS) also has a corresponding overall linear ***running time*** of $O(n + m)$ (where $n = |V|$ and $m = |E|$ ).

**Dijkstra's algorithm** is a somewhat "more sophisticated" version of breadth first search (BFS). Dijkstra's algorithm solves a similar problem to breadth first search (BFS), however, it considers a ***weighted*** graph as its input.
  * Correspondingly, the ***inputs*** to Dijkstra's algorithm are (weighted) graph $G = (V, E)$ (in adjacency-list representation), starting vertex $s \in V$ , as well as weight parameter $\ell$ , subject to the constraint that $\ell(e) > 0$ for every edge $e \in E$ .
  * The resulting ***output*** of Dijkstra's algorithm is essentially the weighted analog of breadth first search (BFS), where resulting $\text{dist}(v)$ is the length of the shortest (directed) path $s \rightsquigarrow v$ in graph $G$ for a given ending vertex $v$ .
  * The overall ***running time*** of Dijkstra's algorithm is $O((n + m) \log n)$ (where $n = |V|$ and $m = |E|$ ).
    * ***N.B.*** Dijkstra's algorithm uses the breadth first search (BFS) framework along with a **min-heap** data structure (also called a **priority queue**), which in general gives rise to $O(\log n)$ operations with respect to this data structure (i.e., element-wise search, insertion, deletion, etc.).

***N.B.*** The constraint of $\ell(e) > 0$ for every edge $e \in E$ is strictly necessary for correctness of Dijkstra's algorithm. To relax this assumption (i.e., to potentially include *negative* edge weights), refer to the algorithm described in topic Dynamic Programming 3 (i.e., all-pairs shortest paths).

***N.B.*** There are other variants of Dijkstra's algorithm beyond what is described here (i.e., using alternative data structures to min-heaps), however, in general, this course will only be concerned with that implementation which specifically uses the min-heap data structure. For additional reference, Chapter 4 of the course companion textbook *Algorithms* by Dasgupta et al. further elaborates upon this topic.

# Graph Algorithms 2: 2-Satisfiability

## 1-4. Satisfiability (SAT)

### 1. Notation

> [!NOTE]
> ***Instructor's Note***: For Eric's notes see [here](https://cs6505.wordpress.com/schedule/2-sat/).

Now, we consider an application of the strongly connected components (SCCs) algorithm (cf. Graph Algorithms 1), the **satisfiability** (**SAT**) **problem**.
  * ***N.B.*** The satisfiability problem has a central role in our later study/examination of NP-completeness.

![](./assets/13-GR2-001.png){ width=650px }

First, consider some relevant ***terminology***.

A **Boolean formula** is comprised of $n$ **variables** $x_1, x_2, \dots, x_n$ (having Boolean values $true$ or $false$ ) and $2n$ **literals** $x_1, \overline{x_1}, x_2, \overline{x_2}, \dots, x_n, \overline{x_n}$ (where $\overline{x_i}$ is the complement of $x_i$ ). Furthermore, the formulas are composed of logical **operators** $\wedge$ ($\text{AND}$ ) and $\vee$ ($\text{OR}$ )

Given this notation, we examine formulas in **conjunctive normal form** (**CNF**), which is composed of several **clauses** (the $\text{OR}$ of several literals, e.g., $x_3 \vee \overline{x_5} \vee \overline{x_1} \vee x_2$ ), which are used to construct such a **formula** $f$ in conjunctive normal form, which is in the $\text{AND}$ form of $m$ such clauses.

An example of a formula in conjunctive normal form is as follows:

$$
(x_2) \wedge (\overline{x_3} \vee x_4) \wedge (x_3 \vee \overline{x_5} \vee \overline{x_1} \vee x_2) \wedge (\overline{x_2} \vee \overline{x_1})
$$

This formula is comprised of four clauses (where each such clause is comprised of at least one literal). In order to satisfy this formula, at least one literal in each these clauses must be satisfied. For example, the following satisfies this formula:

$$
x_1 = \text{F}\\
x_2 = \text{T}\\
x_3 = \text{F}
$$

***N.B.*** In this particular case/formula, this is sufficient to satisfy the formula, irrespectively of the values of $x_4$ and $x_5$ .

In general, any given formula can be converted into conjunctive normal form (CNF), however, the size of the resulting formula may also generally increase arbitrarily.

Given this background information, we next define the satisfiability (SAT) problem more precisely.

### 2-3. Satisfiability (SAT) Problem

#### 2. Introduction

![](./assets/13-GR2-002.png){ width=650px }

The ***input*** to the **satisfiability** (**SAT**) **problem** is a formula $f$ in conjunctive normal form (CNF) with $n$ variables ($x_1, x_2, \dots, x_n$ ) and $m$ clauses.

The ***output*** is an assignment (i.e., assign $\text{T}$ or $\text{F}$ to each input variable) which satisfies the formula $f$ , if such an assignment exists, otherwise $\text{NO}$ if no such assignment exists.

#### 3. Quiz and Answers

![](./assets/13-GR2-003Q.png){ width=650px }

Consider the following input formula to the satisfiability (SAT) problem:

$$
f = (\overline{x_1} \vee \overline{x_2} \vee x_3) \wedge (x_2 \vee x_3) \wedge (\overline{x_3} \vee \overline{x_1}) \wedge (\overline{x_3})
$$

Specify the corresponding output for this input.

One such satisfying assignment for this formula is the following:

$$
x_1 = \text{F}\\
x_2 = \text{T}\\
x_3 = \text{F}
$$

### 4. $k$-SAT

![](./assets/13-GR2-005A.png){ width=650px }

We will now consider a more ***restrictive*** form of the satisfiability (SAT) problem called **$k$-SAT**,e.g., in the 3-SAT problem, the input is a formula $f$ in conjunctive normal form (CNF) with clause of size at most $3$ .

More generally we can restate the ***input*** as follows:

> Formula $f$ in conjunctive normal form (CNF) with $n$ variables ($x_1, x_2, \dots, x_n$ ) and $m$ clauses, with each clause of size at most $k$ (i.e., $\le k$ ).

***N.B.*** Recall (cf. Section 1) that the size of a given clause is based on the number of literals that it contains (e.g., $x_1, x_2, x_3$ in a 3-SAT problem).

We will later see (cf. NP-completeness) that the satisfiability (SAT) problem is NP-complete, and furthermore $k$-SAT is NP-complete for all $k \ge 3$ .

For now, we will next examine a polynomial-time algorithm for the 2-SAT problem.
  * ***N.B.*** Note the interesting dichotomy here: While the 2-SAT problem (i.e., $k = 2$ ) has a polynomial-time algorithm (as will be demonstrated shortly), conversely, the $k$-SAT problem with $k \ge 3$ is generally NP-complete.

## 5. Simplifying Input

![](./assets/13-GR2-006.png){ width=650px }

Consider the following input $f$ for the 2-SAT problem:

$$
(x_3 \vee \overline{x_2}) \wedge (\overline{x_1}) \wedge (x_1 \vee x_4) \wedge (\overline{x_4} \vee x_2) \wedge (\overline{x_3} \vee x_4)
$$

Now, consider how to ***simplify*** this input to the 2-SAT problem. In particular, we wish to remove ***unit clauses*** (i.e., clauses with exactly *one* literal).

In this particular example, the only way to satisfy the unit clause $\overline{x_1}$ is to set $x_1 = \text{F} \implies \overline{x_1} = \text{T}$ .

More generally, to to simplify unit clauses, use the following ***procedure***:
  * 1 - Given a unit clause comprised of literal $a_i$
  * 2 - Satisfy the unit clause by setting $a_i = \text{T}$
  * 3 - Eliminate any clauses containing $a_i$ and drop $\overline{a_i}$
  * 4 - Let $f'$ be the resulting formula

Following this procedure with $x_1 = \text{F} \implies \overline{x_1} = \text{T}$ as before, the input $f$ simplifies to $f'$ as follows (with corresponding elimination of $x_1$ )

$$
(x_3 \vee \overline{x_2}) \wedge (x_4) \wedge (\overline{x_4} \vee x_2) \wedge (\overline{x_3} \vee x_4)
$$

![](./assets/13-GR2-007.png){ width=650px }

The ***claim*** now is that $f$ is satisfiable if and only if $f'$ is also satisfiable.

Furthermore, with this simplified input, observe that another unit clause results, $x_4$ . We can set $x_4 = \text{T}$ and repeat the aforementioned process, repeating in this manner until an empty formula results (which is trivially satisfied), or where all clauses are of size exactly $2$ .

![](./assets/13-GR2-008.png){ width=650px }

A ***key observation*** is the following:

> $f$ is satisfiable $\iff$ $f'$ is satisfiable

This is readily true, as the only way to satisfy $f$ (the original formula) is via corresponding satisfiability of the unit clause used to simplify $f$ to $f'$ . Furthermore, the implication of this simplification procedure is that as long as there are unit clauses, eventually the resulting formula is either satisfied or otherwise yields clauses of exactly size $2$ .

Now, in order to design an algorithm, we can assume that the input to the 2-SAT problem has clauses which are all of exactly size $2$ . Next, we will examine the relationship between this 2-SAT problem and the previously seen (cf. Graph Algorithms 1) strongly connected components (SCCs) algorithm.

## 6. Graph of Implications

Now, take the input $f$ in cumulative normal form (CNF) with all clauses assumed to be of exactly size $2$ (cf. Section 5), where $f$ is comprised of $n$ variables and $m$ such clauses.

![](./assets/13-GR2-009.png){ width=650px }

We want to convert this logic problem into a graph problem. To accomplish this, we take Boolean formula $f$ and convert it into corresponding directed graph, whereby the graph encodes all of the information in this input formula. The general correspondence is a follows:
  * $2n$ vertices correspond to inputs $x_1, \overline{x_1}, \dots, x_n, \overline{x_n}$
  * $2m$ edges correspond to $2$ "implications" per clause

Consider the following example input:

$$
f = (\overline{x_1} \vee \overline{x_2}) \wedge (x_2 \vee x_3) \wedge (\overline{x_3} \vee \overline{x_1})
$$

The corresponding graph has six vertices corresponding to the six literals (as in the figure shown above, denoted by purple vertices).

In the first clause $\overline{x_1} \vee \overline{x_2}$ , suppose that $x_1 = \text{T}$ . In this case, the first literal (i.e., $\overline{x_1}$ ) is *not* satisfied, and therefore it is necessarily true that $x_2 = \text{F}$ , i.e., $x_1 = \text{T} \rightarrow x_2 = \text{F}$ . Similarly, in this first clause, $x_2 = \text{T} \rightarrow x_1 = \text{F}$ .

Therefore, to encode these ***implications***, we add the corresponding edges as follows (as denoted by red edges/arrows in the figure shown above):

$$
x_1 \rightarrow \overline{x_2}\\
x_2 \rightarrow \overline{x_1}
$$

Similarly, the second clause yields the following pair of implications:

$$
\overline{x_2} \rightarrow x_3\\
\overline{x_3} \rightarrow x_2
$$

And, finally, the third clause similarly yields the following pair of implications:

$$
x_3 \rightarrow \overline{x_1}\\
x_1 \rightarrow \overline{x_3}
$$


![](./assets/13-GR2-010.png){ width=650px }

The resulting graph is in the figure shown above.

Furthermore, in general, given a clause comprised of literals $\alpha$ and $\beta$ (i.e., clause $(\alpha \vee \beta)$ for the 2-SAT problem), then the corresponding edges are given as:

$$
\overline{\alpha} \rightarrow \beta\\
\overline{\beta} \rightarrow \alpha
$$

i.e., inability to satisfy the left (complementary) literal implies necessary satisfiability of the right literal in the corresponding pairs $x \rightarrow y$ .

## 7. Graph Properties

![](./assets/13-GR2-011.png){ width=650px }

Recall (cf. Section 2) the following example input (with corresponding graph as in the figure shown above):

$$
f = (\overline{x_1} \vee \overline{x_2}) \wedge (x_2 \vee x_3) \wedge (\overline{x_3} \vee \overline{x_1})
$$

Now, let us further consider this graph, and explore some of its corresponding properties.

Consider the particular path $x_1 \rightarrow \overline{x_2} \rightarrow x_3 \rightarrow \overline{x_1}$ (as denoted by black shading in the figure shown above), or equivalently $x_1 \rightsquigarrow \overline{x_1}$ .

Observe that this is a ***path of implications***, where each such edge is an implication.

Following along this path, if $x_1 = \text{T}$ (start of path), then ultimately necessarily $\overline{x_1} = \text{F}$ (end of path); however, this is clearly a *contradiction*. Therefore, $x_1 = \text{T}$ *cannot* satisfy formula $f$ in this manner.

Conversely, if $x_1 = \text{F}$ (start of path), since there are no edges out of $\overline{x_1}$ , then there are no corresponding implications, therefore, this *may* be appropriate. At this point, we can proceed to other variables, since all that is known is that there is a path $x_1 \rightsquigarrow \overline{x_1}$ for which $x_1 = \text{F}$ is *not* a valid choice. Therefore, if $x_1$ and $\overline{x_1}$ are in the *same* strongly connected component (SCC), then formula $f$ is ***not*** satisfiable.

Now, consider the following: If there were such a reverse path $\overline{x_1} \rightsquigarrow x_1$ in addition to the original path $x_1 \rightsquigarrow \overline{x_1}$ , then $f$ is necessarily not satisfiable, since there is no way to set $x_1$ and $\overline{x_1}$ in such a consistent manner which is satisfiably assignable.

Furthermore, with respect ot the graph, if there are two such complementary paths $x_1 \rightsquigarrow \overline{x_1}$ and $\overline{x_1} \rightsquigarrow x_1$ , then this implies that both corresponding vertices $x_1$ and $\overline{x_1}$ reside in the *same* strongly connected component (SCC). More generally, this holds for any such complementary pair of variables $x_i$ and $\overline{x_i}$ , i.e., the presence of both in the same strongly connected component (SCC) implies that input $f$ is *not* satisfiable.

Therefore, by corollary, we will next see that that, in general, if literal $x_i$ and its negation $\overline{x_i}$ are in *different* strongly connected components (SCCs), and if this holds true for all of the variables (i.e., vertices in the corresponding graph), then we can find a corresponding satisfiable assignment for $f$ . Furthermore, finding such a satisfiable assignment will correspondingly prove the satisfiability of $f$ accordingly.

## 8. Strongly Connected Components (SCC)

Let us now formalize the previously described (cf. Section 7) relationship between the strongly connected components (SCCs) of the directed graph resulting from the input formula $f$ in cumulative normal form (CNF) for the 2-SAT problem, and the corresponding satisfiability of $f$ .

![](./assets/13-GR2-012.png){ width=650px }

Consider the following ***lemma***:

> For some $i$ , if literals $x_i$ and $\overline{x_i}$ (the negation of $x_i$ ) are both in the ***same*** strongly connected component (SCC), then $f$ is ***not*** satisfiable.

***N.B.*** Recall (cf. Section 7) that this is proved to be necessarily true, because otherwise the existence of such a strongly connected component (SCC) results in a contradiction between $x_i$ and $\overline{x_i}$ with respect to the corresponding assignments.

Now, consider the complementary corollary ***lemma***:

> For all $i$ , if literals $x_i$ and $\overline{x_i}$ (the negation of $x_i$ ) are both in a ***different*** strongly connected component (SCC), then $f$ ***is*** satisfiable.

In this latter lemma, we will prove this by directly finding such a corresponding satisfying assignment via the corresponding directed graph form of the input $f$ . To accomplish this, we will next construct an algorithm to find such a satisfying assignment.

## 9-10. Algorithm Idea

### 9. Approach 1

Recall (cf. Graphing Algorithms 1) the strongly connected component (SCC) algorithm:
  * 1 - Find the sink strongly connected component (SCC)
  * 2 - Mark the vertices in the sink strongly connected component (SCC)
  * 3 - Remove the sink strongly connected component (SCC) and recurse on the resulting remainder graph

![](./assets/13-GR2-013.png){ width=650px }

In this first approach, we follow a similar procedure.

First, we identify a sink strongly connected component (SCC) $S$ (as in the figure shown above). In this example, sink strongly connected component (SCC) $S$ is comprised of literals $x_1$ and $\overline{x_3}$ .

Sink strongly connected component (SSC) $S$ only has edges coming in, but none going out. How should we set the values of the literals? We should set them both to $\text{T}$ .

Why is this the case? Consider the edge into literal $\overline{x_3}$ , i.e., let this edge be denoted by $x_2 \rightarrow \overline{x_3}$ . If we let $x_2 = \text{T}$ , then necessarily this implication only holds if correspondingly $\overline{x_3} = \text{F}$ . Therefore, in order to satisfy all such literals in sink strongly connected component (SCC) $S$ , it is necessarily the case that all (i.e., both) of its constituent literals are $\text{T}$ (e.g., $x_1 = \text{T}$ and $\overline{x_3} = \text{T} \implies x_3 = \text{F}$ in this particular case).

Correspondingly, we set the sink strongly connected component (SCC) $S$ to be $S = T$ (i.e., satisfy all of the literals in $S$ accordingly). Since $S$ is a sink, there are no outgoing edges, and therefore there are no corresponding implications to follow as a result of this assignment; correspondingly, the "tail" end of the implications for incoming edges are already satisfied.

![](./assets/13-GR2-014.png){ width=650px }

Now, we can remove this sink strongly connected component (SCC) and proceed onto the remainder of the graph (as in the figure shown above).

We repeat the aforementioned procedure on the remainder of the graph.

However, there is a problem: What to do about the complement of the set $\{ x_1, \overline{x_3} \}$ (i.e., $\{ \overline{x_1}, x_3  \}$ ) in the initial sink strongly connected component (SCC)? In general, we have *not* satisfied the complementary set, which may generally have incoming edges that result in a contradictory assignment for these (complementary) literals.

To potentially resolve this issue, ideally, the complementary strongly connected component (SCC) $\overline{S}$ would be a source strongly connected component (SCC), which correspondingly does *not* contain any such incoming edges, thereby satisfying the assignments of the complementary-pairs sets. In this case, we can safely set $\overline{S} = \text{F}$ accordingly; furthermore, such a source strongly connected component (SCC) $\overline{S}$ does *not* have outbound edges (i.e., implications) requiring satisfiable assignment for the (non-existent) "downstream/tali" literal.

Therefore, next, we will use this idea of complementary sink and source strongly connected components (SCCs) to reformulate our approach for this algorithm.

### 10. Approach 2

![](./assets/13-GR2-015.png){ width=650px }

Consider the previous idea (cf. Section 9), whereby a sink strongly connected component (SCC) is satisfied with respect to its constituent literals.

Furthermore, now, consider the reverse idea: Take source strongly connected component (SCC) $S'$ , having no incoming edges, and set $S' = \text{F}$ (i.e., not satisfied) with respect to its constituent literals.

For example, given such a sink strongly connected component (SCC) comprised of set $\{ \overline{x_2}, x_4 \}$ (as in the figure shown above), let $x_2 = \text{T}$ and $x_4 = \text{F}$ .

Since there are no incoming edges, there are no later (i.e., "downstream/tail") implications to satisfy. Furthermore, since the constituent literals of this source strongly connected component (SCC) are not satisfied (i.e., set to $\text{F}$ ), we are not particularly concerned with the implications of the outgoing edges. Therefore, we can remove this source strongly connected component (SCC), and proceed onto the remainder of the graph.

Correspondingly, in the complementary set $\overline{S'}$ (e.g., $\{ x_2, \overline{x_4} \}$ ), these reside in a sink strongly connected component (SCC) which is set to $\overline{S'} = \text{T}$ accordingly. Furthermore, with this setting of $\overline{S'} = \text{T}$ , the latest (i.e., downstream-most) implications are set accordingly, and furthermore there are no outgoing edges from $\overline{S'}$ requiring any additional such satisfying assignment for the corresponding (non-existent) implications.

As it turns out, these two approaches are equivalent: Setting a sink strongly connected component (SCC) $\overline{S'} = \text{T}$ and simultaneously setting source strongly connected component (SCC) $S' = \text{F}$ are complementary operations accordingly.

Therefore, we can summarize this procedure as follows:
  * 1 - Take source strongly connected component (SCC) $S'$ and set $S' = \text{F}$, and simultaneously take sink source strongly connected component $\overline{S'}$ and set $\overline{S'} = \text{T}$
  * 2 - Remove the corresponding literals (i.e., those appearing in $S'$ and $\overline{S'}$ ), and repeat this process
    * ***N.B.*** This removal correspondingly simplifies the resulting formula (i.e., remainder of the graph)

## 11. 2-SAT Algorithm

![](./assets/13-GR2-016.png){ width=650px }

The ***key fact*** that we have discussed (cf. Section 10), but not yet proven, is the following:

> For all $i$ , if literals $x_i$ and $\overline{x_i}$ (the negation of $x_i$ ) are both in a ***different*** strongly connected component (SCC), then $S$ is a ***sink*** strongly connected component (SCC) if and only if its complement $\overline{S}$ is a ***source*** strongly connected component (and vice versa).

### Pseudocode

Taking this key fact for granted (for now), we can design the corresponding algorithm for the 2SAT problem as per the following pseudocode:

$$
\boxed{
\begin{array}{l}
{{\text{2SAT}}(f):}\\
\ \ \ \ {{\text{input:\ }} {\text{formula\ }} f {\text{\ in\ conjunctive\ normal\ form\ (CNF)}}}\\
\ \ \ \ {{\text{output:\ }} {\text{a\ satisfiable\ assignment\ for\ }} f}\\
\\
\ \ \ \ {{\text{1.\ }} {\text{Construct\ graph\ }} G {\text{\ for\ }} f}\\
\ \ \ \ {{\text{2.\ }} {\text{Take\ a\ sink\ source\ strongly\ connected\ component\ (SCC),\ }} S:}\\
\ \ \ \ \ \ \ \ {{\text{Set\ }} S = {\text{T}} {\text{\ and\ set\ }} \overline{S} = {\text{F}}}\\
\ \ \ \ \ \ \ \ {{\text{Remove\ }} S {\text{\ and\ }} \overline{S} {\text{\ from\ graph\ }} G}\\
\ \ \ \ \ \ \ \ {{\text{Repeat\ Step\ 2\ until\ graph\ }} G {\text{\ is\ empty}}}\\
\end{array}
}
$$

As ***input*** we have formula $f$ in conjunctive normal form (CNF). Here, we assume that all of the clauses in $f$ are of exactly size $2$ .

Next, we construct the (directed) graph of implications $G$ corresponding to formula $f$ . Given this graph $G$ , we run the strongly connected component (SCC) algorithm (cf. Graphing Algorithms 1) on this graph, resulting in a topological ordering of these strongly connected components (SCCs) in $G$ .

Now, we take the last component $S$ (i.e., a sink strongly connected component [SCC]) in $G$ via corresponding topological ordering, and then set it such that $S = \text{T}$ (i.e., all/both of the constituent literals in $S$ are satisfied); correspondingly, we also set $\overline{S}$ (the complementary source strongly connected component [SCC]) such that $\overline{S}$ (i.e., all/both of the constituent literals in $\overline{S}$ are unsatisfied). Upon setting in this manner, we simultaneously remove $S$ and $\overline{S}$ from $G$ , and then repeat this procedure on the resulting remainder graph, until the remainder graph is ultimately empty. At this point, input formula $f$ has been satisfied.

### Running Time

By inspection, the main/"bottlenecking" step in this algorithm is construction of the strongly connected components (SCCs); recall (cf. Graphing Algorithms 1) that this has an overall linear running time, i.e.,:

$$
O(n + m)
$$

where $n = |V|$ and $m = |E|$ .

Now, it still remains to prove the aforementioned "key fact" which underlies this algorithm, as discussed next.

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
