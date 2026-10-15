# P3L6: Virtualization

## 1. Preview

TODO

Reference: Rosenblum and Garfinkel "*Virtual Machine Monitors: Current Technologies and Future Trends*" (2005).

## 2. What Is Virtualization?

TODO

<center>
<img src="./assets/P03L06-001.png" width="650">
</center>

## 3. Defining Virtualization

TODO

<center>
<img src="./assets/P03L06-002.png" width="650">
</center>

Reference: Popek and Goldberg "*Formal Requirements for Virtualizable Third Generation Architectures*" (1974)

## 4. Virtualization Technologies Quiz and Answers

Based on the classical definition of **virtualization** by Popek and Goldberg (1974), which of the following can be considered **virtualization technologies**? (Select all that apply.)
  * VirtualBox
    * `APPLIES`
  * Java Virtual Machine (JVM0)
    * `DOES NOT APPLY`
  * Virtual GameBoy
    * `DOES NOT APPLY`

**Explanation**: The ***goals*** of the system or platform virtualization are different than those intended by the Java Virtual Machine (JVM) or a hardware emulator (e.g., Virtual GameBoy). Per the definition given by Popek and Goldberg, a virtual machine is an efficient, isolated duplicate of the real machine. JVM is a language run-time which provides system services and portability for Java applications, which is very different from the underlying physical machine. Simulator, hardware emulators (e.g., Virtual GameBoy) emulate the hardware platform in question (e.g., GameBoy), which similarly is different from the underlying hardware platform on which the emulator runs. Therefore, with system virtualization (e.g., VirtualBox), the physical hardware that is visible to the virtual machine is ***identical*** (or at least very similar) to the underlying physical platform itself which supports the execution of the virtual machine.
  * ***N.B.*** Classical definition of **virtualization** (cf. Popek & Goldberg, 1974): **Virtualization** (or a **virtual machine**) is an efficient, isolated duplicate of the machine.

