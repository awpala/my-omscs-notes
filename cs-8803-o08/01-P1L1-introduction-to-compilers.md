# P1L1: Introduction to Compilers

## 1. Introduction to Course

This course will study **compilers**, which translate from a program written in a high-level source language into a lower-level assembly language.
  * ***N.B.*** This course will ***not*** study a particular high-level-language-to-machine-code translation, but rather the course will focus on the theories and algorithms which can be applied to any language and/or machine.

The course is divided into three sections (corresponding to the constituent ***phases*** of the compilation process), as follows:
  * **front-end** → syntactic and semantic analysis of the source language
  * **middle-end** → the intermediate representation, and the corresponding analysis and optimizations associated with the source-code translation
  * **back-end** (or **code generator**) → generator of the resulting machine code

## 2. Introduction to Compilers

This lesson will examine the overall working of the compiler in terms of its various aforementioned phases (cf. Section 1), and their corresponding interactions. In particular, this section will highlight the following ***concepts***:
  * **tokenization**
  * **parsing**
  * **symbol tables**
  * **semantic analysis**

These concepts will be demonstrated in the context of a simple language and its corresponding processing, based on the language's grammar and its lexical specification.

## 3. What Is a Compiler?

This section explores the central question of the course: What is a compiler?

<center>
<img src="./assets/01-P1L1-001.png" width="650">
</center>

A compiler should be intuitively familiar from previous exposure (e.g., software development, coursework, etc.). However, most likely, this was previously encountered in the context of *developing* software as a *user* of the compiler, but not necessarily with respect to the *internals* of the compiler itself.

As a more formal definition, a **compiler** is a program that ***translates*** a program from a **source language** (written in a high-level language) to a **target language**.
  * Typically, the source language is a higher-level language (e.g., C, C++, Java, Fortran, etc.), whereas the lower-level language is the machine code, which is executed in its binary form directly on the processor itself.

<center>
<img src="./assets/01-P1L1-002.png" width="650">
</center>

A **compiler** takes a **source-file-based program** (which is oftentimes itself spread across *multiple* such source files) and compiles it into an **executable** (as in the figure shown above). The executable is typically a **binary file**, which executes directly on the **processor** (at very fast speed).

<center>
<img src="./assets/01-P1L1-003.png" width="650">
</center>

Additionally, there is another piece of software which is often confused with a compiler: An **interpreter** (as in the figure shown above). An interpreter works in a similar manner, starting with input of a high-level-language **source file(s)**. However, rather than directly translating the instructions into an executable, instead, the interpreter ***interprets*** the source program line-by-line, and then generating the corresponding output (e.g., to the terminal, or equivalent).
  * Observe that in this scheme, there is ***no*** corresponding executable generated, but rather the source file is "directly" interpreted in this manner.
  * There are many such interpreted languages (e.g., Python).

With respect to compilers vs. interpreters, the respective use cases are distinct. In particular, the execution of a compiled program is substantially faster than that of an interpreted program, precisely due to the ***direct*** execution of the executable on the hardware in the case of the former.

In this particular course, the focus will be on compilers.
  * ***N.B.*** Compilers and interpreters share many phases and features, however, this is beyond the scope of this course.

## 4. Why Compilers?

Before commencing with the formal study of compilers, consider some historic artifacts to understand ***why*** compilers came into being in the first place.

<center>
<img src="./assets/01-P1L1-004.png" width="650">
</center>

In the 1950s, the modern notion of "programming of computers" began, which entailed a rather tedious process for writing such source code at a low level, dealing directly at the "bit" level (and still later on arrival of assembly languages, which did not solve this particular problem). This gave rise to a rather tedious and error-prone software development cycle accordingly (i.e., features addition, fixing of bugs, etc.)

<center>
<img src="./assets/01-P1L1-005.png" width="650">
</center>

In 1954, IBM released the first compiler for Fortran (as in the figure shown above), which translated the Fortran source code into lower-level assembly language. This enabled to perform corresponding updates, bug fixes, etc. in the higher-level Fortran language (which provides additionally useful abstractions such as arrays, along with the more human-readable syntax), rather than dealing directly with the lower-level assembly language.

<center>
<img src="./assets/01-P1L1-006.png" width="650">
</center>

The final downstream step from this high-level language to low-level language translation is the conversion of assembly language into the binary machine language (as in the figure shown above), i.e., the constituent bits of the program running directly on the processor. Therefore, the role of the compiler is more specifically situated in the high-level-language-to-assembly-language translation, after which the **assembler** assumes responsibility for the final translation to directly executing binary instructions running on the processor itself.
  * ***N.B.*** By comparison, the role of the assembler is relatively straightforward, as it more or less "directly" translates the bit-format representation of the assembly instructions into the corresponding constituent bits; conversely, the compiler involves the comparatively much more complex task of converting the high-level language to the low-level assembly code, which does not have such a direct/one-to-one correspondence. The latter process is the particular focus of this course.

