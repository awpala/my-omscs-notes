# Cache Review

## 1. Lesson Introduction

In this lesson, we will review **caches**.
  * ***N.B.*** This material should be known already (i.e., course prerequisite), however, it is extremely important to understand the basics of caches before proceeding onto virtual memory (cf. Lesson 13) and other more advanced caching topics (cf. Lesson 14). Therefore, this lesson will correspondingly include *more* detail than is included in a typical "review" lesson.

## 2. Locality Principle

<center>
<img src="./assets/12-001.png" width="650">
</center>

Understanding caches requires an understanding of **locality**. 

The **locality principle** states that things that will happen ***soon*** are likely to be close to things that ***just*** happened.
  * This means that if we know something about the past behavior, then we are likely to be able to guess what will occur soon.

We have already seen the locality principle previously in branch prediction (cf. Lesson 4). Now, we will see this in the context of **caches**.

## 3. Locality Quiz and Answers

<center>
<img src="./assets/12-003A.png" width="650">
</center>

Which of the following are ***not*** good examples of locality? (Select all that apply.)
  * It rained 3 times today → Therefore, it is likely to rain again today
    * `DOES NOT APPLY` - Usually if it rains often, then it will probably continue to rain often (at least for a while)
  * We ate dinner at 6 PM every day last week → Therefore, we will probably eat dinner around 6 PM this week
    * `DOES NOT APPLY` - People tend to eat meals around the same time
  * It was New Year's Eve yesterday → Therefore, it will probably be be New Year's Eve today
    * `APPLIES` -  New Year's Eve occurring on a given day generally means it ***will not*** be New Year's Eve the following day, i.e., New Year's Eve is temporal phenomenon which does ***not*** generally have locality on a timescale of days (this is effectively "anti-locality" in the sense that it "predicts" precisely the *opposite* of what the locality principle implies/suggests)

## 4. Memory References

<center>
<img src="./assets/12-004.png" width="650">
</center>

In computer architecture, we are interested in the locality principle as applied to **memory references**.

If we know that a processor as **accessed** address `X` recently, then the **locality principle** suggests that:
  * It is likely to access the ***same*** address `X` again in the near future → This is known as **temporal locality**
  * It is likely to access addresses proximally to `X` → This is known as **spatial locality** 

Therefore, once a given address is accessed, it is also likely that the ***same*** address will be accessed again soon, along with nearby addresses.

## 5. Temporal Locality Quiz and Answers

<center>
<img src="./assets/12-006A.png" width="650">
</center>

Consider the following code fragment:

```c
int sum = 0;
for (int j = 0; j < 1000; j++)
  sum = sum + arr[j];
```

Which of the following memory locations has ***temporal*** locality in this code? (Select all that apply.)
  * `j`
    * `APPLIES`
  * `sum`
    * `APPLIES`
  * elements of `arr`
    * `DOES NOT APPLY`

***Answer and Explanation***:

Recall (cf. Section 4) that temporal locality indicates that once a memory location is accessed, it is likely to be accessed again.
  * For `j`, this is true because it is used both as the `for` loop's iteration variable and in expression `arr[j]` in each loop iteration. Therefore, after a given iteration, it is generally likely that `j` will be accessed again soon; indeed, on initial access, it will be accessed *many* times (`1000` cumulatively) subsequently thereafter.
  * For `sum`, this is true for similar reasons to `j`, i.e., `sum` is initialized before the loop, and then is subsequently accessed for read and write operations on every loop iteration.
  * Conversely, for any given element of array `arr` (i.e., `arr[j]`), with each element occupying a different (albeit adjacent-to-the-next) memory location, once it is accessed in a given loop iteration, it is no longer accessed again subsequently thereafter.

## 6. Spatial Locality Quiz and Answers

<center>
<img src="./assets/12-008A.png" width="650">
</center>

Returning to the previous example (cf. Section 5), as per the following code fragment:

```c
int sum = 0;
for (int j = 0; j < 1000; j++)
  sum = sum + arr[j];
```

Which of the following memory locations has ***spatial*** locality in this code? (Select all that apply.)
  * `j`
    * `DOES NOT APPLY`
  * `sum`
    * `DOES NOT APPLY`
  * elements of `arr`
    * `APPLIES`

