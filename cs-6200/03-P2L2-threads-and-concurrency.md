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

Consider now:
  * how threads should be represented by an operating system or by a system library that provides multithreading support
  * what is necessary to perform **thread creation**

N.B. During this lesson, discussion will be based on the **primitives** described and used in Birrell's paper, which do not necessarily correspond to certain interfaces provided by real threading systems or programming languages. Furthermore, the next lesson will discuss **Pthreads (POSIX threads)**, a threading interface supported by most modern operating systems, to serve as a more concrete example.

<center>
<img src="./assets/P02L02-017.png" width="400">
</center>

The **thread type** (a thread data structure proposed by Birrell) contains all of the information that is specific to the thread, e.g.:
  * thread identifier
  * registers
  * program counter
  * stack pointer
  * the stack
  * any other attributes and/or data used by the thread (e.g., used by the thread management systems to determine how to schedule threads, how to debug threads, etc.) 

For new **thread creation**, Birrell proposes the function `Fork(proc, args)`, where `proc` is the procedure that the created thread will begin executing and `args` provides the corresponding arguments to the procedure
  * Per the figure above, when thread `T0` calls `Fork()`, a new thread `T1` is created, along with a corresponding new thread data structure, whose constituent values are initialized accordingly (e.g., its program counter `PC` points to `proc` with `args` available on its own stack).
  * After the `Fork()` operation completes, the overall process is now running via two threads `T0` (parent thread) and `T1` (child thread), with both executing concurrently.
    * `T0` proceeds to the subsequent operation immediately following the call to `Fork()`
    * `T1` commences execution of `proc(args)`

  N.B. Birrell's `Fork()` should *not* be confused with the UNIX system call `fork()` discussed previously, which creates a new process as an exact copy of the calling process

Once `T1` completes execution of `proc(args)` (i.e., and correspondingly returning a result or some other status regarding the computation), it must communicate this information back to the process.
  * One programming practice is to store the result of the computation in some well-defined location in the mutually accessible address space (i.e., among all of the threads), with a corresponding mechanism to notify either the parent or some other thread that the result is now available.
  * More generally, however, some **mechanism** is required to determine that the thread has completed execution, and (if necessary) to retrieve its result or to determine the corresponding status of the computation (e.g., success or error).

<center>
<img src="./assets/P02L02-018.png" width="400">
</center>

To deal with this issue, Birrell proposes the function `Join(thread)` to terminate a thread
  * When the parent thread calls `Join()` (e.g., `child_result = Join(T1)` in the figure above), it will be **blocked** until the child thread completes. `Join()` will then return the result of the child thread's computation to the parent thread, at which point the child thread exits the system and its allocated data structure (i.e., state and resources) will be freed and the child thread is consequently terminated.

Observe that other than this mechanism whereby the parent thread is the one `Join()`ing the child, in all other aspects both the parent and child thread are completely equivalent, with both being able to access and share all resources (e.g., hardware, CPU, memory, etc.) and state available to the process as a whole. 

## 10. Thread Creation Example

The following code snippet illustrates **thread creation**:

```c
Thread thread1;
Shared_list list;
thread1 = Fork(safe_insert, 4);
safe_insert(6);
Join(thread1); // optional
```

Two threads are involved in this system:
  1. the parent thread which executes the code
  2. the child thread `thread1` created via call to `Fork()`

<center>
<img src="./assets/P02L02-019.png" width="150">
</center>

Both threads perform the operation `safe_insert()` on `list` (of type `Shared_list`), which is initially empty.

<center>
<img src="./assets/P02L02-020.png" width="350">
</center>

Assume initially that the process begins with one parent thread `T0`, which subsequently calls `Fork()`, resulting in the creation of child thread `T1` (which in turn calls `safe_insert(4)`).

<center>
<img src="./assets/P02L02-021.png" width="250">
</center>

`T0` subsequently calls `safe_insert(6)`, however, since both threads execute concurrently (with corresponding context switches on the CPU), the order in which these `safe_insert()` operations are called is ambiguous (i.e., the insertion order into the list is non-deterministic).

<center>
<img src="./assets/P02L02-022.png" width="350">
</center>

Therefore, when performing the final `Join()` operation:
  * if `Join(thread1)` is called when child thread `T1` has already completed, then it will return immediately
  * if `Join(thread1)` is called when child thread `T1` is still executing, then parent thread `T0` will be ***blocked*** until child thread `T1` completes execution

N.B. In this particular example, the results of the child thread's processing are available via `list`, therefore the `Join()` operation is not strictly necessary here (i.e., the result of the child thread `T1`'s operation is available irrespectively of the call to `Join()`).

## 11. Mutexes

So, then, how is `list` supposed to be updated?

<center>
<img src="./assets/P02L02-023.png" width="350">
</center>

An example naive implementation (corresponding to the figure shown above) is as follows:

```
create new list element e
set e.value = X
read list and list.p_next
set e.p_next = list.p_next
set list.p_next = e
```

Here, each list element has two fields:
  1. `value`
  2. `p_next`, which points to the next element in the list

<center>
<img src="./assets/P02L02-024.png" width="450">
</center>

The first list element `list.head` can be accessed by reading the value of the shared variable `list`. Each thread that needs to insert a new element into the list will do the following (as per the figure shown above):
  1. create the new element `e` and set its value `e.value` (e.g., `value_x`)
  2. read the list (i.e., `list.head`) and its value `list.p_next` (e.g., pointer to element containing `value_y`)
  3. set `e.p_next` to `list.p_next`
  4. set `list.p_next` to `e`

Therefore, with this process, new elements are inserted at the head of the list.

<center>
<img src="./assets/P02L02-025.png" width="350">
</center>

Clearly, there is a **problem** if two threads running concurrently on two separate CPU cores attempt to update `list.p_next` simultaneously; the resulting behavior is non-deterministic.

<center>
<img src="./assets/P02L02-026.png" width="350">
</center>

Another **problem** occurs if two threads are running on the CPU simultaneously because their operations are randomly interleaved. For example, both may read the value of `list` and `list.p_next` (e.g., with `list.p_next` having value `NULL` per the figure shown above).

<center>
<img src="./assets/P02L02-027.png" width="450">
</center>

In this case, both may set `e.p_next` to `NULL`, and then subsequently take turns setting `list.p_next` to `e`, with only one of them actually being inserted into the list (e.g., the element with value `value_x` in the figure shown above) while the other is not and is consequently simply "lost." 

## 12. Mutual Exclusion