## 5-6. How Compilers Work
Having discussed the motivation behind the development of compilers previously in this lesson (i.e., enhancement of developer productivity), consider now the compiler **internals**, and how they work at a high level. Subsequently, each **phase** of the compiler will be examined in further detail.

### 5. Overview

<center>
<img src="./assets/01-P1L1-007.png" width="650">
</center>

One of the key phases of a compiler, which initializes when the compiler is invoked, is called the **parser** (as in the figure shown above). The parser requests a **token** to another phase of the compiler, called the **scanner**. The scanner in turn returns this requested token to the parser.
  * In this sequence, the compiler mimics the human process of reading a book (for example), involving the scanning of the book from start to finish. During this process, the mind "groups" the read characters as words. Analogously, in the terminology of the compiler, such "words" are called **tokens**. In this manner, the scanner traverses the source file and groups characters into tokens, which are subsequently fed back to the parser.
  * For example, the token `157.669` is parsed based on its flanking whitespace and corresponding structure, and consequently determines that it is a floating point constant (abbreviated as `FLOATCONST`) having value `157.669`. Both of these pieces of information (the data type and the value) are used internally in distinct ways: Ensuring that the token is a legal word, and that the value can be used later during execution of the program.

<center>
<img src="./assets/01-P1L1-008.png" width="650">
</center>

Next, the process of scanning (which is triggered by the parser) continues for a while, with the parser continuously ensuring that the token is ***syntactically valid*** (i.e., in compliance with valid statements in the language specification, e.g., assignment, control flow, function call, etc.).

Once the parser has analyzed a sufficient amount of tokens input, it must determine whether the resulting statement is syntactically valid. Additionally, the parser must also determine whether the statement is ***semantically valid*** (i.e., meaningful); this latter determination is called the **semantic action** phase. The purpose of the semantic action phase is to ensure that the statement in question is semantically correct.
  * If this determination fails the semantic action, a **semantic error** results (e.g., attempting to use a binary operator with two incompatible types).

Once the statement is determined to be syntactically and semantically correct, the compiler performs the next action, which involves translation of the statement into an **intermediate representation**, which is an internal representation of the statement within the compiler itself (this will be discussed in more detail later in the course). Essentially, at this point, the high-level construct (i.e., statement) is transformed into a form which is closer resembling to that of the target assembly language.

In summary, the compiler performs two key activities:
  * 1 - Perform checking of syntax and semantics via the parser and scanner
  * 2 - Translate the high-level language construct into the intermediate representation

The corresponding three phases of the compiler (scanner, parser, and semantic action) collectively comprise the **front end** of the compiler, which involves analysis of the program's syntax and semantics.
  * ***N.B.*** Many such compiler front ends additionally incur activities/phases which are particular to a given language, and therefore the front end is particularly amenable to customization with respect to the language specification in question.

### 6. Details

Let us further consider the details of the front end, particularly the semantic analysis phase.

<center>
<img src="./assets/01-P1L1-009.png" width="650">
</center>

When the compiler is invoked, this is tantamount to invoking the **parser** (as in the figure shown above). The parser essentially tracks the "location" during the compilation process (i.e., how much of the source code has been traversed up to a given point, what is the next step to perform, what checks should be performed on the program, etc.).

The parser invokes the **scanner** which in turn provides the next **token** (e.g., constants, variables, keywords, etc.) derived from the input **source file**.
  * ***N.B.*** A **keyword** is a reserved word which is used for a specific purpose in the language (and generally invalid as a variable name, etc.).

The interaction of the parser and the scanner occurs ***iteratively***, determining whether the resulting expression is syntactically valid. Eventually, the parser will have processed a ***partial sentence***, which at this point is determined to be syntactically correct.

<center>
<img src="./assets/01-P1L1-010.png" width="650">
</center>

Subsequently to identifying a syntactically-correct expression, the corresponding **semantic analysis** can be performed on it accordingly (as in the figure shown above). Several types of semantic analyses can be performed on such a candidate expression.

One of the key features of the semantic analysis is identification of all **variables** which are present in the program. Along these lines, the compiler determines whether a variable has been ***declared*** prior to its use in the program (along with appropriate type, scope level in the program, etc.). All of this information regarding declared variables is maintained in the compiler's **symbol table**. The compiler in turn looks up the corresponding variable-name information in the symbol table.
  * If the variable is ***found*** in the symbol table (i.e., the declaration was previously present there already), then it performs subsequent semantic checks (e.g., attributes such as type, scope, etc. for the variable in question, as defined in the symbol-table entry).
  * Conversely, if the variables is ***not*** found in the symbol table, then this implies that the variable in question has not yet been declared. In general, there are two types of statements in a high-level programming languages: Declarations and uses. Generally, declarations must occur ***before*** uses. Therefore, when such a statement is encountered during semantic analysis, the corresponding declaration is placed into the symbol table, for subsequent use-oriented statements with respect to the particular input in question.

