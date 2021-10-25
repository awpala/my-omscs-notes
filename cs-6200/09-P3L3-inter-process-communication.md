# P3L3: Inter-Process Communication

## 1. Preview

This lecture will discuss **inter-process communication (IPC)**.

In particular, this lecture will primarily discuss **shared memory IPC**, and the corresponding APIs.

Additionally, the lecture will describe some of the other IPC mechanisms that are common in modern operating systems.

## 2. Visual Metaphor

<center>
<img src="./assets/P03L03-001.png" width="400">
</center>

Recall (cf. P2L2) that a process is like an order of toys in a toy shop. In this lecture, we will see how processes can **communicate** with each other during their execution. First, however, consider how **inter-process communication (IPC)** is related to the recurring toy shop analogy; in particular, inter-process communication (IPC) is like working together in a toy shop.

| Characteristic | Toy Shop Workers | Inter-Process Communication |
| :---: | :---: | :---: |
| Workers share the work area / Processes share (physical) memory | Leaving common parts and tools on the table to be shared among the workers | Processes can share data they both need to access, which is placed in the shared memory (as will be discussed further in this lecture) |
| Workers can call each other / Processes  can exchange messages | The workers can directly communicate by explicitly ***requesting*** something from one another and consequently receiving the required ***response*** | Processes can explicitly exchange message, requests, and responses via **message-passing mechanisms** that are supported via certain APIs (e.g., **sockets**) |
| Interactions among workers/processes requires synchronization | The worker indicates "*I will start when you finish*" | Processes may need to **wait** on one another and correspondingly may need to rely on certain **synchronization mechanisms** (e.g., mutexes) to ensure that communication proceeds in the correct manner |

## 3. Inter-Process Communication (IPC)

<center>
<img src="./assets/P03L03-002.png" width="550">
</center>

**Inter-process communication (IPC)** refers to a set of mechanisms (e.g., synchronization, coordination, and communication) that the operating system must support in order to permit multiple processes to interact amongst each other.

Inter-process communication (IPC) mechanisms are broadly **categorized** as message-based or memory-based.
  * Examples of **message-passing IPC mechanisms** include sockets, pipes, message queues, and other operating-system-supported constructs.
  * The most common **memory-based IPC mechanism** is for the operating system to provide processes with access to some **shared memory**, which may be in the form of:
    * A completely **unstructured set** of pages of physical memory
    * **Memory-mapped files**

Inter-process communication also provides a means of **higher-level semantics**.
  * With respect to **files**, both categories of inter-process communication (IPC) can be perceived as a method for IPC (i.e., multiple processes reading and writing from/to the *same* file); file systems will be described in a later lecture.
  * Another mechanism that provides higher-level semantics with respect to inter-process communication (IPC) among processes is what is referred to as **remote procedure calls (RPCs)**. RPC will also be discussed in a later lecture.

***N.B.*** Here, "***higher-level semantics"***" describes how the mechanism in question supports more than simply a channel for two processes to coordinate or communicate amongst each other, but rather also prescribe some additional detail on the protocols that will be used, how the data will be formatted, how the data will be exchanged, etc.

Finally, communication and coordination also implies **synchronization**.
  * When processes send and receive **messages** among each other, they effectively synchronize with each other as well.
  * Similarly, when processes synchronize (e.g., via a mutex-like data structure), they also communicate something about the point in their execution. From this perspective, **synchronization primitives** also fall under the category of inter-process communication (IPC) mechanisms; however, a separate lecture will be dedicated to discussing specifically regarding synchronization (this lecture will instead focus on message-passing and memory-based IPC mechanisms).

## 4-5. Message-Based Inter-Process Communication (IPC)

### 4. Message Passing

<center>
<img src="./assets/P03L03-003.png" width="550">
</center>

One mode of inter-process communication (IPC) that operating systems support is called **message passing**. As the name implies, processes create **messages** and the send or receive them.

The operating system is responsible for creating and maintaining the **channel** that will be used to pass messages among processes. This can be thought of as type of buffer, first-in, first-out (FIFO) queue, or other similar data structure.

The operating system also provides some **interface** to the processes to enable them to pass messages via the channel. The processes then **send** (or **write**) messages to a **port**, and on the other end the processes **receive** (or **read**) messages from the associated port. The channel in turn is responsible for **passing** the message from one port to the other.

