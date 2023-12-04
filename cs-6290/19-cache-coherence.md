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

### 9. Write-Update Optimization 1: Memory Writes

We will now consider two possible ***optimizations*** of the write-update protocol.

The first optimization involves avoiding memory writes.

<center>
<img src="./assets/19-024.png" width="650">
</center>

Recall (cf. Section 4) that in a **write-update protocol**, ***every*** write in any given processor must be broadcasted to the shared bus and correspondingly update the main memory (as in the figure shown above). However, since main memory is large and slow, it cannot keep up with with these write operations, thereby forming a ***bottleneck*** accordingly with respect to system memory throughput. Therefore, it is necessary to ***avoid*** any unnecessary/superfluous writes accordingly.

Up to this point in the lesson, each cache has been individually regarded as a ***write-through*** cache, however, this is generally harmful to performance of memory (in a single-core system, let alone in a multi-core system).

<center>
<img src="./assets/19-025.png" width="650">
</center>

To resolve this issue (i.e., reduction in memory traffic), a ***dirty bit*** (`D`) is added to each cache block (as in the figure shown above), which in turn "delays" writes to main memory until a dirty block is eventually replaced.

<center>
<img src="./assets/19-026.png" width="650">
</center>

First, consider a read operation in the left cache (i.e., `RD A`, as in the figure shown above), resulting in a corresponding update of the cache accordingly.

<center>
<img src="./assets/19-027.png" width="650">
</center>

Next, a write operation is performed by the right cache (i.e., `WR A, 17`, as in the figure shown above). This write operation is broadcasted on the shared bus, and correspondingly updated in the left cache accordingly.

Furthermore, ***without*** a dirty bit, there would be a corresponding "naive" update to main memory with this value as well (as in the figure shown above). However, this is generally undesirable, as the right cache may perform subsequent write operations, prior to ultimately writing through to the main memory.

<center>
<img src="./assets/19-028.png" width="650">
</center>

Conversely, ***with*** a dirty bit (as in the figure shown above), the value is placed in the right cache, with the corresponding dirty bit set to `1`.

In this context, "dirty" has two ***aspects***:
  * 1 - The main memory is no longer up-to-date, and therefore it must be updated accordingly
    * ***N.B.*** This is the same as for a uni-processor with a write-back cache (cf. Lesson 12)
  * 2 - Additionally, in the write-update protocol, "dirty" entails writing only when there is a necessary write-update event (as discussed subsequently in this section)

<center>
<img src="./assets/19-029.png" width="650">
</center>

Suppose that the left cache instead replaces the block by reading again (as in the figure shown above), issuing a corresponding request over the bus accordingly.

Typically, the main memory would simply provide the value in question (i.e., `A`). However, at this point, the main memory still has the old value (i.e., `6`); only the right cache has the most up-to-date value at this point (as designated by its respective dirty bit value of `1`).

<center>
<img src="./assets/19-030.png" width="650">
</center>

Since the right cache is the only one with the most up-to-date copy of the value for `A` (as in the figure shown above), as per the dirty bit value `1`, the left cache ***snoops*** this value first, with the corresponding cache write-through operation being significantly faster than a read from main memory. The left cache updates its own value accordingly, with appropriate setting of its dirty bit to `0` (i.e., rather than reading from main memory).

<center>
<img src="./assets/19-031.png" width="650">
</center>

Consider a subsequent write operation by the right cache (i.e., `WR A, 20`, as in the figure shown above). Similarly, the value is broadcasted over the bus, and consequently snooped by the left cache (and updated accordingly in the left cache), without otherwise updating the main memory at this point.

<center>
<img src="./assets/19-032.png" width="650">
</center>

However, once the block in the right cache is eventually ***replaced***, then this value is consequently written-through to main memory (as in the figure shown above).

<center>
<img src="./assets/19-033.png" width="650">
</center>

Another interesting situation arises when, given a dirty block in the right cache, a subsequent write operation is performed by the left cache (i.e., `WR A = 30`, as in the figure shown above).

In this case, the left cache broadcasts this write operation onto the bus, and the right cache consequently snoops this write operation, updating its cache block accordingly (along with setting the appropriate dirty bit value of `0`, indicating that the right cache is no longer responsible for writing-through to main memory). Furthermore, the left cache (the current "writer") sets its own dirty bit to `1`, thereby assuming responsibility for subsequent write-through to main memory.

