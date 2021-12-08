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

## 5. I/O Device Features

<center>
<img src="./assets/P03L05-003.png" width="450">
</center>

As the figure shown above suggests, the devices space is extremely diverse, with variability in shape, size, hardware architecture, functionality provided (e.g., interfaces that applications use to interact with them), etc. Therefore, in order to simplify the discussion in this lecture, focus will be placed on key **features** of a device that enable the integration of the device into a system.

### **Basic I/O Device Features**

<center>
<img src="./assets/P03L05-004.png" width="400">
</center>

(***Figure Reference***: Arpaci-Dusseau, R.H. and Arpaci-Dusseau, A.C. *Operating Systems: Three Easy Pieces* (Chapter 36).)

<center>
<img src="./assets/P03L05-005.png" width="550">
</center>

Any device can be abstracted to have the set of **features** as in the figure shown above.
  * **Control registers**, which can be accessed by the CPU and that permit the CPU-device interactions. These are typically divided into:
    * **Command registers** - used by the CPU to control what exactly the device will do
    * **Data registers** - used by the CPU to control the data transfers in and out of the device
    * **Status registers** - used by the CPU to determine the current status of the device
  * Internally, the device incorporates all other device-specific logic in its **internals**.
    * **Microcontroller** - The device's own CPU, which controls all of the operations that actually occur on the device (which in turn may be influenced by the external/system CPU).
    * On-device **memory**
    * Other processing **logic** (e.g., special chips and/or hardware needed by the device itself, such as analog-to-digital converters, the network medium [fiber optics, copper wire, etc.], etc.)

## 6. CPU-Device Interconnect

Devices ***interface*** with the rest of the system via a **controller**, which is typically integrated as part of the device packaging. The controller is used to connect the device with the rest of the CPU complex via some **CPU-device interconnect** (i.e., some off-chip interconnect supported by the CPU which allows other devices to connect).

<center>
<img src="./assets/P03L05-006.png" width="650">
</center>

The figure shown above depicts a number of different devices that are interconnected to the CPU complex via **PCI (peripheral component interconnect) bus**, one of the standard methods for connecting devices to the CPU.
  * ***N.B.*** Modern platforms typically support **PCIe (PCI express)**, which is technologically more advanced (e.g., more bandwidth, faster, lower access latency, supports more devices, etc.) than its PCI-X (PCI extended) and PCI predecessors. For compatibility reasons, even modern platforms include some of these older technologies (typically PCI-X, which in turn is also compatible with PCI).

However, the PCI bus is not the only interconnect that is typically present. Other buses include:
  * **SCSI bus** (pronounced "scuzzy"), which connects SCSI disks
  * **Peripheral bus**, which connects certain devices (e.g., keyboards)
  * And others

The **controllers** that are part of the device hardware determine the type of interconnect that a given device can directly attach to. Furthermore, there are **bridging controllers** that can handle any differences between different types of interconnects. 

## 7. Device Drivers

TODO

<center>
<img src="./assets/P03L05-007.png" width="750">
</center>

## 8. Types of Devices

TODO

<center>
<img src="./assets/P03L05-008.png" width="750">
</center>

<center>
<img src="./assets/P03L05-009.png" width="750">
</center>

## 9. I/O Devices as Files Quiz and Answers

As indicated in the previous section, Linux represents devices as special files, and the operations on those files have some meaning that is device-specific. The following Linux commands all perform the same **operation** on an **I/O device** (represented as a **file**):
```sh
$ cp file > /dev/lp0
$ cat file > /dev/lp0
$ echo "Hello, world" > /dev/lp0
```

What **operation** do these commands perform?
  * Print something to the `lp0` printer device, where "`lp`" denotes the "line printer" and "`0`" denotes the first line printer (via `0`-index) that is identified by the Linux operating system.

## 10. Pseudo Devices Quiz and Answers

Examining further the notion of "special device" files, Linux also supports **pseudo** (or **virtual**) **devices**. These devices do not represent an *actual* hardware device and are not critical in gaining a basic understanding of file management, however, they are useful to introduce here nevertheless.

Given the following functions, name the **pseudo device** that provides the corresponding functionality.
  * Accept and discard all output (i.e., produces no output)
    * `/dev/null`
  * Produces a variable-length string of pseudo-random numbers
    * `/dev/random`
      * ***N.B.*** There is also an analogous `/dev/urandom`, which similarly allows to create files that contain pseudo-random bytes.

