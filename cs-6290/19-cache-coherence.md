# Cache Coherence

## 1. Lesson Introduction

This lesson will discuss the basics of **cache coherence**. Coherence is needed in order to ensure that when one core writes to its own cache, other cores can also observe these changes when reading out of their own respective caches.

## 2. Cache Coherence Problem

<center>
<img src="./assets/19-001.png" width="650">
</center>

Consider whether **cache coherence** is even necessary in the first place.

From the ***programmer's*** perspective, they expect to observe shared-memory behavior as follows:
  * Core `A` first writes `x = 15` (i.e., to shared memory)
  * When core `B` reads `x`, it "observes" the value `15`

Conversely, from the ***hardware's*** perspective, each core has its ***own*** cache. This is necessary, because a *single* level 1 (L1) cache otherwise would be ***too slow*** and of ***insufficient throughput*** in order to effectively support multi-core processing in this manner.

Therefore, rather than using a single level 1 (L1) cache, each core has a dedicated ***private*** (i.e., per-core) level 1 (L1) cache instead. However, this introduces additional ***complications*** (as in the figure shown above).
  * With both cores (i.e., `A` and `B`) having their own level 1 (L1) caches, when core `A` writes `x = 15`, if a cache miss occurs with respect to its own level 1 (L1) cache, it is consequently fetched from main memory. This fetch correspondingly brings in a new value (i.e., `x = 0`) into core `A`'s level 1 (L1) cache, which is subsequently overwritten with value `15` by core `A`.
  * Subsequently, core `B` attempts to read value `x`. Core `B` accesses its own level 1 (L1) cache, resulting in a cache miss and consequent fetch from main memory. However, since the value from Core `A` has not yet been written back to main memory, the original value (i.e., `x = 0`) is fetched into Core `B`'s level 1 (L1) cache instead, which is the incorrect value (i.e., with respect to the semantics of the program itself).
  * Proceeding in this manner, each core can individually update this value independently many times, prior to subsequent writing back to the shared main-memory information.

This "mismatched" behavior in a shared-memory system is called **incoherence**, i.e., the same main-memory location as viewed from multiple different cores can have disparate/mismatched values (which is *not* intended in such a shared-memory system).

Therefore, in order to avoid this incoherence, a corresponding **cache coherence** strategy is required to mitigate this, i.e., devising in such a manner whereby the entire system effectively behaves as a "single-memory" system.

## 3. Cache Incoherence Quiz and Answers

<center>
<img src="./assets/19-003A.png" width="650">
</center>

Consider a memory location `A` initialized to value `0`.

The system of interest is characterized by three cores, each with a write-back level 1 (L1) cache. These write-back caches do ***not*** provide coherence support (i.e., each level 1 [L1] cache simply behaves as an "independent uni-processor" with respect to its associated core, without otherwise attempting to provide cache coherence for the system at large).

The three cores perform the following sequence of operations (where `←` denotes "read from" and `→` denotes "write to"):

(first, core `0`)
```
LW Reg ← A
Reg++
SW Reg → A
```

(next, core `1`)
```
LW Reg ← A
Reg++
SW Reg → A
```

(last, core `2`)
```
LW Reg ← A
Reg++
SW Reg → A
```

In the final write to memory location `A` (i.e., as performed by core `2`), what is the possible value written? (Select all that apply.)
  * `0`
    * `DOES NOT APPLY`
  * `1`
    * `APPLIES`
  * `2`
    * `APPLIES`
  * `3`
    * `APPLIES`
  * `4`
    * `DOES NOT APPLY`
  * `> 4`
    * `DOES NOT APPLY`

***Explanation***:

The "intended" behavior of the program is such that each subsequent read/write pair performed core-wise will correspondingly update the value in memory location `A` accordingly (i.e., updating from `0` to `3` via corresponding three write operations).

However, a key ambiguity arises in an incoherent system at the "boundaries" (i.e., as one core's write operation occurs, the next core's subsequent read operation occurs).
  * If there is a corresponding "lag" between core `0`'s write and core `1`'s subsequent read, then this will propagate value `1` to core `2` from core `1`, with a consequent update to value `2`.
  * Similarly, if there is a corresponding "lag" in *both* write/read pairs (i.e., across cores `0` to `1`, and `1` to `2`), then core `2` will effectively read initial value `0` and increment this to `1` accordingly immediately prior to writing out.

