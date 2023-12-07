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

<center>
<img src="./assets/22-005A.png" width="650">
</center>

Consider a four-core system, whereby traffic is uniformly distributed (i.e., each core handles a quarter of the overall messages in the system), with each message from a given core being sent to other three cores in a round-robin manner. Furthermore, assume that this message processing is randomly distributed (i.e., there is no inherent synchronicity among these accesses, but rather the traffic sent from each core propagates to the other three cores "straightforwardly").

Each core sends messages at a rate of `10M (million)` messages per second. Furthermore, the maximum throughput of the bus is `20M` messages per second, whereas the equivalent mesh supports a maximum throughput of `20M` messages per second ***per link***.
  * ***N.B.*** If the bus bandwidth is saturated by the four cores, they simply decreased throughput proportionally accordingly in this case (i.e., to match the bandwidth of the bus).

What is the corresponding speedup of the mesh vs. the bus?
  * `2`

***Explanation***:

Ideally, the four-core system should achieve an overall throughput of `40M` messages per second, with each core processing `10M` messages per second.

By inspection, the overall throughput of the ***bus*** is `20M` messages per second, operating at the saturation limit in this manner.
  * With each core having a maximum throughput of `10M` messages per second, due to the saturation limit, it must halve this to `5M` messages per second due to the saturation-limit constraint.

As for the ***mesh***, to determine the overall throughput, it must first be determined whether the network (as specified) gets saturated. This can be done by examining each individual core in turn, and then aggregating the "overall balance" accordingly (i.e., relative to the saturation limit of `20M` messages per second per link).

<center>
<img src="./assets/22-006A.png" width="250">
</center>

For a given core (e.g., the top-left, in the figure shown above), the throughput is split such that `1/3` (i.e., `3.33M` messages per second of the per-link total `10M` messages per second) goes to each adjacent core, and among those adjacent cores the remaining `1/3` of the bandwidth is split across the "downstream" links (i.e., `2 × (1/6)`).

<center>
<img src="./assets/22-007A.png" width="250">
</center>

Therefore, the overall throughput of the top-left core (as in the figure shown above) is `1/3 + 1/6 = 1/2` to each adjacent core, and `1/6` apiece in the "downstream" links from those cores (i.e., the total "fractional throughput" balances out to `1` across the four links accordingly).

<center>
<img src="./assets/22-008A.png" width="250">
</center>

Examining the top-right core, by similar rationale, this adds `1/2` apiece to adjacent links, and `1/6` apiece to the "downstream" links.

<center>
<img src="./assets/22-009A.png" width="350">
</center>

Examining the bottom-right core, by similar rationale, this adds `1/2` apiece to adjacent links, and `1/6` apiece to the "downstream" links.

<center>
<img src="./assets/22-010A.png" width="350">
</center>

Finally, examining the bottom-left core, by similar rationale, this adds `1/2` apiece to adjacent links, and `1/6` apiece to the "downstream" links.

In this manner, each link distributes the overall bandwidth evenly, resulting in a total of `4/3` on a per-link basis, or equivalently `(4/3) × 10M = 13.3 M` messages per second per link. Observe that this is still below the saturation limit per link (cf. `20M` messages per second per link).

Therefore, the overall speed up is `2`.
  * The bus-based system effectively throttles the overall throughput by half due reaching to the saturation limit (i.e., requires achieving at least `40M` messages per second to exhibit a "parity" speedup of `1`, but saturates at `20M` messages per second), an effective "speedup" of `0.5`.
  * Conversely, the mesh network does not saturate, and is therefore able to achieve up to the full `20M` messages per second bandwidth across the system (i.e., only uses `13.3M` messages per second per link, as configured here, thereby allowing the individual cores to achieve the max per-core throughput of `10M` messages per second, relative to a "parity" speedup of `1`).

***N.B.*** If a larger network were used (i.e., beyond four cores), then the equivalent bus would further "slow down" relatively to this proportionally to this increase in the cores count, whereas the mesh will add proportionally more links to manage this increased overall bandwidth accordingly. In this manner, saturation is reached at a much larger quantity of cores.

## 5-7. Many-Cores Challenges: Part 2

### 5. Introduction

<center>
<img src="./assets/22-011.png" width="650">
</center>

Returning to the challenges present in many-cores processors (cf. Section 2), recall (cf. Section 2) that as the number of cores increases, the coherence traffic on the chip correspondingly increases. Furthermore, recall (cf. Section 3) that resolving this issue requires a scalable on-chip network (e.g., mesh) supported by directory coherence (cf. Lesson 19).

Furthermore, another issue introduced by adding more cores to the system is that as the number of cores increases, so does the **off-chip traffic**.
  * To maintain adequate performance, as the number of cores increases, the number of **on-chip caches** must increase accordingly (e.g., a four-core processor requires four level 1 [L1] caches, and possibly a level 2 [L2] cache; a 64-core processor requires `64` level 1 [L1] caches and corresponding level 2 [`L2`] caches; and so on).
    * Accordingly, each core individually does not necessarily generate more cache misses, however, the overall number of cache misses is generally the same across the entire system (i.e., on a per-core basis), regardless of how many cores are present. Therefore, as the number of cores increases, so does the number of ***memory requests*** (i.e., resulting from proportionally more cache misses).
  * However, note that the number of **connecting pins** on the chip increases slowly relative to the number of cores as more cores are added (e.g., a doubling of cores may add 10% more pins, but nowhere close to 100%).
    * The pins themselves must be physically large enough to prevent breaking on connecting/reconnecting the chip to the motherboard, etc.
    * Therefore, the slight improvement in off-chip throughput is not proportional to the corresponding increase in demand for this throughput grows directly proportionally to the amount of cores added. Correspondingly, this **off-chip available throughput** therefore becomes ***bottlenecking*** accordingly.

In order to avoid saturating the off-chip available throughput, it is necessary to reduce the number of memory requests per core. This can be accomplished using a **last level cache (LLC)** (which in modern processors is typically a **level 3 [L3] cache**) which is ***shared*** (equally) among the cores, with the size of this last level cache (LLC) scaling roughly proportionally to the number of cores.

However, there are a couple of ***problems*** with having one such large level cache (LLC), as follows:
  * It is very slow
  * As a single cache, it only has ***one*** "entry point" for entering the requested address and receiving the corresponding data (i.e., from main memory)
    * Furthermore, this entry point will be located somewhere on the chip (comprised of a mesh or other advanced network topology) that may also become ***bottlenecking*** (i.e., not all links can achieve the same maximum per-link throughput), since these entry-point links will receive a disproportionate share of the traffic, even as the number of cores increases

To resolve these particular problems, rather than having "one" such large level cache (LLC), instead a **distributed large level cache (LLC)** is used.

### 6. Distributed Large Level Cache (LLC)
