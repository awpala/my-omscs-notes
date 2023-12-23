# Basic Model of Locality

## 1. Introduction

<center>
<img src="./assets/01-001.png" width="250">
</center>

Real machines have **memory hierarchies** (as in the figure shown above). This means that in between the **processor** and the primary storage device (e.g., a **disk**), there are ***layers*** of memory in between. As the layer approaches the processor, the layer becomes correspondingly faster but smaller.
  * ***N.B.*** The difference in all of the size, latency, and bandwidth between each successive layer may be an order of magnitude.

Unfortunately, our usual model of an algorithm does ***not*** distinguish between the size and the speed of these different memory layers. Nevertheless, in order to achieve ***high performance***, then it is necessary to correspondingly ***design*** algorithms in such a manner which ***exploits*** this memory hierarchy accordingly.

Sometimes the **hardware** or **operating system** can ***manage*** these memory layers ***automatically***. However, using these memory layers ***optimally*** is nevertheless ***difficult*** to achieve in practice (particularly when using such automated approaches). Therefore, it is necessary to design algorithms appropriately for this purpose; this topic is the starting point of the lesson accordingly.

## 2. A First, Basic Model