***Answer and Explanation***:

Recall (cf. Section 4) that spatial locality indicates that once a memory location is accessed, it is likely that nearby memory locations will be accessed soon.
  * For `j`, it is accessed repeatedly as the loop continues to iterate, however, this has no implications for spatial locality (i.e., in relation to adjacent memory locations)
  * For `sum`, this is true for similar reasons to `j`, i.e., `sum` is accessed repeatedly as the loop continues to iterate, however, this has no implications for spatial locality (i.e., in relation to adjacent memory locations)
  * Conversely, for any given element of array `arr` (i.e., `arr[j]`), with each element occupying an adjacent-to-the-neighboring-array-element memory location, when a given element `arr[j]` is accessed for a given loop iteration, it is also likely that an adjacent memory location will also be accessed soon (i.e., on the subsequent loop iteration, and so on)

***N.B.*** Incidentally, when this program is compiled, typically it gives rise to some level of spatial locality between `j` and `sum` as well, i.e., both are likely to be allocated on the stack by the compiler in adjacent/nearby memory. Therefore, successive accesses of variables `sum` and `j` will also likely give rise to spatial locality.

## 7. Locality and Data Accesses

Now that we know what locality is, let us see how it is used to improves **data accesses**.

<center>
<img src="./assets/12-009.png" width="650">
</center>

First, consider the example of borrowing books from a ***library***. Here, the library represents a data repository that is ***large*** in size, but ***very slow*** to access (i.e., we must first visit the building, then locate the book within the building, check out the book, return home, etc.).
  * In this scenario, within the library, typically there is a lot of **temporal locality**
    * For example, a student may often need to look up the definition of "locality" very often
  * Furthermore, there is also a lot of **spatial locality** in using the books within the library
    * For example, if a student looks up some type of "computer architecture" definition once, they will also likely look up other computer-architecture-related information as well in the near future

<center>
<img src="./assets/12-010.png" width="650">
</center>

Continuing with the library-based locality and data access example, we have thus far seen that the library is large but very slow to access, and that accesses to this information within the library has ***both*** temporal and spatial locality.

Furthermore, when a ***student*** requires a piece of information from the library, they have the following available options:
  * 1 - Go to the library, find the information once (i.e., during this visit), and then return back home
  * 2 - Borrow the book, so that future accesses to the information in the book are much faster (i.e., available locally at home)
  * 3 - Take all of the books home from the library, and build the library at home

In the first option (round trip to the library), this incurs a lot of ***wasted time***, particularly if performing multiple round-trips to determine the *same* information. Furthermore, this approach does ***not*** benefit from locality (i.e., getting the *same* information one book via ***temporal locality*** and/or getting subject-matter-related information from multiple books via ***spatial locality***).
  * Correspondingly, this is not a typical approach employed by a student, as it is not an efficient way to study the information via library resources.

In the second option (borrowing the relevant book(s) from the library and taking it/them home), the book(s) is now locally available. This approach correspondingly benefits from locality (both temporally and spatially in the context of the particular book(s) in question), while also ***eliminating*** the ***problem*** of the library being large and slow.
  * Correspondingly, this is typically the ***most commmon*** approach to solve this problem. `:)`

The third approach (building the entire library at home) is very expensive, while conferring very little benefit in the process. While it *does* save the inconvenience of traveling round-trip to the library, it does *not* solve the problem of requiring to search among many books, locating them on the shelves, etc.
  * Correspondingly, this is another ill-advised strategy, as it is generally ***desirable*** to have relatively few books of particular interest, rather than to have many books which require slow lookup.

Therefore, just a student is faced with these choices regarding the library, similar principles apply to a **processor** requiring access to **main memory**: Rather than going to main memory to fetch *every* single memory location, instead it will only retrieve the content of the memory locations of particular interest (and only a limited amount of such content, to prevent from degenerating back to slow-access behavior).
  * For this purpose, to store such a selected subset of useful information retrieved from main memory, the processors uses a small repository of such information which is called the **cache** in the context of such memory accesses.

## 8. Cache Quiz Question and Answers

<center>
<img src="./assets/12-012A.png" width="650">
</center>

Let us now apply the concepts discussed previously (cf. Section 7) to an actual cache.

