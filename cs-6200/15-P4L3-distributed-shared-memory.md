# P4L3: Distributed Shared Memory

## 1. Preview

TODO

## 2. Visual Metaphor

<center>
<img src="./assets/P04L03-001.png" width="650">
</center>

Recall in the previous lecture on memory management (cf. P3L5), a visual analogy was made between the memory contents of a process and the parts used by workers sharing a single work space. Building off of this analogy, managing **distributed shared memory** is like managing tools/parts across *all* workspaces in a toy shop.

As indicated in the figure shown above, there are multiple distributed nodes (e.g., parts distribution centers) working together towards providing a service. The service provided is the sharing of tools and toy parts among workers that are working at multiple such workspaces (i.e., any given location may have multiple such workspaces within it).

| Characteristic | Distributed Toy Shop Workspaces | Distributed Shared Memory |
| :--: | :--: | :--: |
| Must decide placement | Place resources closest to relevant workers | Place memory (pages) close (i.e., in physical memory) to relevant processes (i.e., those which created the content and/or use the content) |
| Must decide migration | Move resources to relevant workers as soon as possible | When a process requires access to memory that is stored in a page frame on a remote node, provide a policy for how to migrate/copy memory (pages) content from the remote node to the local node (i.e., local physical memory) |
| Must decide sharing rules | How long can resources be kept? When are they ready? How to store? etc. | Since a memory page can be accessed *concurrently* by multiple processes, and additionally there may be multiple copies of the memory page among different locations in the system, it is important to establish rules to ensure that the memory operations are properly ordered (i.e., how they are propagated across the different copies) to ensure a consistent view of the entire memory |

## 3. Reviewing DFSs

TODO

<center>
<img src="./assets/P04L03-002.png" width="650">
</center>

## 4. Peer Distributed Applications

TODO

<center>
<img src="./assets/P04L03-003.png" width="650">
</center>

## 5. Distributed Shared Memory (DSM)

TODO

<center>
<img src="./assets/P04L03-004.png" width="650">
</center>

<center>
<img src="./assets/P04L03-005.png" width="650">
</center>

## 6. Hardware vs. Software DSM

TODO

<center>
<img src="./assets/P04L03-006.png" width="650">
</center>

## 7. Implementing DSM Quiz and Answers

According to the paper *Distributed Shared Memory: Concepts and Systems*" by Protic et al. (1996), what is a **common task** that is implemented in software in **hybrid** (hardware and software) distributed shared memory (DSM) implementations? (Select the correct option.)
  * prefetch pages
    * `CORRECT` - Prefetching is a software-implemented task/feature, whose usefulness depends on whether a particular application's access pattern benefits from this.
  * address translation
  * triggering invalidations

***N.B.*** Address translation and triggering invalidations are well-defined operations which are easier to implement using hardware support than using software.

***Instructor's Note***: cf. p. 76 of the reference paper, section "*Hybrid DSM Implementations*."

## 8-10. DSM Design

### **8. Sharing Granularity**

TODO

<center>
<img src="./assets/P04L03-007.png" width="650">
</center>

<center>
<img src="./assets/P04L03-008.png" width="650">
</center>

### **9. Access Algorithm**

TODO

<center>
<img src="./assets/P04L03-009.png" width="650">
</center>

### **10. Migration vs. Replication**

TODO

<center>
<img src="./assets/P04L03-010.png" width="650">
</center>

<center>
<img src="./assets/P04L03-011.png" width="650">
</center>

<center>
<img src="./assets/P04L03-012.png" width="650">
</center>

<center>
<img src="./assets/P04L03-013.png" width="650">
</center>

<center>
<img src="./assets/P04L03-014.png" width="650">
</center>

## 11. DSM Performance Quiz and Answers

If **access latency** as a performance metric is a primary concern, which of the following **techniques** would be best to use in a distributed shared memory (DSM) design? (Select all that apply.)
  * migration
    * `DOES NOT APPLY` - This is suitable for a single-reader, single writer (SRSW) system, however, not in other configurations (e.g., multiple readers and/or multiple writers).
  * caching
    * `APPLIES` - Bringing the data onto the node where it is accessed improves(i.e., reduces) the latency of the subsequent access operations on that data. 
  * replication
    * `APPLIES` - In general, creating copies of the data that are potentially closer to where the data can also improve (i.e., reduce) the latency of access operations on the data.

***N.B.*** For many concurrent write operations, caching and replication can also result in high overheads.
  * Recall the Sprite file system (cf. P4L2), which disables caching in the presence of multiple concurrent writers in order to avoid dealing with multiple invalidations and/or loss of consistency.

## 12. DSM Design: Consistency Management

TODO

<center>
<img src="./assets/P04L03-015.png" width="650">
</center>

<center>
<img src="./assets/P04L03-016.png" width="650">
</center>

<center>
<img src="./assets/P04L03-017.png" width="650">
</center>

<center>
<img src="./assets/P04L03-018.png" width="650">
</center>

## 13. DSM Architecture

TODO

<center>
<img src="./assets/P04L03-019.png" width="650">
</center>

<center>
<img src="./assets/P04L03-020.png" width="650">
</center>

<center>
<img src="./assets/P04L03-021.png" width="650">
</center>

<center>
<img src="./assets/P04L03-022.png" width="650">
</center>