Therefore, many writes can be performed by the caches prior to updating main memory, and the "writing responsibility" can also shift among the caches/cores prior to updating main memory as well. Only when the "last writer" finally replaces its own cache block, does the write-through to main memory occur.

The ***benefits*** of using a dirty bit in a cache-coherent system are therefore:
  * Write-through to main memory only occurs when the cache block is replaced (with many writes occurring prior to this point)
  * Reads from main memory only occur if ***no*** cache block is in the "dirty" state (i.e., dirty bit set to `0`), otherwise the pending-update value is simply snooped from the bus instead

### 10. Write-Update Optimization 2: Bus Writes

The second optimization to the write-update protocol involves minimizing bus writes.

<center>
<img src="./assets/19-034.png" width="650">
</center>

After adding the dirty bit (cf. Section 9), there is substantially less writing-through to main memory. However, in this configuration, the bus still receives ***all*** of the traffic for ***all*** write operations, thereby similarly adding a ***bottleneck*** to the system accordingly (as in the figure shown above).

These bus-broadcasted write operations are necessary, however, because copies of the data must be state-synchronized among the cores/caches. Nevertheless, there is still a possible optimization involving eliminating unnecessary/superfluous writes when there are no other cores pending an updated value to be read.

<center>
<img src="./assets/19-035.png" width="650">
</center>

In order to achieve this additional optimization, a **shared bit** (`S`) is added to each cache block accordingly. This shared bit indicates whether or not the cache block is shared with other cores' cache blocks.

<center>
<img src="./assets/19-036.png" width="650">
</center>

Suppose that the left cache performs a read operation on shared location `A` (i.e., `RD A`, as in the figure shown above). For this purpose, an additional ***line*** is added to the bus. When the read operation goes to main memory, the other core snoops this read operation, and if the other core also contains this same cache block, then the other core pulls this line to state `1` (and setting its own shared bit to `1` accordingly).

In this initial read, the line is not in a shared state, so the left cache simply writes the value `0` in its shared bit.

<center>
<img src="./assets/19-037.png" width="650">
</center>

Next, the right cache performs a write operation on shared location `A` (i.e., `WR A ← 17`, as in the figure shown above). This results in a cache miss and corresponding broadcast of the write operation on the bus. Furthermore, on snooping of the write operation from the right cache, the left cache correspondingly sets its shared bit to `1` in addition to updating its own cache block value accordingly. Additionally, the left cache also pulls the line to state `1`, which is correspondingly recorded as shared bit value `1` in the right cache accordingly as well.

So far, the demonstrated behavior is comparable to that without the additional line and shared bit being present. So, then, what is the benefit of this additional line and shared bit?

<center>
<img src="./assets/19-038.png" width="650">
</center>

The benefit is more discernable when a subsequent write operation is performed by the right cache (i.e., `WR A ← 20`, as in the figure shown above).

The right cache detects a shared bit value of `1`, and broadcasts the write operation accordingly (as before), with corresponding updates in the value in both caches (i.e., `20`).

<center>
<img src="./assets/19-039.png" width="650">
</center>

When the left block performs a subsequent read operation on block `B` (i.e., `RD B`, as in the figure shown above), it adds the new cache block accordingly.

<center>
<img src="./assets/19-040.png" width="650">
</center>

Now, when the left cache subsequently performs a write operation on block `B` (i.e., `WR B = 5`, as in the figure shown above), setting the dirty bit to `1` accordingly. Furthermore, since the shared bit is set to `0`, it simply writes the value locally only (i.e, `B` is not pertinent to any other caches at this point), ***without*** otherwise broadcasting to the bus.

Similarly, if the right cache retrieves block `C` from main memory, it can write values to this block (i.e., `17`, `65`, etc.) independently of the other cores, as long as the shared bit is set to `0`.

Therefore, only shared/common cache blocks require shared (i.e., coherent) read and write operations accordingly. This is particularly advantageous for program-specific data, which otherwise does not require sharing across the cores (e.g., thread-specific stack data).

### 11. Write-Update Optimization Quiz and Answers

<center>
<img src="./assets/19-042A.png" width="650">
</center>

Consider a system comprised of two cores, which uses the write-update protocol for cache coherence.

