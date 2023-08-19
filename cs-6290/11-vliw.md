# Very Long Instruction Word (VLIW)

## 1. Lesson Introduction

In this lesson, we will learn about **very long instruction word (VLIW)** and explicitly parallel processors (e.g., Intel's Itanium). Unlike their out-of-order counterparts, these processors do ***not*** attempt to identify instruction-level parallelism (ILP) on their own, but rather defer to the compiler instead.

## 2. Superscalar vs. VLIW

<center>
<img src="./assets/11-001.png" width="650">
</center>

In a previous lesson (cf. Lesson 8), we have seen that a **superscalar** is one which executes more than one instruction per cycle. Conversely, **very long instruction word (VLIW)** processors attempt to achieve the same amount of work per cycle, but in an alternate manner. Let us compare and contrast these two approaches as follows (where `N` denotes an `N`-issue processor, i.e., capable of performing `N` instructions per cycle):

| Characteristic | Out-of-order superscalar | In-order superscalar | VLIW |
|:--:|:--:|:--:|:--:|
| Instructions per cycle | Attempts to perform `≤ N` instructions per cycle | Attempts to perform `≤ N` instructions per cycle | Attempts to perform `1` ***large*** instruction per cycle, comprised of the equivalent work to `N` "regular" instructions (i.e., relative to a comparable superscalar processor) | 
| Detecting independent instructions within the program | Finds the `N` constituent instructions by looking ahead by ***much greater than*** `N` instructions in its **instructions window** | Finds the `N` constituent instructions by looking ahead by ***exactly*** `N` instructions in its **instructions window** | Does not perform any comparable "look ahead," but rather simply executes the next-in-order large instruction (i.e., otherwise analogously to a non-superscalar in-order processor) |
| Hardware cost| ***Most expensive***, due to the overhead incurred from "extended look ahead" | ***Moderately expensive***, due to the reduced overhead (i.e., no "extended look ahead") relative to out-of-order superscalar processing correspondingly requiring less hardware implementation accordingly | ***Least expensive*** for the same amount of work per cycle, assuming that the work is available and can be found/detected |
| Compiler assistance | The compiler ***can*** assist with improving performance, however, this is not essential | The compiler ***does*** assist with improving performance by reordering instructions in such a manner whereby independent instructions can be performed optimally (otherwise, performance can degrade substantially relative to an out-of-order superscalar processor) | The compiler is ***strictly necessary*** in order to use VLIW processors, otherwise performance will degenerate precipitously |

Therefore, in summary, moving from columns left-to-right in the table above comprises a tradeoff from high hardware dependency to high software/compiler dependency (respectively), in order to achieve equivalent instruction-level parallelism (ILP).

## 3. Superscalar vs. VLIW Quiz and Answers

<center>
<img src="./assets/11-003A.png" width="650">
</center>

Consider an out-of-order superscalar processor characterized by `32`-bit instructions running a program of size `4000` bytes.

Similarly, consider a VLIW processor characterized by `128`-bit instructions (with each VLIW instruction specifying `4` operations, comparable to each `1`/single operation on the other processor). What is the corresponding program size for this VLIW processor? 

***Answer and Explanation***:

In the ideal case, the VLIW processor can correspondingly perform the same `4000` byte program.

However, in the worst case (e.g., all instructions have dependencies), each equivalent instruction will still require a full VLIW instruction (i.e., only utilizing *one* of its *four* total possible operations per cycle), and therefore this will increase the required program size to `4000 × 4 = 16000` bytes.

Therefore, in practice, the corresponding program size will be somewhere in the range of these two (i.e., `4000` to `16000` bytes).

## 4. VLIW: The Good and the Bad

Consider now the ***good*** vs. ***bad*** aspects of VLIW.

<center>
<img src="./assets/11-004.png" width="650">
</center>

The ***good*** aspects of VLIW are:
  * The compiler performs the hard work
    * Since the compiler only runs *once* whereas the program runs *many times*, the compiler has ample time to determine a suitable schedule. Conversely, in an out-of-order processor, there is comparatively much less time available to determine a suitable schedule, because as the program is executing, any time spent determining the schedule is accumulated as additional overhead to the total program execution time.
  * The required hardware is comparatively simpler to that required to implement an out-of-order processor
  * More energy efficient than a comparable out-of-order processor, since (all else equal) the hardware performs less per executed instruction
  * Works really well on loops and so called **"regular" code** (e.g., array traversal, multiplying matrices, and other such patterns which are readily amenable to compiler analysis for subsequent schedule optimization)

Conversely, the ***bad*** aspects of VLIW are:
  * Latencies of instructions are not always uniform
    * The compiler must assume sort of inherent latency in order to optimally schedule instructions, however, with non-uniform latencies, this becomes more challenging. For example, if planning around a cache hit latency, an incidental ***cache miss*** may introduce a much longer latency than originally anticipated.
  * Many applications are irregular
    * Almost every application which performs a lot of "decision making" (e.g., AI applications, applications working on pointers or pointer-intensive structures, etc.) are difficult for the compiler to effectively analyze.
  * Code bloat
    * Code for a VLIW-based program can become much larger than an equivalent out-of-order processor, due to insertion of many ***no-ops*** required to separate inter-dependent instructions in order to prevent them from being scheduled in the *same* VLIW instruction.

## 5. VLIW Backward Compatibility Quiz and Answers
