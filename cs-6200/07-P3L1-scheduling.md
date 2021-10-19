# P3L1: Scheduling

## 1. Preview

This lecture will discuss in detail the key **resource management** components in operating systems.

First, the lecture will examine how the operating system manages CPUs, and how it decides how processes and their threads will get to execute on those CPU. This activity is performed by the **scheduler**.

The lecture will review some the **scheduling mechanisms**, **algorithms**, and **data structures** used by the scheduler.

This lecture will also examine in more detail some of the scheduling algorithms used in the Linux operating system (e.g., **O(1)** and the **Completely Fair Scheduler (CFS)**).

This lecture will also examine certain aspects of scheduling that are common for **multi-CPU platforms**, including multi-core platforms as well as platforms with hardware-level multi-threading (e.g., pay-per-chip multi-threaded processors, which require a new operating system scheduler) in order to demonstrate some of the more **advanced features** that modern schedulers should incorporate.

## 2. Visual Metaphor

This lecture will be discussing at length regarding scheduling and operating system schedulers.

Continuing with the visual metaphor, consider some of the **issues** that arise with respect to operating system scheduling.

<center>
<img src="./assets/P03L01-001.png" width="500">
</center>

Returning to the toy shop an analogy, like an **operating system scheduler**, a **toy shop manager** schedules work in the toy shop. There are multiple ways in which the toy shop manager can schedule the toy shop orders and dispatch them to workers in the toy shop. The motivation for each of these choices is based on some of the high-level goals of the manager and how he wants to manage the shop (i.e., how to utilize the shop's resources).

| Toy Shop Manager Characteristic | Description |
| :--: | :--: |
| Dispatch orders immediately | Scheduling is simple (e.g., **first-in, first-out (FIFO)**), giving rise to low scheduling overhead|
| Dispatch simple orders first | If the objective is for the total number of orders processed per-unit time, then the objective is to maximize the number of orders processed over time; this requires additional processing by the manager for incoming orders (e.g., assessing simple vs. complex orders) |
| Dispatch complex orders first | Since each workbench in the shop may have a variety of tools (which may be underutilized by simple orders), if the objective is to keep all available resources at the workbenches as busy as possible, then the manager ensures to schedule complex orders as soon as they arrive, and if simple orders arrive subsequently, then the workers can suspend work on the complex orders and perform the simple orders, and then return to completing the complex orders |

| Operating System Characteristic | Description |
| :--: | :--: |
| Assign tasks immediately | Scheduling is simple (e.g., **first-come, first-serve (FCFS)**), thereby reducing overhead in the CPU scheduler itself |
| Assign simple tasks first | If the objective is to maximize throughput, then perform tasks with the shortest running time first (e.g., **shortest job first (SJF)**) |
| Assign complex tasks first | If the objective is to maximize utilization of the platform's resources (e.g., CPU(s), devices, memory, etc.), then perform complex tasks first |

***N.B.*** Here, a **task** refers to a thread or process in the context of an operating system scheduler, which schedules the tasks onto the CPUs (analogous to the workbenches in the toy shop) that the scheduler manages.

As this lecture proceeds, it will discuss some of the options to consider when designing **algorithms** such as the aforementioned, as well as various aspects of the **design** and **implementation** of operating system schedulers.

## 3. CPU Scheduling Overview

**CPU scheduling** was briefly discussed in a previous lecture on processes and process management (cf. P2L2).

Recall that a **CPU scheduler** decides ***how*** and ***when*** **processes** (and their constituent **threads**) access **shared CPUs** in the system. In this lecture, the term **task** will be use to refer to processes and thread interchangeably, since the same kinds of mechanisms are valid in both of these contexts.

The CPU scheduler concerns the scheduling of *both* **user-level processes/threads** as well as **kernel-level threads**.

<center>
<img src="./assets/P03L01-002.png" width="650">
</center>

Recall (cf. P2L2, regarding processes and process scheduling) that the key **responsibility** of the CPU scheduler is to select ***one*** of the tasks in the **ready queue** to be scheduled to run on the CPU. As per the figure shown above, tasks may become ready (i.e., they may enter the ready queue) after a blocking I/O operation completes, after a blocking interrupt completes, after being created via fork from a parent process, or after a time slice expires (i.e., it is removed from the shared CPU due to its alloted time on the CPU expiring in order to allow another task to use the CPU).

Therefore, in order to perform scheduling, the CPU scheduler will assess all of the tasks currently in the ready queue to determine which *one* it will dispatch to run the CPU next.
  * Whenever the CPU becomes **idle**, the CPU scheduler must run (e.g., if the scheduled task makes an I/O request and consequently leaves the CPU abruptly to enter the I/O request queue, then the CPU is now idle). The **objective** of the CPU scheduler in this case is to select another task from ready queue as soon as possible in order to **minimize** this idle time on the CPU.
  * Furthermore, whenever a **new task** becomes ready (i.e., is available on the ready queue), the CPU scheduler must be run. The **objective** of the CPU scheduler in this case is to check whether any of the tasks are of relatively high **priority**/**importance** (and therefore should interrupt the currently executing task on the CPU).
  * A common way in which a CPU is shared among the tasks by the CPU scheduler is to assign each task in the system a **timeslice** (i.e., an allotted amount of time in residence on the CPU), such that when the timeslice expires, then the running task is consequently removed from the CPU, thereby initiating a subsequent scheduling operation for the next task.

Once the CPU scheduler selects a task to be scheduled, the task is consequently **dispatched** onto the CPU. This involves the following sequence of events:
  1. A **context switch** (i.e., entering the context of the newly selected task)
  2. Enter **user mode**
  3. Set the **program counter** to the appropriate next-executing instruction from the newly selected task
  4. Proceed with execution of the new task on the CPU

<center>
<img src="./assets/P03L01-003.png" width="650">
</center>

In summary, the **objective** of the **CPU scheduler** is to select the next **task** to run from the **ready queue**.

To achieve this objective, ***which*** task should be selected?
  * This will depend on the particular **scheduling policy/algorithm** that is executed by the CPU scheduler. (Several such algorithms will be described next in this lecture.)

Furthermore, ***how*** is this accomplished (i.e., how are these scheduling algorithms performed)?
  * The details of the CPU scheduler's implementation are highly dependent on the **runqueue** data structure used to implement the ready queue.

Therefore, the design of the runqueue and of the corresponding scheduling algorithm are ***tightly coupled***, as will be discussed in this lecture.
  * Certain scheduling algorithms demand a different type of runqueue data structure
  * Similarly, the design of the runqueue can limit types of scheduling algorithms that it is able to support efficiently.

## 4. "Run-to-Completion" Scheduling

### Introduction: Run-to-Completion Scheduling Algorithms

For the initial discussion of scheduling algorithms, first consider the algorithm called **run-to-completion scheduling**, which assumes that as soon as a task is assigned to a CPU, it will run until the task is completed.

<center>
<img src="./assets/P03L01-004.png" width="550">
</center>

With respect to this algorithm, the following **initial assumptions** will be made:
  * There is a **group** of tasks to be scheduled
    * ***N.B.*** The terms "tasks," "jobs," and "threads" can be used interchangeably in this context.
  * It is known exactly how much time is required (i.e., the **execution time**) for each task to execute
  * There is **no preemption** in the system once the task begins to run (i.e., it will ***run to completion***, without interruption or preemption to run another task instead)
  * There is a *single* CPU available

***N.B.*** We will relax these requirements as the lecture progresses.

Since this lecture will examine various different scheduling algorithms, it will be important to be able to compare them, therefore, we must consider useful **metrics** for this purpose. With respect to comparing scheduling algorithms, some pertinent metrics include the following:
  * **throughput**
  * **average job completion time**
  * **average job wait time**
  * **CPU utilization**

### First-Come, First-Server (FCFS)

<center>
<img src="./assets/P03L01-005.png" width="550">
</center>

In the **First-Come, First Serve (FCFS)** scheduling algorithm (the simplest run-to-completion scheduling algorithm), tasks are scheduled on the CPU in the same order in which they arrival, regardless of their execution time, the system load, etc. When the task completes, the CPU scheduler will select the next-in-line task.

A useful way to organize the tasks is to use a first-in, first-out (FIFO) queue structure, whereby a newly arriving task is placed at the back of the queue, and the CPU scheduler selects the next task from the front of the queue. Correspondingly, to make these decisions, the CPU scheduler must only know the location of the queue's **head** as well as how to **dequeue** tasks from the queue structure. Therefore, for FIFO scheduling, a **FIFO queue** is a suitable runqueue data structure.

<center>
<img src="./assets/P03L01-006.png" width="550">
</center>

Consider a scenario where tasks `T1`, `T2`, and `T3` have the execution times `1s`, `10s`, and `1s` (respectively). Furthermore, the tasks arrive in the order `T1 (first) -> T2 -> T3 (last)` (i.e., the order in which the tasks are placed in the runqueue).

Evaluating the corresponding metrics gives the following:
  * ***throughput***
    * `3 tasks / (1 + 10 + 1) s = 0.25 tasks/s`
  * ***average completion time***
    * `(1 + 11 + 12) s / 3 tasks = 8 s/task`
      * `T1` completes in `1s`, which is immediately followed by execution of `T2` taking `10s` to complete (for a total completion time of `1 + 10 = 11s`, including the prior execution time of `T1`), and then finally `T3` completes execution in `1s` (in total `1 + 10 + 1 = 12s`, including the prior execution times of `T1` and `T2`)
  * ***average wait time***
    * `(0 + 1 + 11) s / 3 tasks = 4 s/task`
      * `T2` waits `1s` for `T1` to complete in order to proceed with execution, and similarly `T3` waits `10s` for `T2`

Given this simple scheduling algorithm, we can achieve better performance with respect to these metrics using other algorithms, as discussed next.

### Shortest Job First (SJF)

<center>
<img src="./assets/P03L01-007.png" width="550">
</center>

Observe that in the first-come, first serve scheduling algorithm, while it is simple, the average wait time for the tasks is poor, even with only a single "long" task occurring in the system (e.g., `T2`) ahead of relatively shorter tasks (e.g., `T3`).

To deal with this issue, another scheduling algorithm called **Shortest Job First (SJF)** schedules tasks in order of their ***execution time***, with ***shortest*** tasks executing ***first*** (e.g., via the previous example, `T1 (first) -> T3 -> T2 (last)`, where the tie between `T1` and `T3` is broken arbitrarily).

In order to organize the **runqueue** in a similar manner as before (i.e., as a FIFO queue), **adding** new tasks simply involves adding tasks at the tail of the queue, as before. However, when **scheduling** the tasks, the entire queue must be traversed in order to determine which task has the shortest execution time; therefore, the runqeue will no longer be a FIFO queue if adding new tasks in this manner, since addition and removal of tasks will not generally occur in order of placement in the runqueue.

One solution to this issue is to maintain the runqueue as an **ordered queue**, whereby placement of newly arriving tasks is done in a specified order. This makes the insertion operation into the queue more complex, however, this will restore the desired property of a FIFO queue, whereby the shortest task is always located at the head of the queue.

Furthermore, it is not necessary to use a queue data structure at all, but rather the runqueue can be a **tree-like data structure**, whereby the **nodes** representing the tasks are ordered within the tree structure in order of their execution time. When inserting a new node/task into the tree, the tree may need to be rebalanced, however, the CPU scheduler will simply select the left-most node/task to find the shortest-execution-time task.

Therefore, it is not strictly necessary to use a queue data structure for the runqueue; other data structures (e.g., trees) may be more appropriate for a particular scheduling algorithm.

## 5. SJF Performance Quiz and Answers

Consider an analysis of the performance of the shortest job first (SJF) scheduling algorithm. Assume that SJF is used to schedule the tasks `T1`, `T2`, and `T3`. Furthermore, assume the following:
  * The CPU scheduler does not preempt tasks (i.e., a run-to-completion model is used).
  * The known execution times are as follows: `T1 = 1s`, `T2 = 10s`, `T3 = 1s`
  * All three tasks arrive into the system at the same time, `t = 0s`

Calculate the throughput, average completion time, and average wait time via the SJF algorithm.
  * **throughput**
    * `3 tasks / (1 + 1 + 10) s = 0.25 tasks/s`
      * via ordering `T1 (first) -> T3 -> T2 (last)`
  * **average completion time**
    * `(1 + 2 + 12) s / 3 tasks = 5 s/task`
      * via ordering `T1 (first) -> T3 -> T2 (last)`
  * **average wait time**
    * `(0 + 1 + 2) s / 3 tasks = 1 s/task`
      * via ordering `T1 (first) -> T3 -> T2 (last)`

***N.B.*** Observe that the average completion time and average wait time are shorter compared to the first-come, first serve scheduling algorithm (cf. Section 4).

Reference equations:
* throughput
<center>
<img src="./assets/P03L01-008.png" width="200">
</center>

* average completion time
<center>
<img src="./assets/P03L01-009.png" width="200">
</center>

* average wait time
<center>
<img src="./assets/P03L01-010.png" width="425">
</center>

where *`n`*<sub>`tasks`</sub> is the number of tasks, *`t`*<sub>`e`</sub> is the total (cumulative) execution time for a task (i.e., relative to time `t = 0`), and *`t`*<sub>`w`</sub> is a wait time for a task.
  * ***N.B.*** *`i`* and *`j`* are indices denoting specific tasks, where both *`i`* and *`j`* are indexed in the ***order*** of the tasks' executions (e.g., *`i`* and *`j`* represent indices `1`, `2`, and `3` for tasks `T1`, `T3`, and `T2` (respectively) in this quiz's example). Correspondingly, index variables *`t`*<sub>*`i`*</sub> and *`t`*<sub>*`j`*</sub> denote these tasks' single-task execution times (e.g., `1s`, `1s`, and `10s` for tasks `T1`, `T3`, and `T2` (respectively) in this quiz's example).

## 6-7. Preemptive Scheduling

Up to this point, the discussion has assumed that the currently executing task on the CPU *cannot* be interrupted (i.e., cannot be preempted). Let us now *relax* this assumption/requirement and consider **preemptive scheduling**, wherein tasks do not have exclusive use of the CPU for the entire duration of their execution (i.e., they *can* be interrupted).

### 6. Shortest Job First (SJF) + Preempt

<center>
<img src="./assets/P03L01-011.png" width="650">
</center>

First, consider preemption in conjunction with the shortest job first (SJF) scheduling algorithm.

Here, let us additionally relax the assumption that all tasks arrive at the same time (i.e., time `t = 0 s`), but rather the tasks can **arrive** at ***arbitrarily different*** times. Furthermore, the initial assumption that the tasks' respective execution times are known still holds.

In the figure shown above, task `T2` arrives first (i.e., at time `t = 0s`). Therefore, upon arrival, the CPU scheduler detects `T2` and schedules it to run on the CPU immediately.

Upon arrival of tasks `T1` and `T3` at time `t = 2s`, `T2` is preempted due to the shortest job first scheduling algorithm (i.e., `T2`'s execution time is comparatively larger than both `T1` and `T3`).

The subsequent execution therefore occurs as in the time plot in the figure shown above. To achieve this behavior, whenever a new task(s) enter the runqueue (e.g., `T1` and `T3` at time `t = 2s`), the CPU scheduler must be invoked in order to inspect the execution times of the tasks and consequently decide whether or not to preempt the currently executing task (e.g., `T2` immediately prior to time `t = 2s`).

While it is assumed here that the execution time for each task is known, in practice it is difficult to determine this a priori, as this is influenced by many factors (e.g., input dependencies for the task, presence/absent of the task's data in the cache, which other tasks are running in the system, etc.).

Therefore, in principle, it is necessary to employ certain **heuristics** based on the task's history in order to estimate the execution time for the task in question. With respect to the *future* execution time of the task, a useful heuristic is to use the task's **past running time**, e.g.,:
  * How long did a task run in the most recent execution?
  * How long did a task run for the last `n` executions?
    * This can be used to to determine an average over a period of time, over a number of past executions, etc. Such an averaging over a defined time interval is called a **windowed average**.

### 7. Priority Scheduling

<center>
<img src="./assets/P03L01-012.png" width="650">
</center>

While the shortest job first (SJF) scheduling algorithm considers the task(s) with the shortest execution time(s) in order to determine tasks scheduling (i.e., by appropriate preemption as necessary), another key **criterion** for making these decisions involves whether the tasks have different **priorities**.

Tasks having different **priority levels** is a common scenario in scheduling problems (e.g., certain operating system kernel-level threads may have tasks with higher priority than other threads supporting user-level processes; within a user-level process, threads which monitor user input events may have relatively higher priority compared to other threads performing background processing or long-running simulations; etc.).

In such scenarios, the CPU scheduler must be able to run the **highest priority** task next, including capability for potential preemption of the currently running task if necessary.

Returning to the previous example, consider now the scenario which includes priority scheduling as in the figure shown above, whereby tasks `T1`, `T2`, and `T3` have priorities `P1`, `P2`, and `P3` (respectively) such that `P1 (lowest) < P2 < P3 (highest)`.

As before, the process begins with task `T2` executing immediately upon arrival at time `t = 0s`. Upon arrival of tasks `T1` and `T3` at time `t = 2s`, based on the relative priorities of these tasks, `T2` is preempted to permit the higher-priority task `T3` to execute.

Once `T3` completes execution, `T2` is now of relatively highest priority and proceed with completing execution, followed by `T1` (which executes last).

<center>
<img src="./assets/P03L01-013.png" width="650">
</center>

In practice, the CPU scheduler must be able to quickly assess not just the current group of runnable tasks, but also their respective relative priorities (i.e., for determination of which task to run at any given time).
  * This can be achieved via **multiple priority queues** as the runqueue, with one per priority level. Consequently, the CPU scheduler can select a task from the runqueue at the highest priority level first, followed by the next highest priority level, etc.
  * Alternatively, this can also be achieved via an **ordered data structure** (e.g., tree) as the runqueue, whereby the ordering is with respect to the priorities (rather than with respect to the execution time, as in the tree data structure for the shortest job first scheduling algorithm [cf. Section 4])

<center>
<img src="./assets/P03L01-014.png" width="650">
</center>

One **danger** with priority scheduling is a condition called **starvation**, whereby the low priority task(s) is stuck in the runqueue indefinitely due to persistent arrival of relatively higher priority tasks to the runqueue.

One **mechanism** to mitigate starvation is called **priority aging**, whereby the priority of the task itself is not fixed, but rather is a function of both its intrinsic priority level as well as the elapsed time spent in the runqueue, with the latter factor increasing in weight/importance as time progresses.

## 8. Preemptive Scheduling Quiz and Answers

Consider now the performance metrics for a preemptive CPU scheduler.

<center>
<img src="./assets/P03L01-015.png" width="400">
</center>

An operating system scheduler uses a priority-based scheduling algorithm with preemption to schedule tasks. Given the values shown in the table above, determine the finishing times of each task. Assume that the priorities are `P3 (lowest) < P2 < P1 (highest)`.
  * `T1` finishes at:
    * `t = 8s`
  * `T2` finishes at:
    * `t = 10s`
  * `T3` finishes at:
    * `t = 11s`

<center>
<img src="./assets/P03L01-016.png" width="400">
</center>

The time plot for these tasks is as shown in the figure above, which is described by the following sequence of events:
  1. `T3` arrives first, and executes for `3s` (`1s` remaining to complete `T3`).
  2. At time `t = 3s` `T2` arrives, and `T3` is preempted to allow `T2` to run. `T2` runs for `2s` (`2s` remaining to complete `T2`).
  * At time `t = 5s` `T1` arrives, and `T2` is preempted to allow `T1` to run. `T1` runs for `3s` to completion.
  * At time `t = 8s` (upon completion of `T1`), `T2` and `T3` remain in the runqueue. Since `T2` has relatively higher priority, it is scheduled to run, and subsequently runs to completion.
  * Finally, at `t = 10s`, `T3` is scheduled to run, and subsequently runs to completion.

## 9. Priority Inversion

An interesting phenomenon called **priority inversion** occurs when priorities are introduced into the scheduling.

<center>
<img src="./assets/P03L01-017.png" width="650">
</center>

Consider the configuration described in the figure shown above, which assumes a shortest job first (SJF) scheduling algorithm. Here, the priorities are: `P3 (lowest) < P2 < P1 (highest)`. For simplicity, the execution times are omitted, but can be assumed to have some finite duration extending beyond the time scale of the shown time plot.

The sequence of events is as follows:
  1. Initially, `T3` is the only task present in the system. At time `t = 3s`, `T3` acquires a lock.
  2. At time `t = 3s`, `T2` arrives, and since `T2` has a higher priority than `T1`, `T3` is preempted to allow for `T2`'s execution.
  3. At time `t = 5s`, `T1` arrives, and since `T1` has a higher priority than `T2`, `T2` is preempted to allow for `T1`'s execution.
  4. `T1` executes for `2s`, at which point it reaches a point in its execution where it must acquire the lock held by `T3`.
  5. Since the lock is not accessible by `T1`, `T1` is put on a wait queue associated with the lock, and the next highest priority task `T2` is consequently scheduled to execute.
  6. At time `t = 9s`, `T2` completes execution, and since `T3` is the only *runnable* task at this point, `T3` proceeds with execution.
  7. At time `t = 11s`, `T3` releases the lock, thereby allowing for the higher priority `T1` to proceed with execution; consequently, `T3` is preempted, and `T1` acquires the lock and executes.

Based on this sequence, the ***expected priority*** is `T1 (highest) > T2 > T3 (lowest)`. However, the ***actual order of execution*** that occurs is `T2`, `T3`, `T1`. Therefore, the priorities of the tasks are **inverted**.

A **solution** to this inversion problem is to temporarily **boost** the priority of the mutex owner (e.g., at time `t = 7s`, rather than executing `T2`, boost the priority of `T3` to the level of `T1` in order to allow `T3` to execute and eventually free the lock so that `T1` can proceed, rather than performing the intermediate switch to `T2` first instead).
  * This technique in particular demonstrates the importance of tracking the current owner of the mutex (e.g., in the corresponding mutex data structure), as this information allows to perform such coordination in the first place.
  * Furthermore, note that such boosting generally should only be performed ***temporarily*** (e.g., after `T3` releases the lock, it should be restored to its original low priority level).

***N.B.*** This boosting technique is used commonly in many operating systems today.

## 10. Round Robin Scheduling

When it comes to running tasks that have the ***same*** priority level, there are other options available in addition to the first-come, first-serve (FCFS) or shortest job first (SJF) scheduling algorithms discussed so far.

<center>
<img src="./assets/P03L01-018.png" width="650">
</center>

A popular option is the so-called **round robin scheduling** algorithm, as demonstrated in the figure shown above. Here, there are three tasks `T1`, `T2`, and `T3`, with all three having the *same* priority and entering the system at the same time (i.e., time `t = 0s`), and consequently entering the runqueue.

With round robin scheduling, the first task is selected from the head of the queue (e.g., `T1`), similarly to the first-come, first serve (FCFS) scheduling algorithm.

<center>
<img src="./assets/P03L01-019.png" width="650">
</center>

However, unlike in first-come, first-serve (FCFS) scheduling (where it is assumed that each task executes to completion), there is the possibility of a task being interrupted (e.g., `T1` yields to wait on an I/O operation at time `t = 1s`). If this occurs, the blocked task either completes or is placed at the tail of the queue, and the next task in the queue (e.g., `T2`) is selected to run. This process then proceeds in this manner until the queue is empty.

<center>
<img src="./assets/P03L01-020.png" width="650">
</center>

Conversely, if there were no I/O operation to interrupt `T1`, execution of the tasks would proceed as shown in the figure above (i.e., via the ordered placement in the runqueue).

<center>
<img src="./assets/P03L01-021.png" width="650">
</center>

Round robin scheduling can also be generalized to include **priorities**. Consider, for example (as in the figure shown above), tha the tasks arrive at different times having different priorities such that `P1 (lowest) < P2 < P3 (highest)`. In this case, if a higher priority task arrives (e.g., when `T2` arrives at time `t = 1s`), then the currently running task (e.g., `T1` immediately prior to time `t = 1s`) is preempted to proceed with execution of the former.

<center>
<img src="./assets/P03L01-022.png" width="650">
</center>

Furthermore, as shown in the figure above, if two of the tasks have equal priorities (e.g., `T2` and `T3`, both of which are higher than `T1`), then tie breaking is achieved in the usual round-robin manner (i.e., via the runqueue order for the tasks in question).

Therefore, in order to include priorities with round robin scheduling, it is necessary to also include **preemption**, but otherwise the tasks are scheduled from the runqueue (i.e., similarly to first-come, first-serve (FCFS)).

<center>
<img src="./assets/P03L01-023.png" width="650">
</center>

A further **modification** that is sensible for round robin scheduling is rather than to wait for tasks to yield explicitly, instead to interrupt them so that they are **interleaved** (i.e., such that the tasks currently in the system are "mixed" together). Such a mechanism is called **timeslicing**.

For example, in the the figure shown above, each task is assigned a timeslice of one time unit (e.g., `1s`), and operates over this fixed interval and then the system proceeds onto the next task in a round-robin manner via the runqueue (with a corresponding interruption of the current task, if necessary), and thus the system proceeds in this manner until all tasks complete execution.

Timeslicing will now be discussed in more detail in the following sections.

## 11-15. Timesharing and Timeslices

### 11. Introduction

#### Timeslice

<center>
<img src="./assets/P03L01-024.png" width="550">
</center>

Timeslices were introduced briefly previously (cf. P2L1). As a more formal definition, a **timeslice** is the maximum amount of ***uninterrupted time*** that can be assigned to a given task. A timeslice is also referred to as a **time quantum**.

Inasmuch as a timeslice defines a *maximum* amount of time, this also implies that a task may run for ***less*** time than the specified timeslice.
  * For example, if a task must wait on an I/O operation, synchronization (e.g., coordinating the locking/unlocking of a mutex), etc., then it will be removed from the CPU and placed on a queue, which may occur prior to expiration of the timeslice.
  * Furthermore, in a priority-based scheduling system, a higher priority task will preempt a relatively lower priority task, therefore in general a lower priority task will account for a smaller portion of a given timeslice.

Irrespectively of the particular system configuration, the use of timeslices allows to achieve the **interleaving** of tasks, i.e., the tasks can participate in **timesharing** of the CPU.
  * This is not particularly critical for **I/O-bound-tasks**, since they are waiting for the I/O operation to complete, externally to the system.
  * Conversely, for **CPU-bound tasks**, the timeslice is the primary mechanism by which timesharing of the CPU is achieved in the first place. This occurs by virtue of the fact that after the timeslice expires, the current task is preempted and the next task is scheduled onto the CPU.

#### Timeslice Scheduling

<center>
<img src="./assets/P03L01-025.png" width="650">
</center>

Consider an example derived from that seen previously in the lecture, as in the figure shown above.
  * Note that here the metrics (i.e., throughput, average wait time, and average completion time) computed with respect to the first-come, first-serve (FCFS) scheduling algorithm also apply to the round robin (RR) without timeslices scheduling algorithm. As given, the tasks `T1`, `T2`, and `T3` would be scheduled in the usual manner via the runqueue (i.e., in order of position within the queue).

For the round robin (RR) scheduling algorithm with a timeslice *`t`*<sub>`s`</sub> of `1s`, the execution for the tasks is as shown in the figure above, corresponding to the following sequence:
  1. Tasks `T1`, `T2`, and `T3` each execute for `1s` per the timeslice (in that order), thereby completing the execution of both `T1` and `T3`.
  2. At time `t = 3s`, since `T2` is the only remaining runnable task, it is scheduled an proceeds to execute until completion.

Regarding the corresponding metrics (relative to time `t = 0s`, as before):
  * **throughput** - by inspection, this is identical to that of the first-come, first-serve (FCFS) scheduling algorithm (i.e., the three tasks are completed over the course of `12s`)
  * **average wait time** - `(0 + 1 + 2) s / 3 tasks = 1 s/task`
  * **average completion time** - `(1 + 12 + 3) s / 3 tasks = 5.33 s/task`

Therefore, by simply using a round robin scheduling algorithm with a timeslice, a comparable performance to that of the shortest job first (SJF) scheduling algorithm is achieved with respect to the average completion time. Furthermore, this is achieved by maintaining the simplicity of the first-come, first-serve (FCFS) scheduling algorithm (i.e., without the additional complexity of managing the runqueue, as in SJF).

<center>
<img src="./assets/P03L01-026.png" width="250">
</center>

Accordingly, the **benefits** of timeslice scheduling (particularly with a relatively *short* timeslice) include:
  * Relatively short tasks (e.g., `T1` and `T3`) generally finish sooner.
  * Scheduling is more responsive.
  * Lengthy I/O operations can be initiated sooner, which improves the user experience (e.g., the wait operation can be made in an early timeslice, which in turn allows for other tasks to complete in the meantime).

<center>
<img src="./assets/P03L01-027.png" width="650">
</center>

Conversely, a key **drawback** is the **overhead** associated with performing the task changes (e.g., interrupts, scheduling, and context switches).
  * In practice, these are not instantaneous events, and can add non-trivial overhead in terms of run-time (i.e., relative to the timeslice's time scale), memory, and performance, etc. Furthermore, there is no useful application processing occurring during this overhead "downtime."
  * Also, note that, in principle, this "pure overhead" is incurred at each timeslice interval even when the *same* task is running (e.g., `T2` performs these overhead operations at *each* interval `t = 4s`, `t = 5s`, etc. until it completes). However, in practice, these timeouts are handled by the operating system in a more efficient manner (e.g., avoiding re-schedules and context switches for the *same* task, with those being among the two most expensive overhead operations) than this "naive" approach in such a case; the details of this are beyond the present scope.

Therefore, relative to the "ideal" metrics as computed (i.e., assuming *no* overhead), the dominant overhead operations will impact the performance accordingly:
  * The **throughput** will be lower than that computed.
  * The tasks will begin slightly later (i.e., rather than *immediately* following the previous time slice), thereby increasing the average wait time and the average completion time due to this overhead time delay.

The exact impact of overhead on these metrics will depend on the exact time duration of the overhead operations relative to that of the timeslice. In general, it is ideal to maintain *`t`*<sub>`s`</sub>`  >>  `*`t`*<sub>`context_switch`</sub> to maximize performance accordingly (i.e., to minimize the impact of overheads on performance).

Therefore, in general, consider both the nature of the tasks as well as intrinsic overheads in the system when **determining** meaningful values for the timeslice.

### 12. How Long Should a Timeslice Be?

<center>
<img src="./assets/P03L01-028.png" width="450">
</center>

As described in the previous section, the use of timeslices delivers certain **benefits** (e.g., the ability to begin the execution of tasks sooner, which in turn enables the achievement of an overall schedule for the task that is more responsive). However, this is accompanied by **overheads** as well. Therefore, the **balance** between these benefits and drawbacks has **implications** for the particular **length** of the timeslice that is selected.

To answer the question "*How long should a timeslice be?*," the corresponding **balance** differs for...
  * I/O-bound tasks (those tasks that perform I/O operations), vs.
  * CPU-bound tasks (those tasks that are mostly executing on the CPU and perform little-to-no I/O operations)

These two scenarios are discussed in turn next.

### 13. CPU-Bound Timeslice Length

<center>
<img src="./assets/P03L01-029.png" width="650">
</center>

(***N.B.*** There are **errata** in the metrics calculations in the table shown above. See the in-text table below for the correct values.)

Now consider an example consisting of two **CPU-bound tasks** both having an execution time of `10s` and a context switching time of `0.1s` (i.e., to switch between the two tasks), as shown in the figure above. Furthermore, consider two different timeslice values (*`t`*<sub>`s`</sub>): `1s` and `5s`.
  * **N.B.** In the time plot of the figure, the "thick" vertical bars encompass the corresponding context switching time.

As demonstrated in the time plot, the context switches are more frequent with a shorter timeslice (`1s`).

The corresponding metrics are calculated as follows:

| Scheduling Algorithm | Throughput (tasks/s) | Average Wait Time (s) | Average Completion Time (s) |
| :---: | :---: | :---: | :---: |
| round robin<br/>(*`t`*<sub>`s`</sub>` = 1s`) | `2 / (10 + 10 + 19*0.1)`<br/>`= 0.091` | `[0 + (1 + 0.1)] / 2`<br/>`= 0.55` | `[(19*1 + 18*0.1) + (1.1 + 19*1 + 18*0.1)] / 2`<br/>`= 21.35` |
| round robin<br/>(*`t`*<sub>`s`</sub>` = 5s`) | `2 / (10 + 10 + 3*0.1)`<br/>`= 0.098` | `[0 + (5 + 0.1)] / 2`<br/>`= 2.55` | `[(5*3 + 2*0.1) + (5.1 + 5*3 + 2*0.1)] / 2`<br/>`= 17.75` |

As these metrics suggest:
  * A higher timeslice value (e.g., *`t`*<sub>`s`</sub>` = 5s`) is more advantageous for higher throughput and for a shorter average completion time
  * Conversely, a lower timeslice value (e.g., *`t`*<sub>`s`</sub>` = 1s`) is more advantageous for a shorter average wait time

However, since these are CPU-bound tasks, the wait time is not particular concern here, but rather, the user is more interested in throughput and completion times, therefore, in general a ***longer*** timeslice is more advantageous here.

In particular, for CPU-bound tasks, the theoretical limit for this example/configuration is as follows:

<center>
<img src="./assets/P03L01-030.png" width="500">
</center>

| Scheduling Algorithm | Throughput (tasks/s) | Average Wait Time (s) | Average Completion Time (s) |
| :---: | :---: | :---: | :---: |
| round robin<br/>(*`t`*<sub>`s`</sub>` → ∞`) | `2 / (10 + 10)`<br/>`= 0.1` | `[0 + (10)] / 2`<br/>`= 5` | `[(10) + (20)] / 2`<br/>`= 15` |

Therefore, in summary, in general a CPU-bound task prefers a **large timeslice**.

### 14. I/O-Bound Timeslice Length

<center>
<img src="./assets/P03L01-031.png" width="650">
</center>

Now consider an example consisting of two **I/O-bound tasks** both having an execution time of `10s` and a context switching time of `0.1s` (i.e., to switch between the two tasks), as shown in the figure above. Furthermore, consider two different timeslice values (*`t`*<sub>`s`</sub>): `1s` and `5s`. The nature of the I/O calls is such that the task issues an I/O operation every `1s`, and each such I/O operation completes in `0.5s`.

As shown above in the figure, the resulting time plot is identical to that of the CPU-bound tasks with for a timeslice of `1s`. However, in this scenario, rather than being preempted, the tasks issue the I/O operation and subsequently yield of their own volition (i.e., irrespectively of the timeslice length).

Furthermore, with a timeslice `5s`, the resulting timeslice is also equivalent, since the I/O operations' frequency (once per `1s`) is higher than that of the timeslice duration (`5s`).


The corresponding metrics are calculated as follows:

| Scheduling Algorithm | Throughput (tasks/s) | Average Wait Time (s) | Average Completion Time (s) |
| :---: | :---: | :---: | :---: |
| round robin<br/>(*`t`*<sub>`s`</sub>` = 1s`) | `2 / (10 + 10 + 19*0.1)`<br/>`= 0.091` | `[0 + (1 + 0.1)] / 2`<br/>`= 0.55` | `[(19*1 + 18*0.1) + (1.1 + 19*1 + 18*0.1)] / 2`<br/>`= 21.35` |
| round robin<br/>(*`t`*<sub>`s`</sub>` = 5s`) | `2 / (10 + 10 + 19*0.1)`<br/>`= 0.091` | `[0 + (1 + 0.1)] / 2`<br/>`= 0.55` | `[(19*1 + 18*0.1) + (1.1 + 19*1 + 18*0.1)] / 2`<br/>`= 21.35` |

Therefore, it can be concluded here that for I/O-bound tasks, the value of the timeslice is not relevant.

<center>
<img src="./assets/P03L01-032.png" width="650">
</center>

However, as demonstrated by the figure shown above, this is not a correct conclusion. Here, consider the case where *only* `T2` is I/O-bound (with characteristic times as given previously), while `T1` is not (i.e., `T1` is strictly CPU-bound).
  * In this case, the time plots are identical for `T1` and `T2` for a timeslice of `1s`, with the difference that for `T1` there is preemption after each `1s` timeslice, whereas for `T2` there is a voluntary yield off of the CPU to wait the I/O operation.
  * However, for the timeslice of `5s`, at time `t = 5s`, `T1` is preempted, and then `T2` is scheduled for `1s` until it yields due to the I/O operation, and then `T1` is scheduled again and executes to completion. Lastly, `T2` is the last remaining task from time `t = 11s` onwards.

For the latter case (i.e., a timeslice of `5s` with only `T2` being I/O-bound), the performance metrics are as follows:

| Scheduling Algorithm | Throughput (tasks/s) | Average Wait Time (s) | Average Completion Time (s) |
| :---: | :---: | :---: | :---: |
| round robin<br/>(*`t`*<sub>`s`</sub>` = 5s`)* | `2 / (10 + 10 + 3*0.1 + 8*0.5)`<br/>`= 0.082` | `[0 + (5 + 0.1)] / 2`<br/>`= 2.55` | `[(11 + 2*0.1) + (11 + 9 + 3*0.1 + 8*0.5)] / 2`<br/>`= 17.75` |

Therefore, in the I/O-bound case, a decreased timeslice (i.e., `1s`) both increases throughput and decreases the average wait time. With respect to the average completion time, this is increased in the smaller timeslice due to the large variance in the completion times of `T1` and `T2` (i.e., `t = 11s` and `t = 20s`, respectively). However, overall, it can be concluded that for I/O-bound tasks, a **smaller** timeslice is generally more advantageous.
  * With a smaller timeslice, an I/O-bound task is more likely to run sooner, to issue an I/O request, or to respond to a user.
  * Furthermore, with a smaller timeslice, it is possible to keep both the CPU and the I/O devices busy, thereby maximizing the use of the system resources.

### 15. Summarizing Timeslice Length

<center>
<img src="./assets/P03L01-033.png" width="500">
</center>

Revisiting the question of "*How long should a timeslice be?*"...
  * CPU-bound tasks prefer ***longer*** timeslices
    * Longer timeslices give rise to less frequent context switches, and correspondingly a reduction in overheads from associated operations
    * Longer timeslices maintain high CPU utilization and throughput by maximizing the useful application processing (and correspondingly minimizing "non-useful" overhead)
  * I/O-bound tasks prefer ***shorter*** timeslices
    * With shorter timeslices, I/O-bound tasks can issue I/O operations sooner/earlier
    * Shorter timeslices maintain high CPU utilization and device utilization
    * Shorter timeslices promote better user-perceived performance (i.e., the system appears "more responsive" to the user with respect to user inputs and corresponding outputs to the user)

## 16. Timeslice Quiz and Answers

On a single-CPU system, consider the following workload and conditions:
  * `10` I/O-bound tasks and `1` CPU-bound task
  * The I/O-bound tasks issue an I/O operation every `1ms` of CPU computing time
  * I/O operations always take `10ms` to complete
  * The overhead for context switching is `0.1ms`
  * All tasks are long-running (i.e., assume *large* execution times relative to the other aforementioned times)

Given these parameters, what is the CPU utilization (%) for a round robin scheduler where the timeslice is:
  * `1ms`?
    * `91%`
      * Every `1ms`, there is either a preemption of the CPU-bound task, or the I/O-bound task will intrinsically stop to perform the I/O operation.
      * Therefore, over a timeslice of `1ms`, the CPU utilization is `1ms / (1ms + 0.1ms) = 0.91`.
  * `10ms`?
    * `95%`
      * Each of the ten I/O-bound tasks run for `1ms` apiece, with an immediately succeeding context switch of `0.1ms` after each. After this, the CPU-bound task is scheduled and then runs for `10ms` (i.e., the full timeslice).
      * Therefore, over a timeslice of `10ms`, the (aggregate) CPU utilization is `(10*1 + 1*10) / [(10*1 + 10*0.1) + (1*10 + 1*0.1)] = 0.95`. This is represented diagrammatically as follows:
      <center>
      <img src="./assets/P03L01-034.png" width="200">
      </center>

As this example demonstrates, from the CPU's perspective (i.e., with respect to maximizing CPU utilization), having a larger timeslice (which favors the CPU-bound task) increases CPU utilization.
  * Though not computed explicitly in the example, from the perspective of the I/O device, the opposite will be true: Having a smaller timeslice will favor more frequent operation of the I/O device, inasmuch as the I/O device is otherwise idle while the system is running the CPU-bound task.

Reference equation:
<center>
<img src="./assets/P03L01-035.png" width="200">
</center>

Tips to solve:
  1. Determine a ***consistent, recurring interval***.
  2. In the interval, each task should be given an opportunity to run.
  3. During that interval, how much time is spent computing? This is the ***CPU running time*** (*`t`*<sub>`CPU`</sub>).
  4. During that interval, how much time is spent context switching? This is the ***context switching overheads*** (*`t`*<sub>`cso`</sub>).
  5. Calculate based on (1)-(4).

## 17. Runqueue Data Structure
