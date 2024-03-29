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
  * For example, the caller thread can simply pass a request data structure to the device itself, and in turn the device performs the operation (e.g., direct memory access). Subsequently, the thread can come back at a later time to check whether the device has completed the operation.

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

Consider now an analysis of the three concurrency models discussed thus far in this lecture.

Of the three models mentioned, which model likely requires the *least* amount of memory?
  * Boss/Worker Model
    * `INCORRECT`
  * Pipeline Model
    * `INCORRECT`
  * Event-Driven Model
    * `CORRECT`

Why do you think this model requires the least amount of memory?
  * In the other models, a *separate* (worker) thread is required for each request or for each pipeline stage (respectively), whereas in the event-driven model, there are handlers (which are just procedures in the same address space) and helper threads (which only occur for blocking operations). Correspondingly, for the event-driven model, extra main memory is only required for helper threads for currently blocking I/O operations, but otherwise not for *all* other concurrent requests (as is the case in the other two models). Therefore, for the same configuration, it is most likely that the event-driven model will have the smallest memory footprint.

## 18. Flash Web Server

### Flash: An Event-Driven Web Server

<center>
<img src="./assets/P02L05-024.png" width="550">
</center>

Given the background information given on the event-driven model, discussion will now focus on Flash (as described in Pai et al.). **Flash** is an event-driven web server following the AMPED model, with asymmetric helper processes to deal with blocking I/O operations.

In the discussion thus far, we have essentially described the architecture of Flash, which consists of the following (familiar) components:
  * **helper** processes to handle blocking I/O operations
  * everything else is implemented via an **event dispatcher**, with **handlers** performing different portions of the Web servicing tasks

Given that we are discussing a Web server--and particularly, the older Web 1.0 model, the contemporary of the Flash server (wherein the server simply returns static files)--the primary blocking I/O operations that occur in the system are **disk reads** (i.e., reading the files that the client requests).

The communication from the helpers to the event dispatcher is performed via **pipes**.

The helper reads files in memory via the call `mmap()`.

The dispatcher checks (via operation `mincore()`) if the pages are in main memory in order to determine whether to call one of the local handlers or to call the helper.
  * As long as the file is in main memory, reading the file will result in a blocking I/O operation, and therefore passing it to the local handlers is an acceptable solution.
  * Because of this "extra check" immediately prior to performing the (relatively expensive) file read operation, this nets large savings due to prevention of blocking the entire process in the case where it is unnecessary (i.e., when a local handler is sufficient instead).

### Flash: Additional Optimizations

Now, consider an outline of some additional details regarding the performance optimizations applied by Flash, which later will help to understand the performance comparisons. The **important point** to note is that these optimizations are particularly relevant to any Web server.

<center>
<img src="./assets/P02L05-025.png" width="550">
</center>

Flash performs **application-level caching** at multiple levels, and it does this for both data and computations.
  * Caching of files is referred to as **data caching**.
  * Additionally, in some cases it is also sensible to cache **computations**. 
      * In the case of a Web server, the requests are made for files, which in turn must be repeatedly searched (e.g., file location, directory traversal, reading directory data structures, etc.); this processing will compute results (e.g., file pathnames), which can be cached (i.e., rather than re-computed repeatedly for each new request).
      * Similarly, the HTTP header that is sent as a response from the server to the browser/client will depend on the file itself (e.g., a lot of the corresponding fields are file-dependent); therefore, given that the file does not change, correspondingly the header does not need to change these parts either, and therefore similar 
      application-level computational caching can be applied.

Additionally, Flash performs other optimizations that take advantage of the network hardware (i.e., the network interface card), e.g.,:
  * All of the data structures are aligned to facilitate direct memory access operations without superfluous copying of data
  * direct memory access operations with **scatter-gather** support are also used to relax the requirement of the response header and file data needing to be aligned adjacently in memory (i.e., they can be sent from *different* memory locations instead), similarly avoiding a superfluous copy operation

