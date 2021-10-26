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

Because of their relative simplicity, spinlocks are a **basic synhcronization primitive**, which in turn can be used to implement more-complex, more-sophisticated synchronization constructs. Therefore, because they are a basic construct, spinlocks will be revisited later in this lecture; accordingly, the next sections will discuss different **implementation strategies** for spinlocks.

## 5. Semaphores

