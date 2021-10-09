# P2L5: Thread Performance Considerations

## 1. Preview

This lecture will contrast several approaches for structuring applications that require concurrency
  * This will include a comparison between multi-process vs. multi-threaded vs. event-driven approaches

Additionally, this lectures's discussion will be based on the **event-driven models/architectures**, specifically Flash vs. Apache
  * Reference: Pai et al. "*Flash: An Efficient and Portable Web Server*." This paper describes the event-driven architecture Flash, and also includes detailed performance comparisons between multi-process, multi-threaded, and event-driven implementations of a Web server application
  * Additionally, Apache is a popular open source Web server that will be discussed towards the end of this lecture.

The lecture will conclude with a discussion on how to structure good experiments.

## 2. Which Threading Model Is Better?

<center>
<img src="./assets/P02L05-001.png" width="650">
</center>

Recall the comparison between the boss/workers and pipeline concurrency models (cf. P2L2 Section 40). As shown above, the total execution times to process 11 work orders are `360 ms` and `320 ms` (respectively).

Additionally, consider a comparison of the respective **average times** to complete the orders. Per the calculations shown above, these amount to `196 ms` and `220 ms` (respectively).

Therefore, for this particular configuration (i.e., 11 toy orders processed by 6 threads):
  * If minimizing the execution time is of importance (e.g., for the toy shop manager), then select the pipeline model
  * Otherwise, if minimizing the average time to completion is of importance (e.g., for the customers), then select the boss/workers model

***N.B.*** Changing the configuration (i.e., different number of threads and/or work orders) can affect these results, i.e., the analysis and conclusion ***depend on the metrics***.

## 3. Are Threads Useful?

At the beginning of P2L2, we asked: are threads useful?

<center>
<img src="./assets/P02L05-002.png" width="150">
</center>

Recall, there are a number of **reasons** why threads are indeed useful, e.g.,:
* **parallelization** - speed up execution
* **specialization** - hot cache via specialized threads
* **efficiency** - lower memory requirements and cheaper synchronization compared to equivalent multi-process implementations
* Even on a single CPU, threads are useful because they can hide the latency of I/O operations.

However, how did we draw these conclusions? (e.g., what resources were available in the system, what metrics were used for comparing implementations with/without threads, etc.)

### What is *Useful*?

To measure whether something is "useful" or not, this differs depending on what exactly is being measured.

For example:
  * For a matrix-multiplying application, the **execution time** is a key metric
  * For a Web service application:
    * The **number of client requests per-unit time** is a key metric for the server
    * The **response time** is a key metric for the client 
  * For a hardware chip (ie.g., CPU), **higher overall utilization** is a key metric

In the Web service application, useful metrics may include:
  * average time (a typical value)
  * maximum time (worst-case value)
  * minimum time (best-case value)
  * 95-percentile time (detect outliers)

Therefore, as these examples demonstrate, in order to evaluate a solution and to determine whether or not it is useful, it is important to determine the relevant **properties** (or **metrics**) that characterize the desired behavior.

## 4. Visual Metaphor

<center>
<img src="./assets/P02L05-003.png" width="500">
</center>

Let us now consider a visual metaphor for our discussion regarding metrics as follows:

| Characteristic | Optimization | Toy Shop | Operating Systems |
| :--: | :--: | :--: | :--: |
| throughput | maximize (as many as possible) | how many toys per hour? | process completion rate (i.e., the number of processes completed on a given platform per-unit time) |
| response time | minimize (as short as possible) | average time to react to a new order | average time to respond to an input (e.g., mouse click)  |
| utilization | maximize (ideally 100%)  | percentage of work benches in use over time  | percentage of CPU utilization (i.e., CPU, devices, memory, etc. are used efficiently, rather than persistently leaving a lot of unused/under-utilized resources) |

...and many more!

Therefore, metrics exist in virtually all systems, and accordingly it is imperative to have them be well-defined when attempting analyze the behavior of systems and how it compares to alternative solutions.

## 5-7. Performance Metrics

### 5. Introduction

As has been emphasized, performance considerations are focused on the metrics that we choose.

