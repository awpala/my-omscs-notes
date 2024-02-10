# Comparison-Based Sorting

## 1. Introduction

This lesson is about parallel algorithms for ***sorting*** in the dynamic multi-threading model, and is comprised of two parts.

<center>
<img src="./assets/06-001.png" width="350">
</center>

The first part of this lesson consists of videos, which cover the idea of a **sorting network**.

<center>
<img src="./assets/06-002.png" width="350">
</center>

A sorting network is a special kind of circuit which performs sorting (as in the figure shown above).
  * ***N.B.*** This topic is not typically covered in a standard undergraduate algorithms course. It is therefore introduced here both for the edification and enjoyment of students in this course.

<center>
<img src="./assets/06-003.png" width="350">
</center>

Separately from the videos component, this lesson also entails a short chapter on **parallel merge sort** from algorithm textbook CLRS (as in the figure shown above), intended to reinforce the main ideas behind the dynamic multi-threading model.

This lesson will also introduce some additional techniques to analyze algorithms in this model more formally.

## 2. Comparator Networks

Initially, parallel algorithms research centered around the idea of **sorting networks**.

### Comparators

<center>
<img src="./assets/06-004.png" width="350">
</center>

A **sorting network** is a fixed circuit which sorts its inputs (as in the figure shown above), using a special type of circuit element/gate called a **comparator**.

In a **comparator**, there are two inputs ($x$ and $y$ ) and two outputs.
  * The "↑" (increasing) or "+" comparator places the smaller of its two inputs on the top output wire (i.e., $\min(x,y)$ ) and the larger of its two inputs on te bottom output wire (i.e., $\max(x,y)$ )
  * Conversely, the "↓" (decreasing) or "-" comparator places the larger of its two inputs on the top wire (i.e., $\max(x,y)$ ) and the smaller of its two inputs on the top output wire (i.e., $\min(x,y)$ )

<center>
<img src="./assets/06-005.png" width="650">
</center>

<center>
<img src="./assets/06-006.png" width="650">
</center>

For example, consider the following examples (as in the figures shown above):

| Comparator type | $x$ | $y$ | Top output | Bottom output |
|:--:|:--:|:--:|:--:|:--:|
| + | 1 | 6 | $\min(x,y) = 1$ | $\max(x,y) = 6$ |
| - | 1 | 6 | $\min(x,y) = 6$ | $\max(x,y) = 1$ |

### Example: Sorting with Comparators

<center>
<img src="./assets/06-007.png" width="650">
</center>

Similarly to an electrical circuit, comparators can be ***composed*** by connecting wires. For example, suppose that the values $3$ , $0$ , and $1$ are given (as in the figure shown above), with the intention of ***sorting*** them.

This can be accomplished using the circuit as in the figure shown above, which takes these three values as inputs, producing three correspondingly sorted outputs.

<center>
<img src="./assets/06-008.png" width="650">
</center>

The first comparison produces the intermediate result as in the figure shown above.

<center>
<img src="./assets/06-009.png" width="650">
</center>

The next comparison produces the intermediate result as in the figure shown above.

<center>
<img src="./assets/06-010.png" width="650">
</center>

The final comparison produces the correspondingly sorted result as in the figure shown above.

<center>
<img src="./assets/06-011.png" width="650">
</center>

Symbolically, the intermediate sorting operations are represented as in the figure shown above, which represents the following overall operation (given inputs $x$ , $y$ and $z$ ):

$$
\max(\min(x,y), \min(\max(x,y), z)) = \rm{median}(x,y,z)
$$

<center>
<img src="./assets/06-012.png" width="650">
</center>

Furthermore, observe that this circuit is comprised of three comparators (as in the figure shown above), with a corresponding depth (or critical-path length) of $3$ (cf. Lesson 5), with dependencies among the comparators denoted by solid red lines in the figure shown above.
  * ***N.B.*** This analysis is reminiscent of work and span (cf. Lesson 5).

Therefore, by encoding an algorithm in a comparators-based circuit in this manner, the resulting circuit can be correspondingly analyzed with respect to how many operations it performs, as well as its critical-path length.

As a follow-up question: Suppose that you are only allowed to use these two types of comparators, then compared to this example circuit, is there a way to sort three elements either by using fewer comparators and/or by reducing the critical-path length?
  * ***N.B.*** This question is left as an exercise for the reader.

## 3. Sort Four Values Quiz and Answers
