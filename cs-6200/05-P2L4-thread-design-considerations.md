# P2L4: Thread Design Considerations

## 1. Preview

Recall (cf. P2L2) that threads can be implemented at the kernel level, the user level, or both. This lesson will revisit this notion and explore what is necessary (e.g., data structures and operating-system mechanisms) in order to be able to implement threads both at the user level and at the kernel level.

This lesson will also discuss two **notification** mechanisms that are supported by operating systems:
  1. **interrupts**
  2. **signals**

To make discussion in this lesson more concrete, two papers will be referenced:
  1. Eykholt et al. "*Beyond Multiprocessing: Multithreading the Sun OS Kernel.*"
  2. Stein and Shah. "*Implementing Lightweight Threads*."

These are historic papers which give insight into how threading systems have evolved over time.

This lesson will conclude with a brief summary of the current threading model in the Linux operating system.

## 2. Kernel- vs. User-Level Threads

Recall the following illustration (cf. P2L2):

<center>
<img src="./assets/P02L04-001.png" width="450">
</center>

Supporting threads at the **kernel level** means that the operating system kernel itself is multithreaded. To achieve this, the operating system kernel maintains:
  * a thread abstraction (e.g., via data structure)
  * coordinating mechanisms for resource management among the threads (e.g., scheduling, synchronization, etc.)

Supporting threads at the **user level** means that there is a user-level library (e.g., `thread_lib`) linked to the application, which analogously provides all of the management and run-time support for threads, e.g.,:
  * a thread abstraction (e.g., via data structure)
  * coordinating mechanisms for resource management among the threads (e.g., scheduling, synchronization, etc.)

Furthermore, different processes may use entirely different user-level libraries (e.g., `thread_lib 1` vs. `thread_lib 2`), which provide these support mechanisms in different ways.

Recall (cf. P2L2) that different mechanisms/models are available for **mapping** of user-level threads to kernel-level threads (e.g., 1:1, M:1, and M:M).

The lesson will now consider a more detailed look into what exactly is required to describe user-level vs. kernel-level threads, as well as how to support these different mapping models.

## 3. Thread-Related Data Structures: Single CPU

<center>
<img src="./assets/P02L04-002.png" width="450">
</center>

Consider what occurs in a single-threaded process. The process is described by all of the process-related **state** (e.g., address space via virtual-to-physical address mapping, stack, registers, etc.), as contained in the **process control block (PCB)**.

When the process makes a system call, it traps into the kernel, and then executes in the context of a kernel thread.

<center>
<img src="./assets/P02L04-003.png" width="450">
</center>

Now, consider a multithreaded process, and assume that there is only one CPU. This resembles a M:1 model, wherein many user-level threads are supported by one kernel-level thread. The user-level threads are managed by the user-level library (`thread_lib`).

The user-level library needs a way to represent the threads in order to track resource usage and to perform management mechanisms (e.g., scheduling and synchronization), which is accomplished using a **user-level thread (ULT)** data structure.

<center>
<img src="./assets/P02L04-004.png" width="450">
</center>

In order to associate multiple kernel-level threads with the process, rather than replicating the *entire* process control block structure, only the information pertaining to execution state of the **kernel-level threads (KLTs)** (e.g., stack and registers) is isolated to a corresponding data structure, while the process control block maintains the common information.

Observer that from the perspective of the user-level library, the underlying kernel-level threads resemble "virtual CPUs," which it uses to schedule the user-level threads.
  * UNIX-based systems have certain operations (e.g., `setjmp()` and `longjmp()`) which are useful when it is necessary to save and restore the context of a user-level thread

## 4-5. Thread-Related Data Structures

### At Scale

<center>
<img src="./assets/P02L04-005.png" width="450">
</center>

Consider now the scenario where there are multiple such processes. Clearly, this will require multiple copies of the data structures representing the user-level threads, process control blocks, and kernel-level threads. Therefore, it is necessary to maintain **relationships** among these data structures.
  * With respect to the user-level threads, the user-level library keeps track of these threads representing the single process. Therefore, there is a relationship between the user-level threads and the process control block representing the corresponding address space.
  * Furthermore, for each process, it is necessary to keep track of the kernel-level threads executing on behalf of the process, and correspondingly each kernel-level thread in turn must associate itself with the correct address space for the process.

<center>
<img src="./assets/P02L04-006.png" width="450">
</center>

In a system with multiple CPUs, there must be a data structure to represent each CPU, as well as a corresponding relationship between the CPU data structure and the associated kernel-level thread(s).

<center>
<img src="./assets/P02L04-007.png" width="450">
</center>