We know that the **main memory** in a computer is large and very slow to access compared to the **processor**'s speed. Furthermore, we know that there is a lot of ***both*** spatial ***and*** temporal locality present in the data accesses (indeed, most programs exhibit a lot of spatial and temporal locality).

Therefore, for an access operation to a main-memory location, which ***one*** of the following options should the processor perform?
  * Go to main memory for every access
  * Have small memory built into the processor core, and store retrieved information there (for faster subsequent access)
    * `CORRECT`
  * Have a huge memory store co-located adjacently to the processor chip (since it is too large to fit on/in the processor chip itself), and store all of the information there

***Explanation***:

These options correspond analogously to the library example seen previously (cf. Section 7). Correspondingly, **caches** overcome the problem of having a large but slow main memory, while also exploiting both spatial and temporal locality.

## 9. Cache Lookups

<center>
<img src="./assets/12-013.png" width="650">
</center>

Now that we know that the **cache** is a small memory section inside of the processor where the processor attempts to find the data first before subsequently proceeding to the main memory (cf. Section 8), let us know consider the **requirements** for a cache, which are as follows:
  * It must be ***fast*** → Therefore, it must be ***small***
    * As a consequence of its small size, ***not*** everything will fit in the cache, and therefore there will be a lot of main-memory locations which are ***not*** accounted for in the cache 

Therefore, when a **processor** wants to **access** some memory, the following can occur:
  * A **cache hit**, whereby that which was sought from the cache has been ***found*** in the cache (i.e., the main-memory location of interest is already ***present*** in the cache, thereby obviating the need to access main memory) → This results in a ***fast*** access operation, as ***desired***
  * A **cache miss**, whereby that which was sought from the cache has ***not*** been found in the cache (i.e., the main-memory location of interest is ***absent*** from the cache, thereby presenting the need to access main memory instead), a direct consequence of the cache's small size → This results in a ***slow*** access operation, which is ***undesirable***
    * When a cache miss does occur, the processor consequently ***copies*** this location from main memory to the cache, to (hopefully) improve locality for the subsequent memory access of this location (i.e., resulting in a cache hit at that point, rather than a cache miss); in this regard, (occassional) cache misses are "necessary" in order to progressively populate the cache with "useful" memory (i.e., that which improves cache hits overall and consequently correspondingly improved locality)

Therefore, once the cache is "warmed up" (i.e., initial cache misses eventually producing subsequent improved cache hits), the slow-memory access caused by cache misses will otherwise occur relatively ***rarely*** as the program continues to execute (i.e., the running programming will predominantly use data from the cache).

## 10. Cache Performance

<center>
<img src="./assets/12-014.png" width="650">
</center>

Let us now consider the properties of a ***good*** (i.e., ***performant***) cache.

### `AMAT`

We want our system to have a good **average memory access time (AMAT)**, which is the access time to memory as seen from the perspective of the **processor**. The `AMAT` is defined as follows:

```
AMAT = Hit Time + Miss Rate × Miss Penalty
```

where:
  * `Hit Time` is how quickly the cache can return the data when a **cache hit** occurs
  * `Miss Rate` is how often a **cache miss** occurs
  * `Miss Penalty` is the penalty per **cache miss**, which is effectively the main-memory access time

In general, an optimal `AMAT` is that which is ***minimized*** (i.e., the lower the better, and ideally `0`). To achieve this, that requires the following:
  * A ***low*** `Hit Time` → This requires a cache which is ***small*** and ***fast***
  * A ***low*** `Miss Rate` → This requires a cache which is ***large*** and/or ***smart***
    * A ***large*** cache is capable of fitting more data, thereby reducing cache misses
    * A ***smart*** cache will be "better-aware" of what data in particular that it should store, thereby also reducing cache misses
  * A ***low*** `Miss Penalty` → The penalty itself (i.e., due to requiring main-memory access) is typically ***very large*** (on the order of tens or even hundreds of processor cycles), but otherwise will be necessarily incurred in the event of a cache miss

Therefore, when designing caches, this entails a ***balance*** between the `Hit Time` and the `Miss Rate`, i.e., small-and-fast vs. large-and-intelligent (respectively), with "intelligence" typically implying a slower operation in order to achieve this.
  * Accordingly, some caches can be extremely small and fast and have a very good (i.e., small) `Hit Time`, but at the expense of having a larger `Miss Rate`.
  * Conversely, other caches can have a relatively large `Hit Time`, but with the corresponding benefit of extremely low `Miss Rate` thereby reducing the overall contribution from the `Miss Penalty` as a result of necessary main-memory accesses