***References***:
  * [/dev/null](https://en.wikipedia.org/wiki/Null_device) (the Null device)
  * [/dev/random](https://en.wikipedia.org/?title=/dev/random)

## 11. Looking at `/dev` Quiz and Answers

As an exploratory quiz, run the command `ls -la /dev` in a Linux environment. What are some of the resulting **device names** observed? Indicate at least five such device names.
  * hard drive devices: `hda`, `sda`
  * terminal stations: `tty`
  * other devices: `null`, `zero`, `ppp`, `lp`, `mem`, `console`, `autoconf`
  * etc.

***Reference***: Ubuntu VM setup [instructions](https://www.udacity.com/wiki/ud923/resources/software/vm-setup)

## 12. CPU-Device Interactions

TODO

<center>
<img src="./assets/P03L05-010.png" width="800">
</center>

<center>
<img src="./assets/P03L05-011.png" width="800">
</center>

## 13. Device Access PIO

TODO

<center>
<img src="./assets/P03L05-012.png" width="650">
</center>

<center>
<img src="./assets/P03L05-013.png" width="650">
</center>

## 14. Device Access DMA

TODO

<center>
<img src="./assets/P03L05-014.png" width="650">
</center>

<center>
<img src="./assets/P03L05-015.png" width="650">
</center>

<center>
<img src="./assets/P03L05-016.png" width="650">
</center>

## 15. DMA vs. PIO Quiz and Answers

For a hypothetical system, assume the following:
  * It costs `1` cycle to run a **`store` instruction** to a **device register**
  * It costs `5` cycles to configure a **DMA controller**
  * The PCI bus is `8` bytes wide
  * All devices in the system support *both* **DMA** and **PIO** access

With these assumptions in mind, which **device access method** is best for the following devices? (Indicate `PIO`, `DMA`, or `Depends`.)
  * Keyboard
    * `PIO` - It is unlikely for the keyboard to transfer very much data per keystroke, therefore a PIO approach is better, since configuring the DMA may be more complex than to simply perform one or two additional `store` instructions.
  * Network Interface Card (NIC)
    * `Depends` - If sending out small packets that require less than `5` `store` instructions to the device data registers (given tha the difference between the `store` instruction and DMA controller is `1` vs. `5`, respectively), then it is better to perform `PIO`. Otherwise, if necessary to perform larger data transfers, then the `DMA` option may be better, since it is only necessary to configure the DMA controller and then issue the request.

***N.B.*** The answer depends heavily on the size of the data transfers.

## 16. Typical Device Access

TODO

<center>
<img src="./assets/P03L05-017.png" width="650">
</center>

<center>
<img src="./assets/P03L05-018.png" width="650">
</center>

## 17. OS Bypass

TODO

<center>
<img src="./assets/P03L05-019.png" width="650">
</center>

<center>
<img src="./assets/P03L05-020.png" width="650">
</center>

## 18. Sync vs. Async Access

TODO

<center>
<img src="./assets/P03L05-021.png" width="650">
</center>

## 19. Block Device Stack

TODO

<center>
<img src="./assets/P03L05-022.png" width="650">
</center>

## 20. Block Device Quiz and Answers

As indicated in the previous section, system software can access devices directly. In Linux, the command `ioctl()` (I/O control) is used to directly access and manipulate a device via the device's control registers.

<center>
<img src="./assets/P03L05-023.png" width="350">
</center>

In the code snippet shown above, complete the call to `ioctl()` to determine the **size** of a **block device**.
  * `BLKGETSIZE` - This argument is specified in the Linux header file `fs.h`. When `ioctl()` is executed, the memory location that is pointed to by the variable `numblocks` is populated with the returned value from `ioctl()`.

***References***:
  * [`ioctl` man page](https://man7.org/linux/man-pages/man2/ioctl.2.html)
  * [`ioctl_list` man page](https://linux.die.net/man/2/ioctl_list)

## 21. Virtual File System

TODO

<center>
<img src="./assets/P03L05-024.png" width="650">
</center>

<center>
<img src="./assets/P03L05-025.png" width="650">
</center>

## 22. Virtual File System Abstractions

TODO

<center>
<img src="./assets/P03L05-026.png" width="650">
</center>

## 23. VFS on Disk

TODO

<center>
<img src="./assets/P03L05-027.png" width="650">
</center>

## 24. ext2 Second Extended Filesystem

TODO

<center>
<img src="./assets/P03L05-028.png" width="650">
</center>

## 25. inodes

TODO

<center>
<img src="./assets/P03L05-029.png" width="650">
</center>

<center>
<img src="./assets/P03L05-030.png" width="650">
</center>

<center>
<img src="./assets/P03L05-031.png" width="650">
</center>

## 26. inodes with Indirect Pointers

TODO

<center>
<img src="./assets/P03L05-032.png" width="650">
</center>

<center>
<img src="./assets/P03L05-033.png" width="650">
</center>

## 27. inode Quiz and Answers

<center>
<img src="./assets/P03L05-034.png" width="350">
</center>

An **inode** has the structure shown above, where each block pointer (both direct and indirect) is `4 bytes` long in size.

If a block on disk is `1 KB`, what is the **maximum** file size that can be supported by this inode structure? (Round to the nearest `GB`.) 
  * `16 GB` - `1` block addresses `256` pointers (i.e., `1 pointer/4 bytes` × `1024 bytes`), therefore the the total file size is (`12` + `256` + `256`<sup>`2`</sup> + `256`<sup>`3`</sup> blocks) × `1 KB/block`.
    * ***N.B.*** Properly rounding up results in `17 GB` or `16 GiB` (where `1 GB` is `10`<sup>`3`</sup> bytes and `1 GiB` is `2`<sup>`10`</sup> bits)

Similarly, what is the **maximum** file size if a block on disk is `8 KB`? (Round to the nearest `TB`.)
  * `64 TB` - `1` block addresses `2048` pointers (i.e., `1 pointer/4 bytes` × `8 * 1024 bytes`), therefore the total file size is (`12` + `2048` + `2048`<sup>`2`</sup> + `2048`<sup>`3`</sup> blocks) × `8 KB/block`.

To determine these results, it is necessary to add up the sizes that can be addressed with each type of different pointer included in the inode data structure. Per the results, by increasing the block size from `1 KB` to `8 KB`, the corresponding use of non-linear data structures achieves a much larger increase in the maximum file size (`16 GB` to `64 TB`, respectively).

***Reference Notes***:
  * Maximum File Size calculations
```
maximum_file_size = number_of_addressable_blocks * block_size
```
where:
```
number_of_addressable_blocks = 12 + blocks_addressable_by_single_indirect + blocks_addressable_by_double_indirect + blocks_addressable_by_triple_indirect
```

## 28. Disk Access Optimizations

TODO

<center>
<img src="./assets/P03L05-035.png" width="650">
</center>

## 29. Lesson Summary

TODO