When the kernel itself is multithreaded, multiple kernel-level threads can support a single user-level process. When the kernel needs to schedule or context switch among kernel-level threads belonging to different processes, it can quickly determine via the aforementioned relationships that the processes belong to different process control blocks (i.e., distinct virtual address mappings), and therefore it can easily decide that it must completely invalidate the existing address mappings and restore new ones. In the process, it will save the entire process control block structure of the first kernel-level thread, and then restore the entire process control block structure of the second one.

### Hard and Light Process State

<center>
<img src="./assets/P02L04-008.png" width="450">
</center>

When two kernel-level threads belong to the *same* address space, there is corresponding information in the process control block pertaining to the entire user-level process, however, the information is also specific to only one kernel-level thread (e.g., signals and system call arguments). Therefore, when context switching among two kernel-level threads, there is a portion of the process-control block structure that must be preserved (e.g., the virtual address mapping), as well as a portion that is only specific to a particular kernel-level thread and which depends on the currently executing user-level thread (i.e., as managed by the user-level library).

Therefore, the information originally contained in the process control block is separated into the **'hard' process state** (which is relevant to all of the user-level threads that execute within the process) and the **'light' process state** (which is only relevant to the subset of user-level threads that are currently associated with a particular kernel-level thread(s)).

As has been described in this section, a large, monolithic process control block can be split into many smaller, more-specialized data structures and corresponding relationships in order to coordinate between the user-level threads and the associated kernel-level threads.

## 6. Rationale for Multiple Data Structures

With a ***single*** process control block:
  * there is a large, contiguous data structure
  * requires separate copies for every single thread (i.e., private for each entity), even though they share some information
  * requires saving and restoring the entire data structure on each context switch, which is an expensive "reset" operation to perform due to its large size
  * this one data structure is use for any changes/operations necessary (e.g., scheduling, memory management, synchronization, etc.), therefore, any customization will potentially affect multiple operating system services, thereby making such updates/changes more challenging

Therefore, there are several **limitations** to this approach of using a single process control block structure to represent *all* aspects of the execution state of a process:
  * poor scalability due to size
  * large overheads due to the requirement of private copies of data
  * poor performance due to saving and restoring of large amounts of data
  * poor flexibility making updates more difficult to achieve

Conversely, when using ***multiple** data structures:
  * smaller data structures (i.e., partitioned from the original large/monolithic data structure), maintained via pointers/relationships
  * easier to share via relationships and smaller data segments
    * shared data across threads can simply be pointed to
    * new elements can be created when it is necessary to have different information
  * on context switch, it is only necessary to save and restore what needs to be changed
    * any modifications will only impact a subset of the data elements
  * user-level library only needs to update a *portion* of the state (i.e., only that pertaining to the changed elements, thereby being confined to a much smaller interface)

Overall, the **benefits** of the multiple data structures approach are complementary to the limitations of the single data structure approach, i.e.,:
  * improved scalability via smaller, isolated data structures
  * lower overhead due to less overall copies of otherwise redundant data
  * improved performance due to reduced context switching time
  * improved flexibility due to the modular design

Consequently, modern operating systems adopt a multiple data structures approach for organizing information about their execution context.

## 7. Thread Structures Quiz and Answers

Having discussed how thread data structures are separated, consider now an actual Linux kernel implementation. Each question in this quiz references Linux kernel version 3.17.

1 - What is the name of the **kernel thread structure** (name of the C `struct`)?
  * `kthread_worker` - this data structure (along with the functions defined in this file) provides a simple interface for creating and stopping kernel threads

2 - What is the name of the data structure (contained in the `struct` from question 1) that describes the **process** that the kernel thread is running (name of the C `struct`)?
  * `task_struct` - this data structure is a holding place for tons of important information regarding a process