Ideally, **metrics** should be represented with values that we can ***measure*** and ***quantify***, preferably in a ***standardized*** manner. Correspondingly, the metric should be a measurable and/or quantifiable property.
  * A quantifiable metric allows to evaluate the system's behavior and/or to compare it to other systems
    * e.g., execution time
  * The metric itself should ***pertain*** to the **system** of interest
    * e.g., software implementation of a problem
  * The metric should be able to evaluate the system ***behavior***
    * e.g., improvement of the system compared to other implementations (i.e., over a range of meaningful parameters/dimensions such as varied workload, varied allocated resources, etc.)

### 6. Other Performance Metrics

<center>
<img src="./assets/P02L05-004.png" width="550">
</center>

So far, this lecture has mentioned several useful metrics (e.g., **execution time**, **throughput**, **response time/request rate**, and **CPU utilization**). Additionally, there are many other useful metrics to consider, e.g.,:
  * **wait time** - the user may not just care about when they *receive* a response, but also about when their request actually *begins* to execute
    * With a request/job involving many interactions, the sooner it starts, the sooner the user can proceed with these interactions
    * With a long-running request/job, the sooner it starts, the sooner the user is able to diagnose issues that can occur (e.g., to stop, re-configure, and re-launch)
  * **throughput** - how many tasks are completed per-unit time
    * In addition to helping to evaluate the utility of a platform, throughput can be relevant in the context of both a single machine (e.g., server) as well as a collection of machines (e.g., an entire data center)
  * **platform efficiency** - a combination of how well resources are utilized and how well they deliver the corresponding throughput
    * This is an additional metric (i.e., in addition to throughput) that is useful to assess large, complex systems (e.g., an entire data center)
    * There is a ***trade-off*** between throughput (i.e., revenue generation) and resource usage (i.e., incurred cost for additional machines, personnel, etc.)
  * A corollary to platform efficiency is assessing performance with respect to a ***particular resource***, e.g.,:
    * **performance per-unit cost** (e.g., per $) - operating cost
    * **performance per-unit power** (e.g., per Watt) - energy consumption
  * **percentage of service level agreement (SLA) violations** - determine if customer requirements are being met adequately
    * Service level agreements (e.g., guaranteed response within 3 seconds, guaranteed 95% accuracy of quotes, etc.) are typically used in enterprise applications to fulfill customer requirements 
  * **client-perceived performance** - assessing the customer experience
    * For certain applications, there is some "slack" in the requirements, e.g., in a regular video application, humans can only perceive up to 30 frames per second, therefore improving performance beyond this frame rate is unnecessary for this use case--rather, it is sufficient to simply ensure a frame rate of *at least* 30 frames per second is maintained
  * Furthermore, it may be useful to consider more ***holistic assessments***, e.g.,:
    * **aggregate performance** - Rather than focusing on the performance of an *individual* application, a more complex system may require assessment of average/aggregate performance across the system (e.g., average task time, weighted averages based on priorties of tasks, etc.)
    * **average resource usage** - In addition to CPU utilization, it may be useful to measure other resources (e.g., memory, file system, storage sub-system, etc.)

### 7. Summary

<center>
<img src="./assets/P02L05-005.png" width="300">
</center>

In summary, a **metric** is some ***measurable quantity*** that we can use to reason about the behavior of the system. Ideally, these metrics are obtained from:
  * **experiments** with real software deployment, real machines, real workloads, etc.
    * However, sometimes this is not an option (e.g., we cannot wait to actually deploy the software to before we begin measuring something about it and/or analyzing its behavior)
  * **'toy' experiments** using ***representative, realistic*** settings/configurations that mimic the real behavior of the system as much as possible (e.g., similar access patterns, similar types of machines, etc.)
  * supplemental **simulation** if necessary (e.g.,, if using toy experiments), such as creating an environment that mimics a larger system that is feasible to achieve with a smaller experiment/simulation

Any of these methods represent viable settings whereby one can evaluate a system and gather some performance metrics about it. Such experimental settings are referred to as a **testbed**.
  * A testbed indicates where the experiments were carried out and what were the relevant metrics that were measured

## 8. Are Threads *Really* Useful?

