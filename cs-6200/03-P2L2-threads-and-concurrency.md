# P2L2: Threads and Concurrency

## 1. Preview

The previous lecture described processes and process management. Recall that a process is represented by its **address space** and its **execution context** (via corresponding **process control block**, or **PCB**).

### What if Multiple CPUs?

<center>
<img src="./assets/P02L02-001.png" width="350">
</center>

However, when represented this way, such a process can only execute at one CPU at any given point in time.

<center>
<img src="./assets/P02L02-002.png" width="400">
</center>

Conversely, in order for the process to execute on multiple CPUs simultaneously (i.e., taking advantage of modern multi-CPU/multi-core systems), such a process requires ***multiple*** execution contexts; such multiple execution contexts within a single process are called **threads**.

This lesson will therefore address the following:
  * What are **threads**?
  * How are **threads** different from **processes**?
  * What **data structures** and mechanisms are used to implement and manage **threads**?

This lesson will reference "*An Introduction to Programming with Threads*" (Birrell, 1989) to explain the concept of threads, a paper which describes:
  * threads and concurrency
  * basic mechanisms for multithreaded systems
  * synchronization

N.B. A later lesson will discuss a concrete multithreading system called **Pthreads** (**POSIX threads**).

## 2. Visual Metaphor

<center>
<img src="./assets/P02L02-003.png" width="200">
</center>

This lesson will discuss threads and concurrency. As an analogy, a **thread** is like a worker in a toy shop, which has the following characteristics:

| Characteristic | Toy Shop Metaphor | Operating System |
| :--: | :--: | :--: |
| is an active entity | executing a unit of work required for a toy order | executing a unit of work on behalf of a process |
| works simultaneously with others | many workers completing toy orders | many threads executing (i.e., **concurrency**, which can occur on multicore systems in which multiple threads execute at the exact same time) |
| requires coordination  | sharing of tools, parts, workstations, etc. (particularly when multiple workers are working simultaneously, and perhaps even contributing to the *same* toy order) | sharing of I/O devices, CPUs/cores, memory, etc. (i.e., coordinating ***access*** to the underlying platform resources, which is carefully controlled and scheduled by the operating system) |

This begs the question: How to determine which thread gets access to the underlying platform resources?
  * As this lesson will discuss, this is a very important design decision made by both operating systems and software developers in general.

## 3. Process vs. Thread

<center>
<img src="./assets/P02L02-004.png" width="300">
</center>