Finally, once semantic checks have passed (e.g., declarations, type compatibility of operands in operator expressions, etc.), **code generation** can occur, yielding the resulting **intermediate code** (which more closely resembles the target assembly language), for subsequent generation of the assembly code in the next pass of the compiler.
  * At this point, it is still possible for semantic checks to ***fail*** (e.g., type incompatibility, use of a variable without its preceding declaration, an unavailable variable in the given scope, etc.), which results in corresponding **semantic errors**, which are consequently flagged and reported. In such cases of either syntactic or semantic errors, the code generation is simply abandoned, as it is not sensible to proceed with code generation of an otherwise invalid program. In order to resolve these errors, the source program must first be ***corrected*** accordingly before re-processing in this manner via the front end.

## 7. Compiler Parts

The previous sections of this lesson discussed the compiler phases and their interactions (i.e., intermediate checks), resulting in a net conversion from the high-level source code into a lower-level intermediate representation.

<center>
<img src="./assets/01-P1L1-011.png" width="650">
</center>

The compiler is comprised of two key parts: The **front end** and the **back end**.

The **front end** performs the following ***phases***:
  * 1 - **lexical analysis** → scanning activity to identify the valid groupings of tokens in the source code
  * 2 - **syntax analysis** → parsing of statements to verify their correctness
  * 3 - **semantic analysis** → downstream of the lexical and syntax analyses, this is the determination of whether or not the resulting statement is semantically meaningful

The **back end** involves translation/conversion of the intermediate representation (i.e., output of the front end) into the machine-level assembly code. The back end therefore performs the following ***phases***:
  * 4 - **code generation** → converting the intermediate representation into assembly code
  * 5 - **optimization** → as software becomes extremely large and complex, with correspondingly demanding performance, this ensures that the resulting assembly code is very efficient (e.g., fast execution, efficient packing of data segments, etc.)
    * ***N.B.*** The optimization phase is characteristic of most modern compilers. This course will briefly touch on this topic (e.g., handling of registers, and instruction selection), however, it will not be discussed comprehensively.

## 8. The Big Picture

Having seen the parts of the compiler previously in this lesson, consider now the corresponding details.

<center>
<img src="./assets/01-P1L1-012.png" width="650">
</center>

First, there is the **scanning** phase. The principal objective of the **scanner** is to convert the input text into a stream of known objects called **tokens** (or **words**), for subsequent feeding into the **parser**.

Next, in the **parsing** phase (as conducted by the aforementioned parsers), the principal objective is to match the input tokens (from the scanner) according to the defined **rules** in the **grammar** of the language in question (i.e., ensuring ***syntactic correctness*** of the tokens accordingly).
  * The **lexical rules** (or **word lexicon**) of the language (as used by the scanner) dictate how a **legal word** is ***formed*** by concatenating the corresponding constituent **alphabet**.
  * The high-level programming language also defines a **grammar**, which dictates the **syntactic rules** of the language (i.e., how a **legal sentence** is formed in the language).
    * Analogously, the English languages specifies a syntactic rule/convention of subject-verb-object, for example. Similarly, in a typical programming language, an assignment statement has a left-hand operand and a right-hand operand (and perhaps a terminating semicolon).

## 9. Tokenization Quiz and Answers

<center>
<img src="./assets/01-P1L1-013Q.png" width="650">
</center>

To check understanding of tokenization (or word formation), consider the following. If we use a whitespace character to delimit the end of a word (i.e., the prescribed lexical rule), then how many tokens/words are present in the following quoted sentence (ignoring quotation and period characters)?

> *"The question of whether a computer can think is no more interesting than the question of whether a submarine can swim."*
  *   ***N.B.*** Quote of famed computer scientist Edsger W. Dijkstra.

### ***Answer and Explanation***:

<center>
<img src="./assets/01-P1L1-014A.png" width="650">
</center>

There are `21` total tokens in the quoted sentence.
  * ***N.B.*** Here, each (English) word is a "token." The concept is analogous in programming languages, however, of course they do not strictly adhere to the same lexicon as the English language in this regard.

## 10. Scanning and Tokenization

Having seen the high-level view of a compiler previously in this lesson, consider now the process of **scanning** (i.e., **token generation**) in more detail.

<center>
<img src="./assets/01-P1L1-015.png" width="650">
</center>

Starting with one (or more) **source file**(s), the scanner proceeds with reading the input file character-by-character. The read characters are in turn placed sequentially into the **token buffer**, which contains the candidate **token** pending identification.

<center>
<img src="./assets/01-P1L1-016.png" width="650">
</center>

Consider the famous/familiar "hello world" program as follows (as implemented in the C programming language):

