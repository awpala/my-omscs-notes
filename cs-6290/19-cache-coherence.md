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
