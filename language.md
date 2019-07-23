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
functions, and that functions can be passed as arguments of other
functions. This might look like a crazy thing at first, but it is actually quite
common in some language communities (such as OCaml). The second thing it might
look is quite useless: why should we need such functions when describing
webradios? It happens to be quite convenient in many places: for handlers (we
can specify the function which describes what to do when some event occurs such
as when a DJ connects to the radio), for transitions (we pass a function which
describes the shape we want for the transition) and so on.

### Streams

The unique feature of Liquidsoap is that it allows the manipulation of _sources_
which are functions which will generate streams. These streams typically consist
of stereo audio data, but is not restricted to this: they can contain audio with
arbitrary number of channels, they can also contain an arbitrary number of video
channels, and also MIDI channels (there is limited support for sound synthesis).

### Execution model

When running a Liquidsoap program, the compiler goes through these four phases:

1. lexical analysis and parsing: Liquidsoap ingests your program and ensures
   that its syntax follows the rules,
2. type inference and type checking,
3. compilation of the program: this produces a new program which will generate
   the stream (a _stream generator_),
4. execution of the stream generator to actually produce audio.

The two last phases can be resumed by the following fact: Liquidsoap is a
_stream generator generator_, it generates stream generators.

Basic expressions
-----------------

We begin by describing the most simple everyday expressions in Liquidsoap.

### Floats and integers

The most basic values are integers, such as `3`, which are of type `int`, and
the floats, such as `2.45`, which are of type `float`. The floats always have a
decimal point in them, so that `3` and `3.` are not the same thing: the former
is an integer and the later is a float. This is a source of errors for
beginners, but is necessary for typing to work well. For instance, running a
program containing

```
s = sine(500)
```

will raise the error

```
At line 1, char 9:
Error 5: this value has type int but it should be a subtype of float
```

which means that the sine function expects a float as argument, but an integer
is provided. The fix here consists in replacing "`500`" by "`500.`".

### Strings

strings, string interpolation: `"my name is #{name}"`, string representation of any value, printing, logging

### Booleans

booleans: conditionals time predicates (see [here]{#sec:time-predicates}).

### Constructed values

lists (head, tail)

tuples (fst, snd, let ...)

### Variables

variable masking

unused variables, `ignore`

### Playing with Liquidsoap

interactive mode, type display, etc.

References
----------

ref ! :=

Float getters

Exemple de `gstreamer.hls`

Functions
---------

builtin functions, that we like to call _operators_, but the user can define other

labels, optional parameters, inline functions, {}

handlers (e.g. `on_blank`)

crossfade

Partial evaluation

detail the type for `+`

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