### `Miss Time`

Additionally, `Miss Time` is another characteristic of caches, which is the overall time it takes for a **cache miss** occurs. `Miss Time` is defined as follows:

```
Miss Time = Hit Time + Miss Penalty
```

If a cache miss occurs, resulting in an incurred `Miss Penalty`, which contributes to an effective increase in the `Hit Time`.

`Miss Time` can also be considered/interpreted as the memory-access time elapsed due to the cache miss.

### `AMAT`: Alternately Expressed

Lastly, `AMAT` can also be alternately expressed only in terms of the `Hit Time` and `Miss Rate` (i.e., eliminating `Miss Penalty` from the previous/original equation via `Miss Penalty = Miss Time - Hit Time`) as follows:

```
AMAT = (1 - Miss Rate) × Hit Time + Miss Rate × Miss Time
```

Here, `(1 - Miss Rate)` is how often cache hits occur.

Typically, we use the ***original form*** of the `AMAT` definition, simply because checking the `Miss Time` usually includes checking whether there is a cache hit (`Hit Time`) followed by what must be performed in the event of a cache miss (`Miss Penalty`). Furthermore, it will ***always*** be necessary to have the `Hit Time` on hand, and ***occasionally*** it will also be necessary to have the `Miss Penalty`.

## 11. Hit Time Quiz and Answers

<center>
<img src="./assets/12-016A.png" width="450">
</center>

Having now seen the relationship between `Hit Time`, `Miss Time`, and cache performance (cf. Section 10), Recalling (cf. Section 9) that `Miss Time = Hit Time + Miss Penalty`, now consider the following.

Which of the following properties characterize a ***well-designed*** cache? (Select all that apply.)
  * `Hit Time < Miss Time`
    * `APPLIES`
      * In a well-designed cache, `Hit Time` is significantly lower than `Miss Time` (which encompasses both the `Hit Time` itself as well as the `Miss Penalty`). In fact, this will also generally be true for a poorly designed cache as well (i.e., once a cache miss occurs, the `Miss Penalty` component of the `Miss Time` will predominate).
  * `Hit Time > Miss Penalty`
    * `DOES NOT APPLY`
      * If the `Hit Time` exceeds the `Miss Penalty`, the cache is effectively useless as it is now even slower than the just fetching from main memory directly at that point.
  * `Hit Time == Miss Penalty`
    * `DOES NOT APPLY`
      * For similar rationale to the case of `Hit Time > Miss Penalty`, this is essentially the critical point at which the cache is effectively just equivalent to the main memory itself.
  * `Miss Time > Miss Penalty`
    * `APPLIES`
      * Per definition of `Miss Time`, this is inherently true (regardless of how well or poorly the cache is designed), i.e., `Miss Time - Miss Penalty > 0 ` implies some positive, finite `Hit Time` constituting this difference.

***N.B.*** Essentially, in a well-designed cache, necessarily `Hit Time < Miss Time`. What's more, ideally `Hit Time << Miss Time`, thereby moving performance closer to `Miss Time == Miss Penalty` (which would be the case if `Hit Time` were `0`).

## 12. Miss Rate Quiz and Answers

<center>
<img src="./assets/12-018A.png" width="650">
</center>

Recall (cf. Section 10) that `Hit Rate` can be expressed as `Hit Rate = 1 - Miss Rate`. Given this, which of the following is/are true regarding a ***well-designed*** cache? (Select all that apply.)
  * `Hit Rate > Miss Rate`
    * `APPLIES`
  * `Hit Rate < Miss Rate`
    * `DOES NOT APPLY`
  * `Hit Rate == Miss Rate`
    * `DOES NOT APPLY`
  * `Hit Rate` is almost `1`
    * `APPLIES`
  * `Miss Rate` is almost `1`
    * `DOES NOT APPLY`

***Explanation***:

