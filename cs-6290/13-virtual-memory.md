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
