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
| single instruction, single data (SISD) | `1` | `1` | This is a conventional **uniprocessor** (i.e., single-core machine), as described previously in this course |
| single instruction, multiple data (SIMD) | `1` | `>1` | This involves only a single program counter executing the single instruction stream, however, it operates on multiple data streams. A typical example is so called **vector processors**, which executes on simultaneous vector values (rather than single scalar values) in a single program involving correspnding vector operations (e.g., vector addition). Modern processors also have **multimedia extensions** (e.g., SSE, MMX, etc.) which fall under this classification.  |
| multiple instruction, single data (MISD) | `>1` | `1` | This involves several program executing simultaneously, all operating on the *same* data stream. This is a relatively rare configuration, however, a relevant example is a **stream processor** (which performs step-wise/stage-wise processing of the data stream). |
| multiple instruction, multiple data (MIMD) | `>1` | `>1` | This is a bona fide **multi-processor**, whereby each processor has its own independent program counter, etc., with each independently operating on its own data stream. |

Most processors today are classified as multiple instruction, multiple data (MIMD), corresponding to the commonly used **multi-core processors**. Correspondingly, these multi-core processors are the focus of this lesson accordingly.

## 3. Why Multi-Processors?
