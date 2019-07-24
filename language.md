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
_stream generator generator_, it generates stream generators.\TODO{give an
example of a reduction of the language, e.g. a list.init which generates a list
of sources?}

Basic expressions
-----------------

We begin by describing the most simple everyday expressions in Liquidsoap.

### Interactive mode

In order to test the functions that will be introduced in this section, it can
be convenient to use the _interactive mode_ of Liquidsoap which can be used to
type small expressions and immediately see their result. This interactive mode
is rarely used in practice, but is useful to learn the language and do small
experiments. It can be started with

```
liquidsoap --interactive
```

It will display a "`#`", meaning it is waiting for expressions, which have to be
ended by "`;;`". For instance, if we type

```{.liquidsoap}
name = "Sam";;
```

it anwsers

```
name : string = "Sam"
```

which means that we have defined a variable `name` whose type is `string` and
whose value is `"Sam"`. It can be handy as a calculator:

```
2*3;;
```

results in

```
- : int = 6
```

("`-`" means that we did not define a variable, that the type of the expression
is `int` and that it evaluates to 6). Also, variables can be reused: it we type

```{.liquidsoap}
print("Hello #{name} and welcome!");;
```

it will answer

```
Hello Sam and welcome!
- : unit = ()
```

which is the result of printing and the indication that we did not define a
variable, that the result is of type `unit` and that its value is `()`. The
meaning of these is detailed below. In the following, all examples starting by
`#` are in the interactive mode.

Another useful feature is the `-i` option of Liquidsoap which displays the types
of variables in a file. For instance, if we have a file `test.liq` containing

```{.liquidsoap include="liq/interactive.liq" from=0 to=1}
```

and we run

```
liquidsoap -i test.liq
```

it will display the types for `x` and `f`:

```
x : float
f : (int) -> int
```

### Integers and floats

The integers, such as `3`, are of type `int`. Depending on the architecture (32
or 64 bits) they are stored on 31 or 63 bits. The minimal (resp. maximal)
representable integer can be obtained with the function `min_int`
(resp. `max_int`); typically, on a 64 bits architecture, they range from
-4611686018427387904 to 4611686018427387903.

The floats, such as `2.45`, are of type `float`, and are in double precision
(stored on 64 bits). They always have a decimal point in them, so that `3` and
`3.` are not the same thing: the former is an integer and the later is a
float. This is a source of errors for beginners, but is necessary for typing to
work well. For instance, running a program containing

```{.liquidsoap include="liq/bad/sine.liq" from=0 to=0}
```

will raise the error

```
At line 1, char 9:
Error 5: this value has type int but it should be a subtype of float
```

which means that the sine function expects a float as argument, but an integer
is provided. The fix here obviously consists in replacing "`500`" by "`500.`"
(beware of the dot).

The usual arithmetic operations are available (`+`, `-`, `*`, `/`) are
available, and work for both integers and floats. For floats, additional
functions are available such as `sqrt` (square root), `exp` (exponential), `sin`
(sine), `cos` (cosine) and so on. Random integers (resp. floats) can be
generated with the `random.int` (resp. `random.float`) function.

### Strings

Strings are written between quotes, e.g. `"hello!"`, and are of type
`string`. The concatenation of two strings is achieved by `^`, as in

```liquidsoap
user = "dj"
print("Current user is " ^ user)
```

As a side note, the `print` function will work on any type, so that

```liquidsoap
print(3+2)
```

will output `5` as expected. Instead of using concatenation, it is often rather
convenient to use _string interpolation_: in a string, `#{e}` is replaced by the
string representation of the result of the evaluation of the expression `e`:

```liquidsoap
user = "admin"
print("The user #{user} has just logged.")
```

or

```liquidsoap
print("The number #{random.float(min=-1., max=1.)} is random.")
```

In practice, one rarely does use print, which displays on the standard output,
but rather the logging functions `log.critical`, `log.severe`, `log.important`,
`log.info` and `log.debug` which write strings of various importance in the
logs, so that it is easier to keep track of them (they are timestamped, stored
in files, etc.).

The string representation of any value in Liquidsoap can be obtained using the
function `string_of`, e.g. `string_of(5)`{.liquidsoap} is `"5"`. Some other
useful string-related function are

- `string.sub`: extract a substring,
  ```
  # string.sub("hello world!", start=6, length=5);;
  - : string = "world"
  ```
- `string.split`: split a string on a given character
  ```
  # string.split(separator=":", "a:42:hello");;
  - : [string] = ["a", "42", "hello"]
  ```
