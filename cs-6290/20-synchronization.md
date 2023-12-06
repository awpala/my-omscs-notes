# Synchronization

## 1. Lesson Introduction

This lesson will examine how to provide efficient **synchronization** among cores and threads that are working on the ***same*** program.

## 2-3. Synchronization Example

### 2. Example

<center>
<img src="./assets/20-001.png" width="650">
</center>

Consider an example (as in the figure shown above) to demonstrate why **synchronization** is necessary.

The system in question is characterized as follows:
  * Two threads count the occurrences of different letters in a document
  * Thread `A` counts the first half of the document
  * Thread `B` counts the second half of the document
  * Lastly, the counting of the threads is combined in the end

The corresponding program code is as follows:

(thread `A`)
```mips
LW  L, 0(R1)    # load a letter into `L`
LW  R, Count[L] # load count for letter `L` into memory
ADD R, R, 1     # increment the count
SW  R, Count[L] # load the new count back into memory
```

(thread `B` - same work as thread `A`)
```mips
LW  L, 0(R1)    # load a letter into `L` -- N.B. `R1` is distinct from that of thread A
LW  R, Count[L] # load count for letter `L` into memory
ADD R, R, 1     # increment the count
SW  R, Count[L] # load the new count back into memory
```

As long as the letters processed are ***different*** between the threads, then this program will work normally.

However, if both threads encounter the ***same*** letter (e.g., `'A'`), then both threads attempt to load the ***same*** counter value (i.e., `Count[L]`, having current value `15`).

On increment (i.e., `ADD R, R, 1`), both threads update the value (i.e., `16`) and store it into memory (i.e., `SW R, Count[L]`). However, since there were ***two*** occurrences of the letter (i.e., `'A'`), this count is incorrect (i.e., `16` rather than `17` is stored in memory).

Therefore, to ensure ***correct*** program behavior, the count-incrementing operations must be performed ***sequentially*** across the two threads when handling the ***same*** data.
  * For example, if thread `A` increments first, then cache coherence ensures that the value `16` is read by thread `B`.
  * Thread `B` then subsequently increments the value to `17`.

***N.B.*** The ordering of these two operations among the threads is not significant (i.e., the equivalent holds if Thread `B` had written first instead).

These thread-coordinated operations are called **atomic (or critical) sections**. Synchronization is therefore necessary to perform such operations accordingly (i.e., additional code which ensures such thread-wise operation accordingly).

### 3. Lock

<center>
<img src="./assets/20-002.png" width="650">
</center>

Continuing from the previous example (cf. Section 2), the type of synchronization used for atomic sections is called **mutual exclusion** (or **lock**). Such a lock is used to "flank" the atomic section in order to coordinate accordingly among the threads.

<center>
<img src="./assets/20-003.png" width="650">
</center>

To perform this locking, an explicit mechanism of `lock` and `unlock` is used (as in the figure shown above).

The lock `CountLock[L]` has a status of open/closed at any given time.
  * When the lock `CountLock[L]` is ***open***, then the atomic section can be entered.
  * Otherwise, when the lock `CountLock[L]` is ***closed***, then **spinning** will occur by the thread, until the lock is once again opened.

On ***acquisition*** of the lock (and consequently closing the lock to other threads), the thread enters the atomic section and performs its operations. On exit of the atomic section, the lock becomes unlocked and subsequently available to another thread.

By having the lock present in this manner, this enforces mutual exclusion of the atomic-section code. However, this does not otherwise impose ***order*** among execution by the respective threads (it simply prevent ***simultaneous*** execution at any given time).

## 4. Lock Variable Quiz and Answers

<center>
<img src="./assets/20-005A.png" width="650">
</center>

Consider the following code fragment denoting an atomic section:

```c
lock(CountLock[L]);
count[L]++;
unlock(CountLock[L]);
```

How is `CountLock[L]` described in this context? (Select the correct option.)
  * Just another location in shared memory
    * `CORRECT`
  * A location in a special synchronization memory
    * `INCORRECT`
  * A special variable without a memory address
    * `INCORRECT`

***Explanation***:

A lock is essentially just another "variable" like any other, having a memory address, which in turn can be loaded, modified, etc.

This lesson will subsequently explore the nature of these lock variables and associated functions `lock()` and `unlock()` accordingly.

## 5-7. Lock Synchronization

### 5. Introduction

<center>
<img src="./assets/20-006.png" width="650">
</center>

To further examine lock-based synchronization, consider the following function definitions:

```cpp
typedef int mutex_type;

void lock_init(mutex_type &lock_var) {
  lock_var = 0;
}

void lock(mutex_type &lock_var) {
  while (lock_var == 1);
  lock_var = 1;
}

void unlock(mutex_type &lock_var) {
  lock_var = 0;
}
```

For simplicity, an integer is used here to represent "*a location in (shared) memory*" (cf. Section 4).

The function `lock_init()` initializes the lock variable `lock_var` to `0` (unlocked).

The function `lock()` "spins" on value `1` (locked) via `while` loop until the `lock_var` is set to `0`. On exit of the `while` loop, `lock()` sets `lock_var` to `1` (i.e., the lock is acquired, for subsequent entry into the critical section).

The function `unlock()` sets the lock `lock_var` to `0` on exit from the critical section, thereby opening/freeing the lock for subsequent use.
  * Coherence ensures that the other thread(s) waiting on `lock_var` within function `lock()` at this point observe this update to value `lock_var` accordingly (i.e., for subsequent lock acquisition)

However, note that the function `lock()` does not work in practice as implemented here.
  * Suppose there are two threads (one purple, one green), which both initially encounter the `while` loop with `lock_var` having value `0` and subsequently *both* acquire the lock via setting of `lock_var` to `1`.
  * Now, *both* threads are simultaneously accessing the critical section.

Therefore, in order to ***correctly*** implement the function `lock()`, both the ***checking*** and ***setting*** of the lock value `lock_var` must be ***atomic operations*** (i.e., performed in its own critical section accordingly).

This gives rise to an apparent ***paradox***: A critical section is needed in order to implement a critical-section-based lock.

### 6. Implementing `lock()`

<center>
<img src="./assets/20-007.png" width="650">
</center>

Per the apparent "paradox" identified in the previous section (cf. Section 6), some sort of "magic locK" modification is necessary, as follows:

```cpp
void lock(mutex_type &lock_var) {
Wait:
  lock_magic();
  if (lock_var == 0) {
    lock_var = 1;
    unlock_magic();
    goto Exit;
  }
  unlock_magic();
  goto Wait;

Exit:
}
```

Of course, there is no such "magic." Instead, the correspondingly available ***resolution measures*** for this issue are as follows:
  * Lamport's **bakery algorithm** (or another comparable algorithm) which is able to use normal load/store instructions in this manner
    * This approach is fairly ***expensive*** and complicated to implement (i.e., tens of instructions), however.
  * Use special ***atomic*** read and write instructions

### 7. Atomic Instruction Quiz and Answer

