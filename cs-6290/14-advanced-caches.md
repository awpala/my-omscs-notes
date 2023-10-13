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

Additionally, `Hit Time` is affected by having to access the **translation look-aside buffer (TLB)** prior to accessing the cache itself.

<center>
<img src="./assets/14-010.png" width="650">
</center>

Recall (cf. Lesson 13) that the processor starts out with the **virtual address**, as in the figure shown above. From there, the following ***sequence*** occurs:
  * A portion of the virtual is used to index into the translation look-aside buffer (TLB) to determine the **frame number**
  * The **page offset** of the virtual address is then combined with the frame number to reconstitute the **physical address**
  * The physical address is used to access the data in the **cache**

Therefore, if the translation look-aside buffer (TLB) requires one cycle and the cache requires an additional cycle, then two cycles are required for the processor to obtain the cache data from the virtual address.

Such a cache that is accessed via a physical address in this manner is called a **physically accessed cache**, **physical cache**, or **physically indexed, physically tagged (PIPT) cache**.
  * The overall **hit latency** of such a cache is effectively comprised of the translation look-aside buffer (TLB) hit latency and the cache hit latency.

## 6. Virtually Accessed Cache

<center>
<img src="./assets/14-011.png" width="650">
</center>

The overall hit latency of the cache can be improved using a **virtually accessed cache**. In a virtually accessed cache (as in the figure shown above):
  * The virtual address is used to access the data via the cache (cf. Section 5), via corresponding **cache hit**
    * In this case, there is no need to access the translation look-aside buffer (TLB) immediately prior to accessing the data
  * Otherwise, on a **cache miss**, the virtual address is used in tandem with the translation look-aside buffer (TLB) to determine the physical address, in order to bring that corresponding data into the cache

Therefore, the ***advantages*** of using a virtually accessed cache over a corresponding physically accessed cache (cf. Lesson 12) are as follows:
  * `Hit Time = Cache Hit Time`, i.e., the `Hit Time` is comprised solely of the `Cache Hit Time`, with no additional translation look-aside buffer (TLB) latency added
  * There is correspondingly no translation look-aside buffer (TLB) access required on cache hits, thereby reducing energy usage accordingly

With these advantages, why even bother with physically accessed caches at all, then? This is due to the following inherent ***problems*** with (exclusively) virtually accessed caches:
  * In addition to containing the translation for the physical address, the translation look-aside buffer (TLB) also contains the **permissions** required to determine whether it is permissible to read, write, or execute certain pages.
    * Therefore, even though the physical address produced by the translation look-aside buffer is not strictly required in a (fully) virtually accessed cache (i.e., in order to access the corresponding cache data), in practice, it still necessary to access the translation look-aside buffer (TLB) to determine these permissions in a *real* processor (i.e., even on cache hits).
  * A bigger problem arises by virtue of the fact that a given virtual address is ***specific to*** a particular process running on the system. 
    * Correspondingly, if running one process and filling the cache with its data, once another/separate process begins to run, then that other process will have virtual addresses which may potentially overlap with the virtual addresses of teh previous process, thereby creating ambiguity with respect to the intended data for each respective process. To resolve this matter, the translation look-aside buffer (TLB) additionally contains different translations for each corresponding process, mapping unambiguously to the respective physical-memory addresses.
    * Conversely, in a (fully) virtually accessed cache, it would otherwise be necessary to ***flush*** the cache on context switch between the processes (i.e., removing all the cache data for a given process immediately prior to the context switch), thereby introducing bursts of cache misses on each such context switch. For reference, context switches occur among processes on the order of 1 millisecond, which while relatively large with respect to a typical clock (cf. 1-10 nanoseconds per cycle), bear in mind that the cache can be quite large, and correspondingly may nevertheless generate many such cache misses in tandem with such "re-heating" of the cache on context switch.

## 7. Virtually Indexed, Physically Tagged (VIPT) Cache

<center>
<img src="./assets/14-012.png" width="650">
</center>

To resolve the issues which are inherent to the (fully) virtually accessed cache (cf. end of Section 6), the **virtually indexed, physically tagged (VIPT) cache** was devised. The virtually indexed, physically tagged (VIPT) cache combines the advantages of the two types of caches.

<center>
<img src="./assets/14-013.png" width="350">
</center>

In a virtually indexed, physically tagged (VIPT) cache, the virtual address is comprised of the **cache offset**, **index bits**, and **tag region** (as in the figure shown above), however, the tag region is not used in the initial lookup. Instead, the index bits from the virtual address are used to locate the corresponding set in the cache. The **valid bits** of this cache set are then read accordingly.

<center>
<img src="./assets/14-014.png" width="350">
</center>

Meanwhile, the **page number** from the virtual address is used to access the **translation look-aside buffer (TLB)** in order to determine the corresponding physical-address **frame number**. With the **physical address** obtained in this manner, the corresponding **tag check** is performed via this physical address (i.e., *not* via the virtual address).

