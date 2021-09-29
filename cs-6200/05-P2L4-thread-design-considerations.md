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

## 4. Thread-Related Data Structures: At Scale


