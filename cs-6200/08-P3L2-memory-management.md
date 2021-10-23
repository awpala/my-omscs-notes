# P3L2: Memory Management

## 1. Preview

This lecture will discuss the **memory-management mechanisms** used in operating systems, i.e., how operating systems manage **physical memory** and also how they provide processes with the "illusion" of **virtual memory**.

Note that the intent of this course is to review some of the basic mechanisms in operating systems, as well as to serve as a refresher of this (perhaps previously seen) content. Therefore, the **objective** of this lesson is to review the **key concepts** and to facilitate the use of additional references (e.g., textbooks, online material, etc.) in order to "fill in blanks."
  * Accordingly, this lecture will illustrate some **advanced services**.

## 2. Visual Metaphor

<center>
<img src="./assets/P03L02-001.png" width="500">
</center>

Returning to the toy shop analogy, **operating systems** and **toy shops** each have **memory/part management systems** (i.e., a mechanism to manage **state** required for processing actions).
  * In an operating system, this state is captured by **memory** (via the corresponding **memory-management subsystem**).
  * In a toy shop, state is captured by the various constituent **parts** that are required to assemble the toys.

| Characteristic | Toy Shop | Operating System Memory Management |
| :---: |  :---: |  :---: |
| Uses intelligently sized containers | Same-sized crates of toy parts to facilitate management of the parts in and out of the storage room | The memory management subsystem of the operating system typically manages memory at the granularity level of **memory pages** or **memory segments**, the size of which is an important design consideration |
| Not all parts/memory are needed at once | Toy orders are completed in stages, and not all toy orders are completed at the same time (e.g., teddy bears may require fabric and threads vs. other toys requiring wooden parts, etc.) | Executing tasks/processes on a computing system only operate on a ***subset*** of the entire memory at any given time, and therefore do not require *all* of the memory simultaneously (i.e., some subset of the memory state can be brought in/out of memory at any given time to meet the demands of the currently executing task) |
| The process is optimized for achieving high performance | Reduce the wait time for parts (i.e., reduce the time required to move the parts in/out of containers) in order to make more toys | Reduce the time to **access** state in memory (i.e., transferring state from main memory to/from memory pages and segments) in order to improve performance (i.e., to achieve ***faster*** memory access) |

To achieve performance improvements with respect to memory access optimization, operating systems' memory management subsystems rely on **hardware support** (e.g., **translation lookaside buffers (TLBs)**, caches, and **software algorithms** (e.g., for pages, for memory allocation, etc.)).

## 3-4. Memory Management

### Introduction

<center>
<img src="./assets/P03L02-002.png" width="150">
</center>

Recall (cf. P2L1) that the introductory lecture on processes and process management briefly discussed a few **basic mechanisms** pertaining to memory management. The **goal** of this lecture is to complete this discussion with a more detailed description of operating-system-level memory management components.

### 3. Memory Management: Goals

<center>
<img src="./assets/P03L02-003.png" width="600">
</center>

Recall that one of the **roles** of the operating system is to manage the physical resources (e.g., **physical memory (DRAM)**) on behalf of one or more executing processes.

In order to avoid the imposition of a ***limit*** on the size and on the layout of an address space (i.e., based on the amount of physical memory that is actually available, and/or based on how it is shared among processes) there is a ***decoupling*** of the notions of **physical memory** (available on the hardware itself) vs. **virtual memory** (used by the address space).

As a matter of fact, most processes use **virtual addresses**, which in turn are ***translated*** into the actual **physical addresses** where the particular process state is stored.
  * The **range** of the virtual addresses (i.e., from `V`<sub>`0`</sub> to `V`<sub>`max`</sub>) establishes the amount of virtual memory that is visible in the system, which can in fact ***exceed*** the amount of available physical memory.

Therefore, in order to manage the **physical memory** itself, the operating system must be able to **allocate** physical memory and to **arbitrate** how the physical memory is accessed.
  * **Allocation** requires that the operating system incorporates certain **mechanisms** (e.g., algorithms and data structures) to track how physical memory is being used, as well as to determine what regions of physical memory are free at any given time.
  * Furthermore, since the physical memory is generally ***smaller*** than the virtual memory, it is likely that some of the contents required in the virtual address space are not present in physical memory (e.g., they may be stored on secondary storage, such as on disk); therefore, the operating system must have mechanisms to perform **replacement** operations (i.e., replacing the contents *currently* in physical memory with content that is currently *needed* in the virtual address space but is instead present in some other temporary storage).
    * To accomplish this, there is some **dynamic component** in the memory management system that determines *when* content should be brought in from disk as well as *which* content from physical memory should be  stored on disk, depending on the kinds of processes that are currently running.
  * **Arbitration** requires that the operating system is quickly able to **interpret** and **verify** a process's memory access attempt (i.e., when examining the virtual memory address space, the operating system should be able to quickly **translate** the virtual address into a corresponding physical address, as well as to **validate** that the access attempt is indeed ***legal***).
    * To accomplish this, current operating systems rely on a combination of **hardware support** as well as smartly-designed **data structures** that are used in to perform  **address translation** and **address validation**.