Furthermore, the program running on this two-core system is comprised of the following (which occur simultaneously on each core):

| Sequence(s) | Core `0` | Core `1` |
|:--:|:--:|:--:|
| `1` | `WR A` | (N/A) |
| `2` | (N/A) | `RD A` |
| `3` through `2001` | repeat sequences `1` and `2` | repeat sequences `1` and `2` |
| `2002` | `REPLACE A` | `REPLACE A` |

Upon conclusion of this program, what are the following resulting counts with respect to shared memory block `A`?

| System operation | Without optimizations | With dirty bit optimization only | With both dirty bit and shared bit optimizations |
|:--:|:--:|:--:|:--:|
| How many bus uses? | | |
| How many writes to main memory? | | |

***Answer and Explanation***:

| System operation | Without optimizations | With dirty bit optimization only | With both dirty bit and shared bit optimizations |
|:--:|:--:|:--:|:--:|
| How many bus uses? | `1001` | `1002` | `1002` |
| How many writes to main memory? | `1000` | `1` | `1` |

In the case of ***no optimization***:
  * Sequence `1` (i.e., `WR A`) uses the bus, as well as writes-through to main memory
  * Sequence `2` uses the bus (i.e., `RD A`), however, it does not write-through to main memory (it is a read miss only)
  * Generalizing in this manner, in the subsequent `999` write/read pairs (i.e., sequences `3` through `2001`), each core `0` write operation (i.e., `WR A`) will add an additional `999` writes-through to main memory and an additional `999` uses of the bus, however, the core `1` read operations (i.e., `RD A`) will neither use the bus nor write to main memory, as these subsequent read operations will ***not*** be cache misses
  * On subsequent replacement of `A` in the respective caches (i.e., sequence `2002`), the state is already up-to-date (i.e., relative to main memory)

In the case of only ***dirty bit optimization***:
  * The write operations on core `0` (i.e., ` WR A`) will be localized to core `0`'s own cache, with only a ***single*** write to main memory on replacement of the cache block (i.e., sequence `2002`)
  * With respect to the uses, all `1000` write operations on core `0` (i.e., `WR A`) will be broadcasted on the bus, however, only the initial read operation on core `1` (i.e., `RD A`) requires reading from the bus (with the subsequent `999` occurring as read hits). Furthermore, the replacement of the cache block for `A` in core `0` incurs an additional use of the bus to read from main memory.

Therefore, overall, there is one additional bus use in the dirty bit optimization, however, this reduces writes dramatically (i.e., down from `1000` to `1`).

Lastly, in the case of both ***dirty bit and shared bit optimizations***:
  * By inspection, on initial write operation on core `0` (i.e., `WR A`), core `0` is the sole accessor of this block (correspondingly setting shared bit to `0` accordingly), however, on subsequent read operation on core `1` (i.e., `RD A`), sharing commences between the cores with respect to memory location `A`. Consequently, the resulting counts are identical to those for "only dirty bit optimization" case.

***N.B.*** The additional shared bit optimization is only effective in bypassing bus accesses when cache blocks are ***isolated*** to specific cores (however, if this *is* the case, then there will be a corresponding dramatic reduction in bus accesses as well).

### 12. Write-Invalidate Snooping Coherence

Recall (cf. Section 6) that there are two snooping-based approaches to coherence: Write-updated (discussed in the previous sections) and write-invalidate. This section will discuss the latter.

<center>
<img src="./assets/19-043.png" width="650">
</center>

Recall (cf. Section 10) the optimized write-update cache coherence system (as in the figure shown above), which includes a dirty bit and a shared bit on each cache block.

A **write-invalidate protocol** involves broadcasting write operations over the bus in order to be detected by the other cores, however, rather than ***updating*** their respective copies of the data, they simply ***invalidate*** their respective cache block entries.

<center>
<img src="./assets/19-044.png" width="650">
</center>

Initially, the left core performs a read operation on shared location `A` (i.e., `RD A`, as in the figure shown above), with corresponding read from main memory.

<center>
<img src="./assets/19-045.png" width="650">
</center>