All of the aforementioned are useful techniques which are now fairly **common optimizations**, however, at the time of the paper's release, these were relatively novel features which were largely absent in the systems against which the Flash server was compared at the time.

## 19. Apache Web Server

Before proceeding further, let us briefly describe the **Apache** Web server, a popular open-source Web server which is one of the technologies compared against by Pai et al. with respect to Flash.
  * ***N.B.*** The intent here is *not* to give a detailed lecture on Apache, which is beyond the scope of the course, but rather to provide sufficient details regarding the architecture of Apache for comparison with the aforementioned models, and in turn to highlight how the topics discussed in the course are reflected in "real world" designs. 

<center>
<img src="./assets/P02L05-026.png" width="550">
</center>

From a high level, the software architecture of Apache is as shown in the figure above.
  * The **core** component provides the basic server-like capabilities (e.g., accepting connections and managing concurrency).
  * The different **modules** correspond different types of functionality that is executed on each request. The specific Apache deployment can be configured to include different types of modules (e.g., certain security features, management of dynamic content, basic HTTP request processing, etc.)

The **flow of control** is similar to the event-driven model seen previously, whereby each request passes through all of the modules. As in the event-driven modules, ultimately each request passes through all of the corresponding handlers.

However, Apache is a **combination** of a multi-process and a multi-threaded model.
  * ***Multi-threaded***: In Apache, a single process (i.e., a single instance) is a multi-threaded **boss/workers** process having a dynamically managed workers thread pool, wherein there is a configurable threshold that can be used to dynamically track when to adjust (i.e., increase or decrease) the number of workers threads in the pool.
  * ***Multi-process***: Furthermore, the total number of processes can also be adjusted dynamically, based on information such as the number of outstanding connections, the number of pending requests, CPU usage, etc.; these (and other) factors correspondingly determine how to adjust the number of threads per process and/or the total number of processes.

## 20. Experimental Methodology

### Setting Up Performance Comparisons

Consider now the experimental approach used by Pai et al. in the Flash paper. The experiments were designed so that they can make stronger arguments about the contributions that the authors claim regarding Flash; in general, this is always something to consider when designing experiments and drawing such conclusions/inferences.

<center>
<img src="./assets/P02L05-027.png" width="500">
</center>

To achieve this, it is imperative to answer several **important questions**, e.g.,:
  * Define **comparison points**: *What* **systems** are you actually comparing?
    * If comparing two software implementations, keep the hardware the same, and similarly if comparing two hardware platforms, keep the software the same.
  * Define **inputs**: *What* **workloads** will be used for evaluation?
    * Does the input data resemble "real world" data, will synthetic traces be used, etc. These are all important questions to be resolved.
  * Define **metrics**: *How* will you **measure** performance?
    * What is the relevant metric(s) for the system, stakeholders, and resources used (e.g., execution time, throughput, response time, etc., as discussed previously in this lecture).

### Flash Performance Comparisons

Let us now consider how these questions are addressed in the Flash paper.

#### Define Comparison Points

<center>
<img src="./assets/P02L05-028.png" width="500">
</center>

Regarding the comparison of **systems** in the Flash paper:
  * Used a **multi-process** system using the same kind of Flash processing (i.e., a Web server with the exact same optimizations that were applied in Flash), however, in a multi-process, single-threaded configuration
  * Again, using the same optimizations as Flash, they developed a **multi-threaded** Web server following the boss/workers model.
  * They compared Flash with a **Single-Process Event-Driven (SPED)** model, similar to the basic event-driven model discussed first in this lecture (cf. Section 12).
  * Furthermore, they compared two existing Web server implementations:
    * **Zeus**, a research implementation that follows the SPED model, however, which uses two processes in order to deal with blocking I/O.
    * **Apache**, the open-source Web server, which at the time (v. 1.3.1) was implemented with a multi-process configuration

With the exception of Apache, each of these compared implementations integrated many of the **optimizations** that Flash had already introduced.

