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