```c
main()
{
  printf("Hello World");
}
```

On input of the source file, the token buffer processes the character sequence as follows:

| Sequence | Token buffer contents |
|:--:|:--:|
| `S1` | `m` |
| `S2` | `am` |
| `S3` | `iam` |
| `S4` | `niam` |
| `S5` | `(niam` |

As the sequence proceeds, the scanner commences with identification of a legal token (i.e., via inputs `m`, `a`, `i`, `n`) per the corresponding lexical rules for the programming language C.

<center>
<img src="./assets/01-P1L1-017.png" width="650">
</center>

On encountering the character `(`, the parser determines that there is no valid token of form `m...(` as per the lexical specification for C, suggesting that the parser has now traversed past a legal token.

At this point, the scanner sends the character `(` back from the buffer (i.e., for subsequent identification of the next legal token), and correspondingly identifies the valid/legal token `main`, which is a keyword in the C programming language. In the meantime, this token `main` is completed and send over to the parser for subsequent processing.

In general, observe that during the character-by-character processing into the token buffer, at any given point, the scanner determines whether the in-progress scan is either ***starting*** a new legal token or otherwise ***extending*** a legal token's formation. Eventually, the scanner reaches a point where the subsequently read character cannot further extend a legal token, indicating that the next valid token has been encountered (thereby sending this character back for re-processing of the next valid token). Correspondingly, this process is called the **longest-match algorithm** (i.e., forming the maximum/longest token that is legally formed via concatenation in this manner), and is the most commonly used algorithm for scanners.

## 11. Parser Quiz and Answers

<center>
<img src="./assets/01-P1L1-018Q.png" width="650">
</center>

Having understood the working of the scanner (cf. Section 10), consider now the following grammar rules for defining a valid expression `E` (where `id` represents a variable name):
  * `E -> E + E` (addition/concatenation)
  * `E -> E * E` (multiplication/joining)
  * `E -> -E` (negation)
  * `E -> (E)` (parenthesization)
  * `E -> id` (defining an identifier)

Here, the rules start from the most-base case of `E -> id` and increase in complexity moving upwards.

Apply these grammar rules to the following candidate expressions, and determine which are valid:
  * `a + b`
    * `CORRECT`
  * `a + b * c`
    * `CORRECT`
  * `a b + c`
    * `INCORRECT`
  * `a + b + (a) c`
    * `INCORRECT`

***N.B.*** This act of applying grammar rules to evaluate the validity of a candidate expression is called **parsing**.

### ***Answer and Explanation***:

<center>
<img src="./assets/01-P1L1-019A.png" width="650">
</center>

In `a + b`:
  * `a` and `b` are valid operands for the operator `+` (second rule),
  * `a` and `b` are identifiers (fifth rule),
  * and therefore forms a ***valid*** expression.

In `a + b * c`:
  * `a` and `b * c` are valid operands for the operator `+` (first rule),
  * `b` and `c` are valid operands for the operator `*` (second rule),
  * `a`, `b`, and `c` are identifiers (fifth rule),
  * and therefore forms a ***valid*** expression.

In `a b + c`:
  * `a b` and `c` are valid operands for the operator `+` (first rule),
  * however, `a b` is not a valid expression,
    * ***N.B.*** This is generally true if attempting to match ***any*** of the given grammar rules, as this candidate sub-expression conforms to none of them as specified.
  * and therefore forms an ***invalid*** expression.

In `a + b + (a) c`:
  * By inspection, the sub-expression `(a) c` is not a valid expression, and therefore forms an ***invalid*** expression.
    * ***N.B.*** This analysis was done in an abbreviated manner, however, systematic analysis as for the previous candidate statements will yield a similar conclusion.

***N.B.*** In the case of malformed expression, the corresponding result of parsing is a **syntax error**.

## 12-16. Parser

### 12. Introduction

Now having a better understanding of grammar rules, consider a review of the working of the **parser**.

<center>
<img src="./assets/01-P1L1-020.png" width="650">
</center>

The main objective of the parser is to ***check*** the syntax using the grammatical rules of the language.

Furthermore, the parser ***controls*** the overall operation of parsing (i.e., in addition to checking the candidate expressions for valid syntax, the parser controls the flow of input characters from the scanner and subsequent forwarding to the semantic checker of validated tokens).

Lastly, the parser ***regulates*** the scanner by demanding its production of a candidate token for subsequent matching per the specified grammar.

Following this process of scanning, there are two possible **outcomes**:
  * **failure** → results in a syntax error
  * **success** → generation of the subsequent token, until reaching the point of semantic action (i.e., forwarding accordingly)

### 13. Grammar Rules

This section will introduce a mini grammar for a very small language, in order to give an idea of how the parsing process between the parser and scanner work.

<center>
<img src="./assets/01-P1L1-021.png" width="650">
</center>

