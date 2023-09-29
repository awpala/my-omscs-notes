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
