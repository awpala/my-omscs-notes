# Algorithmic Time: Energy and Power

## 1. Introduction

At the Massachusetts Institute of Technology (MIT) in the early 1980s, Danny Hillis attempted to build a new supercomputer, called a **connection machine**, characterized by lights blinking according to where communication was occurring within the system.

Hillis' consequent PhD dissertation on this work subsequently won the doctoral dissertation award from the Association of Computing Machinery (ACM) in 1985, one of the highest honors in the field of computer science.

This award was conferred despite the dismal title of its concluding chapter:

> Chapter 7: New Computer Architectures and Their Relationship to Physics or, Why Computer Science is ***No Good***

Hillis was critiquing parallel algorithms research at the time. Hillis argued that, ultimately, an algorithm ust run on a ***physical machine***, subject to the constraints of the laws of physics. In this vein, Hillis contended that algorithms researchers were "overly generously" abstracting away too many such (arguably non-trivial) details regarding the ***physical costs*** of computation.
  * In particular, Hillis was concerned with the speed of light, which fundamentally limits how fast information can travel.

Whether such physical costs ***can*** indeed be "reasonably ignored" is still an open question. However, there is nevertheless merit to Hillis' assertion that, at a minimum, such physical costs are at least "relevant considerations."

This lesson will begin from this line of thinking, and to pose the following question accordingly:

> What would it mean to consider the ***physical costs*** in designing in designing an algorithm?

## 2. Speed Trends Quiz and Answers
