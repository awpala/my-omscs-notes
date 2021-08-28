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