Next, the right core performs a write operation on shared location `A` (i.e., `WR A ← 1`, as in the figure shown above). This results in a cache miss with respect to the right cache, and consequent broadcast to the bus. However, it is not necessary to write-through to memory with this value (i.e., `1`), but rather the left core snoops the value on broadcast with respect to shared location `A`. Furthermore, in following the write-invalidate protocol, rather than updating the value in the cache block of the left cache, the left cache simply sets the valid bit to `0` for this block, thereby rendering it ***invalidated*** accordingly (i.e., subsequent read attempt will yield a cache miss).
  * ***N.B.*** On each such write-and-broadcast operation, the right cache will have a shared bit value of `0`, because up to this point, all other copies of the value (i.e., in the left cache) will be invalidated in such a manner. Therefore, in general, a write operation will render the writing cache as being in the non-shared (i.e., shared bit value of `0`) accordingly.

<center>
<img src="./assets/19-046.png" width="650">
</center>

Next, the left core performs another read operation on shared location `A` (i.e., `RD A`, as in the figure shown above). In a write-update protocol, the read would simply be a cache hit localized to the left core; however, in a write-invalidate protocol, since the previous value is invalidated, there is a corresponding ***broadcast*** on the bus (i.e., resulting from a cache miss), which is correspondingly snooped by the right cache, since the main memory has not been written-through to yet. Furthermore, since the right cache has a dirty bit of `1`, it will also broadcast the updated value (i.e., `1`) to the bus, resulting in an update of the value in the left cache's block, as well as corresponding update in both cache's shared bits to `1`.

Therefore, with respect to the write-invalidate protocol, observe the following:
  * Similarly to the write-update protocol, localized reads can yield successive cache hits.
  * However, unlike in the write-update protocol, a write-update from another core's cache will invalidate the other cache's value, resulting in a cache miss and consequent read from the bus. Therefore, in the write-invalidate protocol, there is a ***disadvantage*** whereby a read miss occurs on all reading cache whenever another cache writes.

However, the write-invalidate protocol also provides a distinct ***advantage*** whenever writing to the ***same*** block multiple times (as demonstrated in the following sequences).

<center>
<img src="./assets/19-047.png" width="650">
</center>

Next, the right core performs another write operation on shared location `A` (i.e., `WR A ← 2`, as in the figure shown above). The right core broadcasts this value, thereby invalidating the cache block in the left cache (i.e., its valid bit is set to `0`). Furthermore, the shared bit of the right cache is set to `0`.

<center>
<img src="./assets/19-048.png" width="650">
</center>

Next, the right core performs another write operation on shared location `A` (i.e., `WR A ← 3`, as in the figure shown above). Since the previous write operation invalidated the local copy of the data in the left cache, the write cache can simply perform this write operation "locally" with respect to `A` accordingly, without otherwise requiring broadcasting.

Therefore, in such a scenario where the cores alternatively perform successive write operations on a shared memory location, only the ***first*** such write operation must be broadcasted when following the write-invalidate protocol, as subsequent write operations are localized accordingly. Conversely, in the write-update protocol, each such successive write operation requires a corresponding broadcast in order to update the other cache(s) accordingly.

<center>
<img src="./assets/19-049.png" width="650">
</center>

Furthermore, as with write-invalidate (cf. Section 10), an analogous optimization occurs when writing ***simultaneously*** on both cores with respect to two ***different*** shared locations (as in the figure shown above).
  * The left cache can perform localized reads and writes with respect to shared location `B`, and similarly the right cache can perform localized reads and writes with respect to shared location `C`, with neither caches performing necessary broadcasts.
  * In this manner, cache blocks which are isolated to a given core will be "localized," similarly to that which occurs when following the write-invalidate protocol.

Therefore:
  * The write-update protocol generally yields more hits, but results in more broadcasts when repeatedly updating.
  * Conversely, the write-invalidate protocol generally generates misses on all reading caches upon occurrence of an initial write operation, however, it allows to localize writes on subsequent write operations.

Note that in the write-update protocol, the second property of cache coherence (cf. Section 4) is ensured by updating ***all*** of the copies of the data in all caches (and thus on subsequent write operation, all copies are up-to-date, thereby returning the updated value of the most recent write operation). Conversely, the write-invalidate protocol ensures this property by write-invalidating ***all*** other copies of the data, thereby forcing an update of the data to the new version across all other caches.
  * Therefore, in following either protocol, read operations will yield the ***correct*** data in both protocols.