Correspondingly, the nomenclature "virtually indexed, physically tagged" is now readily apparent:
  * The ***index bits*** derive from the ***virtual address***
  * The ***tag bits*** derive from the ***physical address***

Downstream from these steps, the steps proceed as usual (i.e., a cache hit vs. cache miss is determined, etc.).

So, then, what are the corresponding ***advantages*** of a virtually indexed, physically tagged (VIPT) cache?
  * Since the respective upstream cache array and translation look-aside buffer (TLB) accesses generally proceed ***in parallel*** in this manner, if the translation look-aside buffer (TLB) access is sufficiently fast (which is typically the case, given its small size), then correspondingly `Hit Time = Cache Hit Time` (i.e., the latency component contributed by the translation look-aside buffer [TLB] to the `Hit Time` is negligible relative to the more prominent/bottlenecking cache hit time).
    * This is reminiscent of the **virtually indexed, virtually tagged (VIVT) cache**.
  * Additionally, in a virtually indexed, physically tagged (VIPT) cache, it is ***not*** necessary to flush on context switch, because if the process is switched (i.e., with virtual addressed correspondingly mapping to ***different*** physical addresses), then the cache content is effectively being checked against the actual ***physical*** addresses. Therefore, even if another process maps to the ***same*** cache set (i.e., via virtual address), it will still otherwise map to another set of corresponding physical addresses by virtue of the different/distinct tags.
    * This is reminiscent of the **physically indexed, physically tagged (PIPT) cache**.

Recall (cf. Lesson 13) that **aliasing** can occur when multiple virtual physical addresses in the same address space map to the ***same*** physical address (furthermore, since virtual addressing is performed with respect to cache access, then these addresses may ultimately occur in ***different*** locations within the constituent cache array, with mutually exclusive read/writes to these otherwise disparate/distinct cache locations). So, then, is this a concern with respect to virtually indexed, physically tagged (VIPT) caches?
  * As it turns out, there are ***no*** such aliasing issues with respect to virtually indexed, physically tagged (VIPT) caches, provided that the cache is ***sufficiently small***, a direct consequence of the ***index bits*** themselves. This in turn ensures **correctness** of the cache operation itself.

The concept of aliasing in the context of virtually indexed, physically tagged (VIPT) caches is further examined in the next section.

## 8-9. Aliasing in Virtually Accessed Caches

### 8. Introduction

We have seen (cf. Section 7) that virtually accessed caches can ***overlap*** the latency of the translation look-aside buffer (TLB) lookup and the cache lookup. However, virtually accessed caches have an inherent issue called **aliasing**.

<center>
<img src="./assets/14-015.png" width="650">
</center>

The issue of aliasing occurs because in the virtual address space of a given application (as in the figure shown above), one page from a given process (e.g., `A`) can map to some part of the physical address space (e.g., via Linux function `mmap()`, or equivalent system call in other operating systems, in order to map part of a file to appear within range of addressable memory, `A`), while another page from a different process (e.g., `B`) can also map to the ***same*** physical address (e.g., via `mmap()` on the same part of the same file to another address, `B`).

The result of this is two (or more) virtual addresses referring to the ***same*** physical-memory location.

To see why this is problematic in a virtually accessed cache, consider the following two addresses:
  * `A = 0x12345000`
  * `B = 0xABCDE000`

Furthermore, let the cache be characterized by the following:
  * `64 KB` in size
  * direct-mapped
  * `16 bytes` block size
  * virtually accessed

For this `16 byte` block size, there is a `4 bit` offset (via least-significant bit), along with the next-twelve-least-significant bits indexing into the cache itself, i.e.,:

```
          index bits
         |   |
              offset bits
             | |
A: 0x1234|500|0
B: 0xABCD|E00|0
```

***N.B.*** `64 KB / 16 bytes = 4 KB` entries in the cache, requiring `log_2(4 KB) = log_2(2^12) = 12 bits` index bits required to identify the index uniquely. Also note that with respect to the offset bits, `0x0` (hex) is equivalent to `0000` (binary).

<center>
<img src="./assets/14-016.png" width="350">
</center>

Consider when the processor writes a value of `16` to `A` (as in the figure shown above), i.e., operation `WR A, 16`. It first decomposes the virtual address and indexes into the cache via index bits `0x500`. If a ***cache miss** occurs, then the correspondingly mapped data is first fetched from the physical memory, which in turn returns a value (e.g., `4`).

<center>
<img src="./assets/14-017.png" width="350">
</center>

Once the cache block is fetched, the corresponding value `16` is placed there, and the cache-block content is updated accordingly (as in the figure shown above).
  * ***N.B.*** If we assume that the cache in question is a write-back cache, then this value of `16` simply stays there as written.