Furthermore, each of these implementations was compared against Flash (i.e., the **AMPED** model), given that the other implementations otherwise used the exact same code with the same/equivalent optimizations.

#### Define Inputs

<center>
<img src="./assets/P02L05-029.png" width="500">
</center>

Regarding the comparison of **workloads**/**inputs** in the Flash paper, to define useful inputs, they wanted workloads that:
  * Represented a realistic sequence of requests in order to capture the distribution of Web page accesses over time
  * Were controlled and reproducible (i.e., using the *same* access patterns), which prompted the authors to use a **trace-based** approach, wherein they gathered traces from real Web servers and subsequently replayed those traces in order to be able to repeat the experiment with the different implementations (i.e., with all of them being evaluated against the *same* traces). This resulted in the following **traces**:
    * CS Web Server trace (Rice University), representing Rice University's Web server for the CS department, which included a large number of files which do not all fit in memory
    * Owlnet trace (Rice University), derived from a Web server that hosted a number of student Web pages, which was comparatively smaller and consequently capable of fitting in the memory of a common server.
  * Additionally, the authors used a **synthetic workload generator** (i.e., rather than replaying traces), which allowed to perform some best- and worst-case analysis, as well as running "*what if?*" queries (e.g., *"What if the distribution of the Web page accesses had a certain pattern, then would something change about the observation?"*).

#### Define Metrics

<center>
<img src="./assets/P02L05-030.png" width="500">
</center>

Regarding the comparison of **performance**/**metrics** in the Flash paper:
  * When evaluating Web servers, a common metric to use is **bandwidth** (units of `bytes/time`, e.g., `MB/s`), i.e., the total amount of useful bytes transferred from files over the time period elapsed when making the transfer.
  * Because the authors were particularly concerned with Flash's ability to deal with concurrent processing, they evaluated the impact on the **connection rate** (units of `requests/time`), i.e., the total number of client connections serviced over a period of time.

Both of these metrics were evaluated as a function of the **file size**, therefore, the understanding the authors were attempting to gain was regarding how the workload property of requests (which were made for different file sizes) impact either of these metrics?\
  * The general **intuition** was that with a larger file size, the connection cost can be ***amortized** while simultaneously increasing the bandwidth (i.e., transmitting more bytes per-unit time)
  * However, at the same time, the larger file size also introduces more work per connection (i.e., reading and sending more bytes, all else equal), thereby adversely impacting the connection rate

Therefore, it was determined that file size is a useful parameter to vary in order to observe the impact on the metrics (bandwidth and connection rate) for the various implementations.

## 21. Experimental Results

Let us now consider the experimental results of the Apache paper.

### Best-Case Numbers

<center>
<img src="./assets/P02L05-031.png" width="600">
</center>

To gather the best-case numbers, the authors used a **synthetic load**, in which they varied the number of requests that are issued against the Web server, with every request being for the exact *same* file (e.g., `index.html`).
  * This is the **best case**, because in reality clients will likely be asking for *different* files.
  * Furthermore, in this "pathological" best case, it is very likely that the file will be in the cache, so that every one of the requests are serviced as quickly as possible.

For these best-case experiments, the authors measured the **bandwidth** by varying the file size over the range of `0` to `200` kilobytes (KB), and they ***measured*** the bandwidth as follows:
```
BW = N * bytes(F)/t
```
where `N` is the number of requests, `bytes(F)` is the file size, and `t` is the time required to process the `N` requests for the given file size.

Therefore, by varying the file size, they varied the work that *both* the Web server performed per request *and* also the amount of bytes that were generated per request. Correspondingly, with this setup, as the file size is increased, the bandwidth generally increases.

<center>
<img src="./assets/P02L05-032.png" width="600">
</center>

