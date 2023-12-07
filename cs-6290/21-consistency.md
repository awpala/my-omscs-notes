# Consistency

## 1. Lesson Introduction

This lesson will discuss **memory consistency**, which determines how strictly to order among accesses to different memory locations. This is necessary in order to achieve expected behavior from synchronization-based accesses in a shared-memory program.

## 2. Memory Consistency

<center>
<img src="./assets/21-001.png" width="650">
</center>

Consider **memory consistency**, and how it differs from cache coherence (cf. Lesson 19).

Recall (cf. Lesson 19) that **coherence** defines the order of accesses (i.e., as observed by different threads) to the ***same*** address.
  * Coherence is needed in order to share this data accordingly; otherwise, a thread is able to modify the memory location without regard for the other threads.
  * Furthermore, an ***important consideration*** regarding coherence is that while it defines ordering with respect to the ***same*** address, it does ***not*** otherwise specify behavior pertaining to accesses to ***different*** memory location/address.

Therefore, **memory consistency** addresses this latter consideration, i.e., defining the order of accesses to ***different*** addresses.

However, this begs the question: Is order of accesses even significant with respect to *different* addresses in the first place? After all, if a given write is broadcasted to the other threads (i.e., via coherence), and this is performed for every address, then is memory consistency *still* necessary?

These questions are explored further in the remainder of this lesson accordingly.

## 3. Consistency Matters

