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

To achieve performance improvements with respect to memory access optimization, operating systems' memory management subsystems rely on **hardware support**,e.g., **translation lookaside buffers (TLBs)**, caches, and **software algorithms** (e.g., for pages, for memory allocation, etc.).

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

## 5. Page Tables

<center>
<img src="./assets/P03L02-006.png" width="350">
</center>

As was mentioned, paging is currently the more popular approach to memory management, as shown in the figure above.

<center>
<img src="./assets/P03L02-007.png" width="650">
</center>

Now, consider one of the major components that allows page-based memory management: **page tables**. Page tables alow to translate virtual memory addresses to physical memory addresses, as shown in the figure above.

For each virtual address, an **entry** in the page table is used to determine the actual physical location corresponding to the virtual address in the physical memory (DRAM). Therefore, in this manner, the page table serves a "**map**" which instructs the operating system (as well as the hardware itself) where to find specific virtual memory references.

While the relative sizes in the figure shown above are not strictly to scale, note that the **sizes** of the **pages** in virtual memory are ***identical*** to the sizes of the corresponding **page frames** in physical memory.
  * By maintaining this 1:1 relationship between the sizes, this obviates the requirement to maintain the translation of *every* individual virtual address in the page table, but rather it is only necessary to translate the ***first*** address of a virtual-address page to the ***first*** address of the corresponding physical-address page frame (and consequently, the subsequent addresses will similarly correspond directly between the two via appropriate offsets relative to the first address).
  * Consequently, the number of entries that must be maintained in the page table is ***reduced*** substantially.

<center>
<img src="./assets/P03L02-008.png" width="650">
</center>

Therefore, only the first portion of the **virtual address** is used to ***index*** into the page table; this part of the virtual address is called the **virtual page number (VPN)**, while the remaining portion of the virtual address is the actual **offset**.

The virtual page number (VPN) is used as an offset into the page table itself, which in turn produces the **physical frame number (PFN)** (the corresponding physical address of the page frame itself, located in DRAM/physical memory).

In order to complete the full translation of the virtual address, the physical frame number (PFN) is **combined** with the offset portion specified in the latter portion of the virtual address to produce the actual **physical address**.

The resulting physical address can then ultimately reference the appropriate location in physical memory (i.e., DRAM).

<center>
<img src="./assets/P03L02-009.png" width="650">
</center>

Consider an example, as shown in the figure above. Here, there is an attempt to access the data structure `array_addr` to initialize it (via function call `init_array(&array_addr)`).

The memory for `array_addr` has already been allocated in the virtual address space for the process, however, it has not yet been accessed prior to this point in the process. Consequently, the operating system has not yet allocated memory for `array_addr`.

Therefore, on first access of this memory location in the virtual address space, the operating system determines that there is no physical memory corresponding to the range of virtual memory addresses corresponding to `array_addr`, therefore, the operating system will allocate a page frame `P2` from physical memory via corresponding mapping in the page table to virtual address `V_k` (with corresponding offset).

Note that the physical memory for `array_addr` is only physically allocated when the process ***first*** attempts to access it (i.e., during initialization in this particular case); this is referred to as ***allocation on first touch***. This ensures that physical memory is *only* allocated when it is actually needed (e.g., to avoid allocating physical memory for data structures that programmers create but never use in the program/process).

<center>
<img src="./assets/P03L02-010.png" width="650">
</center>

Consequently, if the process does not use some of its memory pages for an extended time period, it is likely that those pages will be **reclaimed** (i.e., the contents will no longer be present in physical memory, but rather they will be moved to disk and replaced with other memory content which is relevant to currently running processes). 

In order to detect this, page-table **entries**  consist of both the physical frame number (PFN) *and* a **valid bit**, with the latter informing the memory management system regarding the (in)validity of the attempted memory access.
  * For example, if the page frame *is* present in physical memory and the mapping *is* valid, then the valid bit is `1`.
  * Conversely, if the page frame is *not* present in physical memory, then the valid bit is `0`.

If the hardware's **memory management unit (MMU)** detects that the valid bit is set to `0` in the page-table entry, then it will raise a **fault** (i.e., it will trap to the operating system). In this case, control is passed to the operating system, at which point the operating system must determine the following:
  * Should the access be permitted?
  * Where exactly is the page located in the physical memory (i.e, the corresponding page frame)?
  * Where should the page be brought into the physical memory?

