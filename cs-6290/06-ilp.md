# Instruction-Level Parallelism (ILP)

## 1. Lesson Introduction

Recall that branch prediction (cf. Lesson 4) and if conversion (cf. Lesson 5) help to eliminate most of the pipeline issues caused by control hazards. But **data dependencies** can also prevent the finishing of one instruction in every single cycle; so, then, what can be done about data dependencies? And why stop at only *one* instruction per cycle, for that matter?

In this lesson, we will learn about **instruction-level parallelism (ILP)**, which indicates how many instructions could be *possibly* executed.

## 2. *All* Instructions in the *Same* Cycle