<center>
<img src="./assets/P03L02-004.png" width="600">
</center>

As shown in the figure above, the **virtual address space** is subdivided into thick-sized segments of uniform size called **pages**. Analogously, the (generally smaller) **physical address space** is simlarly subdivided into **page frames**, of the same size as the corresponding virtual-address pages.

In **page-based memory management** (or **paging**):
  * The role of **allocation** (as performed by the operating system) is to ***map*** pages from virtual memory to page frames of the physical memory.
  * Furthermore, the **arbitration** of the memory accesses is achieved via **page tables**.

However, paging is not the only mechanism by which to achieve such decoupling of the virtual and physical memories. In **segment-based memory management** (or **segmentation**):
  * With respect to **allocation**, rather than using fixed-sized pages, flexibly-sized **segments** are used to map regions of physical memory as well as to swap in/out of physical memory.
  * With respect to **arbitration** of memory accesses (i.e., to translate or to validate appropriate acceses of the physical memory), **segment registers** are used (which are typically supported on modern hardware).

***N.B.*** **Paging** is currently the dominant form of memory management in modern operating systems, and therefore it will be the focus of current discussion (segmentation will be revisited later in this lecture).

### 4. Memory Management: Hardware Support

<center>
<img src="./assets/P03L02-005.png" width="600">
</center>

As was already suggested, memory management is *not* performed solely by the operating system alone, but rather to improve the efficiency of these **memory management operations**, the **hardware** has evolved over the most recent decades to integrate a number of **mechanisms** to facilitate easier, faster, and/or more-efficient memory management operations (e.g., memory allocation and arbitration).
  * Every CPU package is equipped with a **memory management unit (MMU)**.
    * The CPU issues virtual addresses to the memory management unit (MMU), which in turn is responsible for ***translating*** the virtual addresses to the appropriate physical addresses.
    * Furthermore, the memory management unit (MMU) can generate/report **faults**, which occur as signals that can result from:
      * Illegal memory access attempts (e.g., accessing an address that has not been allocated at all).
      * An inadequate permission level to perform the request access operation (e.g., the memory reference is part of a store instruction in which the process is attempting to overwrite a particular memory address to which it does not have write-access permission, i.e., the page in question is ***write-protected***).
      * An attempt to access memory that is not present in **main memory (MM)**, and there must be ***fetched*** from disk.
  * Designated **registers** also support memory management during ***address translation***.
    * For example, in a paged-based system, there are registers used to point to the currently active **page table**.
    * Similarly, in a segment-based system, there registers used to indicate the base address of the segment, the size limit of the segment, the total number of segments, etc.
  * Since memory address translation occurs for practically all memory references, accordingly most memory management units (MMUs) integrate a small cache of valid virtual-address-to-physical-address translations; this cache is called the **translation lookaside buffer (TLB)**.
    * The translation lookaside buffer (TLB) improves the speed of address translation operation, inasmuch as the presence of such a translation in the cache obviates the need to otherwise perform an additional operation to accomplish this mapping (e.g., accessing the page table and determining the validity of the address).
  * Finally, the actual generation/**translation** of the physical address itself (i.e., from the virtual address) is performed by the **hardware**.
    * The operating system maintains certain **data structures** (e.g., **page tables**) to maintain certain information that is necessary to perform this translation, however, the actual translation itself is performed by the hardware.
    Furthermore, this also implies that the hardware itself dictates what type of **memory management modes** are supported (e.g., segmentation, paging, or both via what types of corresponding registers the hardware supports), as well as what types of pages that can be used, the formats of the virtual addresses and of the physical addresses (i.e., in order to be understood by the hardware itself), etc.

There are other aspects of memory management that are more flexible with respect to their design, since they are performed by the software (e.g., the actual memory allocation of the processes to the main memory's address space, the replacement policy to determine which portion of state will be present in main memory vs. on disk, etc.). The discussion will focus on these **software-oriented aspects** of memory management, since that is most relevant from the perspective of an operating systems course.

### 5. Page Tables