<center>
<img src="./assets/P03L03-004.png" width="550">
</center>

The **operating system kernel** is required to both establish the communication channel as well as to perform every single inter-process communication (IPC) operation. This means that both the **send operation** and the **receive operation** *each* require a system call and a copy of the data.
  * In the case of the **send operation**, this involves copying from the sender process's address space to the communication channel.
  * In the case of the **receive operation**, this involves copying from the channel to the recipient process's address space.

This means that a simple **request-response interaction** among two processes requires `4` user/kernel crossing and `4` data-copying operations (i.e., send request, receive request, send response, and receive response).

<center>
<img src="./assets/P03L03-005.png" width="550">
</center>

Consequently, a key **drawback** of message-passing inter-process communication (IPC) is that there is an associated **overhead** (i.e., the aforementioned user/kernel crossings and data-copying operations).

However, message-passing inter-process communication (IPC) provides the key **benefit** that it is relatively **simple**, inasmuch as the operating system kernel is able to handle all of the necessary operations and synchronization (e.g., channel management, synchronization, ensuring the data is not overwritten or corrupted as the processes send/receive messages, etc.).

### 5. Forms of Message Passing

In practice, there are several **methods** of message-passing-based inter-process communication (IPC), as discussed in the following subsections.

#### Pipes

<center>
<img src="./assets/P03L03-006.png" width="550">
</center>

The first (and simplest) form of message-passing inter-process communication (IPC) (which is also part of the POSIX standard) is called **pipes**. Pipes are characterized by *two* **endpoints** (i.e., only two processes can communicate in this manner).

With pipes, there is no notion of a "message" per se, but rather there is simply a **stream** of bytes that is pushed into the pipe from one process and then received into the other.

One popular use of pipes is to connect the output from one process to the input of another process (i.e., the entire byte stream of process `P1` is delivered as input to process `P2`--rather than typing it in manually, for instance).

#### Message Queues

<center>
<img src="./assets/P03L03-007.png" width="550">
</center>

A more complex form of message-passing inter-process communication (IPC) is **message queues**. As the name suggests, message queues understand the notion of "messages" that they transfer among the processes. The sending process must submit a **properly-formatted message** to the channel, amd then the channel delivers the corresponding properly-formatted message to the receiving process.

The operating-system-level **functionality** regarding message queues also includes the understanding of priorities of messages, scheduling the manner in which messages are delivered, etc.

The use of message queues is supported via different APIs. In UNIX-based systems, these include the **POSIX API** and the **System V (SysV) API**.

#### Sockets

<center>
<img src="./assets/P03L03-008.png" width="550">
</center>

The message-passing API that is likely most familiar is the **socket API**. With this socket form of inter-process communication (IPC), the notion of "*ports*" that is required in message-passing inter-process communication (IPC) mechanisms is itself the **socket abstraction** that is supported by the operating system.

With sockets, processes send or receive messages via an API (e.g., system calls `send()` and `recv()`, respectively). The socket API supports send and receive operations that allow processes to send **message buffers** into and out of the in-kernel **communication buffer** (i.e., the **channel**).

The system call to `socket()` itself creates a kernel-level socket buffer. Additionally, it will associate any necessary **kernel-level processing** that must be performed along with the message's movement (e.g., TCP/IP for a network socket, in which the entire TCP/IP protocol stack is associated with the data movement in the kernel).

***N.B.*** Sockets do not need to be used for processes that are on a *single* machine; rather, if the two processes are on *different* machines, then the channel exists essentially between the (local) process and a network device that will actually send the data externally. Additionally, the operating system is sufficiently "smart" to determine that if two processes are on the *same* machine, then it can **bypass** execution of the full protocol stack (e.g., it will bypass sending the data out on the network just to receive it back and push it into the recipient process). This remains hidden from the programmer, but can be detected via corresponding performance measurements.

## 6. Shared-Memory Inter-Process Communication (IPC)

<center>
<img src="./assets/P03L03-009.png" width="550">
</center>

In **shard-memory inter-process communication (IPC)**, processes read and write from/to a **shared memory region**.

