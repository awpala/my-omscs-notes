# P3L4: Synchronization Constructs

## 1. Preview

Up to this point in the course, **synchronization** has been mentioned multiple times while discussing other operating systems concepts. This lecture will now focus primarily on synchronization itself.

This lecture will discuss several **synchronization constructs**, as well as the **benefits** of using these constructs.

Furthermore, this lecture will discuss the **hardware-level support** that is necessary to implement these synchronization primitives.

In covering these concepts, this lecture will reference the paper "*The Performance of Spin Lock Alternatives for Shared-Memory Multiprocessors*" (1990) by Thomas E. Anderson, involving the efficient implementation of spinlock (synchronization) alternatives. This paper will give a deeper understanding of how synchronization constructs are implemented on top of the underlying hardware and why they exhibit certain performance strengths.

## 2. Visual Metaphor

<center>
<img src="./assets/P03L04-001.png" width="400">
</center>

Returning to the toy shop analogy, now consider synchronization and synchronization mechanisms in the context of this example/analogy. **Synchronization** in operating systems is like waiting for a toy shop co-worker to finish so that you can continue working.

| Characteristic | Waiting Toy Shop Worker | Synchronization |
| :---: | :---: | :---: |
| May repeatedly check if the working co-worker / co-process is done in order to continue working | The waiting co-worker asks: "*Are you done? Or still working?*" This can have a negative impact on the working co-worker by delaying their processing and annoying them. | Processes may repeatedly check whether it is allowable to continue using a synchronization construct called a **spinlock**, which is supported in operating systems.  |
| May wait for a signal from the working co-worker / co-process in order to continue | The working co-worker indicates to the waiting co-worker: "*Hey, I'm done!*" However, the waiting worker may not be ready at this particular time (e.g., left for lunch break), therefore it may take an elapsed time period for the waiting co-worker to return and proceed with processing the toy work order. | Processes can synchronize using **mutexes** and **condition variables**, as discussed previously (cf. P2L2). These constructs can be used to implement the behavior whereby a process waits for a **signal** from another process before it can continue working. |
| Waiting hurts performance | In both of the above cases, the workers waste some amount of productive time while waiting. | Regardless of how the process waits and which synchronization mechanism is used, such waiting will adversely impact performance (e.g., wasted CPU cycles when performing checking operations, as well as due to cache effects when signaling another process that is periodically blocked and subsequently returning and resuming execution).  |

## 3. More About Synchronization

<center>
<img src="./assets/P03L04-002.png" width="550">
</center>

There has already been a fair amount of discussion in this course regarding dealing with concurrency in multi-threaded programs. Specifically, **mutexes** and **condition variables** were described, both in generic terms via Birrell's model (cf. P2L2) and their specific APIs and usage in the context of PThreads (cf. P2L3).

So then, why bother to discuss even *more* about synchronization here?

<center>
<img src="./assets/P03L04-003.png" width="550">
</center>

In the aforementioned discussion of mutexes and condition variables, it was indicated that these constructs have a number of common **pitfalls**, including:
  * Error-proneness, (in)correctness, and ease of use (e.g., forgetting to unlock the mutex, unlocking the wrong mutex, signaling the wrong condition variable, etc.).
    * These issues are an indication that the use of mutexes and condition variables is *not* an error-proof method, which means that such errors in turn may adversely affect the **correctness** of programs that use mutexes and condition variables, and in general will affect the ease of use of these two synchronization constructs.
  * Lack of expressive power.
    * It is necessary to introduce **helper variables** in order to express invariants (e.g., to control readers/writers access to a shared file) or to deal with priority control/restrictions (i.e., given that mutexes and condition variables do not inherently allow to specify anything regarding regarding **priority**).
    * Furthermore, this implies that these two synchronization constructs lack expressive power, inasmuch as they cannot be used to easily express arbitrarily complex **synchronization conditions**.

Furthermore, mutexes and condition variables (and any other software synchronization constructs, for that matter) require **low-level support** from the hardware in order to guarantee correctness of these synchronization constructs. Hardware provides this type of low-level support via **atomic instructions**.

Therefore, for the reasons enumerated above, it is sensible to spend more time discussing synchronization. Accordingly, this lecture will:
  * Examine a few other constructs (some of which eliminate some of these issues with mutexes and condition variables)
  * Discuss different types of uses for the underlying atomic instructions in order to achieve efficient implementations of certain synchronization constructs.

## 4. Spinlocks (Basic Synchronization Construct)

<center>
<img src="./assets/P03L04-004.png" width="500">
</center>

One of the most basic synchronization constructs that is commonly supported in an operating system is the **spinlock**.

