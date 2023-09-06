# Virtual Memory

## 1. Lesson Introduction

In this lesson, we will discuss the support that computer architectures provide for **virtual memory**. This is an important topic because this makes modern operating systems *a lot* more efficient.

## 2. Why Virtual Memory?

<center>
<img src="./assets/13-001.png" width="650">
</center>

First, consider the purpose of **virtual memory** in the first place. Briefly, the purpose of virtual memory is to reconcile the respective views of **memory** from the perspectives of the (application) programmer vs. the hardware itself.

In the ***hardware view***, the machine is composed of some **memory modules** with some finite amount of memory (e.g., two `2 GB` modules for a total of `4 GB` of main memory, addressed as locations `0 GB` through `4 GB`, as in the figure shown above), that is accessible by the (real) **processor** itself.

Conversely, in the ***programmer's view***, the memory is a ***large array***, addressed from locations `0` to a very large number (e.g., `2^64` in the case of a `64 bit` machine), as in the figure shown above. In general, the size of this memory is much larger than that available on the physical hardware itself (e.g., `2^64 >> 4 GB`). Furthermore, this memory is typically composed of various ***regions***, such as:
  * **system** → reserved for the system itself
  * **code** → the actual program instructions
  * **data** → static data
  * **heap** → data allocated at run-time (e.g., via `malloc()` or equivalent), growing "downwards" (i.e., towards larger addresses)
  * **stack** → data pre-allocated at compile-time, typically "lower" in the address array (i.e., at relatively large addresses), and growing "updwards" (i.e., towards smaller addresses)

However, in general, the programmer does not bother by matters such as the remaining space between the heap and the stack, but rather the programmer simply wants to to perform `malloc()` operations (via the heap), push data onto the stack, etc. on an ad hoc basis, with no concern for "running out of memory" otherwise.
  * Furthermore, in a `64 bit` address space, the likelihood is indeed high that such a "running out of memory" is relatively low in practice.
  * Nevertheless, there is still the ***fundamental issue*** of the actual (i.e., physical) memory (on which the program is running) being substantially smaller than this "large-array" address space (or for a small program, the physical memory may also *exceed* the memory requirements substantially as well).

The matter complicates even more when considering the fact that in general, a given machine does not only run ***one*** program, but rather also runs ***multiple*** programs simultaneously (e.g., browsing files, a media player, a word processing application, etc. all running simultaneously), thereby exacerbating this problem.
  * From the perspective of any given *one* of these running applications/processes, ***each*** sees the address space spanning from `0` to `2^64` (in the case of a `64 bit` architecture).
  * Along these lines, it is ***not*** desirable to necessarily have to run these programs in a specific order (i.e., as opposed to on an ad hoc basis, which is a more typical usage), but rather it is desirable for each given program's own "view" of this large address space to be effectively ***isolated***/***independent*** of any other given program's view. However, this begets the ***problem*** of any one of these programs assuming it alone has ***full*** ownership of the ***entire*** address space (e.g., they all may regard the `code` region as belonging to them, despite having disparate/program-specific instructions for this particular region).

Therefore, **virtual memory** is a way to ***reconcile*** these differences between the programmer's view vs. the physical hardware's view; this topic will be further elaborated upon in this lesson accordingly.

## 3. Virtual Memory Quiz and Answers

<center>
<img src="./assets/13-003A.png" width="650">
</center>

Consider a computer with `16` active applications, with each application having a `32 bit` address space (i.e., the application generates `32 bit` addresses, giving rise to a potential `2^32 = 4 GB` of memory).

Which of the following actual/physical memory configurations does the system have? (Select all that apply.)
  * Two `2 GB` memory modules
    * `APPLIES`
  * Four `4 GB` memory modules
    * `APPLIES`
  * Eight `8 GB` memory modules
    * `APPLIES`
  * One `16 GB` memory module
    * `APPLIES`

***Explanation***:

All of these options are potential candidates. When using virtual memory, what a given application "perceives" as its memory vs. what the physical hardware itself supports can be completely decoupled.

## 4. Processor's View of Memory

Now, consider how the **processor** views the memory.

<center>
<img src="./assets/13-004.png" width="650">
</center>

