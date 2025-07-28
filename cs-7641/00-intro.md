# ML is the ROX

## 1. Definition of ML

This course considers the topic of **machine learning**, both from a ***theoretical*** and a ***practical*** perspective.

One definition for machine learning is **computational statistics** or **applied statistics**.

However, arguably, this definition is too narrow/restrictive. Machine learning comprises the broader notion of building computational artifacts that learn over time based on experience. Furthermore, it is *not* simply a matter of ***building*** these intelligent artifacts, but also understanding and appreciating their underlying ***building blocks*** (e.g., mathematics, science, engineering, computation, etc.).

Additionally, in this process, data is analyzed via computational methods and structures to glean further insights.

This course is subdivided into three parts, as follows:
* 1) Supervised Learning
* 2) Unsupervised Learning
* 3) Reinforcement Learning

These parts are discussed further in turn in the following sections.

## 2-3. Supervised Learning

### 2. Introduction

**Supervised learning** entails the problem of using existing data sets to provide insights for labeling new data sets. This could also be described as **function approximation**.

As an example, consider the following data set of inputs and corresponding outputs:

| $\text{input}$ | $\text{output}$ |
|:--:|:--:|
| $1$ | $1$ |
| $2$ | $4$ |
| $3$ | $9$ |
| $4$ | $16$ |
| $5$ | $25$ |
| $6$ | $36$ |
| $7$ | $49$ |

Based on past experience and related heuristics, it stands to reason that the relationship for this data could be described as follows:

$$
{\text{output}} \leftarrow {\text{input}}^{2}
$$

Assuming this relationship is correct, then it can be further surmised, for example, that $\text{input} = 10$ yields $\text{output} = 100$ . However, it is not *absolutely certain* that this will indeed be the case.

### 3. Induction and Deduction

As the example in the previous section demonstrates, when performing supervised learning (and functions approximation more generally), you are making fundamental **assumptions** about the data in question. If, for example, given a well-behaved function that is consistent with the data in question, then it is possible to ***generalize***; indeed, this notion of **generalization** is the ***fundamental problem*** in machine learning.

What underlies this generalization is **bias**, and in particular **inductive bias**. Virtually all of machine learning (and particularly supervised learning) revolves around **induction** (i.e., as opposed to **deduction**).
  * Here, **induction** involves going from specific examples to a more general rule, whereas **deduction** is the reverse (i.e., using a general rule to derive specific instances/examples, which describes the general notion of ***reasoning***).

Much of early artificial intelligence (AI) revolved around deductive reasoning, for example, logic programming, whereby certain rules which are used to deduce only those things that follow immediately from those rules (e.g., $a \implies b$ therefore given $a$ then this also implies $b$). Conversely, a contrasting example of inductive reasoning is as follows: If the sun rose this morning and yesterday (and so on), then the sun will rise again tomorrow.

Therefore, both induction and corresponding inductive bias are crucial to machine learning (and supervised learning in particular), as will be further elaborated upon later in the course.

## 4. Unsupervised Learning

In **unsupervised learning**, rather than beginning with a set of known/given examples (cf. Section 2), a more unstructured input is provided, from which we derive a structure based on corresponding examination of the relationship(s) among the inputs in question.

For example, when studying lifeforms, four-legged animals may be initially called "dogs," which in turn are characteristically different from what might be discerned to be a "tree" (which lack such four legs as a corresponding descriptor/feature).

Therefore, recalling that supervised learning entails *approximation* (cf. Section 2), unsupervised learning correspondingly involves ***description***. More specifically, unsupervised learning involves taking a set of data and determining how it can be divided accordingly. In general, this entails some sort of summarization, i.e., a compressed/concise description of the (otherwise more broadly intrinsically amorphous) data.

For example, if examining individuals in the public, they might be divided along certain categories such as ethnicity, hair style, facial hair, gender, etc.