Now, consider what occurs when attempting to read `B`, i.e., operation `RD B` (as in the figure shown above). On indexing into the cache via index bits `0xE00`, and assuming a cache miss similarly occurs, then due to the absence of the data in the cache, the data is first fetched from physical memory, which returns the value `4`.

This results in a corresponding ***problem*** that will not be simply a consequence of cache misses: Whenever subsequently writing to `A` and reading from `B`, neither process ends up effectively "sharing" the data as otherwise would be sensible to do.
  * Ideally, since `A` and `B` are actually sharing the ***same*** data, on write to cache by `A`, `B` should subsequently read the same corresponding data.

This problem consequently results in ***incorrect execution*** whenever such a mapping occurs (e.g., via `mmap()`), which is unfortunately a legal operation in most operating systems; therefore, virtually accessed caches require additional support to handle this scenario (e.g., on write to any given virtual-memory location, it is necessary to perform a check for aliases or different versions of the same physical data in the cache, and then either invalidate them, remove them from the cache, or update them accordingly to reflect the new value).
  * Such ancillary operations are correspondingly expensive to implement and to perform, and ultimately defeat the purpose/advantage of virtually accessed caches in the first place, which inherently attempt to minimize latency by reducing (or eliminating) translation steps.

To summarize, virtually accessed caches are desirable because they allow to overlap translation look-aside buffer (TLB) latency with cache latency, however, they introduce this aliasing problem which preclude their practical use otherwise (i.e., due to correspondingly introduced complication in their implementation).

### 9. Virtually Indexed, Physically Tagged (VIPT) Cache Aliasing

Now, consider **aliasing** in the context of **virtually indexed, physically tagged (VIPT) caches** (cf. Section 7).

<center>
<img src="./assets/14-018.png" width="650">
</center>

Given a **virtual address (VA)** (as in the figure shown above), it has the following constituent ***regions*** used for cache access:
  * **offset bits**
  * **index bits**
  * **tag region** (used if the cache is accessed)

In a virtually indexed cache, the index bits of the virtual address are used, while the remainder is derived from the **physical address (PA)**.

To form the corresponding **physical address (PA)**, the least-significant bits of the virtual address comprise the **page offset**, while the remaining tag-region bits comprise the **page number**. The page number of the virtual address is correspondingly translated to the **frame number** of the physical address, while the page offset of the virtual address correspondingly comprises the least-significant bits of the physical address.

Conversely, in a **virtually indexed, physically tagged (VIPT) cache**, the physical-address **tag** originates from the physical address' frame number, while the index derives from the index bits of the virtual-address **offset bits** (to promote fast access).
  * It is additionally noteworthy that the index bits are located closely to the least-significant offset bits of the virtual address, and that the page offset has a fixed number of bits. Consequently, for a small cache, the index bits may ***all*** derive from the virtual address's page offset, which is effectively equivalent to using the least-significant bits of the physical address itself (as demonstrated/delineated visually per corresponding alignment in the figure shown above).
  * Therefore, in this manner, despite indexing via the virtual address, effectively the ***equivalent*** index is being used as if it were being accessed via the physical address itself, which in turn ***resolves*** the aforementioned issue of aliasing. This is because the virtual address's page number (having distinct a page number mapping to corresponding physical address's frame number) only differs with respect to this page number, while still maintaining the ***same*** page offset for the same data; furthermore, since only the index-bits region of the page offset is pertinent (provided that the cache is sufficiently small), it will generally ***always*** map to the ***same*** location in physical memory (i.e., corresponding to the appropriate cache set).

To recap, in a virtually indexed, physically tagged (VIPT) cache, there is ***no aliasing*** if all of the index bits derive from the virtual address's page offset (i.e., these are effectively the same index bits that would otherwise derive from the least-significant bits of the physical address in a corresponding physically indexed cache).
  * This is a very desirable property, with the ***caveat*** that is requires the cache to be sufficiently small to allow this uniqueness property to exist in the first place (i.e., unique addressability via the virtual address's page-offset index bits).

For example, given a cache characterized by a `4 KB` page size, this yields a page offset of `12 bits` (`log_2(4 * 2^10) = log_2(2^12) = 12`). Furthermore, given a `32 B` block size for this cache, this correspondingly yields a block offset of `5 bits` (`log_2(32) = log_2(2^5) = 5`). Given these constraints, this yields a `7 bits` index region (i.e., `12 - 5`), thereby limiting the size of the corresponding cache sets to `128` (i.e., `2^7`).
  * If the number of cache sets were to exceed `128`, then the index bits would necessarily "spill over" into the least-significant-bits region of the page number, which correspondingly would impact the unique mapping to the frame number itself (thereby re-introducing potential aliasing, which was intended to be eliminated in the first place).

## 10. Virtually Indexed, Physically Tagged (VIPT) Aliasing Avoidance Quiz and Answers