- `string.match`: test whether a string matches a regular expression,\TODO{give
  an example}
- `string.replace`: replace substrings matching a regular expression.\TODO{give
  an example}

### Booleans

The booleans are either `true`{.liquidsoap} or `false`{.liquidsoap} and are of
type `bool`. They can be combined using the usual boolean operations `and`
(conjunction), `or` (disjunction) and `not` (negation). Comparison operators
such as `==` (which compares for equality), `!=` (which compares for inequality)
or `<=` (which compares for inequality) take two values and return booleans. The
time predicates such as `10h-15h` are also booleans, which are true or false
depending on the current time, see [there]{#sec:time-predicates}.

_Conditional branchings_ execute code depending on whether a condition is true
or not. For instance, the code

```{.liquidsoap include="liq/cond1.liq" from=1}
```

will print that the condition is satisfied when either `x` is between 1 and 12
or the current time is not between 10h and 15h. A conditional branching might
return a value, which is the last computed value in the chosen branch. For
instance,

```{.liquidsoap include="liq/cond2.liq" from=1 to=1}
```

will assign `"A"` or `"B"` to `y` depending on whether `x` is below 3 or
not. The two branches of a conditional should always have the same return type:

```liquidsoap
x = if 1 == 2 then "A" else 5 end
```

will result in

```
At line 1, char 19-21:
Error 5: this value has type (...) -> string
but it should be a subtype of (...) -> int
```

meaning that `"A"` is a string but is expected to be an integer because the
second branch returns an integer. The `else` branch is optional, in which case
the `then` branch should be of type `unit`:

```liquidsoap
if x == "admin" then print("Welcome admin") end
```

### Unit {#sec:unit}

Some functions, such as `print`, do not return a meaningful value: we are
interested in what they are doing (here printing on the standard output) and not
in their result. However, since typing requires that everything returns
something of some type, there is a particular type for the return of such
functions: `unit`. Just as there are only two values in the booleans (`true` and
`false`), there is only one value in the unit type, which is written `()`. This
value can be thought of as the result of the expression saying "I'm done".

In _sequences_ of instructions, all the instructions but the last should be of
type unit. For instance, the following function is fine:

```{.liquidsoap include="liq/fun1.liq"}
```

This is a function printing "hello" and then returning 5, see
[below](#sec:functions) for details about functions. Sequences of instructions
are delimited by new lines, but can also be separated by `;` in order to have
them fit on one line, i.e., the above can equivalently be written

```{.liquidsoap include="liq/fun2.liq"}
```

However, the code

```{.liquidsoap include="liq/bad/fun.liq"}
```

gives rise to the following warning

```
At line 2, char 2-4:
Warning 3: This expression should have type unit.
```

The reason is that this function is first computing the result of 3+5 and then
returning 2 without doing anything with the result of the addition, and the fact
that the type of `3+5` is not unit (it is `int`) allows to detect that. It is
often the sign of a mistake when one computes something without using it; if
however it is on purpose, you should use the `ignore` function to explicitly
ignore the result:

```{.liquidsoap include="liq/fun3.liq"}
```

### Lists

Some more elaborate values can be constructed by combining the previous ones. A
first one is _lists_ which are finite sequences of values, which are all of the
same type. They are constructing by square backeting the sequence whose elements
are separated by commas. For instance, the list

```liquidsoap
[1, 4, 5]
```

is a list of 3 integers, and its type is `[int]` (and the type of `["A",
"B"]`{.liquidsoap} would obviously be `[string]`). Note that a list can be
empty: `[]`. The function `list.hd` returns the head of the list, that is its
first element. This function takes an extra argument `default` which is the
value which is returned on the empty list (which does not have a first
element!). For instance, in the interactive mode

```
# list.hd(default=0, [1, 4, 5]);;
- : int = 1
# list.hd(default=0, []);;
- : int = 0
```

Similarly, the `list.tl` function returns the _tail_ of the list, i.e. the list
without its first element (by convention, the tail of the empty list is the
empty list). Other useful functions are

- `list.add`: add an element at the top of the list:
  ```
  # list.add(5, [1, 3]);;
  - : [int] = [5, 1, 3]
  ```
- `list.length`: compute the length of a list:
  ```
  # list.length([5, 1, 3]);;
  - : int = 3
  ```
- `list.mem`: check whether an element belongs to a list:
  ```
  # list.mem(2, [1, 2, 3]);;
  - : bool = true
  ```
- `list.map`: apply a function to all the elements of a list:
  ```
  # list.map(fun(n) -> 2*n, [1, 3, 5]);;
  - : [int] = [2, 6, 10]
  ```
- `list.iter`: execute a function on all the elements of a list:
  ```
  # list.iter(print(newline=false), [1, 3, 5]);;
  135- : unit = ()
  ```
  
### Tuples

Another construction present in Liquidsoap is _tuples_ of values, which are
finite sequences of values which, contrarily to lists, might have different
types. For instance,

```{.liquidsoap}
(3, 4.2, "hello")
```

is a triple (a tuple with three elements) of type

```
int * float * string
```

In particular, a _pair_ is a tuple of length two. For those, the first and
second element can be retrieved with `fst` and `snd`:

```
# p = (3, "a");;
p : int * string = (3, "a")
# fst(p);;
- : int = 3
# snd(p);;
- : string = "a"
```

For tuples with more elements, there is a special syntax in order to access
their elements. For instance, if `t` is the above tuple `(3, 4.2,
"hello")`{.liquidsoap}, we can write

```liquidsoap
let (n, x, s) = t
```

which will assign the first element to the variable `n`, the second element to
he variable `x` and the third element to the variable `s`:

```
# t = (3, 4.2, "hello");;
t : int * float * string = (3, 4.2, "hello")
# let (n, x, s) = t;;
(n, x, s) : int * float * string = (3, 4.2, "hello")
# n;;
- : int = 3
# x;;
- : float = 4.2
# s;;
- : string = "hello"
```

### Association lists

A quite useful combination of the two previous data structures is _association
lists_, which are lists of pairs. Those can be thought of a some kind of
dictionary: each pair is an entry whose first component is its key and second
component is its value. These are the way metadata are represented for instance:
they are lists of pairs of strings, the first string being the name of the
metadata, and the second its value. For instance, a metadata would be the
association list

```liquidsoap
m = [("artist", "Sinatra"), ("title", "Fly me")]
```

indicating that the artist of the song is "Sinatra" and so on. For such an
association lists, on can obtain the value associated to a given key using the
`list.assoc` function:

```liquidsoap
list.assoc(default="", "title", m)
```

will return `"Fly me"`, i.e. the value associated to `"title"`. The `default`
argument is the value (here the empty string) which will be returned in the case
where the key is not found. Since this is so useful, we have a special notation
for the above function, and it is equivalent to write

```liquidsoap
m["title"]
```

to obtain the `"title"` metadata. Other useful functions are

- `list.mem_assoc`: determine whether there is an entry with a given key,
- `list.remove_assoc`: remove all entries with given key.

Apart from metadata, those lists are also used to store http headers (e.g. in
`http.get`).

### Variables

We have many examples of uses of _variables_ so that we should be quick: we use

```liquidsoap
x = e
```

in order to assign the evaluation of an expression `e` to a variable `x`, which
can later on be referred to as `x`. Variables can be masked: we can define two
variables with the same name, at each point in the program the last defined
value for the variable is used:

```{.liquidsoap include="liq/masking.liq"}
```

will print `3` and `5`. Contrarily to most languages, the value for a variable
cannot be changed (unless we explicitly require this, see [below](#sec:ref)), so
the above program does not modify the value of `n`, it is simply that a new `n`
is defined.

When we define a variable it is generally to use its value: otherwise, why
bothering defining it? For this reason, Liquidsoap issues a warning when an
unused variable is found, since it is likely to be a bug. For instance, on

```{.liquidsoap include="liq/bad/unused.liq"}
```

Liquidsoap will output

```
Line 1, character 1:
Warning 4: Unused variable n
```

If this situation is really wanted, you should use `ignore` in order to fake a
use of the variable `n` by writing

```liquidsoap
ignore(n)
```

Functions {#sec:functions}
---------

builtin functions, that we like to call _operators_, but the user can define other

labels, optional parameters, inline functions, {}, recursive functions


handlers (e.g. `on_blank`)

crossfade

Partial evaluation, this is a source of errors (e.g. `list.hd([1,2,3])`) which
are however easily detected by typing

### Polymorphism

polymorphism, restrictions on type variables (detail the type for `+`), give the
type of `[]`

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

References {#sec:ref}
----------

ref ! :=

Float getters

Exemple de `gstreamer.hls`

The preprocessor
----------------

`%include` (useful for passwords!)
`%define`

`%ifdef`, `%ifndef`, `%ifencoder`, `%ifnencoder`, `%endif`

Sources
-------

### What is a faillible source?

In practice, simply use `mksafe`{.liquidsoap}

Requests
--------