Furthermore, the value `0` will not "fall through" regardless, as core `2` will still ultimately perform at least one increment operation accordingly. Similarly, the value `4` will be neither reached nor exceeded, as the maximum number of upstream increments (i.e., from initial value `0`) is two additional increments immediately preceding the additional increment performed by core `2`.

## 4. Coherence Definition

<center>
<img src="./assets/19-004.png" width="650">
</center>

Consider now a more formal definition of **cache coherence** (i.e., beyond the simple intuition of "a shared-memory system behaving as if there is only one composite cache").

To fulfill the definition of cache coherence, the system must fulfill the following three ***requirements***:
  * 1 - Read operation `R` on address `X` performed on core `C1` must return the value written by the most recent write operation `W` to `X` on `C1` if no other core has written to `X` in the elapsed time between operations `W` and `R`.
    * This part of the definition implies that if one care is operating on a location all by itself, then its reads should be the most recent writes with respect to that same core. Accordingly, cache coherence therefore implies cache-correct uni-processor behavior with respect to any given core in the system.
  * 2 - If core `C1` writes to `X` and core `C2` reads ***after*** a sufficient time has elapsed, and if there are no other writes in between this elapsed time, then `C2`'s read must return the value from `C1`'s preceding write operation.
    * Conversely, if a subsequent write operation(s) were to have occurred in this elapsed time, then this latter write operation(s) would be regarded as correct/canonical.
    * This part of the definition implies that a "slow-reading" core must eventually resolve to correct/updated values, even if an equivalent uni-processor cache would otherwise simply "stall" on this stale value due to otherwise not requiring its replacement (i.e., with respect to its own operation and corresponding program of execution).
  * 3 - If there are simultaneously write operations to the ***same*** location, then these write operations must be ***serialized*** accordingly: Any two writes to `X` must be ***observed*** as occurring in the ***same*** order from the perspective of ***all*** constituent cores
    * This part of the definition implies that there must be a universal consensus on the ordering of these write operations, with no disagreement among any two (or more) cores (including the currently writing cores) with respect to the ordering in question.
    * ***N.B.*** This third part of the definition does not depend on the second part of the definition, but rather the "slow-reading" core must simply "ultimately" read the intended order of the writes (i.e., the most recent write must be coherently ordered accordingly).

## 5. Coherence Definition Quiz and Answers

<center>
<img src="./assets/19-006A.png" width="650">
</center>

Consider a coherent system comprised of two cores. These two cores simultaneously execute the following programs respectively (where `A` is a shared-memory location):

(core `1`)
```c
A = 1;
while (A == 1):
A = 1;
print("Done 1!");
```

(core `2`)
```c
A = 0;
while (A == 0);
A = 0;
print("Done 2!");
```

***N.B.*** It is not strictly necessary for both cores to execute their respective programs in "lock-step" (i.e., execution of each program is independent of the other).

What is the correspondingly possible output of these programs running on this system? (Select all that apply.)
  * `Done 1! Done 2!`
    * `APPLIES`
  * `Done 2! Done 1!`
    * `APPLIES`
  * `Done 1!`
    * `DOES NOT APPLY`
  * `Done 2!`
    * `DOES NOT APPLY`
  * (no printed output)
    * `DOES NOT APPLY`

***Explanation***:

Each program's blocking condition (i.e., `while` loop) will be "unblocked" by the program running on the other core. However, this will otherwise occur non-deterministically, and thus the order of the printed outputs can occur in either order.
  * Furthermore, note that by the strict (i.e., three-part) definition of cache coherence (cf. Section 4), this will be guaranteed/ensured accordingly, i.e., the sequential writes will ultimately prevent either program individually from never clearing the blocking condition (e.g., one core's program will not "outpace" the other prior to the latter's reaching of this blocking condition, because cache coherence will enforce appropriate state updates, thereby precluding this possibility).

