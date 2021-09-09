# P2L3: Threads Case Study: PThreads

## 1. Preview

Recall that Birrell's paper "*An Introduction to Programming with Threads*" (1989) describes multithreading, concurrency, and synchronization in *generic* terms. This lecture will cover ***PThreads***, which are a ***concrete*** multithreading system, which is the de facto standard in UNIX systems (e.g., Linux).

"PThreads" denotes **POSIX Threads**, wherein **POSIX (Portable Operating System Interface)** describes the system call interface to be supported by operating systems. POSIX is intended to improve portability among different operating systems. Within POSIX, **PThreads** describes the threading-related API that must be supported by the operating systems in order to perform creation, usage, management, etc. of threads, which encompasses the threads themselves as well as the synchronization and concurrency-related constructs (e.g., mutexes and condition variables).
  * ***N.B.*** The complete POSIX standard is specified by [IEEE P1003.1](https://standards.ieee.org/project/1003_1.html) and [ISO/IEC/IEEE 9945](https://www.iso.org/standard/50516.html).

## 2. PThread Creation

First, let's examine the **PThread** thread abstraction and the thread-creation mechanism that corresponds to the mechanisms proposed by Birrell, as follows:

| Birrell's Mechanisms | PThreads |
| :-- | :-- |
| `Thread` | `pthread_t aThread`, a type of thread |
| `Fork(proc, args)` for thread creation | `int pthread_create(`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`pthread_t *thread,`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`const pthread_attr_t *attr,`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`void *(*start_routine)(void *),`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`void *arg`<br/>`)` |
| `Join(thread)` | `int pthread_join(`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`pthread_t thread,`<br/>&nbsp;&nbsp;&nbsp;&nbsp;`void **status`<br/>`)` |

The data type `pthread_t` represents a **thread**, which uniquely identifies the thread with an identifier and describes the thread (i.e., a PThread thread), e.g., id, execution state, other relevant information, etc.
  * Most of this information is not used by the developer, but rather by the PThread library itself.

The function `pthread_create()` is used for **thread creation**
  * the parameters `start_routine` (a function pointer) and `arg` correspond to `proc` and `args` (respectively) in Birrell's model
  * the function creates a new data structure of type `pthread_t` (passed in as the first argument), populating it with the corresponding information required for the thread to begin execution
  * the parameter `attr` (of type `pthread_attr_t`) is a data structure that can be used to specify certain things about the thread that can be subsequently used by the PThread library to manage the thread instance
  * the function also returns status information regarding whether creation of the thread was a success or failure

The function `pthread_join()` has two parameters, `thread` (the thread instance to be joined) and `status` (which captures all relevant return information as well as the results returned from the thread). This function also returns a status indicating whether the join operation was a success or failure.

As is evident, these PThread operations are fairly analogous to the corresponding operations proposed by Birrell.

### PThread Attributes

Within the function `pthread_create()`, the type `pthread_attr_t` (via corresponding parameter `attr`), denoting **PThread attributes**, defines the features of the newly created thread, e.g.,:
  * stack size
  * scheduling policy
  * priority
  * scope (e.g., system vs. process scope)
  * inheritance of attributes from the calling thread (e.g., whether or not it is joinable)

Passing `NULL` to `pthread_create()`'s for parameter `attr` yields the ***default behavior***. 

Several functions support PThread attributes, e.g.,:
  * `int pthread_attr_init(pthread_attr_t *attr)` to create and initialize the attributes data structure
  * `int pthread_attr_destroy(pthread_attr_t *attr)` to destroy and free (i.e., from memory) the attributes data structure
  * various `int pthread_attr_{set/get}([const] pthread_attr_t *attr, ...)` functions allow to set or read a given value from the attributes data structure
    * one of these requiring particular attention is the attribute regarding ***joinability***; to understand this, however, first some additional mechanisms not originally considered by Birrell must be described (see the next subsection)

### Detaching PThreads

A key mechanism not originally described by Birrell is  **detachable threads**.

<center>
<img src="./assets/P02L03-001.png" width="300">
</center>

In PThreads, the the default behavior of thread creation is just as Birrell described, i.e., the threads are ***joinable***. With joinable threads, the parent thread creates children threads, which can then be subsequently joined at a later time. Furthermore, the parent thread should *not* terminate until *all* children threads have completed their respective operations have been subsequently joined back to the parent thread.

<center>
<img src="./assets/P02L03-002.png" width="350">
</center>

However, if the parent thread terminates prematurely, then consequently the children threads may become **zombies** (those children which have completed their respective operations, but have not been joined back, or "*reaped*," to the parent yet).

<center>
<img src="./assets/P02L03-003.png" width="300">
</center>

Therefore, with PThreads there is the additional ability to **detach** the children threads from the parent thread. Once detached, the children threads cannot be subsequently joined back to the parent thread; if the parent terminates/exits, the children can subsequently proceed with execution as normal, thereby making the parent and children threads equivalent to each other (with the exception that the parent thread has some additional information on the children threads it has created).

The PThread library provides the function `int pthread_detach(pthread_t thread)` for this purpose.

Furthermore, PThread threads can also be created as detached children threads as follows via `attr`:
```c
pthread_attr_setdetachstate(attr, PTHREAD_CREATE_DETACHED);

// ...

pthread_create(..., attr, ...);
```

With detached threads, since the parent thread is not required to wait to join all children prior to termination/exit, it can simply exit via `void pthread_exit()`.

### Example

The following is an example of using PThread attributes:

`pthread-creation.c`
```c
#include <stdio.h>
#include <pthread.h>

/* thread main */
void *foo (void *arg) {
  printf("Foobar!\n");
  pthread_exit(NULL);
}

int main (void) {
  int i;
  pthread_t tid;

  pthread_attr_t attr;
  pthread_attr_init(&attr); // required!!!
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  pthread_attr_setscope(&attr, PTHREAD_SCOPE_SYSTEM);
  pthread_create(&tid, &attr, foo, NULL);

  return 0;
}
```

`attr` is first created and initialized via `pthread_attr_init()`, which creates the attributes data structure with sufficient memory, and then is subsequently set with corresponding attributes (i.e., overriding the defaults) via `pthread_attr_setdetachstate()` and `pthread_attr_setscope()`.

The resulting data structure `attr` is then passed to `pthread_create()`, which runs the procedure `foo()` via the resulting child thread.

## 3. Compiling PThreads
