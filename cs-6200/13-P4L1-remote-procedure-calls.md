# P4L1: Remote Procedure Calls

## 1. Preview

The previous lectures have discussed several mechanisms for inter-process communication (IPC). It was indicated then that these are fairly low-level mechanisms inasmuch as they focus on providing the basic capability for moving data among address spaces, but otherwise do not specify anything about the semantics of those operations or the protocols involved.

This lecture discusses **remote procedure calls (RPCs)**, an inter-process communication mechanism which specifies that processes interact via **procedure call interface**.

For the general discussion of remote procedure calls, this lecture will roughly follow the paper "*Implementing Remote Procedure Calls*" (1984) by Birrell and Nelson. This is an older paper, however, it very nicely discusses the general design space of remote procedure calls.

Later, the lecture will discuss SunRPC, a concrete implementation of an RPC system that is common in modern operating systems.

## 2. Why RPC?

<center>
<img src="./assets/P04L01-001.png" width="600">
</center>

To understand why RPC is necessary, consider two example applications, as in the figure shown above.

In the first application, a client requests a file from a server using a simple HTTP-like protocol called **GetFile** (cf. CS 6200 Project 1). In this application, the client and the server interact via a socket-based API, requiring the developer to:
  * Explicitly create and initialize the sockets.
  * Allocate and populate buffers for sending via the sockets.
  * Include protocol information (e.g., GetFile directive/header, buffer size, etc.).
  * Explicitly copy data (e.g., filename, file, etc.) into/out of the buffers.

In the second application, which is another client-server application, the client interacts with the server to upload some images, and then requests to the server for these images to be modified (e.g., to create a grayscale version of an image, to create a low-resolution version of an image, to apply some phase-detection algorithm, etc.). Therefore, while this application is similar to the first, there are some additional functionalities (i.e., processing) to be performed for every image. Correspondingly, the developer must perform similar steps (in some case identically) to the first application, with some notable differences:
  * Protocol-related information to be included in the buffers must specify information such as the algorithm (e.g., grayscaling, face detection, etc.) requested by the client to be performed by the server, as well as any relevant parameters.
  * The data sent between the client and the server is image data, which is both sent from the client to the server for processing, as well as received back by the client in post-processed form.

Observe that many of the ***steps*** are identical between the two applications. In the 1980s, as the speed of networks improved and as increasingly more distributed applications were being developed, it became obvious that these kinds of steps are quite ***common*** in related inter-process communications, requiring tedious re-implementation for a majority of these kinds of applications. Consequently, it became apparent that some system solution was necessary to simplify this process, i.e., capturing the common steps related to *remote* inter-process communication; accordingly, this gave rise to **remote procedure calls (RPCs)**.

## 3. Benefits of RPC

<center>
<img src="./assets/P04L01-002.png" width="550">
</center>

Remote procedure calls (RPCs) are intended to simplify the develop of cross-address space and/or cross-machine interactions.

Therefore, the **benefits** of remote procedure calls (RPCs) are as follows:
  * Remote procedure calls (RPCs) provide a higher-level interface for data movement and communication (e.g., communication establishment, requests, responses, acknowledgements, etc.).
  * Remote procedure calls (RPCs) permit for capturing a lot of error-handling and automating it, relieving the programmer's responsibility to otherwise manage this (i.e., via explicit implementation of error-handling facilities for *all* types of errors).
  * Remote procedure calls (RPCs) hide the complexities of cross-machine interactions from the programmer (e.g., machines of different types, failure of the connecting network, failure of either machine, etc.).

## 4. RPC Requirements

<center>
<img src="./assets/P04L01-003.png" width="550">
</center>

