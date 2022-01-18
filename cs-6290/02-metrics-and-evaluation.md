# Metrics and Evaluation

## 1. Lesson Introduction

Before learning how to make "better" computers, we must learn what "better" means in this context, as well as how to measure this.

This lecture will discuss **latency** and **throughput**, which we use as a measure of computer performance. Subsequently, we will examine how to measure performance of real computers using **benchmarks**, as well as a few general ways to achieve "good" performance. 

## 2. Performance

<center>
<img src="./assets/02-001.png" width="650">
</center>

When considering **performance**, we typically associate this with processor speed. However, within this, there are really two underlying aspects of performance, which are not necessarily identical:
  1. **latency** - the elapsed duration between the start and completion of a task
  2. **throughput** - the number of operations per-unit time (e.g., `ops/s`)

It may seem intuitive that latency and throughput are inverses of each other; however, this is not necessarily true, i.e., in general:
```
throughput ≠ 1/latency
```

Consider a car assembly line, having the following sequential operations:
  1. begin with a bare chassis
  2. install an engine
  3. add wheels
  4. install the frame (doors, hood, etc.)

For this assembly process, the latency is the total duration of assembly (e.g., `4` hours). However, this assembly process occurs continuously (e.g., when a chassis is moved from stage 1 to stage 2, another chassis replaces it in stage 1 immediately thereafter; and so on), resulting in a throughput of `5` cars/hour (assuming the four operations comprise 20 sub-steps), i.e., rather than simply `1/(4 hr) = 0.25/hr`.

## 3. Latency and Throughput Quiz and Answers

<center>
<img src="./assets/02-003A.png" width="650">
</center>

Consider a website for ordering penguin-shaped USB drives having the following features:
  * `2` servers
  * An order request is assigned to a server
  * The server takes `1 ms` to process an order
  * The server cannot perform any other tasks while processing an order

What is the throughput and latency for this website?
  * Throughput
    * `(2 orders)/(1 ms) = 2000 orders/s` - both servers process an order simultaneously over the *same* `1 ms` time interval, thereby achieving a higher throughput relative to a *single* server processing orders by itself
  * Latency
    * `1 ms` - as given in the prompt

## 4. Comparing Performance

<center>
<img src="./assets/02-004.png" width="650">
</center>

We can therefore measure performance as either latency or throughput. So, then, how do we ***compare*** performance of two (or more) different systems?

For example, consider how to substantiate the claim "*System X is N times faster than System Y.*" Typically, in such a characterization, we define the **speedup** as follows:
```
speedup = N
```

where:
```
N = speed(X)/speed(Y)
```

With this characterization, there is a distinction between comparing with respect to latency vs. with respect to throughput, i.e.,:
```
N = latency(Y)/latency(X)
```
vs.
```
N = throughput(X)/throughput(Y)
```

***N.B.*** For latency, in general, speed(X) is not directly proportional to latency(X), but rather there is an inverse relationship instead (i.e., the longer the latency, the slower the speed).

## 5. Performance Comparison 1 Quiz and Answers

Assume that an old laptop takes `4 hours` to compress a video, while a new laptop can perform this same task in `10 minutes`.

What is the speedup of the new laptop relative to the old laptop?
  * `speedup = latency(old)/latency(new) = (4 hr × 60 mins/hr)/(10 min) = 24`

***N.B.*** Intuitively, `speedup > 1` indicates that the new system is *faster* than the old system; conversely, `speedup < 1` indicates that the new system is *slower* than the old system. With this intuition, incorrectly calculating speedup in this example via throughputs (i.e., `speedup = 10/240 = 0.04`) yields an unintuitive result.

## 5. Performance Comparison 2 Quiz and Answers

Consider again the laptop which can compress a video in `10 minutes`. Now, assume that it falls down the storm drain, and we are forced to use the old laptop instead, which can compress the same video in `4 hours`.

What is the speedup of the old laptop relative to the new laptop?
  * `speedup = latency(new)/latency(old) = (10 min)/(4 hr × 60 mins/hr) = 0.04`

***N.B.*** As before, intuition can help with interpreting the result. In this case, it is sensible that indeed the older system has a "slow speedup" (i.e., `speedup < 1`).

## 7. Speedup


