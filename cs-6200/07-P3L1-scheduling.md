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
| Assign complex tasks first | If the objective is to maximize utilization of the platform's resources (e.g., CPU(s), devices, memory, etc.), perform complex tasks first |

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