In some ways, spinlocks are similar to mutexes, e.g.,:
  * The spinlock is used to protect the critical section to provide **mutual exclusion** among potentially multiple threads (or processes) attempting to perform the critical-section code.
  * The spinlock has certain **constructs** that are equivalent to the locking and unlocking constructs/operations of mutexes.
    * The corresponding use of these lock and unlock operations in spinlocks is similar to that of mutexes: If the lock is free then it can be acquired and consequently the critical section can be executed, otherwise if the lock is *not* free then the thread will be suspended at this particular point (i.e., `spinlock_lock(s)`) and unable to proceed.

However, a key **difference** between a spinlock and mutex is that when the lock is busy, the thread that is suspended in its execution (i.e., suspended at `spinlock_lock(s);`) is *not* blocked (i.e., as in the case of mutexes), but rather it is **spinning** (i.e., it is running on the CPU and repeatedly checking to see whether the lock has been freed, burning CPU cycles in this manner until the lock becomes free or until the thread becomes preempted for some reason [e.g., its timeslice has expired, a higher-priority thread has become runnable, etc.]). Conversely, with mutexes, the thread would have relinquished the CPU and allowed another thread to run.

Because of their relative simplicity, spinlocks are a **basic synhcronization primitive**, which in turn can be used to implement more-complex, more-sophisticated synchronization constructs. Therefore, because they are a basic construct, spinlocks will be revisited later in this lecture to discuss different **implementation strategies** for spinlocks.

## 5. Semaphores

<center>
<img src="./assets/P03L04-005.png" width="400">
</center>

The next synchronization construct to discuss is the **semaphore**. Semaphores are common synchronization constructs that have been part of operating system kernels for a while.

