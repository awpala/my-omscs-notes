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

Passing `NULL` to `pthread_create()`'s parameter `attr` yields the ***default behavior***. 

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
void *foo(void *arg) {
  printf("Foobar!\n");
  pthread_exit(NULL);
}

int main(void) {
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

Before examining some examples, there are a few things to consider when compiling PThread threads:
  1. `#include <pthread.h>` in the main file is required
  2. Compile the source with flags `-lpthread` or `-pthread` (preferred on certain platforms) to instruct the compiler to link the PThreads library and to configure the compilation for threads, e.g.,:
  ```
  $ gcc -o main main.c -lpthread
  $ gcc -o main main.c -pthread
  ```
  3. Check the return values of common functions (e.g., creating threads, creating variables, initializing certain data structures, etc.), which is a good programming practice in general, as well as in particular when dealing with multithreaded programs

## 4. PThread Creation Example 1

The following is a simple example of creating threads with the PThreads library:

`pthread-creation-quiz-1.c`
```c
#include <stdio.h>
#include <pthread.h>
#define NUM_THREADS 4

/* thread main */
void *hello (void *arg) {
  printf("Hello Thread\n");
  return 0;
}

int main (void) {
  int i;
  pthread_t tid[NUM_THREADS];

  /* create/fork threads */
  for (i = 0; i < NUM_THREADS; i++) {
    pthread_create(&tid[i], NULL, hello, NULL);
  }

  /* wait/join threads */
  for (i = 0; i < NUM_THREADS; i++) {
    pthread_join(tid[i], NULL);
  }

  return 0;
}
```

The `main()` function initially creates `4` threads, each of which executes the function `hello()`; the last argument `NULL` in `pthread_create()` indicates that no arguments are passed (i.e., to the function `hello()`). Furthermore, the second argument `NULL` in `pthread_create()` indicates that the default attributes will be used when creating the threads (e.g., in particular, the threads will be ***joinable***, as per default).

Subsequently, `pthread_join()` is called to join the child threads to commence subsequent execution of the parent thread.

## 5. PThread Creation Quiz 1 and Answers

What is the output of the program in the previous section? Assume that all programs fully execute and exit.

```
Hello Thread
Hello Thread
Hello Thread
Hello Thread
```

## 6. PThread Creation Example 2

The following is another example of creating threads with the PThreads library, with some slight variations:

`pthread-creation-quiz-2.c`
```c
#include <stdio.h>
#include <pthread.h>
#define NUM_THREADS 4

/* thread main */
void *threadFunc(void *pArg) { 
  int *p = (int*)pArg;
  int myNum = *p;
  printf("Thread number %d\n", myNum);
  return 0;
}

int main(void) {
  int i;
  pthread_t tid[NUM_THREADS];

  /* create/fork threads */
  for(i = 0; i < NUM_THREADS; i++) {
    pthread_create(&tid[i], NULL, threadFunc, &i);
  }

  /* wait/join threads */
  for(i = 0; i < NUM_THREADS; i++) {
    pthread_join(tid[i], NULL);
  }

  return 0;
}
```

This example is a variation on the previous one. Here, the threads execute the function `threadFunc()`, which additionally receives the argument `&i` via call to `pthread_create()`. 

Inside of `threadFunc()`, the variables `p` and `myNum` are private with respect to each given thread (i.e., their scope is limited to that particular thread), which in general will be set to different values.

## 7. PThread Creation Quiz 2 and Answers

What is the output of the program in the previous section? Assume that all programs fully execute and exit. (Select all that apply.)
  * Output A
    ```
    Thread number 0
    Thread number 1
    Thread number 2
    Thread number 3
    ```
  * Output B
    ```
    Thread number 0
    Thread number 2
    Thread number 1
    Thread number 3
    ```
  * Output C
    ```
    Thread number 0
    Thread number 2
    Thread number 2
    Thread number 3
    ```

*All* of these options are possible. Both Outputs A and B are permutations of each other; the thread creation order is non-deterministic due to the actual scheduling order of the threads. Furthermore, Output C is also possible, however; this will be discussed in the next section.

## 8. PThread Creation Example 3

The following is another example of creating threads with the PThreads library, with some slight variations:

```c
#include <stdio.h>
#include <pthread.h>
#define NUM_THREADS 4

/* thread main */
void *threadFunc(void *pArg) {
  int *p = (int*)pArg;
  int myNum = *p;
  printf("Thread number %d\n", myNum);
  return 0;
}

int main(void) {
  int i;
  int tid[NUM_THREADS];

  /* create/fork threads */
  for(i = 0; i < NUM_THREADS; i++) {
    pthread_create(&tid[i], NULL, threadFunc, &tNum[i]);
  }

  for(i = 0; i < NUM_THREADS; i++) { /* wait/join threads */
    pthread_join(tid[i], NULL);
  }

  return 0;
}
```

This example is another variation on the previous ones. As a follow-up to the previous section/quiz (cf. Output C), the issue encountered there is that `i` is defined in `main()`, and is therefore a ***globally visible*** variable; therefore, when its value changes in one thread, all other threads see the new value as well. Therefore, the statement `int *p = (int*)pArg;` inside of function `threadFunc()` may be referencing corresponding value `&i` from the `for` loop of `main()` *after* it has already changed (but *before* `p` has been assigned in the new child thread).

Such a scenario is called a **data race** or **race condition**, i.e., whereby a thread attempts to read a value while another thread modifies it.

Therefore, to correct this issue, the code can be modified as follows:

`pthread-creation-quiz-3.c`
```c
#include <stdio.h>
#include <pthread.h>
#define NUM_THREADS 4

/* thread main */
void *threadFunc(void *pArg) {
  int myNum = *((int*)pArg);
  printf("Thread number %d\n", myNum);
  return 0;
}

int main(void) {
  int i;
  pthread_t tid[NUM_THREADS]; 
  int tNum[NUM_THREADS];// store data in an array `tNum`

  /* create/fork threads */
  for(i = 0; i < NUM_THREADS; i++) {
    tNum[i] = i; // use array `tNum` as local/"private" storage for each thread
    pthread_create(&tid[i], NULL, threadFunc, &tNum[i]);
  }

  for(i = 0; i < NUM_THREADS; i++) { /* wait/join threads */
    pthread_join(tid[i], NULL);
  }

  return 0;
}
```

With this approach, there is no execution-order dependency among the threads, because the data is stored in array `tNum` and is specific to each thread.

## 9. PThread Creation Quiz 3 and Answers

What is the output of the program in the previous section? Assume that all programs fully execute and exit. (Select all that apply.)
  * Output A
    ```
    Thread number 0
    Thread number 0
    Thread number 2
    Thread number 3
    ```
  * Output B
    ```
    Thread number 0
    Thread number 2
    Thread number 1
    Thread number 3
    ```
  * Output C
    ```
    Thread number 3
    Thread number 2
    Thread number 1
    Thread number 0
    ```

The correct choices are Outputs B and C. With the race condition fixed, Output A (or similar) is no longer possible. However, as before, the execution order is still non-deterministic (i.e., it depends on how scheduler actually processes the threads at run-time), therefore, Outputs B and C (among other permutations) are the expected outputs.

## 10. PThread Mutexes