The processor sees what is called **physical memory**, which is the memory (i.e., address space) contained in the ***actual*** memory modules physically present in the system itself.
  * The amount of this memory is sometimes even less than `4 GB`.
  * It is almost never a full `4 GB` ***per process*** that is dedicated in the system, because there tens or even hundreds of other processes running at any given time in a modern operating system.
  * It is also virtually never `16 exabytes` (i.e., `2^64` address locations via `64 bit` addresses) ***per process***, as this would require an overwhelmingly large amount of physical memory to accommodate.

Therefore, in general, it can be concluded from these observations that the amount of **physical memory** present in the system is generally ***less*** than what a given program(s) can access (i.e., if all of the programs could access *all* of the possible memory intended, then this would far exceed the amount of physical memory available).

Lastly, note that the **addresses** that the processor uses for the physical memory have a **one-to-one mapping** to the bytes/words in the physical memory (i.e., a given processor address always maps to the ***same*** physical-memory location).

## 5. Program's View of Memory

Now, consider how the **program** views the memory.

<center>
<img src="./assets/13-005.png" width="650">
</center>

The program sees a large amount of memory (as in the figure shown above), and usually some contiguous regions of this memory are actually used by the program. Furthermore, there is a large region in the middle, between the heap and the stack (as denoted by oppositely directed green arrows in the figure shown above), that the program will generally not access unless the heap incidentally grows in that manner during run-time (however, in practice, the heap is usually small relative to the corresponding `2^64` address space, i.e., the program "thinks" it has a lot of this memory available but ultimately does not access most of it). This large (e.g., `2^64`) address space is what is correspondingly called **virtual memory** (i.e., the program "virtually" has "a lot" of memory available, but in practice only a small fraction of this exists as actual, physical memory).

Correspondingly, a separate smaller program also has its own virtual-memory address space (as depicted on the right side of the figure shown above, with relatively more memory in the heap region, which it similarly "under-utilizes" relative to the "full virtual-memory size"). Similarly, the "idea" that this program has about the corresponding virtual memory is that it "can always use more."

<center>
<img src="./assets/13-006.png" width="650">
</center>

With both programs running simultaneously, consider now how this corresponds to the **physical memory** itself, as in the figure shown above.

When the first/larger program generates a memory-access operation that should access a given address in its virtual-memory address space (as denoted by purple in the figure shown above), how is it determined ***where*** exactly this maps in the physical-memory address space? Furthermore, when the second/smaller program correspondingly generates a memory-address operation with the ***same*** address, how is it determined ***where*** exactly this maps in the physical-memory address space as well?

The second/smaller program might go to a ***different*** location in physical memory (e.g., if the two programs are completely independent of each other).

<center>
<img src="./assets/13-007.png" width="650">
</center>

Conversely, the second/smaller program might go to the ***same*** location in phsyical memory (e.g., if the two programs are sharing data), as in the figure shown above.

<center>
<img src="./assets/13-008.png" width="650">
</center>

In fact, **data sharing** among programs is ***not*** constrained to strictly placing data in the ***same*** virtual-memory address space; instead, the second/smaller program can place the data in a different address in its virtual-memory address space (as in the figure shown above), while otherwise sharing the ***same*** physical-memory address space (i.e., mapping to the ***same*** location in the physical-memory address space).

So, then, how can such differences be reconciled? This is discussed next.

## 6. Mapping Virtual Memory to Physical Memory

When a program generates a **virtual address** (e.g., performs a load or store operation using this address), the processor must correspondingly ***access*** some **physical address**. The question is: How does the processor **map** what the program is attempting to access (virtual address) to what really should be accessed (physical address)?

Such a mapping would be very difficult if every byte of virtual memory could map to an ***arbitrary*** byte in the physical memory, as this would necessitate a large table of mappings (which in turn would require a lot of memory to maintain it).

<center>
<img src="./assets/13-009.png" width="650">
</center>

Rather than using such an "arbitrary mapping" approach, the program's **virtual memory** is divided into equally sized chunks called **pages** (as in the figure shown above). A typical **page size** is `4 KB`, with the pages correspondingly labeled in respective `0`-indexed order/alignment (i.e., `Page 0`, `Page 1`, etc. corresponding to virtual-memory addresses `0 KB` through `4 KB`, `4 KB` through `8 KB`, etc., respectively).

