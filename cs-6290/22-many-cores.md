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

However, there are a couple of ***problems*** with having one such last level cache (LLC), as follows:
  * It is very slow
  * As a single cache, it only has ***one*** "entry point" for entering the requested address and receiving the corresponding data (i.e., from main memory)
    * Furthermore, this entry point will be located somewhere on the chip (comprised of a mesh or other advanced network topology) that may also become ***bottlenecking*** (i.e., not all links can achieve the same maximum per-link throughput), since these entry-point links will receive a disproportionate share of the traffic, even as the number of cores increases

To resolve these particular problems, rather than having "one" such last level cache (LLC), instead a **distributed last level cache (LLC)** is used.

### 6. Distributed Last Level Cache (LLC)

<center>
<img src="./assets/22-012.png" width="650">
</center>

Logically, a **distributed last level cache (LLC)** is a "single" cache (in the sense that a data block will ***not*** be replicated in a manner akin to private, per-core caches).
  * Therefore, a `4 MB` cache that is "distributed" in this manner effectively uses all of this cache memory, rather than replicating redundant data across the private caches (thereby reducing the effective capacity accordingly.)

However, this distributed last level cache (LLC) is still "sliced up" (i.e., forming a "disjoint set"), such that each tile (i.e., core and associated local cache[s]) receives a fractional part of the overall cache capacity.

Therefore, in such a mesh network (as in the figure shown above), each tile contains the core, local caches (i.e., level 1 [L2] and level 2 [L2] caches), and a "slice" of the last level cache (i.e., level [L3] cache).
  * For example, if each such "slice" is `1 MB` in size, then the corresponding size of the distributed last level cache (LLC) is `N × 1 MB` (where here `N = 4`). Furthermore, note that this scales accordingly as the number of cores (i.e., `N`) increases.

A ***key advantage*** here is that while the overall capacity increases proportionally to the cores, there is ***no*** longer a single entry point, but rather ***each*** slice of the last level cache (LLC) has its ***own*** entry point. This in turn ***distributes*** the traffic among the caches, thereby avoiding strain on any particular link.

However, if a level 2 (L2) cache miss occurs in a particular core, how can it then be determined from which slice of the last level cache (LLC) to request the data?

One simple approach to this is to simply spread the cache in a **round robin** manner among the slices, using a corresponding **cache index**.
  * For example, given an eight-core processor with a level 3 (L3) cache having `1024` sets, the sets are distributed accordingly among the eight slices in question. Now, after the address is decomposed in order to access the cache, then given the appropriate set number and three least-significant bits of the slice, then the set in question can be located unambiguously.
  * Furthermore, note that as the number of cores increases, then the number of sets in the cache will grow proportionally to this, correspondingly using additional bits to uniquely identify/index these cache sets accordingly.

***N.B.*** If the data is accessed sequentially, then the sets are traversed in order in a given slice. However, given the distribution of the sets among the slices, this round-robin based "spreading" of the memory load is amenable to such a memory-access pattern.

<center>
<img src="./assets/22-013.png" width="650">
</center>

However, note that the spreading of the blocks in a round-robin manner across the chip may potentially disrupt ***locality***, because a given core is just as likely to access something in a core located at "opposite corner" of the chip as something in itself or in an adjacent core.

