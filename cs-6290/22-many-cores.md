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
