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