Notably, unsupervised learning is ***distinct*** from supervised learning in the following important way: Categorizations in unsupervised learning are not inherently distinct, but rather a priori they are effectively "equally weighted." Conversely, supervised learning more explicitly/directly provides a "signal" to direct the appropriate data training.
    * However, these are not mutually exclusive. In particular, these can form a corresponding "processing pipeline" (e.g., unsupervised learning techniques are used to initially describe the data via appropriate categories, to which supervised learning is consequently applied in order to generate appropriate labels; cf. ***density estimation***, which is a corresponding technique utilizing such an approach, as will be discussed later in the course).

## 5. Reinforcement Learning

Lastly, **reinforcement learning** is described as learning from delayed reward. Instead of receiving feedback as in supervised learning and unsupervised learning (cf. Sections 2 and 4, respectively), the feedback itself may be effectively "delayed" by a few steps relative to the decision point itself.

For example, consider a match of tic-tac-toe. After a sequence of X's and O's supplied by adversaries, ultimately, a final outcome is declared (i.e., one of the players wins, or otherwise the match culminates in a draw). Upon reaching this "outcome" state, the match(es) in question can be examined retrospectively to determine consequential vs. inconsequential moves/steps, and similar such information. Therefore, the corresponding signal is with respect to this incremental "good vs. bad move." Effectively, the game is being "played without knowing the rules," and only receiving the feedback along the way with respect to whether a loss, win, or draw was encountered.

## 6. Comparison of These Parts of ML

Given these three parts of machine learning (i.e., supervised learning, unsupervised learning, and reinforcement learning), there are many tools and techniques encompassed across the three, as will be seen in this course (along with their corresponding integration).

Furthermore, as it turns out, while supervised learning and unsupervised learning have distinct characteristics, there are still fundamental qualities which relate the two (e.g., supervised learning involves bias based on induction, while unsupervised learning ultimately involves an implicitly assumed signal when making the determination of corresponding categories; correspondingly, in a fundamental sense, a supervised learning problem can be transformed into an unsupervised learning problem). More fundamentally, all of these problems are essentially "the same kind of problem."

In addition to this, all of these different problems can be formulated as some form of **optimization**, i.e.,:

| ML Technique | Optimization |
|:--:|:--:|
| Supervised Learning | Labeling data well (i.e., find a function that "scores" most accurately) |
| Unsupervised Learning | Scoring clusters well (i.e., find criteria which cluster/"score" the data most accurately) |
| Reinforcement Learning | Scoring behavior well (i.e., find a behavior that "scores" most accurately) |

Observe that there is one common thread underlying all of these techniques: **data**. Data is "king" in machine learning. Correspondingly, machine learning is inextricably linked to **computation**.
  * There are certain schools of thought which focus on **algorithms** within this broader notion of computation (i.e., series of well-defined steps required to solve a particular problem). Or, equivalent, this may be described in terms of **theorems** to describe the problem in a particular way, which in turn could be solved by an appropriately well-defined algorithm.
  * Machine learning encapsulates a lot of this algorithm-theoretical thinking, however, there is one critical distinction: A practitioner focused on artificial intelligence (AI) and machine learning (ML) has *data* as the core/central focus, rather than *algorithms*. (However, algorithms are still essential to performing the appropriate data analysis, transformations, etc. nevertheless.)

For the remainder of this course, we will examine supervised learning and a whole series of algorithms, as well as examine their underlying theory and relate the theory of machine learning with theory of computational notions (e.g., what does it mean to be a "harder" problem vs. an "easier" problem). We will then proceed onto randomized optimization and unsupervised learning, where we will discuss all the issues introduced here in this lecture, while also connecting them back to supervised learning. Finally, the course will conclude with reinforcement learning, as well as a generalization of traditional reinforcement learning to that which involves multiple agents (including a related discussion of game theory). There will also be a demonstration of real-world applications of these techniques.

The most fundamental outcome of this course will be an understanding and appreciation for thinking about data and algorithms, and how to build computational artifacts that can "learn" in the manner introduced in this lecture.