<center>
<img src="./assets/P02L05-006.png" width="150">
</center>

Returning to the question "*are threads useful?*" (recall Section 3), we realize now that the answer is not so straightforward; rather, it depends on the **metrics** and on the **workload**!

In the **toy shop** example, depending on the workload (i.e., different number of toy orders) and the corresponding metric, it led to the conclusion that a different implementation of the toy shop (i.e., a different way to organize its workers) was a better one.

In other domains, such as **graphs** and **graphs processing**, depending on the type of the graph in question (e.g., how well-connected it is), it may be suitable to choose a correspondingly different type of shortest-path algorithm. Here, the graph type is equivalent to the "workload."
  * Some shortest-path algorithms are known to work well on ***densely*** connected graphs
  * Other shortest-path algorithms work better for ***sparsely*** connected graphs

When comparing **file systems**, an important consideration may be is the **file patterns**, e.g.:
  * Some file systems may be optimized for predominantly ***read accesses***
  * Other file systems may be optimized for a mixed workload (e.g., *both* ***reading*** and ***updating***)

The larger **point** that transcends these particular examples is that in order to answer "the" question of whether something is better than an alternative implementation or algorithm is always the same: ***it depends***!

Correspondingly, the answer to the question of whether or not threads are *really* useful is: it depends (i.e., on the context in which we are trying to answer this particular question). Indeed, for practical purposes, this is (almost) *always* the correct answer, particularly when dealing with systems.
  * In fact, the contrary (i.e., a particular implementation/design is *always better*) is **not** an acceptable one in this course!

For the remainder of this lecture, we will attempt to answer more specifically whether threads *are* indeed useful, and particularly when are threads more or less useful when comparing a ***multithreaded-based implementation*** of a problem to some alternatives. Additionally, guidance will be provided for how to define some useful **metrics**, as well as how to structure **experimental evaluations** so that such metrics can be correctly ***measured***.

## 9. Multi-Process vs. Multi-Threaded

### How to Best Provide Concurrency?

To understand when threads *are* useful, let us consider the different ways to provide concurrency, as well as the tradeoffs among those implementations.

<center>
<img src="./assets/P02L05-007.png" width="450">
</center>

So far, discussion has focused around **multi-threaded** applications. Additionally, an application can be implemented by having multiple concurrently running processes (i.e., **multi-process**). (***N.B.*** This was also noted briefly in P2L2.)

<center>
<img src="./assets/P02L05-008.png" width="150">
</center>

To make the discussion of the comparison between these two models more concrete, we will perform this analysis in the context of a **Web server**. For a Web server, a **key feature** is the ability to concurrently process client requests.

### Example: Web Server

Before proceeding, let us consider the steps involved in the operation of a *simple* Web server.

<center>
<img src="./assets/P02L05-009.png" width="550">
</center>

1. The client (or browser) needs to send a request that the Web server will accept (e.g., to `www.gatech.edu`)

2. The Web server (e.g., `www.gatech.edu`) accepts the request

3. After the Web server accepts the request, there are a number of **processing steps** it must perform before finally providing the response (e.g., a **file**)
    * Read and parse an HTTP request
    * Find the file in the local file system (i.e., on the server side)
    * Compute the header
    * Send the header
    * Send the file, or potentially send an error message (e.g., "file not found") via the header

***N.B.*** The remainder of this lecture will focus on these processing steps. Also, note that there are differences among these steps, e.g.,:
  * Some of them are more computationally expensive, with most of the work being performed by the CPU (e.g., parsing the request and computing the header)
  * Others require interaction with the network (e.g., accepting the connection, reading the request, and sending the data) or with the disk (e.g., finding the file and reading the file)
  * Furthermore, some of these steps may potentially **block**; whether or not they block depends on the state of the system at a particular point in time (e.g., the connection may be already pending, the data for the file may already be cached in memory due to a previous request, etc.)
    * In these cases, this will not result in an actual call to the device (i.e., an invocation to the network or disk, respectively), and consequently will be serviced much more quickly

4. The Web server responds by sending the file or corresponding error message, thereby completing the overall process

## 10. Multi-Process Web Server