In a well-designed cache, the `Hit Rate` is ideally as high as possible and correspondingly the `Miss Rate` being as low as possible, because the `Hit Rate` determines how often there is only cache-hit-related latency while the `Miss Rate` is how often full-main-memory latency must be incurred. Therefore, in general, `Hit Rate` should be (much) larger than the `Miss Rate`, and ideally exactly `1` (i.e., a corresponding `Miss Rate` of `0`).

## 13. Cache Size in Real Processors

<center>
<img src="./assets/12-019.png" width="650">
</center>

We have seen already (cf. Sections 10-12) that the cache should be ***fast*** and ***small***, but not too small to a point where it is otherwise unusable (i.e., effectively incapable of storing enough to promote many successive cache hits). So, then, what are the cache sizes which are actually observed in real processors?

There is an inherent ***complication*** in answering this question, due to the fact that real processors typically have ***several*** caches, not just a single one. Therefore, depending on which specific cache is being discussed, the size can vary accordingly.

Consider **L1 (Level 1) caches**, which are the caches that ***directly*** service the read and write requests from the processor (otherwise if a cache miss occurs here, then things get more complicated, because prior to subsequently proceeding to main memory instead the processor proceeds on to the next-level cache(s) first, as well be discussed later in this course). In the case of L1 caches, representative ***sizes*** in recent processors have been in the range of `16 KB` to `64 KB`, which provides the following characteristics:
  * Large enough to get an approximately `90%` cache hit rate (i.e., only correspondingly `10%` or so of all accesses from the processor go beyond this cache)
  * Still otherwise small enough to have a `Hit Time` a hit time commensurately with only `1` to `3` processor cycles (i.e., very short wait time to receive the data back from the L1 cache in a cache hit)
    * cf. Main memory access generally requires on the order of hundreds of processor cycles

## 14. Cache Organization

Now that we have a better understanding of the cache, and approximately how large it must be in real processors (cf. Section 13), let us now consider how the cache is ***organized*** internally.

<center>
<img src="./assets/12-020.png" width="650">
</center>

There are two pertinent ***questions*** to answer to better understand cache organization, which are as follows:
  * 1 - How to determine if there is a cache hit vs. a cache miss?
    * This entails determining what data is available in the cache, and then when the processor gives a requested address to the cache, it must be determined whether that data is or is not present in the cache (furthermore, this must be done very quickly).
  * 2 - How to determine what to eject from the cache once it is full?
    * Eventually, the data will need to be cycled through as the program executes, otherwise the cache will revert from a "hot" state (i.e., predominantly cache hits) back to a "cold" state (i.e., predominantly cache misses).

With respect to the first question (i.e., determining cache hit vs. cache miss), this requires something that is ***very fast***. Typically this involves a table of some sort, which can be quickly indexed via certain address bits from the data; this is depicted in the figure shown above (whose constituent components are described in turn in the subsequent sub-figures).

<center>
<img src="./assets/12-021.png" width="150">
</center>

Conceptually, the cache is a table (as in the figure shown above).

<center>
<img src="./assets/12-022.png" width="450">
</center>

Furthermore, this table is indexed into with some fraction of bits taken from the address of the data (as in the figure shown above), which correspondingly indicate whether there is a cache hit.

<center>
<img src="./assets/12-023.png" width="450">
</center>

The remainder of the information in the **cache entry** (as in the figure shown above, denoted by `Data`) is the pertinent data in the event of a cache hit. The size of this data portion of the cache entry is called the **block size** (or **line size**, since an entry in the cache is also sometimes called a **line**), which specifies how many bytes are in each of these entries.

A block size of `1 byte` means that the entry in the cache is only one byte, and therefore every single byte address will map to a different cache entry within the cache/table. This creates several ***problems***, because usually the processor can issue accesses not only to a single byte, but rather operations can generally operate on multiple bytes simultaneously.
  * For example, `LW` and `SW` both capably access a `4`-byte location, in which case a single-byte access would require four corresponding lookups for different entries in the cache, thereby complicating and slowing down the cache considerably.

Therefore, in general, the block size should be at least sufficiently large enough to perform a ***single*** access in a given cache entry, in order to find all of the data within the ***same*** cache entry most of the time.

