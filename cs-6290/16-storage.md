# Storage

## 1. Lesson Introduction

This lesson will discuss **storage systems** (e.g., hard drives) and how they are connected to the rest of the computer. This will facilitate in understanding why they are so much slower than main memory, but can also store comparatively much more data.

## 2. Storage

<center>
<img src="./assets/16-001.png" width="650">
</center>

Consider the role of **storage** in a computer system:
  * 1 - Storage maintains all of the **files** (e.g., programs, data, settings, the operating system, etc.).
  * 2 - **Virtual memory** is also implemented using storage.
    * It is not possible to fit *all* of the data required by *all* applications *simultaneously* in main/physical memory; instead, many of those pages actually reside ***on disk***, and therefore when the program(s) accesses these pages, they are subsequently loaded into main/physical memory.

For both (and other) of these uses of storage, ***performance*** is a critical concern, most notably:
  * Throughput (i.e., bytes per-unit time)
    * With respect to storage performance, increased throughput is improving over time, however, ***not*** as quickly processor speed has improved concomitantly.
  * Latency (i.e., response time to return a page of data upon request)
    * With respect to storage performance, decreased latency is improving, but relatively very slowly (even more slowly than dynamic random access memory [DRAM])

In addition to performance, ***reliability*** is another critical concern.
  * If the processor fails, then the system is temporarily "out of commission" until the processor can be replaced. However, on restoration of the processor, it is expected that the system will reboot and consequently return to its "normal" state.
  * Conversely, if the storage (i.e., disk) fails, then this is a ***catastrophic loss*** with respect to programs, data, settings, etc. Therefore, reliability is an even more critical concern with respect to storage than with respect to most other components of the computer system in this particular regard.

Lastly, the types of storage that can be used in practice are actually quite ***diverse***,e.g.,:
  * magnetic disks (traditional hard drives)
  * optical disks (compact discs [CDs], digital video discs [DVDs], etc.)
  * tape (i.e., for backup)
  * flash drives
  * etc.

## 3-6. Magnetic Disks

### 3. Introduction

<center>
<img src="./assets/16-002.png" width="650">
</center>

Consider **magnetic disks** (generally called **hard disks** presently), as in the figure shown above.
  * ***N.B.*** So called (older) "floppy disks" are also magnetic disks, and work along the same lines, however, hard disks are much more ubiquitous in present day.

<center>
<img src="./assets/16-003.png" width="300">
</center>

A magnetic disk (as in the the figure shown above) has a **spindle** to which **platters** are attached. These platters are attached to the ***same*** spindle (rotated by a motor), thereby rotating at a ***uniform*** speed accordingly.

<center>
<img src="./assets/16-004.png" width="350">
</center>

Examining a single such platter (as in the figure shown above), both sides of the surface are coated in a magnetic material. Each such surface contains the constituent **data bits**.

<center>
<img src="./assets/16-005.png" width="650">
</center>

The data bits are accessed via a **magnetic head** (as in the figure shown above), which is attached to a **head assembly**, which moves all of these magnetic heads in unison.

Since typically the head assembly is ***stationary*** relative to the rotating surfaces, the magnetic head correspondingly accesses the associated surface at a given "concentric circle" distance from the center/spindle, called a **track** (furthermore, this is true for ***all*** of the head/surface pairs). All of the tracks at this given radial distance from the spindle form what is collectively called a **cylinder**, comprised of the set of all tracks from each surface (all of which can be correspondingly accessed simultaneously by their respective magnetic heads at any given time).

<center>
<img src="./assets/16-006.png" width="500">
</center>

In order to ***vary*** the track that is accessed on a given surface, the magnetic head simply changes its radial distance relative to the spindle. Based on this geometric configuration, the data bits are therefore naturally ***organized*** on a track-wise basis (as in the figure shown above, from the "top" view of a given platter).

Generally, a given track does not store data continuously (since generally a given track is comprised of ***many*** data bits), but rather a give track is divided into **sectors**, where a sector is the smallest unit that can be read. As the disk rotates (as in the figure shown above), a given sector will pass under the magnetic head and provide the following information:
  * **preamble**  (denoted by black dot in the figure shown above) → a recognizable bit pattern indicating the start of a sector
  * **data bits** (denoted by blue in the figure shown above) → the actual data
  * **checksum** and other error-correction data (denoted by red in the figure shown above) → used to correct possible errors in the read sector

Therefore, when the head assembly reaches a particular cylinder, the corresponding magnetic heads commence searching for the beginning of a sector. Once the preamble is identified, the magnetic heads correspondingly become "oriented" with respect to the location within the track itself.

Given this, the **disk capacity** can therefore be defined as:

```
disk capacity = (# platters) × (2 surfaces per platter) × (# tracks per surface) × (# sectors per track) × (# bytes per sector)
```
  * ***N.B.*** `# tracks per surface` is equivalent to the `# cylinders`

Typical quantity sizes for these factors are as follows:
  * `# platters` → `1` to `4` or so
  * `# tracks per surface` → thousands
  * `# sectors per track` → tens to hundreds
  * `# bytes per sector` →  `0.5` to `1` kilobytes

To accommodate relative large capacities in relatively small physical space:
  * The head assembly and cylinder-spindles collectively must be relatively thin (with the platters correspondingly very spatially close together).
    * A typical feature size is `2.5 inches` in total width, with tracks spaced very closely together.
  * Furthermore, the head assembly must be very precise in its positioning for accurate reading.

### 4. Access Times for Magnetic Disks