The grammar for a "micro C" language is specified as in the figure shown above. This language is simply capable of declaring the function `main()`.
  * The parameter list `<PARAMS>` is delimited in parenthesis (i.e., `OPENPAR` and `CLOSEPAR`).
  * The parameter list `<PARAMS>` is either `NULL`, or otherwise comprised of one or more variables (i.e., `VAR` or correspondingly comma-separated `<VARLIST>`, respectively).
  * The body of function `main()` (i.e., `MAIN-BODY`) is delimited by curly brackets (i.e., `CURLYOPEN` and `CURLYCLOSE`), and is comprised of a constituent declaration statement(s) `<DECL-STMT>` and assignment statement(s) `<ASSIGN-STMT>`.
  * Both `<DECL-STMT>` and `<ASSIGN-STMT>` are terminated by a semicolon `;`.
  * Lastly, the atomic operators `<OP>` are restricted to `+` and `-`,  and the atomic types `<TYPE>` are restricted to `INT` and `FLOAT`.

***N.B.*** At a glance, this "micro C" language has relatively limited utility/functionality (i.e., restricted solely to the function `main()`, does not include input-output, etc.). However, it is nevertheless useful for demonstration of grammar specification and corresponding syntax checking.

One important thing to note here is that there is no prescription with respect to mixing of types with respect to the operands/operators (e.g., "addition" of a float and an integer operand). This is not a relevant specification with respect to ***syntax***, but rather such a specification falls under the purview of the ***semantics specification*** (which in turn is implemented as part of the **semantic check** accordingly, rather than the syntactic check).
  * The reason for such a "separation of concerns" is that by comparison, most semantic checks are relatively much more ***context-sensitive*** (where as for most language specifications, the upstream parsing activity is relatively ***context-insensitive***). Correspondingly, two different mechanisms can be used for checking syntax (which is much simpler and inexpensive) vs. checking semantics (which is much more complex and expensive, due to the added context required to perform the corresponding semantics checking).
  * Therefore, the design of the compiler checks is such that the upstream syntax checks occur ***first***, i.e., before commencing with (and correspondingly incurring the higher cost of) the more expensive semantics checks. Otherwise, there is no benefit gained from performing semantics checks on a syntactically invalid expression in the first place.

### 14. Example

Consider now a simple example for performing the syntax checking via the parser-scanner interaction, as per the previously specified (cf. Section 13) "micro C" language.

<center>
<img src="./assets/01-P1L1-022.png" width="650">
</center>

Consider the simple program as follows:

```c
main() {
  int a,b;
  a = b;
}
```

<center>
<img src="./assets/01-P1L1-023.png" width="650">
</center>

Initially, the parser demands the token from the scanner (as in the figure shown above).

<center>
<img src="./assets/01-P1L1-024.png" width="650">
</center>

Subsequently, the scanner performs a character-by-character sequential analysis of the input source file (as in the figure shown above), summarized as follows:

| Sequence | Token buffer contents |
|:--:|:--:|
| `S1` | `m` |
| `S2` | `am` |
| `S3` | `iam` |
| `S4` | `niam` |
| `S5` | `(niam` |

Since the input `(` does not form a legal token via `m...)`, it is discarded.

<center>
<img src="./assets/01-P1L1-025.png" width="650">
</center>

However, the resulting expression `main` *is* a valid token (i.e., a keyword per the grammar), it is consequently sent to the parser (as in the figure shown above).

<center>
<img src="./assets/01-P1L1-026.png" width="650">
</center>

Correspondingly, the parser receives the token and verifies it against the grammar rules. Indeed, `main` is the first token which is expected at the start of any valid "micro C" program as per the specification.

<center>
<img src="./assets/01-P1L1-027.png" width="650">
</center>

Recalling the grammar (cf. Section 13, and as repeated in the figure shown above), a valid program `<C-PROG>` begins with token `MAIN` (ignoring case-sensitivity for simplicity). Therefore, at present, the input source code is syntactically ***valid*** as of this point.
  * ***N.B.*** At this point, if any ***other*** token were received besides `main`, then the program would be rendered as syntactically ***invalid***.

On matching of the token `main`, the next token is demanded by the parser from the scanner. It will proceed in this manner until the full source program is analyzed, until all tokens are fully matched (success) or an invalid expression is encountered (failure, i.e., syntax error).

### 15. Overview

<center>
<img src="./assets/01-P1L1-028.png" width="650">
</center>

Consider now an ***overview*** of how the parser works (as in the figure shown above).
  * 1 - The parser starts by **matching**, using a given **rule**.
  * 2 - When the match occurs at a certain position in that rule, the parser will proceed onto the next location in that rule in order to retrieve the next token, and this process repeats accordingly as follows:
    * 2A - If **expansion** of a given candidate token is necessary, it must do so using the appropriate **rule**:
      * 2Ai - If ***no*** appropriate rule for expansion is found, then an **error** is declared
      * 2Aii - Otherwise if ***several*** rules are found, then the grammar is **ambiguous** (in general, a correctly-specified grammar should be able to unambiguously select a ***distinct*** rule for a given candidate token)