Furthermore, with respect to the third property of cache coherence, in the write-invalidate protocol, this is ensured by snooping on the bus, which orders the write operations according to their successive occurrences on the shared bus.
  * In fact, proceeding in this manner, at any given time, only the ***last*** version of the value effectively "survives" in all of the caches (i.e., a write operation invalidates all other copies otherwise, forcing all of the reading caches to read this last value accordingly).

### 13. Write-Update vs. Write-Invalidate Quiz 1 and Answers

<center>
<img src="./assets/19-051A.png" width="650">
</center>

Similarly to previously (cf. Section 11), consider a system comprised of two cores, with both cores' caches being initially empty.

Furthermore, the program running on this two-core system is comprised of the following (which occur simultaneously on each core):

| Sequence(s) | Core `0` | Core `1` |
|:--:|:--:|:--:|
| `1` | `WR A` | (N/A) |
| `2` | (N/A) | `RD A` |
| `3` through `2001` | repeat sequences `1` and `2` | repeat sequences `1` and `2` |

Upon conclusion of this program, what are the following resulting counts of bus uses with respect to shared memory block `A` in the following configurations:
  * Write-update protocol with shared bit and dirty bit optimizations?
    * `1001`
  * Write-invalidate protocol with shared bit and dirty bit optimizations?
    * `2000`

***Explanation***:

In the optimized write-update protocol, as before (cf. Section 11), there is a broadcast onto the bus on each write operation in core `0` (i.e.,`WR A`), as well as a single bus access on initial read operation in core `1` (i.e., `RD A`) (however, subsequent read operations in core `1` are read hits).

Conversely, in the optimized write-invalidate protocol, the initial write operation in core `0` (i.e., `WR A` via sequence `1`) is a miss, resulting in a bus operation to retrieve the (only) copy of this data from main memory. The subsequent read operation in core `1` (i.e., `RD A` via sequence `2`) yields a miss, which necessitates a read of this data from core `0` via broadcast. Furthermore, on subsequent read/write pairs across the cores with respect to shared location `A` (i.e., sequences `3` through `2001`), the write from core `0` broadcasts an invalidation, and the subsequent read requires a bus access to update the data in core `1`. Therefore, each read/write pair (i.e., `1000` total) will yield two bus uses per pair accordingly.

***N.B.*** With respect to bus usage, write-update is generally more efficient than write-invalidate in the access pattern of one core producing the data continuously while the other core consumes the data continuously. 
  * The write-update protocol involves simply updating the data on write from the writer/producer, while the read can be performed locally with respect to the reader/consumer cache.
  * Conversely, the write-invalidate protocol involves the broadcast of the invalidation on write from the writer/producer, while the reader/consumer incurs successive read misses, thereby necessitating bus access to update the data accordingly.

### 14. Write-Update vs. Write-Invalidate Quiz 2 and Answers

<center>
<img src="./assets/19-052Q.png" width="650">
</center>

Consider the same system from the previous section (cf. Section 13), however, the program running on this two-core system is now comprised of the following (which occur simultaneously on each core):

| Sequence(s) | Core `0` | Core `1` |
|:--:|:--:|:--:|
| `1` | `RD A` | (N/A) |
| `2` | `WR A` | (N/A) |
| `3` through `1000` | repeat sequences `1` and `2` | repeat sequences `1` and `2` |
| `1001` | (N/A) | `RD A` |
| `1002` | (N/A) | `WR A` |
| `1003` through `2000` | repeat sequences `1` and `2` | repeat sequences `1` and `2` |

Upon conclusion of this program, what are the following resulting counts of bus uses with respect to shared memory block `A` in the following configurations:
  * Write-update protocol with shared bit and dirty bit optimizations?
    * `502`
  * Write-invalidate protocol with shared bit and dirty bit optimizations?
    * `3`

***Answer and Explanation***:

<center>
<img src="./assets/19-053A.png" width="650">
</center>

In the optimized write-update protocol (as in the figure shown above), there is a single bus access on initial read operation in core `0` (i.e., `RD A` via sequence `1`) due to read miss, however, due to no obligatory sharing, the subsequent write operation in core `0` (i.e., `WR A` via sequence `2`) is localized to core `0` (i.e., no additional bus access necessary). Furthermore, in the subsequent `499` iterations of this read/write pair (i.e., sequences `3` through `1000`), there are subsequent cache hits.

