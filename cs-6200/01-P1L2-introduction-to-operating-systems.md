# P1L2: Introduction to Operating Systems

## 1. Preview

This introductory level provides a high-level overview of operating systems, e.g.,:
  * What is an **operating system**, and what role does it play in computer systems?
  * What are key **components** of an operating system?
  * Design and implementation considerations of operating systems

### Simple OS Definition

In simple terms, an **operating system** is a piece of software that ***abstracts*** and ***arbitrates*** the use of the underlying computer/hardware system.
  * An **abstraction** provides a simplified "look" of the underlying entity (i.e., hardware)
  * **Arbitration** involves the management and oversight of the hardware

This course will highlight several abstraction and arbitration mechanisms for the various types of hardware components in computer systems.

## 2. Visual Metaphor

An operating system is like a *toy shop manager*:

<center>
<img src="./assets/P01L02-001.png" width="400">
</center>

| Characteristic | Toy Shop Manager Metaphor | Operating System |
| :--: | :--: | :--: |
| Directing operational resources | control use of employee time, parts, tools, etc. | control use of CPU, memory, peripheral devices, etc. and deciding their use by applications |
| Enforcing working policies | fairness, safety, clean-up, etc. | fair access to shared resources, limits to resource usage (e.g., number of files opened per process, established threshold to initiate memory-managing daemons, etc.), etc. |
| Mitigating difficulty of complex tasks | simplifies operation and optimizes performance | abstracts hardware details to running applications via **system calls** |

## 3. What Is an Operating Systems?

<center>
<img src="./assets/P01L02-002.png" height="300">
</center>

A **computing system** is comprised of several hardware **components**:
  * One or more **processors** (or **CPUS**)
    * Modern processors additionally consist of multiple **cores** in a single CPU chip
  * **Main memory**
  * **Network devices** (e.g., Ethernet/WiFi card)
  * **Graphics processors** (or **GPUs**)
  * **Storage devices** (e.g., hard-disk drives/HDDs, flash drives, solid-state drives/SSDs, etc.)

With the exception of specific environments (e.g., embedded platforms, sensors, etc.), all of these hardware components will be used by multiple **applications** in general, for example:
  * A laptop running a browser, text editor, Skype, etc.
  * A data center running a Web server, a database, a computationally intensive simulation, etc.

The **operating system** is therefore the layer of software sitting between the complex hardware and the applications. While there is no universal definition of an operating system, it is useful to consider the role that it serves and the functionality that it provides to build a better understanding of what it is.

The operating system:
  * hides the complexity of the underlying hardware, both from the applications and the applications developers
    * it abstracts the underlying **storage** devices with the concept of a **file**, which can be read from / written to by the application 
    * it abstracts the underlying **networking** infrastructure (e.g., bits, packets, etc.) by providing a higher level abstraction called a **socket** which can be sent and received
  * manages **resources** (i.e., the underlying hardware) on behalf of the executing applications
    * it decides how many and which of the hardware components will be used by the application (e.g., via memory allocation and CPU scheduling for its execution)
  * provides isolation and protection
    * this is important when multiple applications are running concurrently on the same hardware, to ensure that they can progress adequately without harming one another (e.g., allocating applications to different parts of the main memory to prevent mutual access, as depicted in the figure above)
    * these types of mechanisms are also important in environments traditionally considered embedded platforms (e.g., mobile phones, which previously only ran one application at a time)

## 4. Operating System Definition

In summary, an **operating system** is a layer of systems software that...
  * directly has ***privileged access*** to the underlying hardware (unlike application software, which does not)
  * hides the hardware complexity
  * manages hardware on behalf of one of more applications according to some predefined **policies**
  * in addition, it ensures that applications are isolated and protected from one another

## 5. Operating System Components Quiz and Answers

Which of the following are likely components of an operating system? Check all that apply.
  * file editor
    * `NO` - not involved in directly managing hardware
  * file system
    * `YES` - directly hides hardware complexity and provides a "file" abstraction (i.e., rather than directly using a block of disk storage)
  * device driver
    * `YES` - makes decisions regarding the usage of the corresponding hardware device
  * cache memory
    * `NO` - while the operating system and application software utilize cache memory for performance, the operating system does not directly manage the cache (but rather, this is managed by the hardware itself)
  * Web browser
    * `NO` - this is application software, which does not have direct access to the underlying hardware
  * scheduler
    * `YES` - responsible for distributing access to the processor/CPU among all of the applications sharing that platform

## 6. Abstraction or Arbitration Quiz and Answers

For the following options, indicate if they are examples of *abstraction* (B) or *arbitration* (R).
  * distributing memory between multiple processes
    * `R` - this is memory management by the operating system
  * supporting different types of speakers
    * `B` - the operating system provides the abstraction to be compatible with many different speakers (which may additionally require corresponding drivers)
  * interchangeable access of hard disk or SSD
    * `B` - the operating system provides the storage abstraction to be compatible with many different memory devices