***N.B.*** In an *incoherent* system, all of these would be possible outputs. In particular, there are possible scenarios whereby one or both programs are independently "blocked" on the respective blocking conditions, due to a temporal mismatch in their respective execution, and otherwise independent core-wise cache maintenance/dependence.
  * In this manner, coherence is generally a strict subset of of incoherence, as the "coherent" outputs could also result in the equivalent incoherent system, however, the reverse is not true (i.e., a coherent system will strictly exclude these "incoherent" outputs).

## 6. How to Achieve Coherence?

<center>
<img src="./assets/19-007.png" width="650">
</center>

There are several ***strategies*** for achieving cache coherence, as follows:
  * 1 - Avoid caches altogether
    * This is a trivial solution, as it results in unacceptably poor performance. However, by strict definition, relying solely on main memory as the "shared memory" mechanism is a valid implementation strategy in this context.
  * 2 - All cores share the ***same*** level 1 (L1) cache
    * This is an analogous situation to a shared main memory, albeit with comparatively better performance (relative to relying strictly on main memory). However, this will still result in unacceptably poor performance nevertheless.
  * 3 - Core-wise ***private*** write-through caches
    * In this case, while the main memory does observe all of the writes, it still introduces the ***problem*** of a "lagging" core(s) with respect to long-reading data with respect to this individual cache. In particular, this may eventually outlast subsequent write-through operations to the main memory from the other cores, resulting in an ***incoherent*** system.
  * 4 - Ultimately, the required solution to achieve coherence is to ***force*** read operations in one cache to observe write changes in the other caches (i.e., a given core's private cache cannot simply perpetuate a "local cache hit" indefinitely, without otherwise consulting the shared memory as prompted), which can be accomplished by the following sub-strategies:
    * 4A - **write-update coherence** → ***broadcast*** writes to update other caches (analogously to a write-through cache in a single-core system)
    * 4B - **write-invalidate coherence** → writes ***prevent*** cache hits on other copies of the cache block (i.e., effectively all of these "copies" of the cache block must behave as "cache misses" or otherwise "invalidated" in some such manner)
    * 4C - **snooping** → ***broadcast*** writes on a ***shared bus***, with the corresponding ordering of these writes being observed by the respective cores accordingly
      * ***N.B.*** In this strategy, the shared bus can become ***bottlenecking***.
    * 4D - **directory-based coherence** → each cache block is assigned an ***ordering point*** (called a **directory** in the context of cache coherence), with different ordering points generally being used by different cache blocks (i.e., for a given cache block, all accessed are ordered by the ***same*** entity, but otherwise these entities are different/distinct among the blocks, thereby precluding any possible contention)

Strategies 4A and 4B ensure that subsequent reads receive updated values produced by writes (i.e., the second coherence property, cf. Section 4). Strategies 4C and 4B ensure that all cores observe the same ordering of the writes (i.e., the third coherence property, cf. Section 4).
  * Accordingly, it is necessarily to select one strategy apiece among the pairs 4A/4B and 4C/4D, with all possible combinations being generally useful.

## 7-15. Write-Update and Write-Invalidate Coherence

### 7. Write-Update Snooping Coherence

<center>
<img src="./assets/19-008.png" width="650">
</center>

Consider a two-cache, two-processor system (as in the figure shown above), with each cache comprised of two blocks (with each block comprised of a valid bit [`V`], a tag [`T`], and the cache data). Each cache is connected to the ***same*** shared bus, which in turn is connected to the main memory. Furthermore, assume that both caches are initially empty (with all valid bits correspondingly set to `0`).

<center>
<img src="./assets/19-009.png" width="650">
</center>

The left processor initially reads from shared block `A` (i.e., `RD A`, as in the figure shown above), resulting in a cache miss with respect to the left cache block and consequent request to main memory.

The right cache constantly monitors activity on the bus, however, it is only specifically interested in write operations. Consequently, `RD A` is ignored by the right cache.

<center>
<img src="./assets/19-010.png" width="650">
</center>

On retrieval of the data from main memory, the left cache is updated accordingly (as in the figure shown above).

<center>
<img src="./assets/19-011.png" width="650">
</center>

Next, the right processor performs a write operation on shared block `A` (i.e., `WR A`, as in the figure shown above).

<center>
<img src="./assets/19-012.png" width="650">
</center>

Even on write-through access to main memory from the right processor, a subsequent read from the left processor will yield a "stale" read of `A` (as in the figure shown above). Assume that the left processor reads value `0` accordingly.

<center>
<img src="./assets/19-013.png" width="650">
</center>

Next, the right processor writes value `1` to shared block `A` (i.e., `WR A ← 1` as in the figure shown above). Even if this write operation were to write-through to main memory, this alone does not yield coherent behavior from the left cache, as a subsequent cache hit by the left processor will still yield (incorrect) value `0`.

Consequently, this situation is where **write-update** and **snooping** become significant.

<center>
<img src="./assets/19-014.png" width="650">
</center>

Since a cache miss occurs here with respect to the right cache (as in the figure shown above), the block is requested from main memory, along with an indication of a write operation (along with the corresponding value and address), with a corresponding update to the main memory's value.

Because the left cache is monitoring (i.e., ***snooping***) the bus, it correspondingly detects this activity, and detects this update relative to its own internal cache state (which is now invalidated accordingly).

<center>
<img src="./assets/19-015.png" width="650">
</center>

Correspondingly, a ***write update*** also occurs with respect to the left cache (as in the figure shown above), whereby the corresponding cache-block entry for `A` is updated accordingly to value `1`. Furthermore, subsequent read operations (i.e., `RD A`) in the left cache will read this updated value accordingly.

In this manner, if there are multiple cores, there will not be any disagreement among the ordering of the write operations, as this ordering is enforced by the shared bus (which broadcasts writes sequentially, one at a time).

<center>
<img src="./assets/19-016.png" width="650">
</center>

Now, consider the scenario whereby both caches attempt to write to `A` ***simultaneously*** (as in the figure shown above).

In this situation, the processors must ***arbitrate*** for the shared bus immediately prior to writing to it. This ***arbitration*** process in turn will enforce ordering among these write operations.

<center>
<img src="./assets/19-017.png" width="650">
</center>

Assuming the left core "wins" the arbitration process (as in the figure shown above), the corresponding write operation will be performed first, with each core updating its respective cache appropriately.

<center>
<img src="./assets/19-018.png" width="650">
</center>

Next, the subsequent write operation is performed, with corresponding update of each respective cache accordingly.

In this manner, there is consensus among both caches with respect to the "true" value of `A` at any given time, which is accomplished via corresponding snooping of the common bus (i.e., by the non-writing cache[s]) and subsequent write-update.

### 8. Write-Update Coherence Quiz and Answers

<center>
<img src="./assets/19-019Q.png" width="650">
</center>

Consider a four-core system, with each core comprised of a single-block cache (as in the figure shown above). Furthermore, the system exhibits write-update cache coherence.

First, operation `RD 0x700` occurs on core `0`, resulting in the state as in the figure shown above.

Subsequent operations occur as follows (the previous operation is repeated below as sequence `1` for reference):

| Sequence | Core | Operation |
|:--:|:--:|:--:|
| `1` | `0` | `RD 0x700` |
| `2` | `1` | `RD 0x700` |
| `3` | `2` | `WR 0x700 ← 17` |
| `4` | `3` | `RD 0x700` |

What is the resulting respective states of the four cores on completion of these operations?

***Answer and Explanation***:

<center>
<img src="./assets/19-020A.png" width="650">
</center>

On completion of sequence `1`, the state of the four cores is as in the figure shown above.

<center>
<img src="./assets/19-021A.png" width="650">
</center>

On completion of sequence `2`, the state of the four cores is as in the figure shown above, with core `1` updating its valid bit to `1` accordingly on read.

<center>
<img src="./assets/19-022A.png" width="650">
</center>

On completion of sequence `3`, the state of the four cores is as in the figure shown above. When core `2` writes, it broadcasts the write-through data accordingly, which in turn is snooped by the other caches (i.e., those of cores `0` and `1`) for which valid bits are already set to `1` at this point.

<center>
<img src="./assets/19-023A.png" width="650">
</center>

On completion of sequence `4`, the state of the four cores is as in the figure shown above, wherein all four cores now contain the same block data, which is coherent and consistent with that currently in shared main memory.

### 9. Write-Update Optimization