The **results** curves indicate that for every one of the cases, they are all comparable. Accordingly, the following **observations** can be made:
  * All exhibit similar results.
  * **SPED** has the best performance overall, as expected.
    * The SPED model does not have any threads or processes among which it needs to context switch.
  * **Flash AMPED** has similar performance to SPED, however, it performs an extra check for the memory presence.
    * In this case, it is a single-file tree, therefore, every request is for this single file, and therefore there is no need blocking I/O and consequently no need for the helper processes to be invoked; however, nevertheless, the check *is* performed here, resulting in a slight performance penalty, as observed in the result curve.
  * **Zeus** has a performance anomaly wherein it begins to "dip" starting around 150 KB, due to misalignment for some of the direct memory access operations. Therefore, not all of the optimizations are bug-proof in the Zeus implementation.
  * For the **multi-threaded (MT)** and **multi-process (MP)** models, the performance is slower due to the associated overhead required for context switching and extra synchronization.
  * The performance of **Apache** is the worst, due to the lack of optimizations as implemented in the other models.

### Traces

Since real clients do not behave as synthetic ones, the authors additionally assessed what happens with some realistic traces.

#### Owlnet Trace

<center>
<img src="./assets/P02L05-033.png" width="600">
</center>

The Owlnet trace yielded the following **observations**:
  * The performance is very similar to the best case, with **SPED** and **Flash** being the best, and then the **multi-threaded**, **multi-process**, and **Apache** implementations dropping down below that.
    * Because this is only a small trace, most of it will fit in the cache, giving rise to similar behavior as for the best case, wherein all of the requests are serviced from the cache.
    * Sometimes, however, blocking I/O *is* required here, i.e., it *mostly* fits in the cache (but not *always*). Given this (albeit remote) possibility, **SPED** did occasionally block, whereas in **Flash** the helper processes were able to resolve this issue.
  * Note that **Zeus**'s performance is not considered in this analysis.

#### CS Trace

<center>
<img src="./assets/P02L05-034.png" width="600">
</center>

