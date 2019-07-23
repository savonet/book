The language
============

Before getting into more advanced radio setups which can be achieved with
Liquidsoap, we need to detail the language and the general concepts behind
it.

General features
----------------

### Typing

One of the main features of the language is that it is _typed_. This means that
every expression belongs to some type which indicates what it is. For instance,
`"hello"` is a string whereas `23` is an integer, and, when presenting a
construction of the language, we will always indicate the associated
type. Liquidsoap implements a _typechecking_ algorithm which ensures that
whenever a string (or whichever other type) is expected a string will actually
be given. This is done without running the program, so that it does not depend
on some tests, but is rather enforced by theoretical considerations. Another
distinguishing feature of this algorithm is that it also performs _type
inference_: you never actually have to write a type, those are guessed
automatically by Liquidsoap. This makes the language very safe, while remaining
very easy to use. For curious people reading French, the algorithm and the
associated theory are described in [@baelde2008webradio].

### Functional programming

The language is _functional_, which means that you can define very easily
functions, and that functions can be passed as arguments of other functions.

functional

### Sources

source manipulation

### Execution model

Language execution vs stream production

Expressions
-----------

### Basic values

int / float

This raises a typing error:

```
s = sine(500)
```

strings, string interpolation: `"my name is #{name}"`, string representation of any value, printing, logging

booleans: conditionals time predicates (see [here]{#sec:time-predicates}).

### Variables

variable masking

unused variables, `ignore`

### Playing with Liquidsoap

interactive mode, type display, etc.

### Constructed values

lists (head, tail)

tuples (fst, snd, let ...)

References
----------

ref ! :=

Float getters

Exemple de `gstreamer.hls`

Functions
---------

labels, optional parameters, inline functions, {}

Partial evaluation

### Function ()->...

A nice example from https://github.com/savonet/liquidsoap/issues/536:
```liquidsoap
f = interactive.float("test", 0.0)
f = {lin_of_dB(f())}
s = amplify(f, in())
out(s)
```

interactive floats

notation `{x}`


Syntax of [language](https://www.liquidsoap.info/doc-dev/language.html)

Preprocessor
------------

include (useful for passwords!)

ifdef

Sources
-------

### What is a faillible source?

In practice, simply use `mksafe`{.liquidsoap}

Requests
--------


