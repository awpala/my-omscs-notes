# P2L1: Processes and Process Management

## 1. Preview

A key abstraction supported by operating systems is that of a **process**. This lecture explains:
  * What is a **process**?
  * How are processes *represented* by operating systems?
  * How are multiple **concurrent** processes managed by operating systems? (i.e., when processes share a single physical platform)

Before proceeding, consider a simple definition of a **process**:
  * ***instance*** of an executing program
  * sometimes synonymously/interchangeably called a **task** or **job**

## 2. Visual Metaphor

<center>
<img src="./assets/P02L01-001.png" width="350">
</center>

Continuing with the visual metaphor of a toy shop (cf. P1L2), a **process** is like an order of toys, which is characterized by the following:

| Characteristic | Toy Shop Metaphor | Operating System |
| :--: | :--: | :--: |
| state of execution | completed toys, and those waiting to be built | program counter, stack pointer|
| parts and temporary holding area | plastic pieces, containers, etc.| data, register state occupies state in memory | 
| may require special hardware | sewing machine, glue gun, etc. | I/O devices (e.g., disks, networking devices, etc.) |

## 3. What Is a Process?

<center>
<img src="./assets/P02L01-002.png" width="250">
</center>

Recall that one of the roles of the operating system is to manage hardware on behalf of applications.
  * An **application** is a program on disk, flash memory, etc., which is a ***static entity*** (i.e., it is *not* executing)

<center>
<img src="./assets/P02L01-003.png" width="250">
</center>

A **process** is therefore the state of a program when loaded in memory and executing (i.e., an ***active entity***)

<center>
<img src="./assets/P02L01-004.png" width="250">
</center>

If the same program is launched more than once, then correspondingly ***multiple*** processes are active (i.e., executing the *same* program, but in general with each process being in a different **state** at any given time).

<center>
<img src="./assets/P02L01-005.png" width="350">
</center>

Therefore, a process represents the **execution state** of an *active* application. It does not necessarily mean that the application is currently running (e.g., may be *waiting* on user input, may be *waiting* on another currently running process in a one-CPU system, etc.)