The CS trace yielded the following **observations**:
  * Since this is the larger trace, it mostly required I/O (i.e., generally, the requests will *not* fit in the system's cache).
  * **SPED** was the worst-performing due to the lack of asynchronous I/O operations
  * The **multi-threaded** model performed better than the **multi-process** model, due to the former having:
    * a smaller memory footprint (i.e., more memory available to cache files and in turn leading to less I/O operations, all else equal)
    * cheaper (faster) synchronization and coordination (e.g., context switching) between threads
  * In *all* cases, **Flash** performs the best due to:
    * a smaller memory footprint (even compared to the multi-threaded and multi-process models), and consequently more memory available for caching files and headers and fewer requests lead to a blocking I/O operation (which additionally speeds up performance)
    * no explicit synchronization required due to the shared address space

### Impact of Optimizations

In both traces, **Apache** performed the ***worst***. Therefore, let us now consider if there is really an impact from the optimizations performed in Flash.

<center>
<img src="./assets/P02L05-035.png" width="600">
</center>

In the figure shown above, the result curves represent the different **optimizations** performed by Flash:
* `no opts` - no optimizations performed
* `path only` - only the directory lookup caching (i.e., computational caching)
* `path & mmap` - caching both of the directory lookup and of the file
* `all` - all of the optimizations (i.e., directory lookup, file caching, and the header computations of the file)

As is apparent from the figure, as incremental optimizations are added, this did indeed **impact** the connection rates (i.e., the performance) that can be achieved by the Web Server with a significant improvement (i.e., for a given file size, it is possible to sustain a higher connection rate as the optimizations are added).

Therefore, this gives rise to two **conclusions**:
  1. These optimizations are indeed important
  2. Apache would also have benefitted from these optimizations

## 22. Summary of Performance Results

<center>
<img src="./assets/P02L05-036.png" width="600">
</center>

To summarize, the performance results for Flash suggest the following:
* When the data is in cache, **SPED** performs much better than **AMPED Flash**, because it does not require the test for memory presence (which *is* necessary in the latter)
* Both **SPED** and **AMPED Flash** perform better than the **multi-threaded (MT)** and **multi-process (MP)** models due to the overhead associated with synchronization and context switching in the latter two
* However, when the workload is disk-bound, **AMPED Flash** significantly outperformed **SPED** because the latter blocks due to no support for asynchronous I/O
* **AMPED Flash** performs better than both the **multi-threaded** and **multi-process** models due to better memory efficiency and less context switching required
  * In AMPED Flash, only the number of *concurrent* I/O-bound requests result in concurrent processes/threads

The AMPED Flash model is not necessarily suitable for every single type of server process, as there are certain **challenges** with event-driven architecture (e.g., requires taking advantage of multiple cores, which in turn requires the ability to route events to the appropriate core; in other cases, perhaps the processing itself is not as suitable for this type of architecture; etc.). However, in examining some of the high-performance server implementations in common use today, many of them do indeed use an event-driven model combined with asynchronous I/O support.

## 23. Performance Observation Quiz and Answers

Let us consider one last look at the experimental results from the Flash paper, this time as a quiz.

<center>
<img src="./assets/P02L05-037.png" width="450">
</center>

Shown above is another figure from the Flash paper. Focusing on the red (**SPED**) and green (**Flash**) curves, at an input of around 100 MB, Flash becomes ***better*** than SPED. Why? (Check all that apply.)
  * Flash can handle I/O operations without blocking
    * `APPLIES`
  * SPED starts receiving more requests
    * `DOES NOT APPLY` - This is nonsensical--both processes receive the *same* number of requests in these experiments
  * The workload becomes I/O-bound
    * `APPLIES` - At 100 MB, the size of the workload increases, and consequently it cannot fit in the cache as much as before and therefore it becomes more I/O-bound (i.e., there are more I/O requests required beyond this point).
      * For SPED, the problem at this point (i.e., once the workload becomes more I/O-bound) is that a single blocking I/O operation will block the *entire* process, and therefore none of the other requests can make progress, thereby adversely impacting its performance.
  * Flash can cache more files
    * `DOES NOT APPLY` - This is incorrect. Both SPED and Flash have comparable memory footprints, and therefore it is not the case that one can handle more files in the memory cache than the other; if anything, Flash has the helper processes available, which if created, then they will interfere with the other available memory, thereby adversely impacting the available cache (i.e., *less* cache would be available rather than *more*). Therefore, this does not explain Flash's comparably *better* performance.

## 24. Advice on Designing Experiments

Before concluding this lecture, let us consider the **design of experiments**.

### Design Relevant Experiments

<center>
<img src="./assets/P02L05-038.png" width="500">
</center>

It sounds simple enough: Just run the test cases, gather metrics, and show the results. However, it is not quite so simple, after all.

There is a lot of planning and thoughtfulness required in planning **relevant experiments**, i.e., those leading to statements about a solution that are ***credible*** (i.e., others believe) and ***relevant*** (i.e., others care for).
  * For example, the Flash paper has many relevant experiments. There, the authors provided detail descriptions of all experiments so that the reader can understand them and believe the results were realistic. Furthermore, given the authors results, it is possible to make well-founded statements about Flash and the AMPED model vs. all of the other implementations.

### Purpose of Relevant Experiments

<center>
<img src="./assets/P02L05-039.png" width="500">
</center>

Consider again the Web server as an example for which we can justify what makes certain experiments **relevant**.

The **clients** using the Web server are concerned with **response time** (i.e., how quickly the Web page is returned).

The **operators** of the Web server are concerned with **throughput** (i.e., how many total client requests can see the Web page over a period of time).

Therefore, this illustrates that it is most likely necessary to justify the solution using criteria that are pertinent to these stakeholder. Possible **goals** include:
  * Demonstrating that the solution improves both response time and throughput will have a great impact.
  * Demonstrating that the solution only improves response time will still have a good impact (e.g., for clients).
  * Demonstrating that the response time is improved but the throughput is adversely impacted, this may still be useful (e.g., for clients).
  * Demonstrating that the response time is maintained when the request rate increases is a useful result (e.g., for operators).

By understanding the **stakeholders** and the **goals** (i.e., of the stakeholders), it is possible to define relevant metrics, which in turn informs the configuration of the experiments.

### Picking the Right Metrics

<center>
<img src="./assets/P02L05-040.png" width="500">
</center>

When selecting metrics, a **rule of thumb** is to select **standard metrics** (i.e., those which are widely recognized in the target domain).
  * For example, in Web servers, it is sensible to discuss the client request rate, the client response time, etc.

Using standard metrics promotes reaching a broader audience, since more prospective stakeholders will have a better understanding of the experiment, even if the particular results are not the most impactful.

It is imperative to include **metrics** which answer the questions "Why? What? Who?," e.g.,:
  * Why am I doing this work?
  * What is it that I want to improve or understand by doing these experiments?
  * Who is it that cares about this?
  * etc.

Answering these questions implies the relevant questions to address, e.g.,:
  * To assess **client performance**, use metrics such as response time, number of timed-out requests, etc.
  * To assess the reduction of **operator costs**, use metrics such as throughput, operating costs (e.g., power), etc.

### Picking the Right Configuration Space

<center>
<img src="./assets/P02L05-041.png" width="500">
</center>

Once the relevant metrics are understood, it is imperative to understand the relevant **system factors** that affect those metrics, e.g.,:
  * **System Resources**
    * hardware (e.g., number and type of CPU(s), amount of main memory available on the server machines, etc.)
    * software (e.g., number of threads, sizes of the queues and buffer structures available in the program, etc.)
  * **Workload**
    * For a Web server, sensible workload factors include the request rate, number of concurrent requests, file size, access pattern, etc.

Once the **configuration space** is better understood, it is necessary to make judicious **choices**.
  * Select a subset of the **configuration parameters** that are most impactful with respect to changes in the metrics being observed.
  * Select **ranges for** each variable parameter. In particular, these ranges should be *relevant* (i.e., representative of actual use).
    * For example, do not simply vary the threads count between 1, 2, and 3 when Web servers that are actually deployed use thread counts in the hundreds.
    * Similarly, do not vary the file sizes to have sizes of 1 KB, 10 KB, and 100 KB when Web servers that are actually deployed serve files of sizes ranging from 10s of bytes up to 10s-100s of MBs and beyond.
  * Select a relevant **workload** (otherwise, unrealistic/hypothetical results will not be particularly impactful).
  * Include **best/worst case scenarios**
    * While these may not be representative of actual use, the value this bring is by virtue of demonstrating **limitations** and/or **opportunities** that are present in the proposed system.

### Are You Comparing Apples toApples?

<center>
<img src="./assets/P02L05-042.png" width="500">
</center>

For the various factors being considered, pick **useful combinations** of these factors. Many experimental results will simply reiterate the *same* point; therefore, it is not sensible to demonstrate such results ad nauseam. However, showing a few representative such results is indeed useful (i.e., to demonstrate that the results are valid).

Furthermore, it is imperative to make **"apples-to-apples" comparisons** (i.e., making valid comparisons using appropriate factors and controls). An example of a ***bad*** experimental design is as follows:
  * Combination 1: large workload, small resource size
  * Combination 2: small workload, large resource size
  * Result: better performance in Combination 2 compared to Combination 1
  * Conclusion: performance improves when resources are increased

This conclusion is ***incorrect***: The experimental design does not address the variation in workload, therefore the conclusion based on this design is tenuous at best.

### What about the Competition? What about the Baseline?

<center>
<img src="./assets/P02L05-043.png" width="500">
</center>

When designing an experiment, it should demonstrate that system being designed (or solution being proposed) in some way improves upon the **state-of-the-art**; otherwise, it is not clear why one would use it in the first place.

If a comparison/benchmark against the state-of-the-art is not feasible or practical (or it is not as valuable of a comparison for the particular experiment in question), then consider comparing against the **most common practice**.

Finally, also consider comparing with **extreme conditions** (i.e., best/worst case scenarios), which will provide insights into the properties of the system/solution under review (e.g., how does it scale as the workload increases).

## 25. Advice on Running Experiments

### I Have Designed the Experiments...Now What?

<center>
<img src="./assets/P02L05-044.png" width="500">
</center>

Once the experiment is properly ***designed***, it can be **performed** as follows:
  * Run the **test cases** `n` times, using the various ranges of the selected experimental factors
  * Compute the relevant **metrics** (e.g., averages over the `n` experimental runs)
  * Represent the **results** appropriately
    * Best practices for this are beyond the scope of current discussion, however, keep in mind that the appropriately selected visual representation can help to strengthen the arguments. Furthermore, reference other works/papers, online documentation, courses, etc. to gain insight into these best practices as well.

Lastly, do not forget to **make conclusions** about the results (i.e., demonstrate how the experimental results support the claims being made).

## 26. Experimental Design Quiz and Answers

Consider a hypothetical experiment for which we will determine if the experiments that are planning to be conducted will allow to make meaningful conclusions.

A toy shop manage wants to determine how many workers to hire to be able to handle the **worst case** scenario (in terms of orders coming into the shop).
  * Orders range in **difficulty** from `blocks` (simplest) to `teddy bears` to `trains` (most complex).
  * The shop has `3` separate **working areas**, each with tools for *any* toy. Each work area can be shared by multiple workers.

Which of the following **experiments** `(types of orders, number of workers)` will allow us to make meaningful conclusions about the manager's question? (Select one.)
  * Configuration 1: `{(train, 3), (train, 4), (train, 5)}`
    * `INCORRECT` - This option correctly identifies the most difficult order `trains` (i.e., the worst case scenario), however, the variation in the number of workers is inappropriate: In the first case, there is one worker per working area (i.e., 1+1+1), in the second case there is one per working area but with an extra assigned to another working area (i.e., 1+1+2), and in the third case there is one per working area but with two extras assigned to other work areas (i.e., 1+2+2). Therefore, the workload is unevenly distributed among the cases, and accordingly useful conclusions cannot be made.
  * Configuration 2: `{(blocks, 3), (bears, 6), (trains, 9)}`
    * `INCORRECT` - This option varies the order difficulties, which does not provide information about the worst case capacity of the system (i.e., it is not relevant to the manager's question).
  * Configuration 3: `{(mixed, 3), (mixed, 6), (mixed, 9)}`
    * `INCORRECT` - With a mixed workload, this could provide useful information about the average throughput of the toy shop (i.e., given a mixed workload, presumably representative of typical orders), however, this is not relevant to the manager's question (i.e., how is the *worst case* impacted by adding more workers to the toy shop).
  * Configuration 4: `{(train, 3), (train, 6), (train, 9)}`
    * `CORRECT` - This configuration both identifies the relevant order difficulty (i.e., `train`, the worst case), as well as appropriately varies the number of workers (i.e., 1 per working area, 2 per working area, and 3 per working area, respectively) to address the manager's question regarding the workers' handling of the worst case scenario as more workers are added. As a corollary, this configuration can also provide insight into the capacity of each individual working area (e.g., a follow-up experiment may be to add condition `(train, 12)`, `(train, 15)`, etc. to further investigate this and to determine if there is an optimal point beyond which adding more workers does not improve overall throughput).

***Rationale***: Given that the most complex case (i.e., worst case) of toy orders includes `trains`, then each of the trials should include a set of orders for trains. Furthermore, given that the toy shop has 3 working areas (which can be used to create any toy order and are shared by the workers), therefore to assess the incremental benefit of adding more workers to the working area (and correspondingly how many more toy orders can be processed), we should add as many more workers per working area as reasonably possible.

## 27. Lesson Summary

This lesson introduced the **event-driven model** for achieving concurrency in applications.

We performed **comparisons** between **multi-process**, **multi-threaded**, and **event-driven** designs/approaches for implementing a Web server application.

Additionally, we discussed in more general terms how to properly structure experiments (i.e., experimental evaluation and methodology)