Recall from the previous lesson that a **single-threaded process** is represented by:
  * its **address space**, which consists of all of the virtual-to-physical address mappings (e.g., code, data, files, etc.)
  * its **execution context** (containing information about the registers' values, the stack pointer, the program counter, etc.)

The operating system contains all of this information in a **process control block (PCB)**

<center>
<img src="./assets/P02L02-005.png" width="550">
</center>

Conversely, **threads** represent multiple independent execution contexts, which:
  * are part of the *same* virtual address space, thereby sharing the same virtual-to-physical address mappings (i.e., code, data, and files)
  * in general execute *different* instructions, access different portions of the address space, operate on different potions of the input, and differ in other ways as well
    * therefore, each thread must have its own *distinct* program counter, stack pointer (and corresponding stack), and thread-specific registers, which accordingly requires different/distinct **data structures** to represent this thread-specific information

The operating system representation of such a **multithreaded process** will therefore be a more complex **process control block (PCB)** structure than the single-threaded counterpart, which contains:
  * all of the information that is ***shared*** among the threads (e.g., virtual address mappings, description of the code and data, etc.)
  * ***separate*** information about each thread-specific execution context that is part of the process

## 4. Benefits of Multithreading: Why Are Threads Useful?

Consider a **multi-processor** (or **multi-core**) system as a representative example. At any given time, when running a given process, there may be multiple threads (`T1`, `T2`, `T3`, `T4`) belonging to the process running concurrently on a different processor.

<center>
<img src="./assets/P02L02-006.png" width="450">
</center>

One possibility is that each thread executes the ***same*** code, but for a different subset of the input (e.g., a different portion of an input array or an input matrix).
  * While all of the threads execute the exact same code, however, they are not necessarily executing the exact same instruction at a given point in time. Therefore, each thread will require its own private copy of the stack, program counter, registers, etc.

**Parallelization** of the program in this manner achieves **speedup**: the input can be processed much faster than via the corresponding counterpart of a single thread running on a single CPU.

<center>
<img src="./assets/P02L02-007.png" width="450">
</center>

Additionally, threads can also execute completely ***different*** portions of the program.
  * Certain threads can be designated to specific I/O tasks (e.g., input processing, display rendering, etc.)

Another option is to have different threads operate on different portions of the code corresponding to specific functions or **tasks** (e.g., a large Web service application can have different threads to handle different types of customer requests).

This type of **specialization** (whereby different threads run different tasks or run different portions of the program) allows to differentiate how the threads are managed.
  * For example, higher priority can be given to those threads which handle more important tasks, more important customers, etc.

<center>
<img src="./assets/P02L02-008.png" width="350">
</center>

Another important benefit of partitioning the exact operations performed by each thread on each CPU derives from the fact that performance is dependent on how much state information can be stored/present in the **hardware cache**.
  * Since each thread running on a separate CPU core has access to its own processor cache (denote `$` in the figure above). Therefore, if the thread repeatedly executes a smaller portion of the code (e.g., one task), more of the relevant program state and information will be present in the corresponding cache, thereby improving the operation of each thread on a **hot cache**.

<center>
<img src="./assets/P02L02-009.png" width="350">
</center>

While the natural conclusion may be to write a **multiprocess** application wherein every CPU core runs a separate process, since the processes do not share an address space, each context must be allocated a ***separate*** address space and execution context. Therefore, such a multiprocess implementation would require separate allocations of address spaces and execution contexts.

<center>
<img src="./assets/P02L02-010.png" width="350">
</center>

Conversely, a **multithreaded** implementation consists of threads ***sharing*** an address space (thereby obviating the requirement to allocate the address space to *each* execution context), which is much more memory-efficient than its multiprocess counterpart. Consequently, such a multithreaded application is more likely to fit in memory and not require as many swaps with the disk compared to the multiprocess alternative.

Another **issue** to consider is that communicating/passing data or synchronizing among processes requires interprocess communication mechanisms that are more costly.
  * As will be discussed later in this lesson, communication and synchronization among threads in a single process is performed via shared variables within the process's address space, which obviates the requirement for this costly interprocess communication.

In summary, multithreaded applications are more efficient in their resource requirements and incur lower overhead for their interprocess communication (i.e., between threads) than corresponding multiprocess applications.

## 5. Benefits of Multithreading: Are Threads Useful on a *Single* CPU?

Are threads useful on a single CPU? Or, more generally, are threads useful when `# Threads > # CPUs`?

<center>
<img src="./assets/P02L02-011.png" width="300">
</center>

Consider the scenario of a single thread `T1` making a disk request.
  * Upon receiving the request, the disk requires time `t`<sub>`idle`</sub> to fulfill the request (i.e., time required to move the disk spindle, access the appropriate data, and then respond to the request).
  * During `t`<sub>`idle`</sub>, thread `T1` cannot perform any useful work and instead must wait for the response (i.e., the CPU is **idle** during this time).

If `t`<sub>`idle`</sub> is longer than the time required to perform a context switch, then it may be sensible to perform a context switch to another thread (e.g., `T2`) during this time instead. In particular, `t`<sub>`idle`</sub> `>=` `2t`<sub>`ctx_switch`</sub> is the critical point at which context switching can "hide" idling time.
  * This applies to both processes and threads, however, recall that one of the most costly steps during a context switch is the time required to create the new virtual-to-physical memory mapping of the address space for the new process that will be scheduled. However, given that threads ***share*** an address space, when context switching among ***threads*** it is ***not*** necessary to recreate ***new*** virtual-to-physical memory mapping.
  * Therefore, because this costly step is avoided, in general `t`<sub>`ctx_switch`</sub> is less among threads than among processes. Correspondingly, it is much more likely the critical point will be reached when using threads, and so threads can be effectively used in this manner to **hide latency** (i.e., by being productive during idling time), even on a ***single*** CPU.

## 6. Benefits of Multithreading: Applications and Operating Systems Code

<center>
<img src="./assets/P02L02-012.png" width="500">
</center>

There are benefits from multithreading both to applications and to the operating system itself.

By multithreading the **operating system kernel**, this allows the operating system to support multiple execution contexts (which is particularly useful when there are multiple CPU cores present, allowing for concurrent execution of the operating system contexts on the different CPUs of a multiprocessor/multicore platform)
  * The operating system's threads may run on behalf of multiple **applications**
  * The operating system's threads may also run on behalf of OS-level **services** (e.g., daemons, device drivers, etc.)

## 7. Process vs. Threads Quiz and Answers

Do the following statements apply to processes (`P`), threads (`T`), or both (`B`)?
  * can share a virtual address space
    * `T` 
  * take longer to context switch
    * `P` - by sharing a virtual address space, threads are able to perform context switches faster
  * have an execution context
    * `B` - in each case, the execution context is described by the stack and registers
  * usually result in hotter caches when multiple exist
    * `T` - because threads share the virtual address space, it is more likely that concurrently executing threads will result in hot caches on the respective CPU cores; conversely, such sharing is not possible among processes
  * make use of some communication mechanisms
    * `B` - for processes, the operating system supports interprocess communication (IPC) mechanisms; there are also corresponding mechanisms for coordinating among threads (as will be seen later in this lesson)

## 8. Basic Thread Mechanisms: What Do We Need to Support Threads?

To support threads, the following are required:
  * a distinct thread **data structure** to distinguish it from a process
    * identify threads, keep track of resource usage, etc.
  * mechanisms to ***create*** and ***manage*** threads
  * mechanisms to safely ***coordinate*** among the threads running **concurrently** in the *same* address space (particularly when there are ***dependencies*** between their execution)
    * for example, it must be ensured that concurrently executing threads do not overwrite each others' inputs or results
    * for example, there must be mechanisms in place to allow one thread to wait on results produced by another thread

### Threads and Concurrency

When considering the type of coordination required between threads, we first must consider the **issues** inherent to concurrent execution.

<center>
<img src="./assets/P02L02-013.png" width="500">
</center>

When **processes** run concurrently, each process operates within its *own* address space. The operating system together with the underlying hardware ensure that ***no*** access from one address space to another occurs.
  * For example, in the figure above, the mapping of `VA_p1` (virtual address of process `p1`) to `PAx` (physical address `x`) will be valid for process `p1` but invalid for process `p2` (i.e., process `p2` will not be able to perform a valid access operation on physical address `x`).

Conversely, **threads** share the ***same*** virtual-to-physical address mappings.
  * For example, in the figure above, both threads `T1` and `T2` (both concurrently running on the *same* virtual address space) can both access the *same* physical address `x`.

<center>
<img src="./assets/P02L02-014.png" width="300">
</center>

Consequently, this introduces some **problems**. If threads `T1` and `T2` are both allowed to access and to modify the same data simultaneously, this can yield several **inconsistencies**, e.g.,:
  * one thread may attempt to read the data while another is modifying it
  * two (or more) threads attempt to modify the data simultaneously, resulting in a **data race**
  * etc.

  ### Concurrency Control and Coordination

<center>
<img src="./assets/P02L02-015.png" width="250">
</center>

To deal with these concurrency issues, mechanisms are required to enforce execution of threads in an ***exclusive*** manner; such mechanisms are called **mutual exclusion**.
  * In mutual exclusion, exclusive access is granted to only one thread at a time to perform any given operation; the remaining threads must wait their turn to perform this same operation.
  * Such **operations** performed under mutual exclusion include: update to state, general access to a data structure that is shared among the threads, etc.
  * To achieve this, Birrell's and other threading systems use what are called **mutexes**.

<center>
<img src="./assets/P02L02-016.png" width="150">
</center>

Additionally, it is also useful for concurrently executing threads to have a mechanism to **wait** on one another, and to exactly specify the necessary **condition** required before proceeding.
  * For example, a thread dealing with shipment processing must wait on all of the items in the shipping order to be processed before the order can be shipped.
  * Birrell discusses the use of **conditional variables** to handle this kind of inter-thread coordination.

Both mutual exclusion and waiting are referred to as **synchronization mechanisms**.
  * Additionally, Birrell describes another such mechanism involving waking up other threads from a **wait state**. (This will be discussed more in a later lesson.)

## 9. Threads and Thread Creation


