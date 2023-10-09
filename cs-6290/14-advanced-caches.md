# Advanced Caches

## 1. Lesson Introduction

<center>
<img src="./assets/14-000.png" width="250">
</center>

This lesson will examine more-advanced topics in caching (e.g., multi-level caches and various caching optimizations). These are very important to achieve:
  * good overall performance (one thumb up), and
  * energy efficiency (two thumbs up)!

## 2. Improving Cache Performance

<center>
<img src="./assets/14-001.png" width="650">
</center>

There are many methods for improving cache performance, however, in general they can be grouped into three **categories**, all three having to do with the aforementioned (cf. Lesson 12) **average memory access time (AMAT)**, defined as:

```
AMAT = Hit Time + Miss Rate × Miss Penalty
```

where:
  * `Hit Time` accounts for a cache hit
  * `Miss Rate × Miss Penalty` accounts for a cache miss
    * `Miss Penalty` is the cost per cache miss
    * `Miss Rate` is the frequency of cache misses

Correspondingly, the three principal **methods** to improve cache performance are as follows:
  * Reduce the `Hit Time`
  * Reduce the `Miss Rate`
  * Reduce the `Miss Penalty`

Any combination of these factors will reduce the average memory access time (AMAT), thereby improving overall performance accordingly when the processor accesses the cache.

## 3. Reduce `Hit Time`

<center>
<img src="./assets/14-002.png" width="650">
</center>

Let us first examine the methods that attempt to reduce the `Hit Time`.

Some of these methods are fairly obvious:
  * Reducing the cache size
    * However, this has a correspondingly negative impact on `Miss Rate` (i.e., due to the increased penalty paid by cache misses), thereby potentially netting out no improvement (or perhaps even worsening) of the average memory access time (AMAT).
  * Reducing the cache associativity, thereby increasing the cache's speed (i.e., by reducing the search area for a given block on cache hit)
    * However, this similarly can have a potentially negative impact, by similarly adversely affecting `Miss Rate` due to increased cache misses (i.e., due to increased conflicts and consequent ejections among the cache blocks, relative to a "peaceful coexistence" in an otherwise more-associative cache).

Additionally, there are more complex methods for reducing the `Hit Time`:
  * Overlapping the cache hit with another cache hit
  * Overlapping the cache hit with a translation look-aside buffer (TLB) hit
  * Optimizing the lookup for the ***common case*** (without otherwise sacrificing too much for the less common cases)
  * Maintaining the replacement state in the cache more quickly (i.e., on cache hits, if state must be updated for some later replacements, then this can be done more efficiently/optimally accordingly)

***N.B.*** These latter methods will be examined in turn in the subsequent few sections of this lesson.

## 4. Pipelined Caches

<center>
<img src="./assets/14-003.png" width="650">
</center>

One way to speed up the `Hit Time` is to overlap one cache hit with another. This can be achieved, for example, by **pipelining** the cache.

If the cache requires multiple cycles to be accessed, then the following ***situations*** can arise:
  * The cache access occurs in cycle `N`, and it is a cache hit
  * A subsequent cache access occurs in cycle `N + 1`, and it is also a cache hit
    * In a ***non-pipelined*** cache, this subsequent access must ***wait*** until the previous cache access finishes using the cache, which itself requires several cycles to complete.

In the scenario described (i.e., a non-pipelined cache), the `Hit Time` is consequently defined as follows:

```
Hit Time = Actual Hit + Wait Time
```

where the `Wait Time` is the overhead incurred due to the inability to access the cache until the previous cache access is completed.

In this situation, pipelining the cache in order to promote immediately-successive cache accesses therefore would improve the overall `Hit Time` (i.e., by correspondingly minimizing the `Wait Time`).

<center>
<img src="./assets/14-004.png" width="450">
</center>

It may sound straightforward to pipeline a cache, by simply dividing into stages (e.g., 3). However, that begs the question: How to "split" what amounts to effectively a read from a large array (as in the figure shown above), which is essentially what the cache itself inherently is?

<center>
<img src="./assets/14-005.png" width="550">
</center>

Recall (cf. Lesson 12) that a **cache access** consists of an **index region** of an address to locate the **cache set** (as in the figure shown above).

<center>
<img src="./assets/14-006.png" width="550">
</center>

On reading out of the **tag regions** and **valid bits** corresponding to the **blocks** in the cache set (as in the figure shown above), comparison of the corresponding tag regions and valid bits is performed to identify whether a **cache hit** occurs.

<center>
<img src="./assets/14-007.png" width="550">
</center>

On comparison/combination, it is determined whether a cache hit occurs, and where it resides within the cache block (as in the figure shown above).

<center>
<img src="./assets/14-008.png" width="600">
</center>

The corresponding cache-hit data is read out and combined with the **offset** in order to select the corresponding region of the cache block, thereby producing the requested output to send to the processor.

<center>
<img src="./assets/14-009.png" width="600">
</center>

On example of a pipelined cache access is as in the figure shown above, comprised of the following ***stages***:
  * ***Stage 1*** (magenta in the figure shown above) → Read the tag regions, valid bits, etc. from the cache array
  * ***Stage 2*** (red in the figure shown above) → Perform comparison of the cache hits and correspondingly locate the data
  * ***Stage 3*** (black in the figure shown above) → Perform the data read and provide it to the processor

As is apparent here, the cache access *can* indeed be pipelined, even if the reading operation itself (i.e., from the cache array) is not as amenable to "discretization" into steps. This is particularly true when the comparison of the cache hits (i.e., via tag regions and valid bits) can be decomposed into a separate step from the data access operation itself, as demonstrated here.

Typically, in a **level 1 (L1) cache**, the `Hit Time` is on the order of 1-3 cycles.
  * A 1-cycle cache by definition does not require pipelining in the first place, whereas 2- or 3-cycle caches can relatively easily pipelined into corresponding two- or three-stage caches (respectively).
  * Correspondingly, L1 caches are typically pipelined in this manner.

## 5. Translation Look-Aside Buffer (TLB) and Cache `Hit Time`