***Examples References***:
  * [VirtualBox](https://www.virtualbox.org/manual/ch01.html)
  * [Java Virtual Machine (JVM)](http://en.wikipedia.org/wiki/Java_virtual_machine)
  * [Virtual GameBoy](http://fms.komkon.org/VGB/)

## 5. Benefits of Virtualization

TODO

<center>
<img src="./assets/P03L06-003.png" width="650">
</center>

## 6. Benefits of Virtualization Quiz 1 and Answers

If **virtualization** has been around since the 1960s, why has it not been used ubiquitously until relatively recently? (Select all that apply.)
  * Virtualization was not efficient
    * `DOES NOT APPLY`
  * Everyone used Microsoft Windows
    * `DOES NOT APPLY`
  * Mainframes were not ubiquitous
    * `APPLIES`
  * Other hardware was cheap
    * `APPLIES`

**Explanation**: The majority of companies historically did not necessarily run mainframe computers, but rather they ran servers based mostly on the x86 architecture. This arrangement was more affordable, and it was generally much simpler to add new pieces of hardware than to determine how to make multiple applications and multiple operating systems coexist on that *same* hardware platform. Therefore, this trend of simply buying/adding more machines in order to run a different kind of operating system to support different applications continued for several decades, up until recently.

## 7. Benefits of Virtualization Quiz 2 and Answers

If **virtualization** was not widely adopted in the past, then what changed? Why did we start to care more about virtualization? (Select all that apply.)
  * Servers were under-utilized
    * `APPLIES`
  * Datacenters were becoming too large
    * `APPLIES`
  * Companies had to hire more system administrators
    * `APPLIES`
  * Companies were paying high utility bills to run and cool servers
    * `APPLIES`

**Explanation**: In the process of following the approach of buying new hardware whenever there is a need to run a slightly different operating system or to support slightly different applications (cf. Section 6, Quiz 1), datacenters became too large. Simultaneously, some of the server were being severely under-utilized; in fact, on average, the utilization rates in datacenters were at a maximum of around 10-20%. Consequently, companies--now having to manage these large datacenters containing many machines--required the addition of more personnel (e.g., system administrators) to manage this complexity, as well as had to manage increasing operating costs (e.g., ensuring that the machines operated within a certain allowable temperature variability range). Cumulatively, these factors contributed to companies spending nearly 70% of their information technology (IT) budget on operating expenses (i.e., to the detriment of capital expenditures on new hardware, new software services, etc.). Therefore, it became apparent there was an importance/urgency in revisiting (previously "dormant") virtualization technology as a mechanism for consolidating these workloads onto fewer hardware resources that will be easier to manage and more cost-effective to operate.

## 8-9. Virtualization Models

### **8. Introduction**

TODO

<center>
<img src="./assets/P03L06-004.png" width="650">
</center>

### **8. Bare Metal**

TODO

<center>
<img src="./assets/P03L06-005.png" width="650">
</center>

<center>
<img src="./assets/P03L06-006.png" width="650">
</center>

### **9. Hosted**

TODO

<center>
<img src="./assets/P03L06-007.png" width="650">
</center>

<center>
<img src="./assets/P03L06-008.png" width="650">
</center>

## 10. Bare Metal or Hosted Quiz and Answers

Classify the following **virtualization products** as **bare-metal/hypervisor-based** (`HV`) or **host-OS-based** (`OS`):
  * KVM
    * `OS`
      * ***N.B.*** With respect to KVM, the host operating system switches to a mode/module in order to assume a hypervisor-like role, whereby the rest of the operating system provides a secondary supporting role (i.e., akin to a privileged partition).
  * Fusion
    * `OS`
  * VirualBox
    * `OS`
  * VMware Player
    * `OS`
  * VMware ESX
    * `HV`
  * Citrix XenServer
    * `HV`
  * Microsoft Hyper-V
    * `HV`

## 11. Virtualization Requirements Quiz and Answers

In the following options, which are **virtualization requirements**? (Select all that apply.)
  * Present the virtual platform interface to the guest virtual machines
    * `APPLIES` - At the lowest level, the virtual machine monitor (VMM) must provide the guest virtual machines with a virtual platform interface to all of the hardware resources (e.g., the CPU, the memory, the devices, etc.).
  * Provide isolation across the guest virtual machines
    * `APPLIES` - The virtual machine monitor (VMM) must isolate the guest virtual machines from each other. This can be easily achieved by using similar mechanisms to those used by operating systems to provide isolation across the guest virtual machines (e.g., preemption, hardware support via the memory management unit (MMU) to perform fast validations and translations of memory references/addresses, etc.)
  * Protect the guest operating system from applications running in the virtual machine
    * `APPLIES` - Within the virtual machine, at the top-most level of the stack, the virtualization solution must continue to provide the ability to protect the guest operating system from faulty or malicious applications (e.g., it is undesirable for the entire guest operating system to crash if a single application crashes). To achieve this, it is necessary to have separate protection levels both for the applications as well as for the guest operating system (i.e., it is *not* permissible to run the guest operating system and the applications at the *same* protection level). Therefore, these expectations that exist when the guest operating system is executing natively on the physical platform must also be met in the virtualized environment as well.
  * Protect the virtual machine monitor (VMM) from the guest operating system
    * `APPLIES` - The virtualization solution must have mechanisms to protect the virtual machine monitor (VMM) from the guest operating system(s). It is undesirable for a single faulty or malicious guest operating system to bring down the hypervisor for the entire machine. Therefore, it is *not* permissible to have a solution wherein the guest operating system and the virtual machine monitor (VMM) run at the *same* protection level; instead, they must be separated.

## 12. Hardware Protection Levels

TODO

<center>
<img src="./assets/P03L06-009.png" width="650">
</center>

<center>
<img src="./assets/P03L06-010.png" width="650">
</center>

<center>
<img src="./assets/P03L06-011.png" width="650">
</center>

## 13. Processor Virtualization

TODO

<center>
<img src="./assets/P03L06-012.png" width="650">
</center>

## 14. x86 Virtualization in the Past

### **Problems with Trap-and-Emulate**

TODO

<center>
<img src="./assets/P03L06-013.png" width="650">
</center>

## 15. Problematic Instructions Quiz and Answers

In earlier x86 platforms, the CPU flag **privileged register** was accessed via the **instructions** `POPF` and `PUSHF` that ***failed silently*** if not called from **ring 0** (**hypervisor**). What do you think can occur as a result? (Select the correct option.)
  * The guest virtual machine could not request interrupts enabled
  * The guest virtual machine could not request interrupts disabled
  * The guest virtual machine could not determine the current state of the interrupts enabled/disabled bit
  * All of the above
    * `CORRECT` - To perform any of the indicated operations indicated in the other options, this requires access to the privileged register and requires execution of the corresponding instructions `POPF` and `PUSHF`. When these fail silently, the guest virtual machine assumes that the request completed, and may consequently interpret some other information that is on the stack incorrectly (i.e., as if it were information provided by the privileged register). Therefore, none of these operations will be performed successfully.

## 16. Binary Translation

TODO

<center>
<img src="./assets/P03L06-014.png" width="650">
</center>

<center>
<img src="./assets/P03L06-015.png" width="650">
</center>

## 17. Paravirtualization

TODO

<center>
<img src="./assets/P03L06-016.png" width="650">
</center>

## 18. Binary Translation & Paravirtualization Quiz and Answers

Which of the following will cause a **trap** and consequent **exit** from the virtual machine to the hypervisor for ***both*** binary-translation and paravirtualized virtual machines? (Select one.)
  * Access of a page that is swapped
    * `CORRECT` - If the page is not present, it will be the hardware memory management unit (MMU) that will fail, resulting in passing of control to the hypervisor (i.e., regardless of the virtualization approach).
  * `INCORRECT` - Update to a page table entry
    * This is not always true; rather, it depends on whether or not the operating system has write permissions for the page tables that it uses.  
      * ***N.B.*** The next section will describe handling this situation.

## 19-20. Memory Virtualization

### **19

TODO

<center>
<img src="./assets/P03L06-017.png" width="650">
</center>

### **20. Paravirtualized**

TODO

<center>
<img src="./assets/P03L06-018.png" width="650">
</center>

## 21-24. Device Virtualization

### **21. Introduction**

TODO

<center>
<img src="./assets/P03L06-019.png" width="650">
</center>

### **22. Passthrough Model**

TODO

<center>
<img src="./assets/P03L06-020.png" width="650">
</center>

### **23. Hypervisor-Direct Model**

TODO

<center>
<img src="./assets/P03L06-021.png" width="650">
</center>

### **24. Split-Device-Driver Model**

TODO

<center>
<img src="./assets/P03L06-022.png" width="650">
</center>

## 25. Hardware Virtualization

TODO

<center>
<img src="./assets/P03L06-023.png" width="650">
</center>

## 26. Hardware Virtualization Quiz and Answers

With hardware support for virtualization, guest virtual machines (VMs) can run unmodified and can have access to the underlying devices. Given this, do you think that the split-device driver model is still relevant?
  * `YES` - With the split-device driver model, all of the requests for device access are consolidated to the surface virtual machine (VM), which can make better decisions and can enforce stronger policies in terms of how the devices are shared (i.e., without otherwise relying on specific support for the desired sharing behavior on the actual physical devices).

## 27. x86 Virtualization Technology Revolution

TODO

<center>
<img src="./assets/P03L06-024.png" width="750">
</center>

## 28. Lesson Summary

TODO