The operating system is involved in establishing this **shared-memory channel/buffer** between the processes. 
  * This means that the operating system will **map** certain physical pages of memory into the virtual address spaces of both processes (e.g., the virtual addresses in `P1` and the virtual addresses in `P2` will map to the *same* physical addresses in main memory).
  * At the same time, the virtual-address regions corresponding to the shared-memory buffer in the two processes, i.e., they do not have to have the same virtual addresses (e.g., `VA(P1) ≠ VA(P2)` in general).
  * Furthermore, the physical memory that is backing the shared-memory buffer need not be a contiguous portion of the physical memory.

***N.B.*** All of these features leverage the memory management support that is available in operating systems running on modern hardware.

<center>
<img src="./assets/P03L03-010.png" width="550">
</center>

A key **benefit** of this approach is that once the physical memory is mapped into both address spaces, the operating system is effectively "out of the way" (i.e., the system calls are only used in the initial setup phase). Furthermore, data copies are potentially reduced.
  * Data copies are not entirely eliminated, however, inasmuch as in order for data to be visible to *both* processes, it must be explicitly allocated from the virtual addresses belonging to the shared-memory region; if this is not the case and there is no such visibility, then the data within the *same* address space must be copied in/out of the shared-memory region.
  * However, in some cases, data copying can be reduced. For instance if `P2` needs to compute the sum of two arguments that were passed to it from `P1` via the shared-memory region, then `P2` can only read these arguments but otherwise does not need to actually copy them into other portions of its address space in order to compute the sum and then pass it back.

However, there are also **drawbacks** with this approach.
  * Since the shared-memory region can be concurrently accessed by *both* processes, this means that the processes must explicitly synchronize their shared-memory operations (i.e., similarly to what is required for threads operating within a single, shared address space).
  * Furthermore, it is the responsibility of the developer to determine any communication-protocol-related issues, e.g., how to format messages, how to delimit messages, what is the header format, how the shared-memory buffer is allocated (i.e., when will each process be able to use a portion of the shared-memory buffer for its needs), etc.--thereby adding complexity.

UNIX-based system (e.g., Linux) support two popular shared-memory APIs:
  1. **System V (SysV) API**, which was originally developed as part of System V.
  2. **POSIX API**

Additionally, shared-memory-based communication can be established between processes using a **file-based interface**. For example:
  * **Memory-mapped files** in both address spaces, which uses an API that is analogous to the POSIX shared-memory API.
  * The Android operating system uses a form of shared-memory inter-process communication (IPC) called **ashmem**.
    * ***N.B.*** There are a number of differences in the details of how ashmem behaves compared to the System V or POSIX APIs, but it is provided here for reference as another "real world" example.

The remainder of this lecture will focus on briefly describing the UNIX-based shared-memory APIs.

## 7. Inter-Process Communication (IPC) Comparison Quiz and Answers

Consider using inter-process communication (IPC) to communicate between processes. You can either use a **message-passing** or a **memory-based** API. Which one do you think will perform better? (Select one option.)
  * message passing
  * shared memory
  * neither; it depends
    * `CORRECT`
      * Message passing must perform multiple copies between the communicating processes and the kernel, resulting in corresponding overhead.
      * Shared-memory inter-process communication (IPC) incurs cost associated with the kernel establishing valid mappings among the processes' address spaces and the shared-memory pages, also resulting in corresponding overhead.
      * Therefore, there are drawbacks with both approaches, and therefore the performance will depend on the relative costs incurred by these respective overheads.

The next section will discuss trade-offs between these two inter-process communication (IPC) mechanisms.

## 8. Copy vs. Map

<center>
<img src="./assets/P03L03-011.png" width="550">
</center>

Before proceeding with further discussion, there is an important **contrast** to consider regarding message-based vs. shared-memory approaches to inter-process communication (IPC). The end **goal** of both of these approaches is to transfer some data from one address space into the other target address space.

<center>
<img src="./assets/P03L03-012.png" width="550">
</center>

In **message passing**, this goal requires that the CPU be involved in the **copying** of data. Accordingly, this requires some number of CPU cycles to copy the data into the channel (via the port) and then from the port into the target address space.