<center>
<img src="./assets/P02L05-010.png" width="600">
</center>
(adapted from Pai et al. Figure 2)

One easy way to achieve **concurrency** is to have *multiple instances* of the *same* process, i.e., a **multi-process** implementation.

The **benefit** of this approach is that it is ***simple***: Once the sequence of steps has been correctly developed for *one* process, this is generalized by simply spawning *multiple* processes of this same sequence.

There are some **drawbacks** to this approach of running multiple processes in a platform, however.
  * Each process requires memory allocation, thereby adding a high load on the memory sub-system and a consequent adverse impact on performance.
  * Given that these are processes, there is an associated cost with performing context switches among the processes.
  * It can be expensive to maintain **shared state** across the processes, because the communication mechanisms and the synchronization mechanisms that are available across processes are relatively higher in overhead.
  * In some cases, it may be tricky to perform certain tasks (e.g., forcing multiple processes to be able to respond to a single address and to share a single socket port)

## 11. Multi-Threaded Web Server

<center>
<img src="./assets/P02L05-011.png" width="550">
</center>
(adapted from Pai et al. Figure 3)

An alternative to the multi-process model is to develop a Web server as a **multi-threaded** application, having multiple execution contexts (i.e., multiple threads within the same address space, with every single one of them processing a request).
  * In the figure shown above, every single one of the threads executes *all* of the steps, starting with the "Accept Connection" operation all the way down to actually sending the file.
  * Another possibility is to have the Web server implemented as a boss/workers model, wherein a single boss thread performs the "Accept Connection" operation, and then subsequently every single one of the workers performs the remaining operations (i.e., from reading of the HTTP requests that comes in on that connection all the way down to sending the file).

The **benefits** of the multi-threaded approach are as follows:
  * The threads share the **address space** (i.e., everything within it), thereby precluding the necessity to perform system calls in order to coordinate with other threads (unlike in the multi-process model).
  * Context switching between the threads is relatively cheap, because it can be done at the user level (i.e., via the user-level threading library).
  * Since a lot of the per-thread **state** is shared among the threads, it is not necessary to allocate memory for *everything* that is required for each of their respective execution contexts (i.e., due to the shared address space). Consequently, the memory requirements are relatively lower in this approach.

The **drawback** of this approach is that it is not simple/straightforward to implement the multi-threaded program, i.e.,:
  * Requires explicit synchronization among the threads (e.g., during access and update of the shared state)
  * There is a reliance on the underlying operating system for it to support threads in the first place. While this is less of an issue with modern operating systems (many of which are multi-threaded already), this was indeed a non-trivial issue contemporaneously with the time period in which the Flash paper (Pai et al.) was written, and is therefore nevertheless an argument to be addressed in the present discussion.

## 12-16. Event-Driven Model

### 12. Introduction

Consider now an alternative model for structuring Web server applications that perform concurrent processing, called the **event-driven model**.

<center>
<img src="./assets/P02L05-012.png" width="600">
</center>
(adapted from Pai et al. Figure 4)

An event-driven application can be characterized as shown in the figure above. The application is implemented in a single address space, having a single process, and only a single thread of control.

The main part of the process is an **event dispatcher** that continuously (i.e., in a loop) looks for incoming **events**, and then based on those events the event dispatcher invokes one or more 
of the registered **event handlers**.

Examples of **events** include:
  * Receipt of the request from the client/browser
  * Completion of the send operation
  * Completion of the disk read operation

The event dispatcher has the ability accept any of these types of event notifications, and then based on their notification type it can invoke the appropriate event handler. In this respect, the event handler operates much like a **state machine** responding to external events.

Since (as described here) this model pertains to a single-threaded process, invoking an event handler is tantamount to jumping to the appropriate location in the process's address space where the event handler is implemented, at which point the event-handler execution can proceed.
  * For example, if the process is notified that there is a pending connection request on the network (i.e., via the corresponding network port), the event dispatcher will pass that event to the "Accept Connection" event handler.
  * Similarly, if the event is the receipt of a data message on an already established connection, then the event dispatcher will pass that to the "Read Request" event handler.
  * Once the file name is extracted from the request and it is confirmed that the file is present, the process will send out the file in chunks, and then once there is a confirmation that the chunks/portions of the file have been successfully sent, it will proceed iteratively in this manner (i.e., via the corresponding event handler responsible for the send operation) until the entire file is sent, or until an error is encountered and a corresponding error message is sent to the client

