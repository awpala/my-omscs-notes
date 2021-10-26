# P3L4: Synchronization Constructs

## 1. Preview

Up to this point in the course, **synchronization** has been mentioned multiple times while discussing other operating systems concepts. This lecture will now focus primarily on synchronization itself.

This lecture will discuss several **synchronization constructs**, as well as the **benefits** of using these constructs.

Furthermore, this lecture will discuss the **hardware-level support** that is necessary to implement these synchronization primitives.

In covering these concepts, this lecture will reference the paper "*The Performance of Spin Lock Alternatives for Shared-Memory Multiprocessors*" (1990) by Thomas E. Anderson, involving the efficient implementation of spinlock (synchronization) alternatives. This paper will give a deeper understanding of how synchronization constructs are implemented on top of the underlying hardware and why they exhibit certain performance strengths.

## 2. Visual Metaphor

