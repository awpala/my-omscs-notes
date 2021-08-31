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

## 4. What Does a Process Look Like?

<center>
<img src="./assets/P02L01-006.png" width="200">
</center>

A process encapsulates the ***entire state*** of a running application, including the code, data, all variables allocated by the application, etc.

Every element of the process state must be ***uniquely idenfied*** by its **address**. Therefore, an **address space** is an abstraction provided by the operating system used to encapsulate the process's state. The address state is defined over a range `V`<sub>`0`</sub> to `V`<sub>`max`</sub>, with different parts of the process state occurring in correspondingly different parts of this range.

The different types of state include:
  * **text** and **data**
    * static state, initialized and subsequently available when the process first loads
  * **heap**
    * dynamically created/allocated during process execution
  * **stack**
    * grows and shrinks during process execution
    * implemented as a **LIFO (last-in, first-out) queue**

N.B. In general, the address space between the heap and the stack is not strictly contiguous; there may be "holes" in the address space, which is not accessed by the running process itself.

<center>
<img src="./assets/P02L01-007.png" width="200">
</center>

If a procedure (e.g., `Y`) is called in the stack during process execution, the caller's (e.g., `X`) state must first be saved prior to calling the procedure. Correspondingly, upon completion of the procedure call, the caller's state must be restored. This type of transfer back and forth is managed on the stack.

## 5. Process Address Space

<center>
<img src="./assets/P02L01-008.png" width="200">
</center>

Collectively, this "in memory" representation of a process is called an **address space**, wherein the potential range of addresses (i.e., `V`<sub>`0`</sub> to `V`<sub>`max`</sub>) constitute the **virtual addresses** used by the process to reference the relevant parts of its state.

<center>
<img src="./assets/P02L01-009.png" width="100">
</center>

The term "virtual" in this context is in contrast to **physical addresses**, which are *actual* locations in physical memory (i.e., DRAM).

<center>
<img src="./assets/P02L01-010.png" width="350">
</center>

In the case of a process, the memory management hardware and the operating system components responsible for memory management (e.g., **page tables**) maintain a mapping between the virtual addresses and the physical addresses. This decouples the layout of the data in the virtual address space (which may be complex and dependent on application specifics, build tools, etc.) from the layout in physical memory.
  * For example, per the figure, mapping variable `x` from virtual `0x03c5` to physical `0x0f0f`

## 6. Address Space and Memory Management

Recall that not all addresses require the *entire* virtual address space; there may be portions which are ***not*** allocated. Furthermore, there may be insufficient physical memory available to store the entire virtual address space that is occupied/allocated (e.g., a virtual address space comprised of 32-bit addresses can occupy up to 2<sup>32</sup> or over 4 GB of physical memory *per process*).

<center>
<img src="./assets/P02L01-011.png" width="250">
</center>

To deal with this, the operating system dynamically decides which portion of which executing processes' (e.g., `P1` and `P2` in the figure above) respective virtual address spaces will be present at a particular location in physical memory. Furthermore, one (or more) of the processes may have some portion of their address space not present in memory/DRAM, but rather temporarily **swapped** to the disk, the latter being restored to memory/DRAM when it is needed.

Therefore, the operating system must track the address space across virtual memory, physical memory, and disk throughout the execution of all of the processes. Furthermore, the operating system must also ensure that the processes' access to these various memory locations is valid/permissible.

## 7. Virtual Addresses Quiz and Answers

<center>
<img src="./assets/P02L01-012.png" width="300">
</center>

If two processes `P1` and `P2` are running at the same time, what are the ***virtual address space*** ranges that they will have? (Select one choice.)

Choice | `P1` | `P2` |
| :--: | :--: | :--: |
| `A` | 0-32,000 | 32,000-64,000 |
| `B` | 0-64,000 | 0-64,000 |
| `C` | 32,000-64,000 | 32,000-64,000 |

The correct choice is `B`. The operating system will map these virtual addresses to the physical address space. This allows each process (i.e., from its "own perspective") to have the same range of virtual addresses; in the corresponding overlapping to physical memory, they will *not* overlap/overwrite each other, however.

## 8. Process Execution State: How Does the OS Know What a Process Is Doing?

For an operating system to manage processes, it must have some understanding of what the processes are doing (e.g., if the operating system stops a processes, it must know the process's state immediately prior to stopping it in order to restore that exact same process state later).

<center>
<img src="./assets/P02L01-013.png" width="450">
</center>

Consider how a CPU executes an application:
  * Prior to executing, the application's source code must be compiled, resulting in a **binary file** (a sequence of instructions, which are not necessarily executed sequentially)
  * At any given time, the **CPU** must know where in the sequence the process currently is; this is tracked via the **program counter (PC)**
    * The program counter is maintained on the CPU in a **register** while the process is executing; furthermore, other registers are also maintained on the CPU, which hold values required for execution (e.g., addresses for data, status information, etc.)
  * The process's **stack** is denoted by the **stack pointer (SP)**, which points to the ***top*** of the stack (i.e., its lowest address in the virtual address space) thereby conferring on it its characteristic last-in, first-out (LIFO) behavior
  * Other information is also maintained to facilitate the operating system's "understanding" of what a process's state is at any given time

To maintain all of this useful information for every single process, the operating system maintains a **process control block (PCB)** (discussed next).

## 9. What Is a Process Control Block (PCB)?

<center>
<img src="./assets/P02L01-014.png" width="150">
</center>

A **process control block (PCB)** is a data structure that the operating system maintains for *each* process that it manages. It consists of the information shown in the figure above.

The process control block is created when the process is created, and also initialized with the appropriate values at that time (e.g., program counter points to the first instruction of the process).

Certain fields of the process control block are updated when the process state changes (e.g., when the process requests more memory, the operating system will allocate more memory and establish new valid virtual-to-physical memory mappings).

Other fields change too frequently to manage via the process control block (e.g., the program counter changes after each instruction, which is instead handled by the CPU itself via a dedicated register); however, in such cases, it is still responsible for collecting and saving all information that the CPU maintains for a process, and to store it in the process control block structure whenever that particular process is no longer running on the CPU.

## 10. How Is a PCB Used?

