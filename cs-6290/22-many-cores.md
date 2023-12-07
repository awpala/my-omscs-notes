# Many Cores

## 1. Lesson Introduction

This final lesson will discuss what occurs when ***a lot*** of cores are placed on the ***same*** chip. This will correspondingly integrate many concepts already discussed in the previous lessons.

## 2-4. Many-Cores Challenges: Part 1

### 2. Introduction

<center>
<img src="./assets/22-001.png" width="650">
</center>

This lesson will discuss several ***challenges*** which are present in a **many-cores processor**, including:
  * As the number of cores increases, the ***coherence traffic*** increases accordingly
    * This is a direct consequence of that fact (cf. Lesson 19) that writes to shared-memory locations result in invalidations and consequent cache misses with respect to this locations. Consequently, both the invalidations and the cache misses propagate through the shared bus, thereby increasing coherence traffic accordingly.
  * As the number of cores increases, the number of writes per-unit time increases, and consequently the required ***bus throughput*** increases accordingly in order to scale concomitantly with this increased amount of writing activity (until the bus's throughput is eventually exceeded)
    * The bus eventually forms a ***bottleneck*** regardless, because it only allows one request at a time. This is partly necessary because the system relies on the bus to enforce ordering among writes, thereby maintaining coherence accordingly.
    * Therefore, to resolve this issue, a **scalable on-chip network** is required, which allows the traffic to grow proportionally to the number of cores (without otherwise bottlenecking). Furthermore, **directory coherence** (cf. Lesson 19) is also required for this resolution measure, in order to obviate the dependency on the bus itself.

### 3. Network on a Chip

<center>
<img src="./assets/22-002.png" width="650">
</center>

Consider now what such a "network on a chip" would look like (as in the figure shown above).

Let a "tile" (denoted by teal square in the figure shown above) represent a core and its corresponding level 1 (L1) cache. Conventionally, each such "tile" is connected to a shared bus (denoted by green in the figure shown above).

In such an eight-tile configuration, assume that the first set of four tiles use half of the available throughput of the shared bus (i.e., cache misses and coherence are managed via the bus accordingly), and similarly the other set of four tiles replicates this configuration exactly, using the other half of the available shared-bus throughput accordingly.
  * With this "compositely shared" bus, ***all*** of the corresponding eight-core traffic passes through the bus, resulting in a relatively slower bus with lower throughput (i.e., as compared to each individual four-tile unit) due to the increased traffic.
  * Therefore, the bus quickly becomes ***saturated*** in this manner as the quantity of tiles increases.

Conversely, consider an alternate network topology called a **mesh** (as in the figure shown above), whereby the tiles are individually interconnected.
  * While there is no longer an equivalent "bus-wide broadcast," there is still the capability present whereby tiles can intercommunicate in this manner. Communication can also pass across tiles in this manner, and independently across such "paths."
  * Correspondingly, the ***overall throughput*** is larger than that of any individual link. Furthermore, since these links are relatively short, this further amplifies the overall throughput of the system as a whole.

Correspondingly, in such a mesh comprised of `16` cores (as in the figure shown above), there are many such (independent) links present; furthermore, this scaling increases with the number of cores (i.e., as the number of cores increases, so does the number of links between them), thereby ***increasing*** available throughput accordingly.
  * Consequently, this topology scales much better with increasing cores than an equivalent single shared-bus configuration.

<center>
<img src="./assets/22-003.png" width="650">
</center>

Note that there are many such **point-to-point networks** available in addition to the aforementioned mesh (as in the figure shown above).
  * The **mesh** is particularly amenable to building chips (i.e., printing on silicon), because none of the links intersect one another.
  * The **torus** uses such "three-dimensional"/"cross-over" linking, whereby "terminal tiles" are also interconnected.
  * The **flattened butterfly** is another more advanced network topology.

 ***N.B.*** Consult an advanced architectures course for more discussion on these point-to-point networks and other related "network on a chip" topologies.

### 4. Mesh vs. Bus Throughput Quiz
