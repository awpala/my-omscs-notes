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



