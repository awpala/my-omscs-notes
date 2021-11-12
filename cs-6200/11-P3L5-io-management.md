# P3L5: I/O Management

## 1. Preview

It was previously indicated that a main role of operating systems is to manage the underlying *hardware*; however, to this point, discussion has focused on CPUs and memory. This lecture focuses on the **mechanisms** that operating systems use to represent and manage **I/O (input/output) devices**.

In particular, this lecture will examine the operating system stack for **block devices**, using **storage** as a representative example. Furthermore, in this context, the lecture will discuss **file systems** and their architecture, since ***files*** are the key operating system abstraction used by processes to interact with storage devices.
  * This lecture will describe the Linux file system architecture as a concrete example of this.

## 2. Visual Metaphor

<center>
<img src="./assets/P03L05-001.png" width="500">
</center>

**I/O management** involves managing the inputs and the outputs of a system. To illustrate some of the tasks involved in I/O management, consider the following analogy: I/O in a computing system is like a shipping department in a toy shop.

| Characteristic | Toy Shop Shipping Department | Operating System I/O Management |
| :---: | :---: | :---: |
| Have protocols | How/what parts come in, and how/what toys go out | Operating systems incorporate **interfaces** for different types of I/O devices; how these interfaces are used in turn determine the protocols used to access those types of I/O devices |
| Have dedicated handlers | Have dedicated staff to enforce shipping protocols | Operating systems have dedicated system components (e.g., **device drivers**, interrupt handlers, etc.) which are responsible for I/O management (i.e., interaction with the devices)  |
| Decouple I/O details from core processing | Abstracts shipping details (e.g., carriers used, shipping methods, etc.) from making toys | By specifying interfaces and by using a device driver model, operating systems abstract the details of the I/O device, hiding them from applications or from upper levels of the system software stack (i.e., other system software components) |

## 3. I/O Devices

<center>
<img src="./assets/P03L05-002.png" width="450">
</center>

The figure shown above is repeated from before (cf. P1L2), demonstrating the components of a computer system. Observe that the execution of applications does not only rely on the CPU and main memory, but also on many other different types of **hardware components**.

Some of these components are specifically tied to providing **inputs** (e.g., keyboard, microphone, and mouse), directing **outputs** (e.g., displays and speakers), or both (e.g., network interface and hard disk); correspondingly, these are referred to as **I/O devices**. The operating system integrates all of these devices into the overall computing system.

## 4. I/O Devices Quiz and Answers

For each of the following devices, indicate whether it is typically used for input (`I`), output (`O`), or both (`B`).
  * keyboard
    * `I`
  * speaker
    * `O`
  * display
    * `O`
  * hard disk drive
    * `B`
  * microphone
    * `I`
  * network interface card (NIC)
    * `B`
  * flash card
    * `B`

***N.B.*** In addition to these types of devices, there are many other types of devices. Furthermore, within each of these types of devices/categories, there are many concrete examples (e.g., different types of microphones, speakers, network interface cards, etc.). Therefore, operating systems must be designed in such a way that they can handle all of these different types of devices efficiently and in a straightforward manner.

## 5. 