Consider the **requirements** for the systems software that provides support for remote procedure calls (RPCs), as shown above.
  1. The model of inter-process interactions that the RPC model is intended for must manage **client-server interactions**, whereby the server supports some potentially complex service (e.g., a complex computation which it executes quickly, a file service that serves remote content, etc.) that is otherwise not present in the client (i.e., either is not needed to be present on the client or is beyond the client's capabilities).
  2. When RPCs were first developed, the state-of-the-art programming languages were of the procedural-programming paradigm (e.g., Basic, Pascal, Fortran, and C). Therefore, since these were most familiar to programmers when RPC was developed, a corresponding goal of RPC systems was to simplify the development of distributed applications via a **procedure call interface** (and hence the namesake, i.e., remote *procedure calls*).
      * Consequently, RPCs are intended to have corresponding ***synchronous*** call semantics, i.e., when a process makes an RPC (e.g., to a server), the calling process/thread (e.g., client) will ***block*** and then ***wait*** until the called RPC completes and returns its result. This is analogous to what occurs when a procedure is called in a *single* address space: The execution of the thread reaches the point where the procedure call is made, and then execution switches to somewhere in the address space where the procedure is implemented, and the originally executing thread does not advance beyond the original procedure-call point until the result from the procedure call is returned, at which point the calling thread can proceed with its execution.
  3. Similarly to regular procedure calls, RPCs also provide **type checking**.
      * Passing an argument of the wrong type produces an error, which in turn can be caught with appropriate error handling.
      * The implementation of the RPC run-time can be optimized, e.g., when packets are being sent among the two machines, the corresponding information is transmitted as a stream of bytes from one point to the other, therefore, conferring some notion of types on the data contained in those bytes can be useful when the RPC run-time attempts to interpret these bytes (e.g., integers, files, etc.).
  4. Since the client and the server may run on *different* machines, there may be differences in how they represent certain data types, i.e., there may be necessary **cross-machine conversion**.
      * For example, there may be differences in big- vs. little-endian representations of integers, in representations of floating-point numbers, in representations for negative numbers, etc.
      * Correspondingly, the RPC system should *hide* all of these differences from the programmer, and ensure that the data is otherwise correctly transported with appropriate conversions/translations performed as necessary. One way to manage this conversion is for the RPC run-time at both endpoints to agree upon a *single* data ***representation*** for the data types (e.g., it can agree that everything will be represented in the **network format**, thereby obviating the requirement for the two endpoints to negotiate exactly how data should be encoded/represented)/
  5. RPC is intended to be more than simply a transport-level protocol (e.g., TCP and UPD), which is concerned with sending packets from one endpoint to another in an ordered, reliable manner; additionally, RPC should provide a **higher-level protocol** that supports underneath it different kinds of protocols (i.e., the same types of client-server interactions should be supported regardless of whether the two machines use UDP vs. TCP, etc. to communicate).
      * RPC should therefore support different transport protocols.
      * RPC should also support other higher-level mechanisms such as access control, authentication, fault tolerance (e.g., if a server is unresponsive, the client can retry and reissue the same request to either the same server or to a replica of the original server), etc.

## 5. Structure of RPC

<center>
<img src="./assets/P04L01-004.png">
</center>

To illustrate the structure of the remote procedure call (RPC) system, consider the example client-server system in the figure shown above. Here, the client must perform some arithmetic operation (e.g., addition, subtraction, multiplication, etc.) but is not capable of performing this operation locally; therefore, the server is the (remote) "calculator" process.

In this scenario, whenever the client must perform some arithmetic operation, it must send a **message** to the server indicating the operation to be performed as well as the corresponding arguments/operands. The server in turn contains the implementation of the operation, returning the result to the client.

To simplify all of the communications-related aspects of the programming (e.g., creating sockets, allocating/managing the buffers for the arguments and for the results, etc.), this communication pattern will use a remote procedure call (RPC) as follows:
  1. The client requires to perform the addition operation `add(i, j)`, storing the result in `k`. Since the client does not possess the corresponding implementation, it must use the RPC.
      * ***N.B.*** In a regular program, when a procedure call is made, the execution jumps to some other point in the address space (i.e., where the implementation of that procedure is actually stored), making the appropriate update to the program counter to set it to some value in that address space corresponding to the first instruction of the procedure. Conversely, when the RPC `add()` is called, the execution of the program also jumps to another location in the address space, however, this location will not be the "real" implementation of `add()`, but rather it will be in a "**stub**" implementation; from the perspective of the rest of the client, this will "appear" as calling `add()`, but the corresponding implementation/internal representation is distinct from that of a local procedure call.
  2. The responsibility of the **client stub** is t ocreate a **buffer** and to populate the buffer with all of the appropriate information (e.g., the descriptor of the function `add` and its arguments `i` and `j`). The stub code itself is ***automatically*** generated via tools that are part of the RPC package, obviating the requirement for the programmer to do this explicitly.
      * Therefore, the client's call to `add()` moves the execution of the client process into a portion of the **RPC run-time** (the systems software that implements all of the RPC functionality), the first step of which is the stub implementation itself.
  3. After the buffer is created, the RPC run-time will send a **message** to the server process (e.g., via TCP/IP sockets or some other transport protocol).
      * ***N.B.*** For simplicity, the figure shown above omits information about the server (e.g., its IP address, the port number where it is running, etc.) which is otherwise available to the client, which in turn is used by the RPC run-time to establish the connection and to carry out all of the necessary communication.
  4. On the server side, when the **packets** for the connection are received, they are relayed to the **server stub**.
  5. The **server stub** is code which knows how to parse and to interpret all of the received bytes in the packets from the client that were delivered to the server stub, and which also knows how to determine that this is an RPC request for the procedure `add()` with arguments `i` and `j`.
      * Once the server stub determines that it must perform `add()`, it knows that the remaining bytes must be interpreted as the corresponding integer arguments `i` and `j` (i.e., the server stub will know how many bytes to copy from the packet stream and how to allocate data structures for these particular integer variables `i` and `j` to be created in the address space of the server process).
  6. Once all of the information is extracted on the server side, the corresponding local variables are created in the address space of the user-level server process, and the server stub is ready to make a call in the server process that has the actual implementation of all of the necessary arithmetic operations, including `add()`. Only at this point is the *actual* implementation of the procedure `add()` called, with the result of the addition of `i` and `j` being computed and subsequently stored in a variable in the server process's address space.

Once the result is computed on the server side, it will take the reverse path:
  1. It proceeds through the server stub, which first creates a buffer for the result, and then sends a response back to the client via the appropriate client connection.
  2. On the client side, it arrives in the RPC run-time via the received response packets, and then result is extracted from these packets by the client stub and then is placed somewhere in memory in the user-level client process's address space, ultimately returning the result to the client process.

For the entire duration between the initial call to the remote procedure call (RPC) by the client up to receiving the response from the server process, the client process is ***blocked*** (i.e., suspended) on the operation `add()`, similarly to what occurs during a local procedure call; the execution of the client process can only continue when the result of the (remote or local) procedure call is available.

## 6. Steps in RPC


