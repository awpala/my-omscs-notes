# P1L1: Introduction to Compilers

## 1. Introduction to Course

This course will study **compilers**, which translate from a program written in a high-level source language into a lower-level assembly language.
  * ***N.B.*** This course will ***not*** study a particular high-level-language-to-machine-code translation, but rather the course will focus on the theories and algorithms which can be applied to any language and/or machine.

The course is divided into three sections (corresponding to the constituent ***phases*** of the compilation process), as follows:
  * **front-end** → syntactic and semantic analysis of the source language
  * **middle-end** → the intermediate representation, and the corresponding analysis and optimizations associated with the source-code translation
  * **back-end** (or **code generator**) → generator of the resulting machine code

## 2. Introduction to Compilers

This lesson will examine the overall working of the compiler in terms of its various aforementioned phases (cf. Section 1), and their corresponding interactions. In particular, this section will highlight the following ***concepts***:
  * **tokenization**
  * **parsing**
  * **symbol tables**
  * **semantic analysis**

These concepts will be demonstrated in the context of a simple language and its corresponding processing, based on the language's grammar and its lexical specification.

## 3. What Is a Compiler?

This section explores the central question of the course: What is a compiler?

<center>
<img src="./assets/01-P1L1-001.png" width="650">
</center>

A compiler should be intuitively familiar from previous exposure (e.g., software development, coursework, etc.). However, most likely, this was previously encountered in the context of *developing* software as a *user* of the compiler, but not necessarily with respect to the *internals* of the compiler itself.

As a more formal definition, a **compiler** is a program that ***translates*** a program from a **source language** (written in a high-level language) to a **target language**.
  * Typically, the source language is a higher-level language (e.g., C, C++, Java, Fortran, etc.), whereas the lower-level language is the machine code, which is executed in its binary form directly on the processor itself.

<center>
<img src="./assets/01-P1L1-002.png" width="650">
</center>

A **compiler** takes a **source-file-based program** (which is oftentimes itself spread across *multiple* such source files) and compiles it into an **executable** (as in the figure shown above). The executable is typically a **binary file**, which executes directly on the **processor** (at very fast speed).

<center>
<img src="./assets/01-P1L1-003.png" width="650">
</center>

Additionally, there is another piece of software which is often confused with a compiler: An **interpreter** (as in the figure shown above). An interpreter works in a similar manner, starting with input of a high-level-language **source file(s)**. However, rather than directly translating the instructions into an executable, instead, the interpreter ***interprets*** the source program line-by-line, and then generating the corresponding output (e.g., to the terminal, or equivalent).
  * Observe that in this scheme, there is ***no*** corresponding executable generated, but rather the source file is "directly" interpreted in this manner.
  * There are many such interpreted languages (e.g., Python).

With respect to compilers vs. interpreters, the respective use cases are distinct. In particular, the execution of a compiled program is substantially faster than that of an interpreted program, precisely due to the ***direct*** execution of the executable on the hardware in the case of the former.

In this particular course, the focus will be on compilers.
  * ***N.B.*** Compilers and interpreters share many phases and features, however, this is beyond the scope of this course.

# 4. Why Compilers?
