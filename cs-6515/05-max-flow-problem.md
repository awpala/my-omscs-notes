# Max-Flow Problem: Topic Introduction

## Introduction

## Overview

> [!NOTE]
> ***Instructor's Note***: For reference see [DPV] Chapter 7.2 (Flows in Networks) or Eric's [notes](https://cs6505.wordpress.com/schedule/).

# Max-Flow 1: Ford-Fulkerson Algorithm

## 3. Problem Setup

## 4. Problem Formulation

## 5-7. Max-Flow

### 5. Problem

### 6. Goal

### 7. Example Quiz and Answers

## 8. Cycles Are Okay

## 9. Anti-Parallel Edges

## 10-12. Toy Example

### 10. Introduction

### 11. Simple Algorithm

> [!NOTE]
> ***Instructor's Note***: Why is this algorithmic approach guaranteed to produce a valid flow?
>
> First off, some terminology: this $st$-path $P$ is called an **augmenting path** since we augment the current flow along $P$ . By using a path we ensure that the new flow satisfies the conservation of flow constraint, since for every vertex $v$ along the path (except for $s$ and $t$ ), the augmented flow along the edge of $P$ into $v$ equals the augmented flow along the edge of $P$ out of $v$ . Since the augmented flow never exceeds the capacity constraints we satisfy the flow constraints. Hence, this new flow is a valid flow.

### 12. Backward Edges

## 13. Residual Network

## 14-17. Ford-Fulkerson Algorithm

### 14. Pseudocode

### 15. Running Time

### 16. Time per Round

### 17. Discussion

# Max-Flow 2: Min-Cut

## 1. Outline

## 2. Recap: Ford-Fulkerson

## 3. Verifying Max-Flow Quiz and Answers

## 4-13. Min-Cut Problem

### 4. Introduction

### 5. Problem Formulation

### 6. Max-Flow = Min $st$-Cut

### 7. Max-Flow $\le$ Min $st$-Cut

### 8-9. Proof of Claim

#### 8. Introduction

#### 9. Finishing Off

### 10. Reverse Inequality

### 11-13. Proof of Claim

#### 11. Introduction

#### 12. Properties of Cut

#### 13. Completing the Proof

# Max-Flow 3: Image Segmentation

## 1. Image Segmentation

## 2. Formulation

## 3. Parameters

## 4. Example

## 5. Partition

## 6. Min-Cut

## 7-8. Reformulation

### 7. Introduction

### 8. New Weights

## 9-14. New Problem

### 9. Introduction

### 10. Flow Network

### 11. Foreground

### 12. Background

### 13. Cuts

### 14. Solution

# Max-Flow 4: Edmonds-Karp Algorithm

## 1-3. Max-Flow Min-Cut Algorithms

### 1. Introduction

### 2. Ford-Fulkerson Algorithm

### 3. Edmonds-Karp Algorithm

## 4-9. Proof

### 4. Outline

### 5-7. Breadth First Search (BFS)

#### 5. Properties

#### 6. Example

#### 7. Properties - Part 2

### 8. Add/Delete Edges

### 9. Conclusion

## 10-12. Proof of Claim

### 10. Introduction

### 11. Delete/Add Effect

### 12. Finishing Off

# Max-Flow 5: Max-Flow Generalization

## 1. Max-Flow with Demands

## 2. Feasible Flow Example Quiz and Answers

## 3-15. Reduction

### 3. Overview

### 4. Vertices

### 5. Original Edges

### 6. New Edges

### 7. One More Edge

### 8. Saturating Flows

### 9-10. Saturating $\Rightarrow$ Feasible

#### 9. Introduction

#### 10. $f$ Is Valid

### 11-12. Feasible $\Rightarrow$ Saturating

#### 11. Introduction

#### 12. $f'$ Is Valid

### 13. $f'$ Constraints

### 14. Max Feasible Flow

### 15. Reduction Example Quiz and Answers
