# Fault Tolerance

## 1. Lesson Introduction

This lesson will examine **reliability** and **availability**, how device faults can result in failures, and how to ensure adequate performance of computer devices even in the event of failure.

## 2. Dependability

<center>
<img src="./assets/17-001.png" width="650">
</center>

The first concept pertaining to fault tolerance is that of **dependability**, which is a characteristic of the delivered service itself. It is the quality of the delivered service that justifies relying on the system in order to provide that service. A **dependable system** is one which provides the service in a way which is "correct"/"as expected."

The "service" itself is comprised of the following two ***definitions***:
  * The **specified service** is the *expected* behavior of the service
  * The **delivered service** is the *actual*/*observed* behavior of the service

Given these definitions, dependability can therefore be understood as the "matching" between the specified service and the delivered service.

Furthermore, note that the system itself has **components** (called **modules**), with each component/module having a corresponding "ideally" specified behavior, from which a "real" component/module will typically deviate to some degree (i.e., this is descriptive of the level of dependability/undependability in this context).
  * ***N.B.*** In this context, "components" are referring to larger, system-scale components (i.e., at the scale of the computer system itself such as the processor, memory, etc., *not* "sub-components" such as transistors)

## 3-4. Faults, Errors, and Failures

### 3. Introduction

<center>
<img src="./assets/17-002.png" width="650">
</center>

When discussing "deviation from specified behavior," this really entails three specific ***concepts***, as follows:
  * A **fault** occurs when a ***module*** in the system deviates from the specified behavior
  * An **error** occurs when the ***actual behavior*** somewhere within the system differs from the specified behavior within the system
  * A **failure** occurs when the ***system*** itself deviates from the specified behavior for the system

### 4. Examples

<center>
<img src="./assets/17-003.png" width="650">
</center>

To better understand the concept of fault, error, and failure, consider corresponding illustrative examples.

Generally, a **fault** is the first-occurring event, for example, a programming mistake. Consider a programming mistake comprised of an `add()` function which works correctly, except in the case of `add(5, 3)` (which generates actual output `7` rather than expected `8`).
  * This type of fault is also called a **latent error**, because an error does not occur until such an "error condition" (i.e., `add(5, 3)`) is encountered.

Once a fault has encountered (i.e., the fault is ***activated***), then a subsequent **error** occurs. This state is also described as having an **effective error** (i.e., as distinguished from a latent error).
  * For example, when `add(5, 3)` is called and the result `7` is stored in a variable, this constitutes the effective error in question.

Finally, the **failure** results as a direct consequence of the system's deviation from the specified behavior.
  * For example, if the result in question was used to determine a meeting time, then the meeting will now be scheduled for `7 AM` rather than (intended) `8 AM`.

It is ***important*** to note that a fault is necessary to generate an error, however, not every fault results in an error.
  * In the preceding example, the fault must be activated first in order to become an error (i.e., called in such a manner which yields this underlying fault condition).

Similarly, an error is necessary to generate a failure, however, not every error results in a failure.
  * In the preceding example, if the errant value `7` were never used for scheduling, then no scheduling error would occur in the system.
  * Similarly, a test condition such as `if (add(5, 3) > 0)` will not produce a failure (despite producing an error).

## 5. Laptop Falls Down Quiz and Answers

<center>
<img src="./assets/17-005A.png" width="650">
</center>

Consider the distinction between a fault, error, and failure in the context of a laptop falling down.

The laptop following down is comprised of the following six steps:
  * 1 - falls out of my bag
  * 2 - hits the pavement
  * 3 - the pavement develops a crack
  * 4 - the crack expands during winter
  * 5 - the pavement breaks
  * 6 - the pavement must be replaced

In this scenario, from the perspective of the pavement as the "system," identify which step corresponds to the following:
  * failure?
    * `5` - This results in the pavement no longer functioning properly
  * fault?
    * `2` - The laptop hitting the pavement results directly in the fault
  * (first) error?
    * `3` - The crack is the appearance of the error, which deviates from the structure of the "intact" pavement

## 6. Reliability

<center>
<img src="./assets/17-006.png" width="650">
</center>

In addition to dependability, there are also several key properties pertaining to fault tolerance.

One of these properties is **reliability**. Unlike dependability (which is a property of the system with respect to its ability to perform its function), reliability is a ***measurable*** property.

In order to measure reliability, the system is considered to be in one of the two following **states** at any given time:
  * ***service accomplishment***  → this is the "normal" state, in which the system provides the service in question
  * ***service interruption*** → in this state, the service is not being provided (i.e., the system is not accomplishing the expected service)

Given these two states, reliability can now be ***defined*** by measuring the ***continuous*** service accomplishment state. A typical metric for reliability in this context is the **mean time to failure (MTTF)**, which quantifies how long is the service accomplished state sustained before the service interruption state occurs.
  * For example, a service which has periodic monthly service interruptions during a continuous two-year interval of operation will have a mean time to failure (MTTF) of one month.  

Another popular metric related to this is called **availability**, which measures the service accomplishment state as a fraction of the overall time. In order express this measurement, the **mean time to repair (MTTR)** (i.e., the time required to restore the system from service interruption state back to service accomplishment state) must also be determined accordingly. Given these constituents, availability can therefore be expressed as follows:

```
availability = MTTF / (MTTF + MTTR)
```

## 7. Reliability and Availability Quiz and Answers

<center>
<img src="./assets/17-008A.png" width="650">
</center>

Consider a system comprised of a hard disk characterized by the following sequence:
  * Works correctly for `12` months
  * Breaks (cannot spin), requiring a consequent `1` month downtime to replace the motor
  * Works correctly for `4` months
  * Breaks (cannot move magnetic heads), requiring a consequent `2` months downtime to diagnose and unstick
  * Works correctly for `14` months
  * Breaks (magnetic head broken), would require a consequent `3` months downtime to fix
  * Throw away and replace with a new hard disk instead of fixing the broken one

For this system, determine the following:
  * mean time to failure (MTTF)?
    * `10` months
  * mean time to repair (MTTR)?
    * `2` months
  * availability?
    * `83.33%`

***Explanation***:

The mean time to failure (MTTF) can be determined as follows:

```
(12 + 4 + 14 months)/(3 failures) = 10 months per failure
```

The mean time to repair (MTTR) can be determined as follows:

```
(1 + 2 + 3 months)/(3 repairs) = 2 months per repair
```

The availability can be determined as follows:

(*via MTTF and MTTR*)
```
10/(10 + 2) = 0.8333
```

(*equivalently via time of service and time of repair*)
```
(3×10 months)/(3×10 + 3×2 months) = 0.8333
```

## 8. Kinds of Faults

<center>
<img src="./assets/17-009.png" width="650">
</center>

There are various ways by which faults can be ***classified***.

One such classification is ***by cause***:
  * ***hardware faults*** → the hardware system fails to perform as it was designed to
  * ***design faults*** → software bugs and hardware design mistakes (e.g., the infamous `FDIV` design bug)
  * ***operation faults*** → operator and user mistakes
  * ***environmental faults*** → fire, power failures, sabotage of the system, etc.

***N.B.*** While all of these "faults by cause" are faults, not all result in failures (e.g., the `FDIV` bug only results in a failure if used in such a failure-inducing manner, an operator shutting down the system while it is not otherwise in use does not constitute a consequent failure, a backup battery or generator can mitigate a power failure to prevent a consequent system failure, etc.).

Another classification is ***by duration*** (i.e., how long the fault condition persists):
  * ***permanent*** → once the fault occurs, the fault is not subsequently corrected (e.g., destructively/non-reversibly examining a processor by accessing its internal components)
  * ***intermittent*** → the fault lasts for a certain time frame, and does so in a ***recurring*** manner (e.g., overclocking a system which results in an eventual crash, followed by a reboot to restore the system until the subsequent overclock-induced crash, and so on)
  * ***transient*** → the fault occurs for a certain time frame but then eventually subsides indefinitely (e.g., an alpha particle collides with a chip causing an incidental fault, which subsequently resolves on reboot of the system)

## 9. Fault Classification Quiz and Answers

<center>
<img src="./assets/17-011A.png" width="650">
</center>

Consider a scenario where a phone gets wet, heats up during subsequent attempted operation, and then explodes.

Classify the following faults appropriately:
  * the phone got wet? (by duration, by cause)
    * `transient` (by duration), `environmental` (by cause)
  * the phone was supposed to prevent itself from operating when wet, therefore heating up is a result of? (by duration, by cause)
    * `permanent` (by duration), `design` (by cause)

***Explanation***:

The wetting of the phone is an environmental fault, which occurs transiently (i.e., eventually, it dries off).
  * ***N.B.*** The explosion would have been a permanent/unrecoverable fault, however getting wet in itself is only a transient fault.

Furthermore, because the phone was supposed to prevent itself from running when wet, the fact that it did actually heat up otherwise is indicative of a design fault. Such design faults are typically permanent.
  * ***N.B.*** Observe that this is an example of how a fault can occur which does not subsequently lead to an error or failure (i.e., the permanent fault of being poorly designed in such a manner which does not prevent heating up and exploding on getting wet only manifests itself on reaching this wet condition).

## 10. Improving Reliability and Availability

<center>
<img src="./assets/17-012.png" width="650">
</center>

In order to improve reliability and availability, the following ***techniques*** can be used:
  * **fault avoidance** → prevent faults from occurring in the first place
    * For example, enforce a "no coffee in the server room" policy in order to prevent a potential damage-causing coffee spill.
  * **fault tolerance** → prevent faults from progressing into failures
    * A typical fault tolerance technique involves **redundancy** (e.g., an error correcting code [ECC] to ensure integrity of data in memory on read)
  * **speed up repair** → reduce the mean time to repair (MTTR), which is limited to improving only availability (but not reliability)
    * For example, keeping a spare hard disk in the drawer in the event of a hard drive failure for quick replacement (i.e., the failure still occurs, however, the repair period is comparatively short)

The remainder of this lesson will focus on the **fault tolerance** technique, particularly in the context of memory and storage.

## 11. Fault Tolerance Techniques

<center>
<img src="./assets/17-013.png" width="650">
</center>

The available **fault tolerance techniques** for improving reliability and availability are as follows:
  * **checkpointing** → save the state of the system periodically, and then detect errors and consequently restore the state of the system on detection of an error(s)
    * This technique is well suited for a system characterized by many transient and intermittent faults.
      * The idea is to save the system when the system is functioning normally, and then if a fault occurs, perform a restore on the system state upon detection of the corresponding errors. With one or several such restore operations, this is sufficient to resolve both transient and intermittent faults accordingly.
    * However, note that the checkpointing/restoring ***cannot*** take a long duration to perform, otherwise such a recovery will be regarded as a **service interruption**; thus, the relevant timescale is relative to this.
    * Furthermore, note that checkpointing is only a **recovery** technique, which additionally requires a detection technique (e.g., two-way redundancy) in order to actually detect the error.
  * **two-way redundancy** → two modules perform the *same* work, and then on comparison of this work, if there is a discrepancy then a rollback is performed
    * Note that this is only an **error-detection** technique, which additionally requires a recovery technique (e.g., checkpointing) for subsequent resolution.
  * **three-way redundancy** → three (or more modules) perform the *same* work, and then subsequently *vote* for which result is correct (thereby "eliminating by vote" any incorrect result(s))
    * This technique performs *both* **error detection** and **recovery**.
    * This technique is also relatively ***expensive***, since it requires a triplicate (or more) of the hardware and the "voter" mechanism, relative to a non-fault-tolerant system, however, as a result, the system can tolerate ***any*** fault in any ***one*** (but not two or more) of the given modules

## 12. N-Module Redundancy

<center>
<img src="./assets/17-014.png" width="650">
</center>

Consider a more general redundancy-based approach called **N-module redundancy**.
  * `N = 2` (**dual-module redundancy**) → guarantees detection but not correction with respect to `1` faulty module total
    * This technique can be used to detect more than one fault in the *same* module, however not multiple faulty modules.
  * `N = 3` (**triple-module redundancy**) → guarantees correction of `1` faulty module (and correspondingly all faults within that given module)
    * This technique can be used to tolerate more than one faulty module, however, the faults cannot impact the same overall result in order to guarantee correction.
  * `N = 5` → increased level of fault tolerance
    * For example, in the scenario of a space shuttle comprised of `5` computers performing the *same* tasks along with a voting mechanism:
      * `1` incorrect result in a vote yields normal operation
      * `2` incorrect results in a vote yields an aborted mission
        * In this case, there is still no failure, because `3` correct have still outvoted `2` incorrect 
      * `3` incorrect results in a vote yields a catastrophic failure of the space shuttle
        * For this reason, the upstream `2` incorrect results yields an aborted mission, in order to prevent this condition from being reached in the first place

## 13. N-Module Redundancy Quiz and Answers

<center>
<img src="./assets/17-016A.png" width="650">
</center>

Consider a system comprised of a computer, for which it is desired to have fault tolerance. To implement this fault tolerance, the following are performed:
  * Two more identical computers are purchased and placed on the same desk
  * The same computation is performed on all three computers, the results are compared, and then the consensus result is taken such that two or more (i.e., all three) agree

With this fault tolerance in place, which single event(s) can be tolerated? (Select all that apply.)
  * Alpha particle strikes a processor
    * `APPLIES`
  * Building collapses
    * `DOES NOT APPLY`
  * Earthquake
    * `DOES NOT APPLY`
  * Mistake in processor design
    * `DOES NOT APPLY`

***Explanation***:

A single alpha particle strike only affects a single processor, thereby leaving the other two computers intact.

Conversely, the remaining events (even if occurring singularly) will impact all three devices uniformly, thereby subverting the consensus mechanism entirely.
  * Therefore, to improve fault tolerance against this situation, one possible resolution measure would be to geographically distribute the three computers. However, with respect to a faulty processor design, this would additionally require replacing the three processors with non-faulty ones.

## 14. Fault Tolerance for Memory and Storage