Therefore, whenever events occurs, the event handlers are the sequence of code that executes in response to the corresponding events.

A **key feature** of the event handlers is that they run to completion. Furthermore, if the handler must perform a **blocking** operation, it initiates the blocking operation and then immediately passes control back to the event dispatcher (i.e., the process is no longer in the handler), at which point the event dispatcher is now free to service other events or to call other event handlers.

### 13. Concurrent Execution in the Event-Driven Model

At this point, it may seem that if the event-driven model has just *one* thread, then it is  unreasonable to expect to achieve concurrency.

<center>
<img src="./assets/P02L05-013.png" width="550">
</center>

Recall that in the multi-process and multi-threaded models, *each* execution context (i.e., process or thread, respectively) handles only *one* request at a time, and therefore to achieve concurrency, *multiple* execution contexts are used accordingly. Furthermore, if there are fewer CPUs than available threads, then there must be context switching among the threads.

Conversely, the event-driven model achieves concurrency by **interleaving** multiple requests within the *same* execution context. Accordingly, in the event-driven model, the single thread switches its execution for the required processing among the different requests at any given time.

<center>
<img src="./assets/P02L05-014.png" width="400">
</center>

Consider a client request `C1` entering the system. It starts with the "Accept Connection" event, and proceeds through the events sequence. Once it reaches the event pertaining to reading the file from the server, I/O is initiated. At this point, `C1`'s request is waiting on the disk I/O operation to complete on the server side.

In the meantime, two additional client requests `C2` and `C3` are received. If `C2` was received first, it will eventually wait on `recv()` (i.e., an event from the network) to receive the HTTP response header from the server. At this point, if `C3` is received, it will begin at the "Accept Connections" handler.

<center>
<img src="./assets/P02L05-015.png" width="400">
</center>

At some later time point, the processing of all three requests will have proceeded along the sequence of events, e.g.,:
  * `C3`'s connection was accepted, and now it is waiting on `recv()` for the server response header
  * `C2` is now waiting on disk I/O on the server side (i.e., reading the file to send the data)
  * `C1` is now waiting on `send()`, receiving the file from the server in chunks

Therefore, as this example demonstrates, while there is only *one* execution context (i.e., a single thread), it is able to service multiple client requests concurrently in an interleaved manner.

### 14. Event-Driven Model: Why?

An immediately arising question is: *Why* does the event-driven model work? And, what is the benefit of having only a *single* thread that switches between different requests, rather than simply assigning different requests to different execution contexts (i.e., to different threads or to different processes).

<center>
<img src="./assets/P02L05-016.png" width="650">
</center>

Recall from the introductory lecture on threads (cf. P2L2) that even on one CPU, threads **hide latency**.
  * The main takeaway from that discussion (cf. P2L2 Section 5) is that if a thread will wait more than twice the amount of time that it takes to perform a context switch (i.e., if `t_idle > 2 * t_ctx_switch`), then it makes sense to perform the context switch to another thread that will perform some useful work in the meantime, thereby hiding latency.
  * Conversely, if there truly is no idle time (i.e., if `t_idle == 0`, such as if the processing of the request does not result in some type of blocking operation [e.g., I/O] on which it must wait), then context switching simply wastes cycles that otherwise could have been use for processing the requests, and therefore it is not sensible to perform the context switch in the first place.

Therefore, in the event-driven model, the request is processed (in the context of a single thread) until it is necessary to wait, and then it switches to another request.

If there are multiple CPUs available, the event-driven model is still sensible, especially when it is necessary to handle more concurrent requests than the number of available CPUs.
  * For example, each CPU can host a single event-driven process, and then handle multiple concurrent requests within that one context. Furthermore, this could be done with less overhead than if each of the CPUs otherwise had to context switch among multiple processes (or multiple threads), where each is handling a separate request.
  * There is one **caveat** here, however: It is important to have **mechanisms** in place that will direct the correct set of events to the appropriate CPU (i.e., at the appropriate instance of the event-driven process), otherwise the operation will be incorrect.
    * ***N.B.*** There are mechanisms available to achieve this, as well as current support in networking hardware, however, this is beyond the scope of the present discussion.