Additionally, the **physical memory** is divided into corresponding `4 KB` slots (called **frames**) that can hold these virtual-memory pages.
  * Recall (cf. Lesson 12) a similar configuration with respect to caches, whereby with respect to memory, the physical memory behaves analogously to a "cache" for the virtual memory, in the sense that it has a certain number of "places" (analogously to cache lines) where it can hold pages (analogously to a main-memory block). The difference here, however, is that the virtual memory is "perceived" to exist (whereas in a cache vs. main memory configuration, the corresponding blocks and cache lines exist "fully" as concrete/physical memory).

<center>
<img src="./assets/13-010.png" width="650">
</center>

Given the page-based virtual memory and frame-based physical memory, the **operating system** correspondingly creates a **mapping** (as in the figure shown above), whereby the operating system determines which pages in the program will map to which corresponding frames.

Furthermore, given another running process (as depicted on the right side in the figure shown above), it has its own corresponding pages, which in turn might map to ***different*** frames. Otherwise, if two pages must share physical memory, then they will map to the ***same*** frame (e.g., `Page 1` of the first process and `Page 1` of the second process both mapping to `Frame 2`), in which case both processes when performing access operations (i.e., read and/or writes) will mutually access the ***same*** physical memory addresses.

<center>
<img src="./assets/13-011.png" width="650">
</center>

So, then, how is it decided how this virtual-memory-to-physical-memory mapping will occur? This is dictated by the **operating system** itself (as in the figure shown above). The corresponding mechanism for this mapping is called a **page table**, which is a table that indicates where each page in a given process will map to physical memory. Furthermore, ***each process*** has a corresponding page table for this purpose.

## 7. Page Size Quiz and Answers

<center>
<img src="./assets/13-013A.png" width="650">
</center>

Consider a system with the following specifications:
  * Physical memory size is `2 GB`
  * Virtual memory size is `4 GB`
  * Page size is `4 KB`

How many page frames are available in this system?
  * `2^19`

How many entries are present in each page table? (Recall that a page-table entry maintains the mapping for the virtual-memory page to the corresponding physical-memory frame.)
  * `2^20`

***Explanation***:

To determine the number of page frames, this follows directly from `2 GB physical memory / 4 KB per page = [2*(2^30)] / [4*(2^10)] = 2^19`.

To determine the number of entries present in each table, this follows directly from `4 GB virtual memory / 4 KB per entry = [4*(2^30)] / [4*(2^10)] = 2^20` (i.e., one "mega/M entry").
  * ***N.B.*** Recall (cf. Section 6) that a ***separate*** page table is necessary for ***each*** `4 GB` process. Therefore, ***each*** process running on the system will require a corresponding `2^20` entry page table (i.e., of approximately `1 MB` in size).

## 8. Where Is the "Missing" Memory?

Now that it is understood that each given application "uses" a large amount of (virtual) memory relative to the available physical memory to accommodate all of these running processes, the question is: Where is the "missing" memory (i.e., accounting for this disparity in virtual vs. physical memory) actually located?

<center>
<img src="./assets/13-014.png" width="650">
</center>

Consider two applications, each with four pages, along with a corresponding physical memory of four frames (as in the figure shown above). Furthermore, assume that both applications are both using **all** of their four pages.

When mapped, the corresponding pages eventually occupy all of the available physical memory frames; furthermore, there are insufficient physical memory frames to accommodate ***all*** of the apps' respective virtual memory frames. So, then, where are these remaining (un-mapped) pages mapped to?

<center>
<img src="./assets/13-015.png" width="650">
</center>

The remaining pages in fact are mapped to the **hard disk** (as in the figure shown above). Thus, rather than being stored in physical memory, they are instead stored on the hard disk in the system.

These hard-drive-stored pages ***cannot*** be accessed directly by the processor, because the processor can only directly access memory via load and store operation on the physical memory itself. Therefore, if the processor must access the hard-drive-stored pages, these pages must first be brought into physical memory from the hard disk prior to being accessed (this will be described shortly). Correspondingly, in general, among the available (virtual) memory a given program "thinks" that it "has," some of this will be located in the hard disk (i.e., rather than in virtual memory) at any given time as the program/process is running.

## 9. Virtual-to-Physical Translation
