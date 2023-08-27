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