### 15. Event-Driven Model: How?

Consider now how the event-driven model can be actually implemented.

<center>
<img src="./assets/P02L05-017.png" width="650">
</center>

At the lowest level, it is necessary to receive some events from the **network** or from the **disk** (e.g., information about the request to be processed). The operating system uses the **abstractions** of **sockets** and **files** (respectively) for this purpose.

More generally, internally, the actual data structure that is used to represent sockets and files is identical, and is called a **file descriptor**. Therefore, an **event** in the context of the Web server example is simply an input on any of the corresponding file descriptors (e.g., socket and files) associated with that particular event.

To determine which file descriptor has an input (e.g., an event has arrived):
* The Flash paper describes using the call `select()`, which takes a range of file descriptors as a parameter and returns the first-encountered one which has an input, irrespective of the nature of the file descriptor (e.g., socket vs. file).
* An alternative approach to this is to use the `poll()` API, which is another system call provided by current operating systems.

The **problem** with both of these approaches is that in general they must scan through a potentially large list of file descriptors before encountering one having an input. Furthermore, it is also very likely that among this long list of file descriptors there will only be a few that have an input, thereby wasting much of the search time.

An alternative to these approaches is a more recent type of API (which is supported by the Linux kernel, for instance) called `epoll()`, which eliminates some of these problems inherent in `select()` and `poll()`. Accordingly, many high-performance servers that require high data rates and low latency use this kind of mechanism today.

#### Benefits of the Event-Driven Model

<center>
<img src="./assets/P02L05-018.png" width="650">
</center>

The **benefits** of the event-driven model derive from its inherent design; these are as follows:
  * A single address space giving rise to a single flow of control
  * Consequently, the overhead is relatively low:
    * smaller memory requirement
    * no context switching
  * The program is comparatively simpler due to no need for explicit synchronization constructs/primitives (e.g., shared access to variables, etc.)

***N.B.*** In the context of the *single* thread, there is switching among the multiple client connections (and corresponding "jumping around" the code to execute various handlers, accessing different parts of state, etc.) which in turn will affect performance (e.g., loss of locality and cache pollution effects), however,  this performance penalty is offset by the corresponding savings in avoiding (comparatively more expensive) context switching and synchronization.

### 16. Helper Threads and Processes

#### Problem with Event-Driven Model

Note that, despite the aforementioned benefits, the event-driven model is not without its **challenges**.

<center>
<img src="./assets/P02L05-019.png" width="550">
</center>

Recall previously when discussing the many-to-one multi-threading model (cf. P2L2 Section 32) that a single **blocking** I/O call originating from one of the user-level threads can **block** the *entire* process, even though there may be other user-level threads that are ready to execute.

A similar **problem** exists in the event-driven model: If one of the event handlers issues a blocking call I/O call (e.g., to read data from the network or from disk), then the *entire* event-driven process can be correspondingly blocked.

#### Asynchronous I/O Operations

<center>
<img src="./assets/P02L05-020.png" width="550">
</center>

One way to circumvent this problem is to use **asynchronous I/O operations**.

**Asynchronous system calls** have the **property** that when the system call is made, the kernel captures enough information about the caller and where and how the data should be returned once it becomes available in order to prevent blocking of normal operation.

<center>
<img src="./assets/P02L05-021.png" width="550">
</center>

Asynchronous system calls also provide the caller with the opportunity to proceed executing a task, and then return at a later time to check whether the results of the asynchronous operation are already available (e.g., the processor/thread can come back later to check if a file has already been read and the data is available in a buffer in memory).

One **aspect** that makes asynchronous calls possible is that the operating system **kernel** is multi-threaded; therefore, while the caller thread continues execution, *another* kernel thread performs all of the necessary work and the required waiting in order to perform the I/O operation (e.g., retrieve the data) and to ensure that the results become available to the appropriate user-level context.