As a first approximation, a semaphore acts like a traffic signal, i.e., it either:
  * Allows threads to ***go***.
  * Or ***stops***/***blocks*** threads from proceeding any further.

Therefore, a semaphore is somewhat similar to what was discussed regarding a mutex (which either allows the thread to obtain the lock and proceed with the critical section, or the thread is blocked and must wait for the mutex to become free), however, a semaphore is ***more general*** than the behavior that can be achieved with a mutex.

<center>
<img src="./assets/P03L04-006.png" width="550">
</center>

More formally, a semaphore is **represented** by a positive integer value.
  * On **initialization**, a semaphore is assigned some **maximum value** (a positive integer).
  * Threads arriving at the semaphore will **try** the semaphore.
    * If the value of the semaphore is ***non-zero***, then its value is ***decremented*** and the thread will **proceed**.
    * If the value is ***zero***, then the thread must **wait**.
    * Therefore, the number of threads that are allowed to proceed equals the maximum value that was used to initialize the semaphore.
  * On **exit**, threads leaving the critical section will **post** (i.e., signal) to the semaphore, causing the semaphore's counter to ***increment***.

Therefore, as a synchronization construct, one of the key **benefits** of a semaphore is that it allows to express **count-based synchronization requirements** (e.g., `5` producers may be able to produce at the same time, via initialization of the semaphore to the maximum value of `5`).

Furthermore, if a semaphore is initialized with the value `1`, then its behavior is equivalent to that of a mutex; such a semaphore is called a **binary semaphore**. Accordingly, for a binary semaphor, the **post** operation is equivalent to unlocking of a mutex.

<center>
<img src="./assets/P03L04-007.png" width="550">
</center>

As a historic aside, semaphores were originally designed by **Edsger W. Dijkstra** (1930-2002), a Dutch computer scientist and Turing award recipient. In Dijkstra's original model, the semaphore operations wait and post were referred to as **P** (*proberen*, Dutch for "*to test out / to try*") and **V (verhogen)** (*verhogen*, Dutch for "*to increase*") (respectively). These operations (i.e., `P` and `V`) are still commonly retained in descriptions and literature regarding semaphores, based on Dijkstra's pioneering work in this area.

## 6. POSIX Semaphores

<center>
<img src="./assets/P03L04-008.png" width="450">
</center>

A brief list of some of the semaphore-related operations that are part of the POSIX API are as follows:
```c
#include <semaphore.h>

sem_t sem;
sem_init(sem_t *sem, int pshared, int count);
sem_wait(sem_t *sem);
sem_post(sem_t *sem);
```

The header `semaphore.h` defines the type `sem_t` for the semaphore.

`sem_init()` is used to initialize the semaphore (i.e., of type `sem_t`). Regarding the parameters:
  * `sem` is a pointer to the semaphore.
  * `count` is the initialization count.
  * `pshared` is a flag indicating whether the semaphore is shared by threads within a single process, or across processes.

The operations `sem_wait()` and `sem_post()` take as a parameter the semaphore variable that was previously initialized (e.g., `sem`).

## 7. Mutex via Semaphore Quiz and Answers

Complete the following code snippet (i.e., the initialization routine for the semaphore, `sem_init()`) so that the semaphore has behavior identical to a mutex used by threads within a process:

<center>
<img src="./assets/P03L04-009.png" width="300">
</center>

Answer:
```c
#include <semaphore.h>
// ...
sem_t m;
sem_init(&m, 0, 1); // answer
// ...
sem_wait(&m);
  // critical section
sem_post(&m);
```

***Explanation***:
  * The second argument (`0`) indicates that the semaphore is a *non*-process-sharing semaphore.
  * The third argument (`1`) for the counter makes this a binary semaphore, whose behavior resembles that of a mutex.
    * When the operation `sem_wait()` is reached, it will decrement this counter and consequently will allow exactly *one* thread at a time to enter the critical section.
    * Similarly, the operation `sem_post()` will increment the counter, which is the equivalent of a mutex being freed.

***Reference***: [`sem_init()` man page](https://linux.die.net/man/3/sem_init)

***N.B.*** Most operating systems textbooks include some examples on how to implement one synchronization construct with another (e.g., mutexes and/or condition variables via semaphores). Therefore, they can be referenced accordingly for this purpose.

## 8-9. Reader/Writer Locks

### 8. Introduction

<center>
<img src="./assets/P03L04-010.png" width="550">
</center>

When specifying synchronization requirements, it is sometimes useful to distinguish among the different **types** of **accesses** that a **resource** can be accessed with.

For instance, it is commonly desirable to distinguish between those accesses that do *not* modify a shared resource (i.e, only **read**) vs. those accesses that *do* modify a shared resource (i.e., always **write**).
  * For **read** accesses, the resource can be ***shared*** concurrently.
  * For **write** accesses, this requires ***exclusive*** access of the resource.

Therefore, operating systems and language run-times support so-called **reader/writer locks**. Reader/writer locks can be defined similarly to a mutex, however, it is additionally necessary to specify the type of access (i.e., read vs. write) to be performed, and then the lock will behave accordingly.

### 9. Using Reader/Writer Locks

<center>
<img src="./assets/P03L04-011.png" width="500">
</center>

In Linux, a reader/write lock can be **defined** using the corresponding type `rwlock_t`, as provided by the header `linux/spinlock.h`.

To **access** a shared resource using this reader/write lock, use the appropriate interface provided by the operations `read_lock()` or `write_lock()`.

The reader/writer API also provides the corresponding unlock counterparts, `read_unlock()` and `write_unlock()` (respectively).

***N.B.*** A few other operations are supported on the reader/write lock type `rwlock_t`, however, the shown above are the primary ones. To explore more such operations, consult the [source code](https://elixir.bootlin.com/linux/latest/source/include/linux/rwlock.h) for the header file `linux/spinlock.h` accordingly.

<center>
<img src="./assets/P03L04-012.png" width="500">
</center>

Reader/writer locks are supported in many operating systems and language run-times (e.g., Windows (.NET), Java, POSIX, etc.). In some of these contexts, the reader/writer operations are referred to as "**shared/exclusive locks**."

However, certain aspects of the behavior of the reader/writer locks are **different** with respect to their **semantics**.
  * It may be sensible to permit a ***recursive*** `read_lock()` operation to be invoked, but then it can differ across implementations with respect to what exactly occurs when calling the complementary operation `read_unlock()`.
     * In some implementations, a single `read_lock()`/`read_unlock()` pair may unlock *every* single one of the `read_lock()` operations that have been recursively invoked from within the same thread.
     * In other implementations, a *separate* `read_unlock()` operation may be required for every single `read_lock()` operation.
  * With respect to the treatment of **priorities**...
    * Handling the **upgrade**/**downgrade** of a priority.
      * In some implementations, a reader (i.e., the owner of a shared lock) may be given a priority to **upgrade** the lock (e.g., conversion from a reader lock to a writer lock), as compared to a newly arriving request for a write/exclusive lock.
      * In other implementations, the owner of a reader lock first releases the lock and then subsequently attempts to re-acquire the lock with write-access permissions, contending with any other thread that is attempting to perform the same operation at that time.
    * Interaction between the **state** of the lock, the priority of the thread, and the **scheduling policy** in the overall system.
      * For instance, it can block a reader such that a thread that otherwise would have been allowed to proceed is blocked if there is already a writer having higher priority that is waiting on the lock. In this case, the writer is waiting because there are other threads that already have read access to the lock; therefore, if there is a **coupling** between the scheduling policy and the synchronization mechanisms, it is possible that a newly-arriving reader will be blocked (i.e., it will not be allowed to join the other readers in the critical section because the waiting writer has higher priority).

## 10. Monitors