<center>
<img src="./assets/P03L02-011.png" width="650">
</center>

As long as a ***valid*** address is being accessed by the process, on the occurrence of a fault, ultimately there will be a **restablished** mapping between a valid virtual address (e.g., `&array_addr`) and a valid location in physical memory.

However, it is likely that if a page frame was moved to disk and is now being brought back into physical memory, then it will be placed in a different location of physical memory (e.g., `P3`) than that at which it was present originally (e.g., `P2`). Accordingly, the corresponding page-table entry is updated to reflect this.

<center>
<img src="./assets/P03L02-012.png" width="500">
</center>

As a final note, to summarize, the operating system creates a page table on a ***per-process*** basis. The operating system maintains such a page table for *every* single running process that exists in the system.

Therefore, on **context switch**, the operating system must ensure that it correspondingly switches to the appropriate (i.e., valid) page table for the switched-to process.

Furthermore, recall that hardware assists with page table accesses by maintaining a **register** to point to the active page table (e.g., on x86 platforms, register `CR3` performs this role, maintaining the address for the page table of the *currently* running process, including following a context switch).

## 6. Page Table Entry

<center>
<img src="./assets/P03L02-013.png" width="500">
</center>

Recall that every page table **entry** contains the **page frame number (PFN)** of the corresponding physical address, as well as (at least one) valid bit; this bit is called the **present bit (P)**, since it indicates whether or not the contents of the virtual memory are actually present in physical memory.

Additionally, there are a number of fields/**flags** that are part of each page table entry used by the operating system during memory management operations, which in turn are also understood and interpreted by the hardware. These include:
  * The **dirty bit (D)**, which is set whenever a page is written to.
    * For instance, this is useful in file systems, where files are cached in memory. Here, the dirty bit can be used to detect which files have been written to and therefore must be updated on disk.
  * The **accessed bit (A)**, which tracks whether the page has been accessed in general (i.e., either for reading or for writing).
  * Other useful information maintained by the page table entry include **protection bits**, i.e., whether a page can be only read (**R**), only written to (**W**), and other similar operations (**X**).

### Page Table Entry on x86

<center>
<img src="./assets/P03L02-014.png" width="550">
</center>

As a more concrete/practical example of a page table entry, consider that of an Pentium x86 system, as shown in the figure above, having the following **flags**:
  * The bits/flags **Present (P)**, **Dirty (D)**, and **Accesses (A)** have identical meanings as for that described more generically in the previous section.
  * The **Read/Write (R/W)** bit is a single bit indicating a permission.
    * The value `0` indicates a read-only-access page.
    * The value `1` indicates that both read and write accesses are permissible for the page.
  * The **U/S** bit is another type of permission bit indicating the access level.
    * The value `0` indicates that the page can only be accessed from `user` mode.
    * The value `1` indicates that the page can only be accessed from `supervisor` (i.e., kernel) mode.
  * The other bits/flags indicate the behavior of the caching system present on the hardware (e.g., whether or not caching is disabled, write-through enabled, etc.).
  * Furthermore, there is a region of **unused** bits/flags which are reserved for future use.

### Page Fault

<center>
<img src="./assets/P03L02-015.png" width="600">
</center>

The **memory management unit (MMU)** uses the page table entry not only to perform the virtual-address-to-physical-address translation, but also relies on the aforementioned bits to establish the **validity** of the memory access operation.

If the hardware (i.e., memory management unit (mmu)) determines that a requested memory access operation cannot be performed, it generates a **page fault**; in this case, the CPU places an **error code** on the kernel stack and the generates a **trap** into the operating system kernel.

Consequently, this generates a **page fault handler**, which determines the appropriate action to perform based on the error code and the faulting address that generated the error. The key **information** included in the error code are the following:
  * Whether or not the fault was caused due to the page not being ***present***, and therefore requiring a corresponding transfer from the disk into main memory.
  * There was an attempt to access memory which violated a permission protection, resulting in a **protection error** (e.g., `SIGSEGV`).

***N.B.*** On an x86 system, the error code information is generated from the page table entry flags, and the faulting address (as required by the page fault handler) is stored in register `CR2`.

## 7. Page Table Size

