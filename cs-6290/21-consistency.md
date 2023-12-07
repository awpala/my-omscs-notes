# Consistency

## 1. Lesson Introduction

This lesson will discuss **memory consistency**, which determines how strictly to order among accesses to different memory locations. This is necessary in order to achieve expected behavior from synchronization-based accesses in a shared-memory program.

## 2. Memory Consistency

<center>
<img src="./assets/21-001.png" width="650">
</center>

Consider **memory consistency**, and how it differs from cache coherence (cf. Lesson 19).

Recall (cf. Lesson 19) that **coherence** defines the order of accesses (i.e., as observed by different threads) to the ***same*** address.
  * Coherence is needed in order to share this data accordingly; otherwise, a thread is able to modify the memory location without regard for the other threads.
  * Furthermore, an ***important consideration*** regarding coherence is that while it defines ordering with respect to the ***same*** address, it does ***not*** otherwise specify behavior pertaining to accesses to ***different*** memory location/address.

Therefore, **memory consistency** addresses this latter consideration, i.e., defining the order of accesses to ***different*** addresses.

However, this begs the question: Is order of accesses even significant with respect to *different* addresses in the first place? After all, if a given write is broadcasted to the other threads (i.e., via coherence), and this is performed for every address, then is memory consistency *still* necessary?

These questions are explored further in the remainder of this lesson accordingly.

## 3. Consistency Matters

As it turns out, consistency ***is*** indeed important.

<center>
<img src="./assets/21-002.png" width="650">
</center>

To understand this, consider two cores performing tasks in ***program order*** (as in the figure shown above), as per the following sequence (where memory locations `D` and `F` are both initialized to `0`):

| Sequence | Core `1` | Core `2` |
|:--:|:--:|:--:|
| `S1` | `SW 1 → D` | `LW F → R1` |
| `S2` | `SW 1 → F` | `LW D → R2` |

***N.B.*** Recall (cf. Lesson 9) that an out-of-order (uni-)processor in general can reorder load and store instructions. In fact, this is also mostly permissible in a multi-core processor as well (however, for simplicity, reordering of one core's instructions will be done here for sake of demonstration, and otherwise without a loss of generality).

Now, consider that in ***execution order***, core `2` can reorder its load operations, as follows:

| Sequence | Core `1` | Core `2` |
|:--:|:--:|:--:|
| `S1′` | `SW 1 → D` | `LW D → R2` |
| `S2′` | `SW 1 → F` | `LW F → R1` |

Consequently to this reordering, consider the possible resulting values upon execution of these instructions in this manner.

In ***program order***, the load instructions in core `2` may occur before the store instructions in core `1`. In this case, the resulting values will be `R1 == 0` and `R2 == 0`.

Similarly, in ***execution order***, the load instructions in core `2` may occur before the store instructions in core `1`. In this case, the resulting values will be `R1 == 0` and `R2 == 0`.

Now consider these and other scenarios as follows (where prime [`′`] distinguishes execution order from non-prime program order):

| Scenario | `R1` | `R2` | `R1′` | `R2′` |
|:--:|:--:|:--:|:--:|:--:|
| Core `2` performs loads before Core `1` performs stores | `0` | `0` | `0` | `0` |
| Core `1` performs stores before Core `1` performs loads | `1` | `1` | `1` | `1` |
| Core `2` performs loads in between Core `1`'s stores | `0` | `1` | `0` | `1` |

Consider now: Is it possible to perform these instructions in such a way to yield `R1 == 1` and `R2 == 0`?

In ***program order***, this outcome is ***not*** possible. This would require the loads in core `2` to occur after the second store in core `1`, however, this would necessarily require both loads to occur at this point, resulting in `R1 == 1` and `R2 == 1`.


<center>
<img src="./assets/21-003.png" width="650">
</center>

Conversely, in ***execution order***, this scenario ***can*** occur, if the loads in Core `2` "flank" the stores in Core `1` (as in the figure shown above), giving rise to an "anomalous" execution relative to (expected) program order. Furthermore, note that this does ***not*** violate coherence at all.

However, this is a rather obscure edge case; do we ***really*** care about this ordering "problem"?

## 4. Consistency Matters Quiz and Answers

<center>
<img src="./assets/21-005A.png" width="650">
</center>

Consider a two-core processor with a coherent memory and out-of-order processing. Furthermore, its constituent operations are characterized as follows:
  * Branches can be predicted correctly (i.e., verified taken vs. not taken on subsequent *actual* execution)
  * Stores are performed ***strictly*** in program order (i.e., no reordering of these operations is performed)
  * Loads can be ***reordered***

Furthermore, the cores simultaneously perform the following programs:

(Core `1`)
```c
while (!flag)
  wait();
print(data);
```

(Core `2`)
```c
data = 10;
data = data + 5;
flag = 1;
```

***N.B.*** For this system, initial values are `flag = 0` and `data = 0` (i.e., immediately prior to access/modification by the cores).

Given this system and corresponding programs, what is/are the subsequent value(s) that can be printed by core `1`? (Select all that apply.)
  * `0`
    * `APPLIES`
  * `5`
    * `DOES NOT APPLY`
  * `10`
    * `APPLIES`
  * `15`
    * `APPLIES`
  * Other
    * `DOES NOT APPLY`

***Explanation***:

From the programmer's perspective, the expected behavior is such that while core `1` waits, core `2` performs the associated data operations, and then finally core `1` prints the net result. From this perspective, the expected output would therefore be `15`; per execution order, this is also indeed ***a*** possible execution path as well (e.g., if core `2` happens to execute its instructions prior to core `1` concluding its check of `flag`, for example).

However, given the out-of-order execution capability of this system, other possible outputs can also result.

Note that in the following section of core `1`'s program:

```c
while (!flag)
  wait();
```

core `1` is waiting while `flag` has value `0`. Furthermore, during this time, core `1` is testing for `0` and branching based on this test; the processor in turn can easily predict this branching in such a manner whereby a "premature exit" of the `while` condition ***can*** occur, prior to actually checking the value of `flag`.

Consequently, if such a "premature exit" occurs, then `data` may have the following values, depending on the particular circumstances of the run-time execution:
  * `data` is read before core `2` commences execution, and consequently core `1` reads the value `0`. Furthermore, due to out-of-order processing, the updated value of `flag` set to `1` by core `2` is subsequently detected by core `1` (i.e., subsequently to exiting the `while` loop), thereby validating a "correct prediction" in core `1` accordingly.
  * Generalizing this, a similar occurrence results if the "premature exit" in core `1` occurs subsequently to execution of statement `data = 10;` by core `2`, resulting in a "detected" value of `10` by core `1` at point of exit from the `while` loop (i.e., due to out-of-order accessing).
  * Similarly, `data` can be detected by core `1` immediately following execution of statement `data = data + 5;` by core `2`, however, in this particular case, this simply yields the aforementioned "expected"/"in-program-order" result `15`.

***N.B.*** Results `5` or "something else" cannot occur in this system, because the writes on core `2` (i.e., stores) will occur ***strictly*** in program order (e.g., `data = data + 5;` will not execute with value `0` for `data` on the right-hand side, as program ordering will enforce execution of statement `data = 10;` prior to this).

Observe that despite using the `flag` to manage accesses, this mechanism was otherwise still "subverted" by out-of-order processing (and furthermore coherence did not manage to prevent this, either). Therefore, consistency ***is*** indeed required to resolve this issue, as discussed next.

## 5. Why Do We Need Consistency?

