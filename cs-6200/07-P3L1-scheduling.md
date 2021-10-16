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
  * ***throughput***: `3 tasks / (1 + 10 + 1) s = 0.25 tasks/s`
  * ***average completion time***: `(1 + 11 + 12) s / 3 tasks = 8 s/task`
    * `T1` completes in `1s`, which is immediately followed by execution of `T2` taking `10s` to complete (for a total completion time of `1 + 10 = 11s`, including the prior execution time of `T1`), and then finally `T3` completes execution in `1s` (in total `1 + 10 + 1 = 12s`, including the prior execution times of `T1` and `T2`)
  * ***average wait time***: `(0 + 1 + 11) s / 3 tasks = 4 s/task`
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
    * `3 tasks / (1 + 1 + 10) s = 0.25 tasks/s` (via ordering `T1 (first) -> T3 -> T2 (last)`)
  * **average completion time**
    * `(1 + 2 + 12) s / 3 tasks = 5 s/task` (via ordering `T1 (first) -> T3 -> T2 (last)`)
  * **average wait time**
    * `(0 + 1 + 2) s / 3 tasks = 1 s/task` (via ordering `T1 (first) -> T3 -> T2 (last)`)

***N.B.*** Observe that the average completion time and average wait time are shorter compared to the first-come, first serve scheduling algorithm (cf. Section L4).

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

## 6. Preemptive Scheduling: SJF + Preempt