The next consideration is **spatial locality**. If there is a cache miss on a given access, then consequently the processor will retrieve an entire block's worth of memory into the cache.
  * If there is no spatial locality, then it should only need to bring in what is currently being accessed.
  * However if there is additionally spatial locality, then ideally it should bring in *more* than simply what is being accessed currently (i.e., the pertinent spatially-related data).

For this purpose, typically block sizes of `32 bytes` to `128 bytes` work well, both from the perspective of their larger-than-a-typical-access size as well as their capturing of much of the spatial locality that exists in programs.

Finally, consider a block size of `1 kilobyte`. In this case, *a lot* of data is fetched from memory every time a cache miss occurs, and if there is insufficient spatial locality then a lot of the additional/extra data will not be used anyways, thereby unnecessarily occupying extra space in the cache.
  * Recall (cf. Section 13) that the cache is only approximately `16 kilobytes` to `64 kilobytes` in real processors, so this is a rather substantial fraction of the overall cache size, and only using it to fill with mostly unused data, no less.

Therefore, it turns out that indeed (at least for L1 caches) the optimal block size is one which is neither too large nor too small, with the optimum occurring around a block size of `32 bytes` to `128 bytes` accordingly.
  * This block size balances the aforementioned tradeoffs while still promoting better overall spatial locality.

## 15. Block Size Quiz and Answers

<center>
<img src="./assets/12-025A.png" width="650">
</center>

Given a cache characterized as follows:
  * Total size of `32 KB`
  * Block size of `64 bytes`

Consider a program which accesses variables `x1`, `x2`, ..., `xN` which are scalar values (i.e., not otherwise elements of the same array), and such that the program itself is characterized by the following with respect to these variables:
  * Lots of temporal locality
  * No spatial locality

Per these specifications, what is the largest `N` (i.e., total count of such variables) that still results in a ***high*** cache hit rate?

***Answer and Explanation***:

When `x1` is brought into the cache, it will be brought in along with an entire block's worth of data (i.e., `64 bytes`), and because there is no spatial locality, that means that none of the other variables will be co-located in that same block. And similarly applies for retrievals of the variables `x2`, ..., `xN`.

Therefore, every time any given variable is accessed, this will require retrieving the full `64 bytes` worth of data into the cache (i.e., the full line). Furthermore, in order to achieve a high cache-hit rate, because each variable (i.e., individually) has a lot of temporal locality, ideally they should *all* remain in the cache. To achieve this, this implies filling the entire cache, i.e.,:

```
32 KB / 64 bytes = 512
```

So, this cache can accommodate up to `512` such variables (i.e., with each occupying its own cache block, despite each variable itself only occupying perhaps `4` to `8` or so of those bytes, depending on the particular data type of the variables in question).

***N.B.*** In order to improve this (i.e., fit more such variables), it is more ideal for them to be more spatially related to improve spatial locality (and correspondingly "better packing" of the cache entries).

## 16. Cache Block Start Address

<center>
<img src="./assets/12-026.png" width="650">
</center>

Now that we know (cf. Section 14) that a cache miss results in fetching an entire block's worth of data from memory, consider where these blocks can actually ***begin*** in memory.

One possible option is that a block can simply begin **anywhere**. For example, consider the case of `64 byte` blocks. In this case, the block may extend from byes `0` through `63`, `1` through `64`, `2` through `65`, and so on; in other words, if the **starting address** of the block can begin anywhere, then these would be the possible blocks fetched in the cache. However, this ***complicates*** matters considerably.

<center>
<img src="./assets/12-027.png" width="250">
</center>

Firstly, recall (cf. Section 14) that the cache is a table, as in the figure shown above. The table is indexed into using some constituent bits of the address being accessed.

<center>
<img src="./assets/12-028.png" width="250">
</center>

However, consider the case where the accessed address is `27`. The ***problem*** here is that the block can actually be found wherever the beginning of the block maps, as in the figure shown above. Block `0` through `63` might map at the top of the block, while block `1` through `64` maps below that, and so on. Therefore, there are ***many*** possible places where target address `27` may reside, by virtue of the fact that each of these blocks may map to these different locations depending on what its beginning address is.

<center>
<img src="./assets/12-030.png" width="250">
</center>