*References*:
  * [Free Electrons Linux Cross Reference](https://elixir.bootlin.com/linux/v3.17/source)
  * [Interactive Linux Kernel Map](https://makelinux.github.io/kernel/map/)

## 8. User-Level Structures in Solaris 2.0

### SunOS 5.0 Threading Model

Consider now the data structures described in the two referenced papers, which describe the kernel- and user-level threads implementations in the SunOS 5.0 kernel used in the Solaris 2.0 operating system.
  * ***N.B.*** Sun Microsystems was acquired by Oracle in 2010 in the wake of the 2008 financial crisis, however, it was previously known for the quality and stability of its UNIX distributions, as well as being a leader in introducing revolutionary features to the kernel, and therefore provides an exemplar for the study of "real-world" threading models.

<center>
<img src="./assets/P02L04-009.png" style="background-color: white;" width="450">
</center>

(*Reference*: Stein and Shah, Figure 1)

This figure illustrates the **lightweight threads** implementation described by the authors, representing the threading model supported by the operating system.

Going from the bottom up, at the hardware and kernel levels, the operating system is intended for multiprocessor systems with multiple CPUs, and furthermore the kernel itself is multithreaded (i.e., having multiple kernel-level threads).

At the user level, the processes can be either single- or multi-threaded, supporting both M:M and 1:1 mappings to kernel-level threads.

Each kernel-level thread executing a user-level thread has a **lightweight process data structure** associated with (represented by blue circles in the figure).
  * From the user-level library's perspective, these lightweight processes represent the virtual CPUs onto which the user-level threads are scheduled.
  * At the kernel level, there is a kernel-level scheduler which manages the kernel-level threads and schedules them onto the physical CPU(s)

### User-Level Thread Data Structures

Now, consider the the user-level thread data structures, as described in Stein and Shah ("*Implementing Lightweight Threads*").
  * ***N.B.*** This paper does not describe POSIX threads, however, the threads described are sufficiently similar for purposes of discussion.

<center>
<img src="./assets/P02L04-010.png" width="350">
</center>

When the thread is **created**, the library returns a **thread ID** (`tid`). This is not a direct pointer to the actual data structure (i.e., as implied previously), but rather it is an index in a table of pointers. The **table pointers** in turn point to the actual underlying **thread data structure**.

With this configuration, if there is a problem with the thread, then if the thread ID were a direct pointer, it would now point to corrupt/invalid memory. Instead, with the pointer table as an intermediary, the table entry itself can encode information which provides meaningful feedback or an error message.

The thread data structure itself contains a number of fields (e.g., registers, signal mask, priority, and stack pointer). Furthermore, the thread data structure contains **thread local storage**, which includes the variables defined in the thread functions that are known at compile time so that the compiler can allocate storage on a per-thread basis for each of them.

The size of the **stack** can be be defined by the library defaults or by the user, but in general the size of most of the information in the thread data structure is fixed at compile time. Therefore, the information contained in the thread data structure can be layered contiguously in memory to improve locality and to facilitate the scheduler's finding of the next thread (i.e., via corresponding basic arithmetic operations).

<center>
<img src="./assets/P02L04-011.png" width="350">
</center>

A key **problem** with this approach, however, is that the threading library itself does not control the stack size/growth during run-time, and furthermore the operating system itself is unaware that there are multiple user-level threads. Therefore, it is possible that as the stack grows, one thread may overwrite the data structure of another thread; if this occurs, the problem will not be detected until the latter thread proceeds to run, however, because the problem originated from the former thread, making identifying/debugging such a problem challenging.

The **solution** proposed by the authors is to separate the information about the different threads with a so-called **red zone**, a portion of the virtual address space that is not allocated, so that if the thread is running with an increasing stack during run-time, if it attempts to write to an address that resides in the red zone, then the operating system will cause a fault. Now, it is much easier to reason about the origin of the error due to its confinement to this specially designated region of memory and corresponding identification of the aberrant thread.

## 9. Kernel-Level Structures in Solaris 2.0

Now, consider the kernel-level data structures.

<center>
<img src="./assets/P02L04-012.png" width="650">
</center>

For each process, information is maintained about the process via the **process data structure**, e.g.,:
  * the list of **kernel-level threads** that execute within the process's address space
  * valid mappings of the virtual address space
  * user credentials (e.g., the user has access to a file during attempted access)
  * signal handlers which are valid for the process (e.g., how to respond to certain events that can occur in the operating system)
    * ***N.B.*** Signal handling is discussed later in this lesson

The **light-weight process (LWP) data structure** contains information that is relevant to some subset of the process, e.g.,:
  * one or more **user-level threads** that are executing in the context of the process, keeping track of their user-level registers and system call arguments
  * resource usage information
    * at the operating-system level, the kernel tracks resource usage on a per-kernel-thread basis; this is maintained in the LWP data structure for the corresponding kernel-level thread
    * therefore, to determine the aggregate resource usage for the entire process, this requires a traversal of all of the associated LWP data structures

***N.B.*** The information maintained in the LWP data structure is similar to that maintained at the user-level via the user-level thread data structure, however, the LWP data structure exposes the information that is visible to the kernel (e.g., as used by the operating system for scheduling). 

The **kernel-level threads data structure** contains information about the kernel-level threads, e.g.,:
  * kernel-level registers
  * stack pointer
  * scheduling information (e.g., class, etc.)
  * **pointers** to the associated LWP, process, and CPU data structures

***N.B.*** Note that the kernel-level threads data structure contains information about an execution context (i.e., for the kernel-level thread) that is always needed (e.g., operating-system-level services that must access kernel-level thread information, even when the thread is not active, such as scheduling information). Therefore, unlike the LWP data structure, the information contained in the kernel-level threads data structure is ***not swappable*** (i.e., it must *always* be present in memory); conversely, the information maintained in the LWT data structure does not need to be persistently present in memory, but rather can be swapped out if necessary (e.g., when memory becomes limited). This in turn allows the system to support a larger number of threads in a smaller memory footprint than would be otherwise possible if it were necessary to persist *all* of the aforementioned in memory.

The **CPU data structure** contains information pertaining to the CPU, e.g.,:
  * the currently executing/scheduled thread
  * a list of the other kernel-level threads
  * information for executing procedures to dispatching a thread, how to handle interrupts from various devices, etc.

***N.B.*** Once the current thread is known, it is possible to determine (via corresponding relationships) information about all of the associated data structures required to rebuild the entire process state.
  * On the SPARC architecture (as mentioned in the Solaris papers/references), many registers are provided, and in particular there is a dedicated register used to identify the current thread at any given point in time (i.e., it is updated accordingly during a context switch). Therefore, the pointer relationships can be followed accordingly to determine the state from this stored information, rather than using more expensive operations to make this determination.

<center>
<img src="./assets/P02L04-013.png" width="350">
</center>

(*Reference*: Eykholt et al., Figure 2)

The figure shown above describes the relationships between all of the aforementioned kernel-level data structures.
  * The process data structure `proc` has information about the `User` and points to the address space `VM address space`, and also points to a list of kernel-level threads (designated `thread` inside of the data structure `LWP data` in the figure)
  * Each kernel-level thread data structure in turn points to the corresponding light-weight process `lwp` and stack `stack`, which are swappable

***N.B.*** For brevity, this figure omits information about the CPU data structure as well as other relationships/pointers among data structures.

## 10. Basic Thread Management Interactions

Given that there are threads at both the user and kernel levels, consider now the **interactions** between them to manage this efficiently.

<center>
<img src="./assets/P02L04-014.png" width="450">
</center>

Consider a multithreaded process having four user-level threads, as shown above. However, the process is such that, at any given time, the actual level of concurrency is just two user-level threads (i.e., the process only requires two corresponding kernel-level threads).

<center>
<img src="./assets/P02L04-015.png" width="450">
</center>

When the process starts, the kernel provides a default number of kernel-level threads (e.g., one, as shown above), and the accompanying light-weight thread.

<center>
<img src="./assets/P02L04-016.png" width="450">
</center>

Next, the process requests an additional kernel-level thread. This is accomplished via a system called `set_concurrency` supported by the kernel, wherein in response to the request from the process, the kernel allocates an additional kernel-level thread(s) and allocates it to the process.

<center>
<img src="./assets/P02L04-017.png" width="450">
</center>

Now, consider the scenario wherein the two user-level threads that were mapped to the underlying kernel-level threads block (e.g., for an I/O operation, which moves them into the corresponding wait queue), thereby blocking the corresponding kernel-level threads as well. In this situation, the process itself is now blocked as well, since the associated kernel-level threads cannot proceed (i.e., are unavailable for the other unblocked user-level threads).

The reason for this occurrence is due to the fact that the user-level library is unaware of what is happening in the kernel (i.e., that the kernel-level threads are also blocked).

<center>
<img src="./assets/P02L04-018.png" width="450">
</center>

A more useful configuration would be to have the kernel notify the user-level library immediately prior to blocking the kernel-level threads, and then the user-level library (which assesses its current state to determine that it has available user-level threads in the run queue) can make a system call to request more kernel-level threads (and corresponding light-weight processes) from the kernel.

<center>
<img src="./assets/P02L04-019.png" width="450">
</center>

Now, with an extra kernel-level thread allocated, the user-level library can proceed with scheduling the remaining available user-level threads onto the associated light-weight process.

<center>
<img src="./assets/P02L04-020.png" width="450">
</center>

At a later time, when the I/O operation completes, at some point the kernel will notice that the additionally allocated kernel-level thread is consistently idle, and correspondingly will notify the user-level library that this kernel-level thread is no longer available.

As this example demonstrates:
  * The user-level library is unaware of what is happening in the kernel
  * The kernel is unaware of what is happening in the user-level library

Both of these observations therefore are problematic. To address these issues, in the Solaris threading implementation, certain **system calls** and **special signals** are introduced in order to allow the kernel and the user-level threading library to interact and coordinate.

## 11. PThread Concurrency Quiz and Answers

Consider an example of how the PThreads threading library can interact with the kernel to manage the level of concurrency that a process receives.

In the PThreads library, which **function** sets the concurrency level? (What is the function's name?)
  * `pthread_setconcurrency()`

Given the above function, which concurrency **value** instructs the implementation to manage the concurrency level as it deems appropriate? (What is the corresponding integer value?)
  * `0`

*Reference*: [manpage](https://man7.org/linux/man-pages/man3/pthread_getconcurrency.3.html)

## 12. Thread Management Visibility and Design

### Lack of Thread Management Visibility