Next, on initial read operation in core `1` (i.e., `RD A` via sequence `1001`), it reads the data from core `0` via the bus; furthermore, the shared bit is correspondingly set to `1` in both cores' respective caches. In the subsequent write operation in core `1` (i.e., `WR A` via sequence `1002`), there is a broadcast on the bus. Furthermore, each subsequent write operation (i.e., `499` total iterations) accesses the bus in order to broadcast the updated value over to core `0`. Note that this is wasteful, as core `0` no longer requires this data.

<center>
<img src="./assets/19-054A.png" width="650">
</center>

In the optimized write-invalidate protocol (as in the figure shown above), there is a single bus access on initial read operation in core `0` (i.e., `RD A` via sequence `1`) due to read miss, however, due to no obligatory sharing, the subsequent write operation in core `0` (i.e., `WR A` via sequence `2`) is localized to core `0` (i.e., no additional bus access necessary). Furthermore, in the subsequent `499` iterations of this read/write pair (i.e., sequences `3` through `1000`), there are subsequent cache hits.
  * ***N.B.*** This occurs identically/analogously to the corresponding write-update protocol sequences.

Next, on initial read operation in core `1` (i.e., `RD A` via sequence `1001`), it reads the data from core `0` via the bus; furthermore, the shared bit is correspondingly set to `1` in both cores' respective caches. In the subsequent write operation in core `1` (i.e., `WR A` via sequence `1002`), there is a broadcast on the bus, which invalidates the data in core `0` accordingly. Furthermore, each subsequent write operation (i.e., `499` total iterations) do not access the bus, as the other reader (i.e., core `0`) is now invalidated; at this point, the shared location `A` is effectively "private" with respect to core `1`.

***N.B.*** Observe that the write-invalidate protocol is therefore much more efficient if the data usage is restricted to a given core for successive accesses.

### 15. Update vs. Invalidate Coherence

<center>
<img src="./assets/19-055.png" width="650">
</center>

Consider a comparison of write-update vs. write-invalidate protocols with respect to applications as follows:

| Application behavior | Write-update | Write-invalidate |
|:--:|:--:|:--:|
| Burst of write operations to a single address (e.g., repeated calculations to yield a final result) | Each write operation sends an update. This is ***bad***, because ***each*** update results in competition for the bus, thereby adding bus contention and yielding slower write operations (due to increased energy consumption). | Only the ***first*** write operation invalidates, while the subsequent write operations yield cache hits which are localized. This results in ***good*** performance. |
| Write different words to the same cache block (e.g., initializing the cache block) which is shared across cores | An update is sent for ***each*** word that is written. This is ***bad***, because one cache line worth of write operations can result in multiple corresponding updates per write operation. | Only the ***first*** write operation invalidates, while the subsequent write operations yield cache hits which are localized. This results in ***good*** performance. |
| Producer-consumer pairs (i.e., `WR → RD`) (e.g., a buffer used in successive read/write operations) | The producer sends updates on ***each*** data modification, and then the consumer subsequently yields cache hits. In this scenario, the write-update protocol is well suited and yields ***good*** performance accordingly. | The producer invalidates the data, and the consumer consequently yields cache misses (which in turn require retrieving the data again from the producer, and so on). This results in ***bad*** performance. |

Given the complementary strengths and weaknesses of these two protocols, which one is used in practice? Modern processors in fact generally use the ***write-invalidate protocol***. However, the reason for this is not necessarily due to the factors in the table shown above,but rather its advantages are particularly amplified in the ***scenario*** of when a thread moves to another core (i.e., the operating system moves the thread across cores).
  * In this scenario, following the write-update protocol, the old core's cache will continue to be updated until the cache block is replaced in that (now-former) core, even after the thread has been moved to another core. This results in ***horrible*** performance accordingly.
  * Conversely, following the write-invalidate protocol, the ***first*** write to each of the cache blocks will incur a cost to invalidate the old copy, however, subsequent bus traffic will be eliminated. This results in ***good*** performance, as it effectively eliminates subsequent interaction with the old core on movement of the thread to the new core.
    * ***N.B.*** Since such "thread movement" is common in modern processors, the write-update is practically advantageous for this reason accordingly.

Because write-invalidate protocols are commonly used, this will be the primary focus for the remainder of this lesson accordingly.

## 16. Coherence Protocols

### 17. Modified-Shard-Invalid (MSI) Coherence