***N.B.*** For present purposes, with respect to step 2A, it is not yet apparent *how* such a rule is appropriately chosen, but rather it is ***assumed*** here that the parser *is* indeed capable of making this appropriate decision accordingly.

<center>
<img src="./assets/01-P1L1-029.png" width="650">
</center>

Recalling the grammar (cf. Section 13, and as repeated in the figure shown above), let us further consider the notion of ***expanding*** a candidate token.

As a representative example, the initial rule `<C-PROG> → MAIN OPENPAR <PARAMS> CLOSEPAR <MAIN-BODY>` contains sub-token `<PARAMS>` which can be further specified/expanded, as per the following valid candidate tokens:
  * `<PARAMS> → NULL`
  * `<PARAMS> → VAR <VARLIST>`, which in turn expands via `<VARLIST>` to:
    * `<VARLIST> → , VAR <VARLIST>`
    * `<VARLIST> → NULL`

<center>
<img src="./assets/01-P1L1-030.png" width="650">
</center>

Recall (cf. Section 14) the simple program as follows:

```c
main() {
  int a,b;
  a = b;
}
```

The first set of valid tokens is therefore `main()`, which corresponds to the function header with a `NULL` declaration of parameters (i.e., empty parameters list), corresponding to the expansion `<PARAMS> → NULL`.

More generally, the grammar therefore specifies the most general way in which such a "micro C" program can be validly constructed (i.e., per appropriate expansion accordingly). Correspondingly, the ***key decision*** made by the parser with respect to a given input program is the expansion performed in this manner, in order to determine syntactic correctness of the program in question.

### 16. Ambiguity

In the previous section, the parsing process was examined more carefully, whereby the corresponding **parsing algorithm** chooses a **rule** at each step (with each such rule being ***unique***), in order to predict the next set of tokens to be matched for the current input program. Furthermore, it was noted that a ***problematic*** case may arise whereby a unique/distinct rule ***cannot*** be identified for a particular candidate token. Consider now a further examination of this **ambiguity**, to further understand its implications.
  * ***N.B.*** Sometimes the language specification itself gives rise to ambiguities, which in turn does not lend itself to a well-specified grammar as result. However, for present purposes, it is assumed that the language in question *is* sufficiently designed in order to be well-specified (i.e., unambiguously) with respect to the corresponding grammar accordingly.

<center>
<img src="./assets/01-P1L1-031.png" width="650">
</center>

In a given grammar, an **ambiguity** is a property of the grammar which is at the core of the concept of parsing itself. Here, parsing is not simply a matter of matching tokens, but rather also encompasses the conferral of ***structure*** on a sentence. In particular, when selecting the appropriate (i.e., unambiguous) grammar rule, it is imperative to understand the sentence (and its constituent "sub-sentence"/"sub-token" accordingly).

In this regard, if an ambiguity arises, then this can lead to an "understanding" of a given sentence in two (or more) ***different*** ways, resulting in the ***highly undesirable*** assignment of two (or more) meanings to the ***same*** sentence. For example, the expression `2 * 2 + 3` can be interpreted in the following two distinct ways:
  * `2 * 2` produces `4` which is added to `3`, yielding result `7`, or
  * `2 + 3` produces `5` which is multiplied by `2`, yielding result `10`

Therefore, to avoid this particular ambiguity, it is necessary to specify the appropriate ***precedence*** of the candidate sub-expressions/operands with respect to the operators in question.

## 17. Ambiguity Quiz and Answers

<center>
<img src="./assets/01-P1L1-032Q.png" width="650">
</center>

To test understanding of ambiguity in parsing (cf. Section 16), consider the candidate statement as follows:

```
if x==1 then if y==2 print 1 else print 2
```

Given this statement, which of the following grammar rules should be applied, with appropriate expansion if necessary, to unambiguously parse the statement (where `stmt` is a statement and `expr` is an expression)?
  * `stmt → if expr then stmt`
  * `stmt → if expr then stmt else stmt`

### ***Answer and Explanation***:

<center>
<img src="./assets/01-P1L1-033A.png" width="650">
</center>

Focusing on the expression `if y==2 print 1 else print 2`, this conforms the corresponding expansion `stmt → if expr then stmt else stmt`. This in turn can serve as the sub-expansion for `stmt → if expr then stmt` to complete the parsing of the candidate statement.

<center>
<img src="./assets/01-P1L1-034A.png" width="650">
</center>

Conversely, the expression `if y==2 print` conforms to the corresponding expansion `stmt → if expr then stmt`. This in turn can serve as the sub-expansion for `stmt → if expr then stmt else stmt` to complete the parsing of the candidate statement.

