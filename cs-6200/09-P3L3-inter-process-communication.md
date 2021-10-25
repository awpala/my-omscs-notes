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

This means that a simple **request-response interaction** among two processes requires `4` user/kernel crossing and `4` data-copying operations.

<center>
<img src="./assets/P03L03-005.png" width="550">
</center>

Consequently, a key **drawback** of message-passing inter-process communication (IPC) is that there is an associated **overhead** (i.e., the aforementioned user/kernel crossings and data-copying operations).

However, message-passing inter-process communication (IPC) provides the key **benefit** that it is relatively **simple**, inasmuch as the operating system kernel is able to handle all of the necessary operations and synchronization (e.g., channel management, synchronization, ensuring the data is not overwritten or corrupted as the processes send/receive messages, etc.).

### 5. Forms of Message Passing