To mitigate this issue, another approach is to distribute the data in a round-robin manner with respect to ***page number*** instead. This way, all of the blocks belonging to the same page generally end up in the ***same*** slice of the last level cache (LLC) accordingly.
  * This in turn facilitates efficient program execution, because the operating system is otherwise capable of mapping pages in such a manner so as to make these last level cache (LLC) accesses more local (e.g., placing the pages pertaining to a given stack in the same core's slice).

### 7. Distributed Last Level Cache (LLC) Quiz and Answers

<center>
<img src="./assets/22-015A.png" width="650">
</center>

Consider a system comprised of `16` cores, organized as a `4×4` mesh (as in the figure shown above).
  * A single ***tile*** in this mesh is comprised of a core, level 1 (L1) and level 2 (L2) caches, and a slice of the level 3 (L3) cache

Furthermore, the level 3 (L3) cache is characterized as follows:
  * `8 MB` capacity
  * `256 bytes` block size
  * `16` way set-associative
  * distributed among the slices in a round-robin manner with respect to its constituent slices (i.e., set `0` goes to slice `0`, set `1` goes to slice `1`, etc., with corresponding "wraparound")

If the core in tile `0` issues a memory request `LW 0x1234567` (where `0x1234567` is the target address) which yields a cache miss in both level 1 (L2) and level (L2) caches, then to which level 3 (L3) tile will this request subsequently forward to?
 * Tile `6`

***Explanation***:

Given a `256 bytes` block size, the least-significant `8` bits (i.e., `log_2(256) = 8`) indicate the block offset, whereas the remaining bits comprise the index. Furthermore, the next-least-significant bits in this index portion specify the tile.

Therefore, since there are `16` tiles, the corresponding `16` least-significant bits (equivalent to a single hex digit) of the index portion identify the tile, i.e., `0x6`, or tile `6`.

Diagrammatically, this corresponds to the following:

```
        |          index bits            |
                                           |offset |
binary: 0000 0001 0010 0011 0100 0101 0111 1110 1111
hex:    0    1    2    3    4    5    6    7    8
```

***N.B.*** In this case, it is not necessary to determine the index exactly, since the least-significant bits of the index region already identify the tile in question.

## 8-11. Many-Cores Challenges: Part 3

### 8. Introduction

<center>
<img src="./assets/22-016.png" width="650">
</center>

Returning to the challenges present in many-cores processors (cf. Section 2), recall (cf. Section 3) that there are indeed solutions to managing the increased on-chip coherence traffic as the number of cores grows via corresponding scalable on-chip networks supported by directory coherence.

Furthermore, recall (cf. Section 6) that there are also solutions to managing the increased off-chip traffic as the number of cores grows via a corresponding large, shared distributed last level cache (LLC).

However, there is still another problem: The **coherence directory** required in order to manage the scalable on-chip network ***too large*** to fit on a chip.
  * A traditional directory has ***one*** entry for ***each*** possible memory block.
  * However, in practice, the memory can reach a size of many gigabytes, which would correspondingly require *billions* of such directory entries, well beyond the physical capacity of a chip.

So, then, how to solve this problem? This is discussed in the next section.

### 9. On-Chip Directory: Part 1

<center>
<img src="./assets/22-017.png" width="650">
</center>

The directory must fit on the chip, otherwise maintaining coherence between the caches (which are very fast) will require searching through a directory in very slow memory, which essentially negates the purpose of having these fast caches in the first place.

Some of the questions regarding this directory are relatively straightforward to answer, namely: Where should the home node (which contains the directory information regarding the cache block in question) be placed? → It is simply placed in the ***same*** tile that contains the corresponding distributed last-level cache (LLC) slice
  * If the directory entry for this cache block indicates that none private caches contain the block, then the last level cache (LLC) is consequently used to locate that block; therefore, it is sensible to do so in the same node containing the directory in question, otherwise there would be a lot of (otherwise superfluous) traffic between the location of the directory and that of the last level cache (LLC) containing the block in question, so they naturally should co-exist in the same node.

However, this does not address another fundamental question: How to manage the scaling issue of having a directory entry for ***every*** memory block?
  * Recall (cf. Section 6) that the last level cache (LLC) slice only contains the cache-blocks data for those blocks which are actually present in the last level cache (LLC).
  * However, without any other changes, the directory would need to contain *every* possible memory block that might ever be placed in that particular slice (but there are ***many*** such prospective memory blocks).

To resolve this matter, a key ***insight*** is that the entries which are ***not*** present in the last level cache (LLC) (or otherwise not in any of the other caches on the chip) are also correspondingly ***not*** shared by any of the tiles, therefore it is unnecessary to maintain this information anywhere in the chip in the first place.

Therefore, a **partial directory** is used accordingly.
  * Rather than maintaining an entry for ***every*** memory block, instead the partial directory has a ***limited*** number of entries.
  * Furthermore, entries are only allocated in this limited directory for those cache blocks which have at least ***one*** presence bit (cf. Lesson 19) set to value `1` (i.e., only those blocks which may be present in at least ***one*** of the private caches in that particular tile).
    * Therefore, for a cache block which is known to be ***absent*** in both the level 1 (L1) and level (L2) caches, but rather the cache block is only present in either the last level cache (LLC) or in main memory, it is otherwise unnecessary to maintain a directory entry for such a cache block (i.e., implicitly, the corresponding "entry" for such a block would be the trivial case of all `0` presence-bit values).

However, even with such a partial directory, upon many such allocations, eventually the directory entries will be "exhausted"; so, then, how to resolve this issue?

### 10. On-Chip Directory Quiz and Answers

<center>
<img src="./assets/22-019A.png" width="650">
</center>

Given that the on-chip partial directory will eventually run out of entries, what is a possible resolution measure?
  * Replace an existing entry (e.g., via least-recently used [LRU]replacement policy, cf. Lesson 12)

***Explanation***:

The resolution is exactly the same to that seen previously when dealing with a full cache (cf. Lesson 12): Simply use a corresponding replacement policy accordingly (e.g., least-recently used [LRU]).

### 11. On-Chip Directory: Part 2

<center>
<img src="./assets/22-020.png" width="650">
</center>

Therefore (cf. Section 8), when the partial directory runs out of directory entries, then the appropriate resolution measure is to simply select an entry for consequent replacement via corresponding replacement policy (cf. Lesson 12), e.g., least-recently used (LRU).

Let `E` denote such an entry identified for replacement (i.e., to be replaced by a new entry). The new entry will be placed with a presence bit set to `1`, however, how should entry `E` (which may already have other presence bits set at this point) be correspondingly handled?

To resolve this, for every presence bit that is set in entry `E`, a corresponding ***invalidation*** must be sent to all applicable caches (i.e., those for which presence bits are set to `1`). By the end of this, all of the presence bits will be set to `0` in entry `E`, at which point entry `E` can be safely ejected from the cache (along with the corresponding directory entry), thereby making room for placement of the new entry accordingly.
  * Observe that in this scenario, invalidation is not occurring with respect to coherence, but rather due to the limited capacity of the partial directory itself. Accordingly, this constitutes yet another distinct type of **cache miss**, one which is otherwise unrelated to either coherence, compulsory, capacity, or conflict (cf. Lesson 19). (This type of miss is not "named" per se, but it is a distinctly different type of cache miss nevertheless.)

## 12-15. Many-Cores Challenges: Part 4

### 12. Introduction

<center>
<img src="./assets/22-021.png" width="650">
</center>

Returning to the challenges present in many-cores processors (cf. Section 2), recall (cf. Section 3) that there are indeed solutions to managing the increased on-chip coherence traffic as the number of cores grows via corresponding scalable on-chip networks supported by directory coherence.

Furthermore, recall (cf. Section 6) that there are also solutions to managing the increased off-chip traffic as the number of cores grows via a corresponding large, shared distributed last level cache (LLC).

Furthermore, recall (cf. Section 9) that there are also solutions to managing the exceedingly large coherence directory (resulting from the scalable on-chip network) as the number of cores grows via corresponding distributed partial directory.
  * Recall (cf. Section 9) that the distributed partial directory does not maintain information for every possible block in memory, but rather the distributed partial directory only maintains information for a limited number of blocks (i.e., those having non-zero presence bits set) via corresponding replacement policy, and invalidates on-chip caches on such replacements.

However, there is still another problem: The **power budget** available for the overall chip (e.g., `100 W` total) must be split among the cores, but as the number of cores increases, the corresponding power budget per core decreases.
  * Consequently, the available frequency and voltage per core decreases accordingly. As a result, given a single-threaded program, its performance actually ***decreases*** with increasing cores (i.e., the equivalent per-core power budget scales down proportionally)!

### 13. Multi-Core Power and Performance

<center>
<img src="./assets/22-022.png" width="650">
</center>

First, consider a ***single*** core with a `100 W` total power budget for the entire chip.
  * This power is defined as ${P_1} = c \times {V^2} \times {f_1}$ (where $c$ is a constant)
  * Furthermore, the `100 W` power consumption occurs at a voltage level corresponding to a frequency ${f_1}$ of `3.8 GHz`

Now, consider a system comprised of ***two*** cores, each splitting the equivalent `100 W` total power budget in half (i.e., `50 W` apiece per core).
  * The corresponding per-core power budget is now ${P_2} = {\textstyle{1 \over 2}}{P_1}$ , and therefore the voltage and frequency must both be reduced accordingly
  * Furthermore, since voltage is proportional to frequency (i.e., $P \propto \underbrace {{V^2}}_{{{\left( {V \propto f} \right)}^2}} \times f \propto {f^3}$ ), this implies a corresponding operating frequency of ${f_2} = \sqrt[3]{{{\textstyle{1 \over 2}}}} \times {f_1} = 0.8 \times {f_1}$ , or `3.0 GHz`, a noticeably slower frequency

### 14. Performance vs. Number of Cores Quiz and Answers

<center>
<img src="./assets/22-024A.png" width="650">
</center>

Consider the following distribution of an equivalent single-core execution time relative to the available parallelism (i.e., number of core) for program execution as follows:

| Available parallelism | Percentage of equivalent single-core time |
|:--:|:--:|
| `1` | `20%` |
| `2` | `30%` |
| `3` | `40%` |
| `4` | `10%` |

(Here, for `20%` of the time, only one core can run; for `30%` of the time, two cores can run; and so on.)

Furthermore, suppose the available chip has a total power consumption of `100 W`, which is sufficient to achieve a clock frequency of `5 GHz` if running only a ***single*** core, and the corresponding program execution time is `100 s`.

What is the correspondingly achievable frequency and total execution time (accounting for the corresponding change in frequency) for the following:
  * `2` cores?
    * `4 GHz`, `75 s`
  * `4` cores?
    * `3.2 GHz`, `79.4 s`

***Explanation***:

With respect to frequency, in the case of `2` cores, each core consumes half of the `100 W` total power, or `50 W` per core. Therefore, the corresponding frequency scaling factor (cf. Section 13) is $\sqrt[3]{{{\textstyle{1 \over 2}}}} = 0.8$ , or `0.8 × 5.0 GHz = 4.0 GHz`.

With respect to frequency, in the case of `4` cores, each core consumes a quarter of the `100 W` total power, or `25 W` per core. Therefore, the corresponding frequency scaling factor (cf. Section 13) is $\sqrt[3]{{{\textstyle{1 \over 4}}}} = 0.63$ , or `0.63 × 5.0 GHz = 3.2 GHz`.

***N.B.*** Subsequent determination of the total execution time must account for ***both*** the change in frequency ***and*** the change in level of parallelism. As a reference point, `100%` of execution on the single-core configuration (i.e., parallelism of `1`) takes `100 s` to complete.

With respect to total execution time, in the case of `2` cores:
  * Parallelism is `[0.20 × 1] + [0.80 × (1/2)] = 0.6` if ignoring frequencies, or equivalently `0.60 × 100 s = 60 s`.
    * ***N.B.*** Increased parallelism yields a corresponding ***fractional*** execution time.
  * However, taking frequencies into account, this "unscaled" execution time must account for the corresponding slowdown of the frequency in the case of `2` cores, i.e., `60 s × (5.0 GHz / 4.0 GHz) = 75 s`.

Similarly, with respect to total execution, in the case of `4` cores:
  * Parallelism is `[0.20 × 1] + [0.30 × (1/2)] + [0.40 × (1/3)] + [0.10 × (1/4)] = 0.6` if ignoring frequencies, or equivalently `0.508 × 100 s = 50.8 s`.
  * Additionally, taking frequencies into account, the corresponding total execution time is `50.8 s × (5.0 GHz / 3.2 GHz) = 79.4 s`.

To summarize:

| Configuration | Power per core | Frequency per core | Total program execution time |
|:--:|:--:|:--:|:--:|
| `1` core | `100 W` | `5.0 GHz` | `100 s` |
| `2` cores | `50 W` | `4.0 GHz` | `75 s` |
| `4` cores | `25 W` | `3.2 GHz` | `79.4 s` |

Observe that the execution time of the `4` cores system is slower than that of the `2` cores system (which is the fastest among the three systems in question). Therefore, there is a corresponding balance/optimization in terms of trading off between clock frequency and parallelism.

### 15. Boost the Frequency When No Parallelism is Available

Recall (cf. Section 14) that adding additional cores beyond a certain point may result in a ***slowdown*** if it is otherwise necessary to stay within a ***fixed*** power budget.

<center>
<img src="./assets/22-025.png" width="650">
</center>

However, this is only strictly true if neither the voltage nor the frequency can be adjusted, such that when there is no parallelism available, the frequency might otherwise be boosted for one or two active cores in order to attain the full power budget of the chip at any given time.

In fact, modern processors do this, e.g., Intel's Core i7-4702MQ processor (debuted in Q2 2013), intended for laptops and mobile devices, which is characterized as follows:
  * The specified design power consumption limit is `37 W`
  * The processor chip is comprised of `4` cores, each operating at a "normal" clock frequency of `2.2 GHz`

However, additionally, the processor has a "turbo" clock frequency of `3.2 GHz` when running on only ***one*** core, corresponding to a factor of `1.45×` the normal frequency, or equivalent to a total power consumption of `3×` relative to "normal." But why is this only `3×`, rather than `4×` (i.e., for a corresponding `4` cores processor)?

The reason for this is that the overall chip power consumption is not the only relevant factor here. Additionally, given a relatively large chip with `4` constituent cores (as in the figure shown above), as one such "turbo-clocked" core proceeds to heat up, this heat will consequently spread into the adjacent cores. At an increased power factor of `3×`, the processor is still capable of distributing this heat evenly across the chip, however, beyond this, performance will degrade accordingly.

<center>
<img src="./assets/22-026.png" width="650">
</center>

Another representative example is Intel's Core i7-4771 processor (debuted in Q3 2013), intended for desktop computers, characterized as follows:
  * The specified design power consumption limit is `84 W`
  * The processor chip is comprised of `4` cores, each operating at a "normal" clock frequency of `3.5 GHz`
  * The "turbo" clock frequency is `3.9 GHz`, corresponding to a factor of `1.11×` the normal frequency, or equivalent to a total power consumption of only `1.38×` relative to "normal"
    * With this being a more "standard" processor, it has much better cooling (relative to a laptop processor), and is consequently able to operate at a much higher total power consumption level, however, this also implies a higher baseline operating temperature to begin with, so there is a smaller "temperature headroom" (i.e., staying within the operational limits of the chip) to work with in the first place.

***N.B.*** This trend is fairly typical: Cores designed for relatively low-power devices have more flexibility with respect to "shifting around" (i.e., among cores) this total power budget accordingly, whereas operating closer to the physical limits reduces this "flexibility" accordingly.

## 16-17. Many-Cores Challenges: Part 5

### 16. Introduction

<center>
<img src="./assets/22-027.png" width="650">
</center>

Returning to the challenges present in many-cores processors (cf. Section 2), recall (cf. Section 3) that there are indeed solutions to managing the increased on-chip coherence traffic as the number of cores grows via corresponding scalable on-chip networks supported by directory coherence.

Furthermore, recall (cf. Section 6) that there are also solutions to managing the increased off-chip traffic as the number of cores grows via a corresponding large, shared distributed last level cache (LLC).

Furthermore, recall (cf. Section 9) that there are also solutions to managing the exceedingly large coherence directory (resulting from the scalable on-chip network) as the number of cores grows via corresponding distributed partial directory.
  * Recall (cf. Section 9) that the distributed partial directory does not maintain information for every possible block in memory, but rather the distributed partial directory only maintains information for a limited number of blocks (i.e., those having non-zero presence bits set) via corresponding replacement policy, and invalidates on-chip caches on such replacements.

Furthermore, recall (cf. Section 15) that despite power budget constraints, if it's possible to use "turbo" frequency mode with respect to a single core (when parallelism is not otherwise available for the program in question, i.e., the program is exclusively single-threaded), then this will generally improve "optimal utilization" of this power budget (i.e., faster execution time), subject to physical limitations imposed by cooling requirements.

A final issue to consider is the corresponding ***confusion*** introduced to the operating system when dealing with such many-core processors. This issue specifically applies to systems characterized by any/all of the following features:
  * ***Multi-threading*** (wherein each core can execute several hardware threads apiece)
  * ***multi-cores*** (which share caches)
  * ***multi-chips*** (with each constituent chip itself being a multi-core processor)

### 17. Simultaneous Multi-Threading (SMT) and/or Multi-Cores, and/or Multi-Chips, and/or etc.

<center>
<img src="./assets/22-028.png" width="650">
</center>

Consider a system which combines ***all*** three aforementioned (cf. Section 16) forms of parallelism; note that such devices ***do*** in fact exist "in practice" in the modern landscape.

Such a representative device is characterized as follows:
  * Dual-socket motherboard (containing two multi-core chips)
  * `4` cores per chip
  * Each core supports `2`-way simultaneous multi-threading (SMT)

Insofar as both the ***programmer*** and the ***operating system*** are concerned, this device is characterized by effectively `2 × 4 × 2 = 16` available execution threads at any given time (i.e., `16` single-threaded programs, one multi-threaded program using up to all `16` threads, or some combination thereof). A relatively simple operating system treats all `16` of these threads (denoted by magenta in the figure shown above) as equivalent "cores" (denoted by teal boxes/squares in the figure shown above).

However, this can give rise to a ***problem***. Consider the situation whereby `3` threads are currently available (denoted by green in the figure shown above).
  * The operating system simply maps these `3` threads to equivalent "cores," being otherwise oblivious to the distribution of these threads among the two physical chips, as well as among each chips four constituent cores.
  * Therefore, the corresponding assignment of these threads by the operating system may be suboptimal with respect to cache utilization and other such factor. In this particular case, a ***smarter*** policy would be to distribute the `3` threads among different chips, and on different cores within a given chip. This minimizes competition for resources (e.g., cache capacity).

Therefore, in general, an "optimal" mapping would prioritize the following:
  * Map one thread per chip (to maximize available total cache-capacity utilization), until all chips have been assigned
  * Then map one thread per core within a given chip (to minimize coherence and traffic-related issues), until all cores have been assigned
  * And only then commence mapping multiple threads per core, if necessary

However, in order to accomplish this, the operating system must be aware of the constituent hardware accordingly.
  * ***N.B.*** Most modern operating system (e.g., Windows, Linux, macOS, etc.) ***are*** indeed capable of determining this and consequently improving/maximizing utilization of these thread contexts accordingly during program execution.

## 18. Many-Cores Challenges: Part 6

<center>
<img src="./assets/22-029.png" width="650">
</center>

As an overall recap, returning to the challenges present in many-cores processors (cf. Section 2), recall (cf. Section 3) that there are indeed solutions to managing the increased on-chip coherence traffic as the number of cores grows via corresponding scalable on-chip networks supported by directory coherence.

Furthermore, recall (cf. Section 6) that there are also solutions to managing the increased off-chip traffic as the number of cores grows via a corresponding large, shared distributed last level cache (LLC).

Furthermore, recall (cf. Section 9) that there are also solutions to managing the exceedingly large coherence directory (resulting from the scalable on-chip network) as the number of cores grows via corresponding distributed partial directory.
  * Recall (cf. Section 9) that the distributed partial directory does not maintain information for every possible block in memory, but rather the distributed partial directory only maintains information for a limited number of blocks (i.e., those having non-zero presence bits set) via corresponding replacement policy, and invalidates on-chip caches on such replacements.

Furthermore, recall (cf. Section 15) that despite power budget constraints, if it's possible to use "turbo" frequency mode with respect to a single core (when parallelism is not otherwise available for the program in question, i.e., the program is exclusively single-threaded), then this will generally improve "optimal utilization" of this power budget (i.e., faster execution time), subject to physical limitations imposed by cooling requirements.

Lastly, the corresponding ***confusion*** introduced to the operating system when dealing with such many-core processors can be mitigated, provided that the operating system(s) in question is/are hardware-aware with respect to the following:
  * ***Multi-threading*** (wherein each core can execute several hardware threads apiece)
  * ***multi-cores*** (which share caches)
  * ***multi-chips*** (with each constituent chip itself being a multi-core processor)

## 19. Lesson Outro

This lesson has examined the characteristics of modern and (presumably) future many-cores processors.

This concludes the third, and final, part of Prof. Prvulovic's course on high-performance computer architecture (CS 6290), which spanned the following topics:
  * The internals of the modern out-of-order processor
  * The memory hierarchy of this modern processor
  * The intricacies of multi-core and multi-threaded execution on this modern processor