<center>
<img src="./assets/01-P1L1-037A.png" width="650">
</center>

Therefore, for this particular candidate statement, there is an ambiguity, whereby both grammar rules can be applied in either order to yield a "valid" parsing, arising from how the `else` clause is parsed. This type of ambiguity regarding ***operator associativity*** for a particular operator (e.g., ternary operator `if ... else ...` in this case) is typical, as was encountered previously (cf. Section 16) with respect to candidate statement `2 * 2 + 3` (as in the figure shown above) in terms of its operands (`2`, `2`, and `3`) and corresponding operators (`*` and `+`).
  * ***N.B.*** In the case of arithmetic operator, a typical disambiguation would be PEMDAS to arbitrate among the two enumerated possibilities (i.e., multiplication preceding addition vs. addition preceding multiplication).

***N.B.*** By design, languages are typically specified in a manner which does *not* yield ambiguous grammars. Later in the course, we will examine how to remove such ambiguities by rewriting the grammar accordingly.

<center>
<img src="./assets/01-P1L1-038A.png" width="650">
</center>

For this particular example, an unambiguous grammar can be specified as in the figure shown above. Per this specification, a given `else` clause is ***always*** associated with the innermost `if`. Here, `unmatched_stmt` is expanded until an `else` clause is encountered.
  * As an additional exercise, it can be shown that this unambiguous grammar can be applied appropriately to the original candidate statement `if x==1 then if y==2 print 1 else print 2`.

## 18. Scanning and Parsing

Having demonstrated parsing and grammar ambiguity previously in this lesson, consider now a "completing the loop" with respect to the parser-scanner interaction.

<center>
<img src="./assets/01-P1L1-039.png" width="650">
</center>

Recall (cf. Section 14) the simple "micro C" program as follows:

```c
main() {
  int a,b;
  a = b;
}
```

Initially, the parser demands the next token from the scanner (as in the figure shown above).

<center>
<img src="./assets/01-P1L1-040.png" width="650">
</center>