Secondly, there is another complication, which that these blocks overlap. Therefore, block `0` through `63` contains data that overlaps with most of what block `1` through `64` contains, as in the figure shown above (as depicted by the shaded regions, i.e., everything else excluding the unshaded circled region, which is particular to the block `1` through `64`). Now the ***problem*** is that while the situation for ***reading*** is simple (i.e., either "copy" can be read for target address `27`), conversely, when it comes to ***writing***, it must be determined which of the copies exist and then correspondingly write to *all* of them, in order to maintain integrity of the reading operations. Therefore, this problem is similarly undesirable.

Therefore, in order to both reduce the complexity of accessing the cache and eliminate the problem of repeating data in the cache, we will only have caches where the blocks start at **block-aligned** addresses. Thus, for a `64 byte` block, this corresponds to a block extending from `0` through `63`, `64` through `127`, and so on. This ensures that any given byte address can only be found in ***one*** of these possible `64 byte` blocks at any given time, which in turn allows us to simply use some bits of the target address to indicate which of these blocks are being referenced for corresponding indexing into the cache for retrieval. For practical purposes, we will only assume block-aligned addresses for all "reasonable" caches.

## 17. Blocks in Cache and Memory

<center>
<img src="./assets/12-031.png" width="450">
</center>

Now that we know cache blocks must be at aligned memory addresses (cf. Section 16), consider what the memory and cache looks like in terms of blocks (as in the figure shown above).

The **memory** appears as a large array of memory locations, starting at address `0` and incrementing at `4` bytes (i.e., `0`, `4`, `8`, etc.). Furthermore, given a block size of `16 bytes`, this suggests a possible block in memory spanning addresses `0` through `15`, `16` through `31`, etc.

Conversely, the **cache** can be considered as a number of slots where a **block** can fit. In this case, there is just a two-block cache (i.e., the cache is the size of two equivalent memory blocks). Furthermore, analogously to the blocks of data in memory, the cache has corresponding **lines**, which are essentially slots where a block can fit (e.g., the memory block starting at address `0` can be fetched into the cache and placed in corresponding line number `0`).
  * Therefore, to make a precise ***distinction*** between the "space" in a cache where a block can be placed vs. the actual memory content (i.e., the memory "block" itself) that is populated there, this "space" in the cache is correspondingly called a "line" to make this distinction. By corollary, the **line size** and the **block size** are the same to accommodate this accordingly.

## 18. Cache Line Sizes Quiz and Answers

<center>
<img src="./assets/12-033A.png" width="650">
</center>

Which of the following are ***not*** good line sizes in a `2 KB` cache? (Select all that apply.)
  * `1 byte`
    * `APPLIES`
      * This size does not exploit spatial locality. Furthermore, word-size accesses will require accessing multiple blocks, or equivalently multiple lines in the cache. 
  * `32 bytes`
    * `DOES NOT APPLY`
      * This size is suitable for a line size. It exploits spatial localities, is not too large, and is a power of 2, and is therefore amenable to easily locating blocks.
  * `48 bytes`
    * `APPLIES`
      * This size, which suitable in terms of magnitude (i.e., neither too large nor too small), is not a power of 2, and therefore introduces issues with respect to alignment, requiring division by `48` rather than simple integer multiples of `2`.
  * `64 bytes`
    * `DOES NOT APPLY`
      * This size is also suitable for a line size, per similar rationale as for a `32 byte` block size. While this would halve the possible total blocks relative to `32 byte` blocks, this would still provide a lot of blocks fitting in a `2 KB` cache.
  * `1 KB`
    * `APPLIES`
      * This size, while suitable on the basis of being a power of 2, is not a good line size, because it would yield only two total lines in the cache due to its overly large size.

***Additional Explanation***:

<center>
<img src="./assets/12-034A.png" width="250">
</center>

As an example, for a `32 byte` block (as in the figure shown above), the lowest `5` bits of the address indicate the location within the block, while the upper bits of the address correspond to the ***block number*** itself. Therefore, if (in this case) dividing by `32`, these lower-most bits are simply "discarded" to trivially compute the corresponding value. Conversely, a `48 byte` block would require an *actual* computation to determine the equivalent (i.e., rather than simple truncation of the bits).

Therefore, ideally, the block size should be one which:
  * Is a power of 2
  * Exploits spatial locality
  * Is relatively small compared to the cache size (i.e., to allow to fit many lines in the cache)

## 19. Block Offset and Block Number
