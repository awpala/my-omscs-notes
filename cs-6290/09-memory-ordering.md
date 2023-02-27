# Memory Ordering

## 1. Lesson Introduction

We have seen (cf. Lesson 8) that an out-of-order processor will track when one instruction uses a register value produced by another.

However, load and store instructions can access the *same* memory location without using the same register to perform the access; this lesson explores *how* exactly this can be done correctly in an out-of-order processor.

## 2. Memory Access Ordering
