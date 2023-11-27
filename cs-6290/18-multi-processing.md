# Multi-Processing

## 1. Lesson Introduction

This lesson will describe what occurs when more than one thread (or process) is executed simultaneously.
  * ***N.B.*** This used to only pertain to supercomputers and to high-end servers, however, practically all modern and future computers are and will be comprised of multiple cores, and possibly multiple threads per core. Therefore, it is accurate to state that *all* processing today is essentially tantamount to ***multi-processing***.

## 2. Flynn's Taxonomy of Parallel Machines

<center>
<img src="./assets/18-001.png" width="650">
</center>

**Flynn's taxonomy of parallel machines** categorizes parallel machines according to how many **instruction streams** and how many **data streams** are used by the machine in question. The corresponding categorizations are as follows:

| Parallel machine classification | Quantity of instruction streams | Quantity of data streams | Comment |
|:--:|:--:|:--:|:--:|
| single instruction, single data (SISD) | `1` | `1` | This is a conventional **uni-processor** (i.e., single-core machine), as described previously in this course |
| single instruction, multiple data (SIMD) | `1` | `>1` | This involves only a single program counter executing the single instruction stream, however, it operates on multiple data streams. A typical example is so called **vector processors**, which executes on simultaneous vector values (rather than single scalar values) in a single program involving correspnding vector operations (e.g., vector addition). Modern processors also have **multimedia extensions** (e.g., SSE, MMX, etc.) which fall under this classification.  |
| multiple instruction, single data (MISD) | `>1` | `1` | This involves several program executing simultaneously, all operating on the *same* data stream. This is a relatively rare configuration, however, a relevant example is a **stream processor** (which performs step-wise/stage-wise processing of the data stream). |
| multiple instruction, multiple data (MIMD) | `>1` | `>1` | This is a bona fide **multi-processor**, whereby each processor has its own independent program counter, etc., with each independently operating on its own data stream. |

Most processors today are classified as multiple instruction, multiple data (MIMD), corresponding to the commonly used **multi-core processors**. Correspondingly, these multi-core processors are the focus of this lesson accordingly.

## 3. Why Multi-Processors?

<center>
<img src="./assets/18-002.png" width="650">
</center>

So, then, why use multi-processors at all, rather than simply using uni-processors?

Firstly, note that modern uni-processors are already approximately 4-wide to 6-wide. By this point, it is advantageous to switch to multi-processors, because beyond this point, there are diminishing returns in making a uni-processor even wider (i.e., executing 6 to 8 instructions per cycle or so will not be as dramatic of a performance improvement as previously increasing from 2 to 4 or so).
  * The diminishing returns are a direct consequence of Amdahl's law (cf. Lesson 2), where there is more improvement in programs which benefit from this increase in width (e.g., those which are inherently parallel) but not otherwise in those which do not (e.g., those which have a lot of dependencies which effectively "serialize" the overall program).

Additionally, another issue with uni-processors is that if they are designed to be faster by increasing the frequency, this requires a corresponding raise in voltage, which in turn increases the power consumption dramatically (proportionally to `f*V^2`, cf. Lesson 1). Beyond a certain level, this increased power consumption will preclude an practical usage of the processor, as it will overheat from this overloaded power consumption.

Nevertheless, despite these drawbacks with uni-processors, Moore's law has persisted into the modern day, with a doubling of transistors every 18 months, for the same cost and area as previously. In order to achieve this continued improvement, the number of cores have been doubled every 18 months accordingly, which allows to have cores which are not individually wider or individually faster, but rather still provide an overall increase in the transistor density (and correspondingly improved computational performance of the processor chip).
  * However, a key **caveat** here is that this assumes that ***all*** of the cores can be used. Conversely, if a program only uses a single thread of a single core, then this doubling is inconsequential. Therefore it is necessary to design programs to exploit this parallelism in order to maximize the potential performance of these multi-core processors.

Put another way, multi-processors exist today not necessarily because a doubling of the cores is inherently "better" than a uni-processor with the equivalent twice-improved per-processor performance, however, as a practical matter, it is no longer feasible to achieve this per-uni-processor improvement as per current physical constraints, and therefore multi-processors have allowed for a more practical alternative route for improvements more recently.

## 4. Multi-Core vs. Single-Core Quiz and Answers