## 7. Operating Systems Examples

<center>
<img src="./assets/P01L02-003.png" width="350">
</center>

To understand what an operating system is, consider some examples of actual operating systems. These examples depend on the specific environment they are targeting, e.g.,:
  * desktop
  * server
  * embedded
  * ultra high-end mainframes

Since desktop and embedded systems are the most commonly used and use the most recent operating systems technology, they wil be the focus of discussion.
  * desktop
    * Microsoft Windows
    * UNIX-based
      * macOS (which extends the BSD kernel)
      * Linux (many versions, e.g., Ubuntu, centOS, etc.)
  * embedded
    * Android
    * Apple iOS
    * Symbian

In each of these operating systems, there are many choices made in their design and implementation. This course and its examples will focus primarily on **Linux**.

## 8. OS Elements

To achieve its goals, an operating system supports a number of higher level **abstractions**, and key **mechanisms** operating on these asbractions.

For example:

| Abstractions | Mechanisms |
| :--: | :--: |
| processes and threads | create and launch and application to start it, and schedule to run it on the CPU |
| file, socket, and memory page | open (e.g., a particular device or hardware component), write (e.g., update state), and allocate memory from an application to a hardware resource |

Operating systems may also integrate specific **policies** to determine how these mechanisms will be used to manage the underlying hardware, e.g.,:
  * the maximum number of sockets accessible by a process
  * which data will be removed from physical memory using a particular algorithm (e.g., **least-recently used** [**LRU**], **earliest deadline first** [**EDF**], etc.)

## 9. OS Elements: Memory Management Example

<center>
<img src="./assets/P01L02-004.png" width="250">
</center>

***Abstractions***:
  * **memory page**, corresponding to some addressable region of memory of fixed size (e.g., 4KB)

***Mechanisms***:
  * allocate the page in **DRAM**
  * map the page into the address space of a **process**, allowing the process to access the physical memory corresponding to the contents of the page
    * over time, the page may be moved to different locations of the DRAM or even stored on **disk**

***Policies***:
  * since it is faster to access data from memory/DRAM than from the disk, it must have some policies to decide whether the page contents will be stored in DRAM or copied over to disk
    * **least recently used** (**LRU**) is a commonly used policy, whereby the pages that have been least recently used over a time period (i.e., accessed the longest time ago) are the ones that are transferred from DRAM to disk (which is also called **swapping**)
      * the rationale for this is that least recently used pages are either least important and/or least likely to be used in the near future, whereas the opposite is true for pages being used more recently and more frequently

## OS Design Principles

Consider some guiding principles when designing an operating system as follows:
  * separation of mechanism and policy
    * implement ***flexible*** mechanisms to support many policies (e.g., LRU, LFU, random, etc.)
      * in different settings, different policies can make more sense than others
  * optimize for the **common case**
    * there are several relevant questions to determine this, e.g.,:
      * where will the operating system be used?
      * what will the user want to execute on that machine?
      * what are the workload requirements?
    * once the common case is understood, select a specific policy that is most sensible for that common case and which can be supported by the underlying mechanisms and abstractions supported by the operating system

## 11. User/Kernel Protection Boundary

To achieve its role of controlling and managing hardware resources on behalf of applications, the operating system must have ***special privileges*** to have direct access to the hardware.

<center>
<img src="./assets/P01L02-005.png" width="325">
</center>

(***N.B.*** in the figure `Mm` denotes ***main memory*** and `CPU` denotes the ***processor***. This convention will be used throughout the course.)

Computer platforms distinguish between at least two modes:
  * **user-level** (unprivileged)
    * applications operate in unpriviliged user mode
  * **kernel-level** (privileged)
    * because an operating system must have direct hardware access, it must operate in privileged kernel mode
    * therefore, hardware access can only be performed by the operating system kernel (i.e., in privileged mode)

**Switching** between the user and kernel modes is supported by hardware on most modern platforms.
  * **trap instructions**
    * In kernel mode, a special bit (called the **privilege bit**) is set in the CPU, which allows any instruction that directly manipulates the hardware to execute.
    * In user mode, when the bit is *not* set, attempts to perform privileged instructions are forbidden; instead, this will result in a **trap instruction**, whereby the application is interrupted and the hardware switches control back to the operating system at a specific location. At that point, the operating system can analyze the trap and determine whether the process should be granted access or terminated.
  * **system calls**
    * The operating system exports a **system call interface**, a set of operations that the applications can explicitly invoke in order to request the operating system to perform a service which requires privileged access on their behalf.
      * Examples include: `open` (file access), `send` (socket access), `malloc` (memory access)
  * **signals**
    * A **signal** is a mechanism whereby the operating system can pass messages to the application. This will be discussed in a later lesson.




## 12. System Call Flowchart


