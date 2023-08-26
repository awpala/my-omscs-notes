# Cache Review

## 1. Lesson Introduction

In this lesson, we will review **caches**.
  * ***N.B.*** This material should be known already (i.e., course prerequisite), however, it is extremely important to understand the basics of caches before proceeding onto virtual memory (cf. Lesson 13) and other more advanced caching topics (cf. Lesson 14). Therefore, this lesson will correspondingly include *more* detail than is included in a typical "review" lesson.

## 2. Locality Principle

<center>
<img src="./assets/12-001.png" width="650">
</center>

Understanding caches requires an understanding of **locality**. 

The **locality principle** states that things that will happen ***soon*** are likely to be close to things that ***just*** happened.
  * This means that if we know something about the past behavior, then we are likely to be able to guess what will occur soon.

We have already seen the locality principle previously in branch prediction (cf. Lesson 4). Now, we will see this in the context of **caches**.

## 3. Locality Quiz and Answers

<center>
<img src="./assets/12-003A.png" width="650">
</center>

Which of the following are ***not*** good examples of locality? (Select all that apply.)
  * It rained 3 times today → Therefore, it is likely to rain again today
    * `DOES NOT APPLY` - Usually if it rains often, then it will probably continue to rain often (at least for a while)
  * We ate dinner at 6 PM every day last week → Therefore, we will probably eat dinner around 6 PM this week
    * `DOES NOT APPLY` - People tend to eat meals around the same time
  * It was New Year's Eve yesterday → Therefore, it will probably be be New Year's Eve today
    * `APPLIES` -  New Year's Eve occurring on a given day generally means it ***will not*** be New Year's Eve the following day, i.e., New Year's Eve is temporal phenomenon which does ***not*** generally have locality on a timescale of days (this is effectively "anti-locality" in the sense that it "predicts" precisely the *opposite* of what the locality principle implies/suggests)

## 4. Memory References

<center>
<img src="./assets/12-004.png" width="650">
</center>

In computer architecture, we are interested in the locality principle as applied to **memory references**.

If we know that a processor as **accessed** address `X` recently, then the **locality principle** suggests that:
  * It is likely to access the ***same*** address `X` again in the near future → This is known as **temporal locality**
  * It is likely to access addresses proximally to `X` → This is known as **spatial locality** 

Therefore, once a given address is accessed, it is also likely that the ***same*** address will be accessed again soon, along with nearby addresses.

## 5. Temporal Locality Quiz and Answers

<center>
<img src="./assets/12-006A.png" width="650">
</center>

Consider the following code fragment:

```c
int sum = 0;
for (int j = 0; j < 1000; j++)
  sum = sum + arr[j];
```

Which of the following memory locations has ***temporal*** locality in this code? (Select all that apply.)
  * `j`
    * `APPLIES`
  * `sum`
    * `APPLIES`
  * elements of `arr`
    * `DOES NOT APPLY`

***Answer and Explanation***:

Recall (cf. Section 4) that temporal locality indicates that once a memory location is accessed, it is likely to be accessed again.
  * For `j`, this is true because it is used both as the `for` loop's iteration variable and in expression `arr[j]` in each loop iteration. Therefore, after a given iteration, it is generally likely that `j` will be accessed again soon; indeed, on initial access, it will be accessed *many* times (`1000` cumulatively) subsequently thereafter.
  * For `sum`, this is true for similar reasons to `j`, i.e., it is initialized before the loop, and then is subsequently accessed for read and write operations on every loop iteration.
  * Conversely, for any given element of array `arr` (i.e., `arr[j]`), with each element occupying a different (albeit adjacent-to-the-next) memory location, once it is accessed in a given loop iteration, it is no longer accessed again subsequently thereafter.

## 6. Spatial Locality Quiz and Answers