Conversely, in **shared memory**, this goal requires that (at a minimum) there are CPU cycles expended to **map** the physical memory into the appropriate address spaces. Furthermore, the CPU is also used to copy the data into the channel whenever necessary (however, in this case there are no user-to-kernel switches required).
  * The memory mapping itself is a costly operation, however, once the channel is established once and then subsequently used many times, this results in a **good payoff** (i.e., the setup cost is amortized appropriately).
  * Furthermore, even for a single use, the memory-mapped approach can still perform quite well. In particular, when it is necessary to move large amounts of data from one address space into another, the CPU time that is required to perform the copy operation can greatly exceed the CPU time required to perform the map operation (i.e., *`t`*`(copy) >> `*`t`*`(map)`).
    * In fact, Windows systems internally leverage the fact that there exists this difference with respect to the communication mechanisms they support between processes (i.e., if the data to be transferred is smaller than a certain threshold, then the data is copied in/out of a communication channel via a port-like interface, otherwise the data is potentially copied at least *once* to ensure that it is in a page-aligned area and then that area is mapped into the address space of the target process). This mechanism supported by the Windows kernel is called **"Local" Procedure Calls (LPCs)"**.

## 9-10. System V (SysV) Shared Memory

### 9. SysV Shared Memory Overview

Now that the shared-memory mechanisms have been described in a general way, consider the specific details of the **System V (SysV)** UNIX API.

<center>
<img src="./assets/P03L03-013.png" width="550">
</center>

Firstly, the operating system supports **segments** of shared memory, which need not necessarily correspond to *contiguous* physical pages.

Furthermore, the operating system treats **shared memory** as a ***system-wide*** resource, using system-wide policies. This means that there is a **limit** on the total number of segments (and correspondingly on the total size) of the shared memory.
  * ***N.B.*** Presently, imposing such limits is not as much of an issue (e.g., in Linux, currently the limit is `4000` segments). However, in the past, this limit was much more significant, being set to even as few as `6` segments in certain operating systems. Even more recent version of Linux had a limit of `128` segments.
  * The operating system may also impose other limits with respect to the system-wide shared memory.

<center>
<img src="./assets/P03L03-014.png" width="550">
</center>

When a process requests for a shared-memory segment to be **created**, the operating system allocates the required amount of physical memory (provided that certain limits are met), and then assigns a **unique key** to the process. This key is used to uniquely identify the segment within the operating system; any other process can refer to this particular segment via the key.

If the creating process wants to communicate with other processes using shared memory, then it will ensure that they "learn" this key in some manner (e.g., by using some other form of inter-process communication (IPC), passing it as a file or as a command-line argument, etc.).

<center>
<img src="./assets/P03L03-015.png" width="550">
</center>

Using the key, the shared-memory segment can be **attached** by a process (e.g., `P1`). This means that the operating system establishes **valid mappings** between the virtual addresses that are part of the processes' virtual address space (e.g., `VA 1`) and the corresponding physical memory (i.e., main memory) that backs the segment.

Furthermore, **multiple processes** (e.g., `P1` and `P2`) can attach to the *same* memory segment, in which case each process shares access to the *same* physical pages. Consequently, read and write operations from/to these pages will be visible across *all* processes, analogously to when threads share access to memory that is part of the same address space. Additionally, the shared-memory segment in physical memory in turn can be mapped to different virtual addresses in different processes (e.g., `VA 1` and `VA 2`).

<center>
<img src="./assets/P03L03-016.png" width="550">
</center>

**Detaching** a segment means **invalidating** the address mappings for the virtual address region (e.g., `VA 1`) that corresponded to the segment within the process (e.g., `P1`). In other words, the page table entries for those virtual addresses will no longer be valid.

However, note that a segment is *not* actually **destroyed** once it is detached; in fact, a segment may be attached, detached, and then re-attached multiple times by different processes over the lifetime of the segment. This means that once a segment is created, it is a **persistent entity** until there is an *explicit* request for it to be destroyed, similarly to what occurs with a file (i.e., the file is created and then the file persists until it is explicitly deleted; in the meantime, the file can be opened, closed, read from, written to, etc. and the file will still be present in the system).
  * ***N.B.*** This **property** of shared memory (i.e., to be removed only when it is explicitly deleted or when there is a system reboot) distinguishes it from regular, non-shared memory (which is `malloc()`d and then subsequently disappears as soon as the process exits).

### 10. SysV Shared Memory API