Furthermore, asynchronous operations can benefit from the actual **I/O devices** themselves.
  * For example, the caller thread can simply pass a request data structure to the device itself, and in turn the device performs the operation (e.g., dynamic memory allocation). Subsequently, the thread can come back at a later time to check whether the device has completed the operation.

***N.B.*** We will return to asynchronous I/O operations in a later lecture. For present purposes, note that when using asynchronous I/O operations, the process will *not* be blocked in the kernel when performing I/O.
  * In the event-driven model, if the event handler initiates an asynchronous I/O operation (e.g., for network or for disk), the operating system can simply use a mechanism such as `select()`, `poll()`, or `epoll()` to catch such events.

In summary, asynchronous I/O operations fit very nicely with the event-driven model.

#### What if Asynchronous Calls Are Not Available?

The **problem** that arises with asynchronous calls is that they were not ubiquitously available in the past, and even at present they may not be available for all types of devices.

<center>
<img src="./assets/P02L05-022.png" width="550">
</center>
(adapted from Pai et al. Figure 5)

In a more general case, perhaps the process to be performed by the server is not to read data from a file (where asynchronous calls *are* available), but rather is to call processing on some other device (e.g., accelerator) that only the server has access to.

To deal with this problem, Pai et al. proposed to use **helpers**.
  * When the event handler must issue an I/O operation that can block, it passes it to the helper and then returns to the event dispatcher. The helper will be responsible for handling the blocking I/O operation, as well as interacting with the event dispatcher as necessary.
  * The communication with the helper can be performed via a socket-based interface or via a **pipe** (another messaging interface that is available on most operating systems), both of which expose a file-descriptor-like interface, thereby allowing similar `select()`, `poll()`, etc. mechanisms for use with the event dispatcher (i.e., to keep track of the various events occurring in the system)
    * This system interface can be used to track whether the helpers are providing any events to the event dispatcher at any given time
  * With this helper in place, the synchronous I/O call is handled by the helper, with the helper performing the **block** operation while the main event loop/dispatcher (an corresponding main process) does *not* block

In operating in this manner, while there are no asynchronous I/O calls, the helpers allow to achieve analogous behavior as if there were asynchronous calls being made.

At the time of the writing of the paper, another **limitation** was that not all kernels were multi-threaded, and therefore not all kernels supported the aforementioned one-to-one model (cf. P2L2 Section 32). In order to deal with this limitation, the decision made by the authors was to make the helper entities processes; accordingly, they called this model the **Asymmetric Multi-Process Event-Driven Model (AMPED)** (i.e., an event-driven model comprised of multiple processes, wherein the processes are asymmetric--the helper processes only deal with blocking I/O operations, while the main process performs everything else).
  * ***N.B.*** In principle, the same idea would apply to a multi-threaded scenario (i.e., where the helpers are threads rather than processes) giving rise to an analogous **Asymmetric Multi-Threaded Event-Driven Model (AMTED)**; in fact, there exists a follow up to the Flash paper that does just this.

<center>
<img src="./assets/P02L05-023.png" width="550">
</center>

The key **benefit** of the asymmetric model is that it resolves some of the limitations of the pure event-driven model pertaining to the requirements of the operating system, e.g.,:
  * Eliminates the dependence on asynchronous I/O calls and threading support
  * Better portability
  * Achieves concurrency with a relatively smaller memory footprint than a regular worker thread in a multi-process or multi-threaded model
    * In the latter case, the worker must perform *everything* for a full request, therefore its memory requirements are comparatively larger than a comparable helper entity
    * Additionally, in the AMPEG model, there is only a helper entity for each concurrent *blocking* I/o operation, whereas the multi-threaded and multi-process models require as many concurrent entities, processes, or threads as there are actual concurrent requests, irrespectively of whether or not they block

The key **drawbacks** of the asymmetric model include:
  * Although it works well with such a server application, it is not necessarily as generally applicable to arbitrary applications.
  * Additionally, there are complexities associated with the event routing of events in multi-CPU systems.

## 17. Models and Memory Quiz and Answers