## 14. Summarizing DSM Architecture

TODO

<center>
<img src="./assets/P04L03-023.png" width="650">
</center>

## 15. Indexing Distributed State

TODO

<center>
<img src="./assets/P04L03-024.png" width="650">
</center>

## 16. Implementing DSMs

TODO

<center>
<img src="./assets/P04L03-025.png" width="650">
</center>

<center>
<img src="./assets/P04L03-026.png" width="650">
</center>

## 17-21. Consistency Models

### **17. What Is a Consistency Model?**

TODO

<center>
<img src="./assets/P04L03-027.png" width="650">
</center>

<center>
<img src="./assets/P04L03-028.png" width="650">
</center>

### **18. Strict Consistency**

TODO

<center>
<img src="./assets/P04L03-029.png" width="650">
</center>

### **19. Sequential Consistency**

TODO

<center>
<img src="./assets/P04L03-030.png" width="650">
</center>

<center>
<img src="./assets/P04L03-031.png" width="650">
</center>

<center>
<img src="./assets/P04L03-032.png" width="650">
</center>

<center>
<img src="./assets/P04L03-033.png" width="650">
</center>

### **20. Causal Consistency**

TODO

<center>
<img src="./assets/P04L03-034.png" width="650">
</center>

<center>
<img src="./assets/P04L03-035.png" width="650">
</center>

<center>
<img src="./assets/P04L03-036.png" width="650">
</center>

### **21. Weak Consistency**

TODO

<center>
<img src="./assets/P04L03-037.png" width="650">
</center>

## 22. Consistency Models Quiz 1 and Answers

<center>
<img src="./assets/P04L03-038.png" width="650">
</center>

Consider the sequence of operations shown above. Is this execution **sequentially consistent**?
  * `YES` - This is a relatively trivial example. All of the write updates/operations in the system are performed by processor `P1`, which are subsequently read by processor `P2`. Furthermore, the updates (i.e., via values `x` and `y`) are visible in the same order (i.e., `R_m3(y)` is visible in `P2` *after* the update `R_m1(x)` is made visible in `P2` first).

## 23. Consistency Models Quiz 2 and Answers

<center>
<img src="./assets/P04L03-039.png" width="650">
</center>

Consider the sequence of operations shown above.

Is this execution **sequentially consistent**?
  * `YES` - Since `m1 == 0` is not the result of a particular write operation, both `P3` and `P4` observe that `m2` has changed but `m1` has not.
    * ***N.B.*** Per instructor's notes clarification, the video erroneously indicates that the answer is `NO` on the basis that since all the processors in the system must observe the *same* order of the events that are occurring on some other processor, then consequently the ordering in `P3` and `P4` is not legal per the sequential consistency model. However, this is incorrect, as the value of `m1` is arbitrary in this diagram. This (erroneously described) situation is described more concretely in the next section's quiz activity.

Is this execution **causally consistent**?
  * `YES` - From the figure, `m1` and `m2` are *not* causally related. However, this is inconsequential, therefore, "by default" this execution conforms correctly to the causal consistency model.

***N.B.*** Observe per the figure that processors `P3` and `P4` observe the updates to `R_m2` and `R_m1` in a complementarily reverse manner.

## 24. Consistency Models Quiz 3 and Answers

<center>
<img src="./assets/P04L03-040.png" width="650">
</center>

Consider the sequence of operations shown above.

Is this execution **sequentially consistent**?
  * `NO` - `P4` incorrectly perceives `m3` having been updated first, rather than `m2`.

Is this execution **causally consistent**?
  * `NO` - On `P1`, `R_m2(y)` (which sees the updated value from `P2`'s operation `W_m2(y)`) occurs *before* `W_m3(z)`; therefore, these operations are potentially causally related. Therefore, every processor in the system must observe that `m2` is updated before `m3`, however, this is not the case, which violates the requirement of causal consistency.

***N.B.*** Observe per the figure that processors `P3` and `P4` observe the updates to `R_m2` and `R_m3` in a complementarily reverse manner. `P3` observes both updates `R_m2(y)` and `R_m3(z)`, however, `P4` only observes `R_m3(z)` but not `R_m2(y)` (via `W_m2(y)` performed by `P2`). Therefore, `P3` (correctly) perceives update to `m2` having occurred first, while `P4` (incorrectly) perceives update to `m3` having occurred first.

## 25. Consistency Models Quiz 4 and Answers

<center>
<img src="./assets/P04L03-041.png" width="650">
</center>

Consider the sequence of operations shown above. Is this execution **weakly consistent**?
  * `YES` - Although `P2` and `P3` the operations in an arbitrary manner, neither of them synchronize in a manner that forces the underlying distributed shared memory to make any kind of guarantee regarding the updates that it observes. Correspondingly, weak consistency does not make any guarantees regarding the ordering unless explicit synchronization operations are used.

## 26. Consistency Models Quiz 5 and Answers

<center>
<img src="./assets/P04L03-042.png" width="650">
</center>

Consider the sequence of operations shown above. If ignoring the `Sync` operations as shown, is this execution **causally consistent**?
  * `NO` - Causal consistency does ***not*** permit the write operations from a *single* processor to be arbitrarily reordered.

## 27. Lesson Summary

TODO