The first-received token is `MAIN` (i.e., `main`), which is the starting point of the program (i.e., `<C-PROG>` as per the grammar, which is called the grammar's **start symbol** accordingly). This is detected as a valid token, and thus the next token is subsequently requested accordingly.

<center>
<img src="./assets/01-P1L1-041.png" width="650">
</center>

The next-received token is `OPENPAR` (i.e., `(`), similarly constituting a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-042.png" width="650">
</center>

The next-received token is `CLOSEPAR` (i.e., `)`). At this point, At this point, there are two possible conforming rules per the grammar with respect to token `<PARAMS>`. In this particular case, the conforming rule is `<PARAMS> → NULL` (i.e., parameter-less function signature), which constitutes a valid token per the grammar.
  * ***N.B.*** In this case, the parser has the "discernment" to choose among the two possible rules for the token in question (i.e., parameter-containing vs. parameter-less function signature). Furthermore, note that as described here, the parser is "keeping track" of these two different possibilities during parsing, and then selecting the appropriate rule accordingly (i.e., and correspondingly eliminating the alternate candidate[s] accordingly); such a "prediction-based" approach is called **predictive parsing**. Conversely, more "naive" parsers will perform backtracking to try another alternative, if reaching such a "branch point" with respect to multiple possibilities among candidate "sub-expressions." This topic will be examined further later in the course.

<center>
<img src="./assets/01-P1L1-043.png" width="650">
</center>

The next-received token is `CURLYOPEN` (i.e., `{`), which in turn corresponds to expansion for `<MAIN-BODY>` (which is otherwise a unique rule with respect this starting token). This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-044.png" width="650">
</center>

The next-received token is `INT` (i.e., `int`), which in turn corresponds to expansion for `<DECL-STMT>`. This results in a corresponding sub-expansion for `<DECL-STMT>` (one rule), which in turn yields two corresponding sub-expansions for `<TYPE>`. However, there is no ambiguity in this case, as the resulting token is `INT`, which constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-045.png" width="650">
</center>

The next-received token is `VAR` (i.e., `a`), which in turn corresponds to expansion for `<VAR>` (a corresponding sub-expansion for previously expanded `<DECL-STMT>`). This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-046.png" width="650">
</center>

The next-received token is `,` (i.e., `,`), which in turn corresponds to expansion for `<VARLIST>` (a corresponding sub-expansion for previously expanded `<DECL-STMT>`). Per corresponding sub-expansion, this unambiguously yields token `, VAR <VARLIST>`, which constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-047.png" width="650">
</center>

The next-received token is `VAR` (i.e., `b`), which in turn corresponds to expansion for `<VAR>` (a corresponding sub-expansion for previously expanded `<VARLIST>`). This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-048.png" width="650">
</center>

<center>
<img src="./assets/01-P1L1-049.png" width="650">
</center>

The next-received token is `;` (i.e., `;`), which in turn corresponds to expansion for `<VARLIST>` (a corresponding sub-expansion for previously expanded `<VARLIST>`). At this point, the terminating `;` corresponds to the intermediate expansion for `<VARLIST> → NULL`, thereby completing the "outer" sub-expansion `<VARLIST>` and "outermost" expansion `<DECL-STMT>`. This constitutes a valid token per the grammar.

At this point, the declaration statement has been completely matched, and the parser proceeds to the subsequent assignment statement accordingly.

<center>
<img src="./assets/01-P1L1-050.png" width="650">
</center>

The next-received token is `VAR` (i.e., `a`), which in turn corresponds to expansion for `<ASSIGN-STMT>` (one rule). This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-051.png" width="650">
</center>

The next-received token is `=` (i.e., `=`), which in turn corresponds to sub-expansion for previously expanded `<ASSIGN-STMT>`. This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-052.png" width="650">
</center>

The next-received token is `VAR` (i.e., `b`), which in turn corresponds to expansion for `<EXPR>` (a corresponding sub-expansion for previously expanded `<ASSIGN-STMT>`). Per corresponding sub-expansion, this unambiguously yields token `<EXPR> → VAR` (among multiple candidate sub-expansions), which constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-053.png" width="650">
</center>

The next-received token is `;` (i.e., `;`), thereby completing the "outermost" expansion `<ASSIGN-STMT>`. This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-054.png" width="650">
</center>

The next-received token is `CURLYCLOSE` (i.e., `}`), thereby completing the "outermost" expansion `<MAIN-BODY>`. This constitutes a valid token per the grammar.

<center>
<img src="./assets/01-P1L1-055.png" width="650">
</center>

Note that immediately prior to `CURLYCLOSE`, the token `<ASSIGN-STMT>` is ***completely matched***. This means that all of the sub-expansions have been resolved immediately prior to proceeding onto token `CURLYCLOSE` (which in turn constitutes a sub-expansion of "outermost" token `<MAIN-BODY>`).

<center>
<img src="./assets/01-P1L1-056.png" width="650">
</center>

More generally, in the sub-expansions, this "drilling down" occurs until all of the right-hand-side expansions of the constituent symbols (i.e., relative to `→`) have been resolved accordingly.

As demonstrated here, since all of the tokens have been parsed, the candidate program in question is syntactically ***valid*** with respect to the "micro C" program specification.
  * ***N.B.*** Otherwise, if a mismatch or ambiguity were encountered, then the candidate program would have been rendered/reported as ***invalid*** (i.e., having a **syntax error**) accordingly.

## 19. Syntax vs. Semantics Quiz and Answers

<center>
<img src="./assets/01-P1L1-057Q.png" width="650">
</center>

In addition to syntax errors, there are also possibilities of semantic errors (e.g., type mismatches, undeclared variables, etc.). To test understanding of the distinction between syntax vs. semantics, consider the following program written in the C programming language:

```c
int main() {
  int a,b,c;
  a +- = b;     // S1
  a = b + c;    // S2
  d = a + b + ; // S3
  d = a + b;    // S4
}
```

Of the four statements (as commented above), which are characterized by the following designations?
  * `A` → syntactically incorrect
  * `B` → semantically incorrect
  * `C` → both syntactically and semantically correct

### ***Answer and Explanation***:

<center>
<img src="./assets/01-P1L1-058A.png" width="650">
</center>

Statement `S1` (i.e., `a +- = b;`) is syntactically incorrect, as there is no such operator `+-` that is validly specified in the language C.
  * ***N.B.*** If a statement is syntactically incorrect, then it is generally semantically incorrect as well.

Statement `S2` (i.e., `a = b + c;`) is neither syntactically nor semantically incorrect (i.e., the statement is validly specified per the language C). The syntax is correct, and furthermore, semantically `a`, `b`, and `c` are all declared in the current scope prior to use, and are of compatible types (`int`) with respect to the operands in question (`=` and `+`).

Statement `S3` (i.e., `d = a + b + ;`) is neither syntactically nor semantically correct. There is a syntax error with respect to the right-most (binary) operator `+`, which is missing an operand. Furthermore, there is a semantic error, because the left-hand operand `d` of the assignment operator `=` is not declared in the current scope.

Statement `S4` (i.e., `d = a + b`) is syntactically correct, however, it is semantically incorrect because `d` is not declared in this scope (similarly to statement `S3`).

***N.B.*** Observe that syntax checking is relatively simple and localized, whereas semantics checking is more complex and requires a larger context (i.e., across multiple statements, etc.). For this reason, syntax checking generally occurs first, as a syntax error precludes performing an otherwise more expensive subsequent semantics check.

## 20. Syntax vs. Semantics
