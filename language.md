A programming language {#chap:language}
======================

Before getting into the more advanced radio setups which can be achieved with
Liquidsoap, we need to understand the language and the general concepts behind
it. If you are eager to start your radio, it might be a good idea to at least
skim though this chapter quickly at a first reading, and come back later to it
when a deeper knowledge about a specific point is required.

General features
----------------

Liquidsoap is a novel language which was designed from scratch. We present the
generic constructions, feature specifically related to streaming are illustrated
in [next chapter](#chap:workflow) and further detailed in [this
chapter](#chap:streaming).

### Typing

One of the main features of the language is that it is _typed_\index{type}. This means that
every expression belongs to some type which indicates what it is. For instance,
`"hello"` is a _string_ whereas `23` is an _integer_, and, when presenting a
construction of the language, we will always indicate the associated
type. Liquidsoap implements a _typechecking_ algorithm which ensures that
whenever a string is expected a string will actually be given, and similarly for
other types. This is done without running the program, so that it does not
depend on some dynamic tests, but is rather enforced by theoretical
considerations. Another distinguishing feature of this algorithm is that it also
performs _type inference_: you never actually have to write a type, those are
guessed automatically by Liquidsoap. This makes the language very safe, while
remaining very easy to use. For curious people reading French, the algorithm and
the associated theory are described in a publication [@baelde2008webradio].

Incidentally, apart from the usual type information which can be found in many
languages, Liquidsoap also uses typing to check the coherence of parameters
which are specific to streaming. For instance, the number of audio channels of
streams is also present in their type, and it ensures that operators always get
the right number of channels.

### Functional programming

The language is _functional_, which means that you can very easily define
functions, and that functions can be passed as arguments of other
functions. This might look like a crazy thing at first, but it is actually quite
common in some language communities (such as OCaml). It also might look quite
useless: why should we need such functions when describing webradios? You will
soon discover that it happens to be quite convenient in many places: for
handlers (we can specify the function which describes what to do when some event
occurs such as when a DJ connects to the radio), for transitions (we pass a
function which describes the shape we want for the transition) and so on.

### Streams

The unique feature of Liquidsoap is that it allows the manipulation of _sources_
which are functions which will generate streams. These streams typically consist
of stereo audio data, but we do restrict to this: they can contain audio with
arbitrary number of channels, they can also contain an arbitrary number of video
channels, and also MIDI channels (there is limited support for sound synthesis).

### Execution model

When running a Liquidsoap program, the compiler goes through these four phases:

1. _lexical analysis_ and _parsing_: Liquidsoap ingests your program and ensures
   that its syntax follows the rules,
2. _type inference_ and _type checking_: Liquidsoap checks that your program
   does not contain basic errors and that types are correct,
3. _compilation_ of the program: this produces a new program which will generate
   the stream (a _stream generator_),
4. _instantiation_: the sources are created and checked to be infallible where
   required,
5. _execution_: we run the stream generator to actually produce audio.

The two last phases can be resumed by the following fact: Liquidsoap is a
_stream generator generator_, it generates stream generators (sic).

In order to illustrate this fact, consider the following script (don't worry if
you don't understand all the details for now, it uses concepts which will be
detailed below):

```{.liquidsoap include="liq/chord.liq" from=1}
```

Let us explain how this script should be thought of as a way of describing how
to generate a stream generator. In order to construct the stream generator,
Liquidsoap will execute the function `list.map`{.liquidsoap} which will produce
the list obtained by applying the function `note`{.liquidsoap} on each element
of the list and, in turn, this function will be replaced by its definition,
which consists of a `sine` generator. The execution of the script will act as if
Liquidsoap successively replaced the second line by

```{.liquidsoap}
s = add([note(0.), note(3.), note(7.)])
```

and then by

```{.liquidsoap}
s = add([sine(440. * pow(2., 0. / 12.)),
         sine(440. * pow(2., 3. / 12.)),
         sine(440. * pow(2., 7. / 12.))])
```

and finally by

```{.liquidsoap}
s = add([sine(440.), sine(523.25), sine(659.26)])
```

which is the actual stream generator. We see that running the script has
generated the three `sine` stream generators!

### Standard library

\index{standard library}

Although the core of Liquidsoap is written in OCaml, many of the functions of
Liquidsoap are written in the Liquidsoap language itself. Those are defined in
the `stdlib.liq` script, which is loaded by default and includes all the
libraries. You should not be frightened to have a look at the standard library,
it is often useful to better grasp the language, learn design patterns and
tricks, and add functionalities. Its location on your system is indicated in the
variable `configure.libdir` and can be obtained by typing

```
liquidsoap --check "print(configure.libdir)"
```

Writing scripts
---------------

### Choosing an editor

Scripts in Liquidsoap can be written in any text editor\index{editor}, but
things are more convenient if there is some specific support. We have developed
a mode for the Emacs editor which adds syntax coloration and indentation when
editing Liquidsoap files. User-contributed support for Liquidsoap is also
available for popular editors such as [Visual Studio
Code](https://github.com/vittee/vscode-liquidsoap) or
[vim](https://github.com/mcfiredrill/vim-liquidsoap).

### Documentation of operators

When writing scripts you will often need details about a particular operator and
its arguments. We recall from [earlier](#sec:sound-sine) that the
documentation\index{documentation} of an operator `operator`, including its type
and a description of its arguments, can be obtained by typing

```
liquidsoap -h operator
```

This documentation is also available [on the
website](https://liquidsoap.info/doc-dev/reference.html).

### Interactive mode

In order to test the functions that will be introduced in this section, it can
be convenient to use the _interactive mode_\index{interactive mode} of
Liquidsoap which can be used to type small expressions and immediately see their
result. This interactive mode is rarely used in practice, but is useful to learn
the language and do small experiments. It can be started with

```
liquidsoap --interactive
```

It will display a "`#`", meaning it is waiting for expressions, which are
programs in the language. They have to be ended by "`;;`" in order to indicate
that Liquidsoap should evaluate them. For instance, if we type

```{.liquidsoap}
name = "Sam";;
```

it answers

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
is `int` and that it evaluates to 6). Also, variables can be reused: if we type

```{.liquidsoap}
print("Hello #{name} and welcome!");;
```

it will answer

```
Hello Sam and welcome!
- : unit = ()
```

The command `print`{.liquidsoap} was evaluated and displays its argument and
then the result is shown, in the same format as above: `-` means that we did not
define a variable, the type of the result is `unit` and its value is `()`. The
meaning of these is detailed below. In the following, all examples starting by
`#` indicate that they are being entered in the interactive mode.

### Inferred types

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

meaning that `x` is a floating point number and `f` is a function taking an
integer as argument and returning an integer.

Basic values {#sec:basic-values}
------------

We begin by describing the values one usually manipulates in Liquidsoap.

### Integers and floats

The _integers_\index{integer}, such as `3` or `42`, are of type
`int`\indexop{int}. Depending on the current architecture of the
computer on which we are executing the script (32 or 64 bits, the latter being
the most common nowadays) they are stored on 31 or 63 bits. The minimal
(resp. maximal) representable integer can be obtained as the constant
`min_int`
(resp. `max_int`); typically, on a 64 bits
architecture, they range from -4611686018427387904 to 4611686018427387903.

The _floating point numbers_, such as `2.45`, are of type
`float`\indexop{float}, and are in double precision, meaning that
they are always stored on 64 bits. We always write a decimal point in them,
so that `3` and `3.` are not the same thing: the former is an integer and the
latter is a float. This is a source of errors for beginners, but is necessary for
typing to work well. For instance, if we try to execute a program containing the
instruction

```{.liquidsoap include="liq/bad/sine.liq" from=0 to=0}
```

it will raise the error

```
At line 1, char 9:
Error 5: this value has type int but it should be a subtype of float
```

which means that the sine function expects a float as argument, but an integer
is provided. The fix here obviously consists in replacing "`500`" by "`500.`"
(beware of the dot).

The usual arithmetic operations are available (`+`, `-`, `*`, `/`), and work for
both integers and floats. For floats, traditional arithmetic functions are
available such as `sqrt` (square root), `exp` (exponential), `sin` (sine), `cos`
(cosine) and so on. Random integers and floats can be generated with the
`random.int`\index{random} and `random.float` functions.

### Strings

Strings\index{string} are written between double or single quotes,
e.g. `"hello!"` or `'hello!'`, and are of type `string`.

The function to output strings on the standard output is `print`\indexop{print}, as
in

```liquidsoap
print("Hello, world!")
```

Incidentally, this function can also be used to display values of any type, so
that

```liquidsoap
print(3+2)
```

will display `5`, as expected. In practice, one rarely does use this functions,
which displays on the standard output, but rather the logging\index{log} functions
`log.critical`, `log.severe`, `log.important`, `log.info` and `log.debug` which
write strings of various importance in the logs, so that it is easier to keep
track of them: they are timestamped, they can easily be stored in files, etc.

In order to write the character "`"`" in a string, one cannot simply type "`"`"
since this is already used to indicate the boundaries of a string: this
character should be _escaped_\index{escaping}\index{string!escaping}, which
means that the character "`\`" should be typed first so that

```{.liquidsoap include="liq/string1.liq"}
```

will actually display "`My name is "Sam"!`". Other commonly used escaped
characters are "`\\`" for backslash and "`\n`" for new line. Alternatively, one
can use the single quote notation, so that previous example can also be written
as

```{.liquidsoap include="liq/string2.liq"}
```

This is most often used when testing JSON data which can contain many quotes or for
command line arguments when calling external scripts. The character "`\`" can also
be used at the end of the string to break long strings in scripts without
actually inserting newlines in the strings. For instance, the script

```{.liquidsoap include="liq/string3.liq"}
```

will actually print

```
His name is Romain.
```

Note that there is no line change between "is" and "Romain", and the indentation
before "Romain" is not shown either.

The concatenation of two strings is achieved by the infix operator "`^`", as in

```liquidsoap
user = "dj"
print("Current user is " ^ user)
```

Instead of using concatenation, it is often rather convenient to use _string
interpolation_\index{string!interpolation}: in a string, `#{e}` is replaced by the string representation of
the result of the evaluation of the expression `e`:
<!--
\SM{there is another kind of string interpolation but I don't think that anybody ever used that in practice}
-->

```liquidsoap
user = "admin"
print("The user #{user} has just logged.")
```

will print `The user admin has just logged.` or

```liquidsoap
print("The number #{random.float()} is random.")
```

will print `The number 0.663455738438 is random.` (at least it did last time I
tried).

The string representation of any value in Liquidsoap can be obtained using the
function `string`\indexop{string}, e.g. `string(5)`{.liquidsoap} is `"5"`. Some
other useful string-related function are

- `string.length`: compute the length of a string
  ```
  # string.length("abc");;
  - : int = 3
  ```
- `string.sub`: extract a substring
  ```
  # string.sub("hello world!", start=6, length=5);;
  - : string = "world"
  ```
- `string.split`\indexop{string.split}: split a string on a given character
  ```
  # string.split(separator=":", "a:42:hello");;
  - : [string] = ["a", "42", "hello"]
  ```
- `string.contains`: test whether a string contains (or begins or ends with) a
  particular substring,
- `string.quote`: escape shell special characters (you should always use this
  when passing strings to external programs).

Finally, some functions operate on _regular expressions_\index{regular expression}, which describe some
shapes for strings:

- `string.match`: test whether a string matches a regular expression,
- `string.replace`: replace substrings matching a regular expression.

A regular expression `R` or `S` is itself a string where some characters have a
particular meaning:

- `.` means "any character",
- `R*` means "any number of times something of the form `R`",
- `R|S` means "something of the form `R` or of the for `S`",

other characters represent themselves (and special characters such as `.`, `*`
or `.` have to be escaped, which means that `\.` represents the character
`.`). An example is worth a thousand words: we can test whether a string `fname`
corresponds to the name of an image file with

```{.liquidsoap include="liq/string.match.liq" from=2 to=-1}
```

Namely, this function will test if `fname` matches the regular expression
`.*\.png|.*\.jpg` which means "any number of any character followed by `.png` or
any number of any character followed by `.jpg`".

### Booleans

The _booleans_\index{boolean} are either `true`{.liquidsoap}\indexop{true} or
`false`{.liquidsoap}\indexop{false} and are of type `bool`\indexop{bool}. They can be combined
using the usual boolean operations

- `and`\indexop{and}: conjunction,
- `or`\indexop{or}: disjunction,
- `not`\indexop{not}: negation.

Booleans typically originate from comparison operators, which take two values
and return booleans:

- `==`\indexop{==}: compares for equality,
- `!=`\indexop{!=}: compares for inequality,
- `<=`: compares for inequality,

and so on (`<`, `>=`, `>`). For instance, the following is a boolean expression:

```liquidsoap
(n < 3) and not (s == "hello")
```

The time predicates such as `10h-15h` are also booleans, which are true or false
depending on the current time, see [there](#sec:time-predicates).

_Conditional branchings_\indexop{if} execute code depending on whether a condition is true
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
second branch returns an integer, and the two should be of same nature. The
`else` branch is optional, in which case the `then` branch should be of type
`unit`:

```liquidsoap
if x == "admin" then print("Welcome admin") end
```

In the case where you want to perform a conditional branching in the
`else`{.liquidsoap} branch, the `elsif`{.liquidsoap} keyword should be used, as
in the following example, which assigns 0, 1, 2 or 3 to `s` depending on whether
`x` is `"a"`, `"b"`, `"c"` or something else:

```{.liquidsoap include="liq/elsif.liq" from=1 to=-1}
```

This is equivalent (but shorter to write) to the following sequence of
imbricated conditional branchings:

```{.liquidsoap include="liq/elseif.liq" from=1 to=-1}
```

Finally, we should mention that the notation `c?a:b` is also available as a
shorthand for `if c then a else b end`{.liquidsoap}, so that the expression

```{.liquidsoap include="liq/cond2.liq" from=1 to=1}
```

can be shortened to

```{.liquidsoap include="liq/cond3.liq" from=1 to=1}
```

(and people will think that you are a cool guy).

### Unit {#sec:unit}

Some functions, such as `print`, do not return a meaningful value: we are
interested in what they are doing (e.g. printing on the standard output) and not
in their result. However, since typing requires that everything returns
something of some type, there is a particular type for the return of such
functions: `unit`\indexop{unit}. Just as there are only two values in the booleans (`true` and
`false`), there is only one value in the unit type, which is written `()`. This
value can be thought of as the result of the expression saying "I'm done".

In _sequences_ of instructions, all the instructions but the last should be of
type unit. For instance, the following function is fine:

```{.liquidsoap include="liq/fun1.liq"}
```

This is a function printing "hello" and then returning 5, see
[below](#sec:functions) for details about functions. Sequences of instructions
are delimited by newlines, but can also be separated by `;` in order to have
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
first kind is _lists_\index{list} which are finite sequences of values, being all of the
same type. They are constructed by square bracketing the sequence whose elements
are separated by commas. For instance, the list

```liquidsoap
[1, 4, 5]
```

is a list of three integers (1, 4 and 5), and its type is `[int]`, and the type
of `["A", "B"]`{.liquidsoap} would obviously be `[string]`. Note that a list can
be empty: `[]`. The function `list.hd` returns the _head_ of the list, that is its
first element:

```
# list.hd([1, 4, 5]);;
- : int = 1
```

This function also takes an optional argument `default` which is the value which
is returned on the empty list, which does not have a first element:

```
# list.hd(default=0, []);;
- : int = 0
```

Similarly, the `list.tl` function returns the _tail_ of the list, i.e. the list
without its first element (by convention, the tail of the empty list is the
empty list). Other useful functions are

- `list.add`: add an element at the top of the list
  ```
  # list.add(5, [1, 3]);;
  - : [int] = [5, 1, 3]
  ```
- `list.length`: compute the length of a list
  ```
  # list.length([5, 1, 3]);;
  - : int = 3
  ```
- `list.mem`: check whether an element belongs to a list
  ```
  # list.mem(2, [1, 2, 3]);;
  - : bool = true
  ```
- `list.map`: apply a function to all the elements of a list
  ```
  # list.map(fun(n) -> 2*n, [1, 3, 5]);;
  - : [int] = [2, 6, 10]
  ```
- `list.iter`: execute a function on all the elements of a list
  ```
  # list.iter(fun(n) -> print(newline=false, n), [1, 3, 5]);;
  135- : unit = ()
  ```
- `list.nth`: return the n-th element of a list
  ```
  # list.nth([5, 1, 3], 2);;
  - : int = 3
  ```
  (note that the first element is the one at index n=0).
  
- `list.append`: construct a list by taking the elements of the first list and
  then those of the second list
  ```
  # list.append([1, 3], [2, 4, 5]);;
  - : [int] = [1, 3, 2, 4, 5]
  ```

<!--
\SM{explain splats}

```
let [x, _, z, ...t] = [1,2,3,4]
x : int = 1
z : int = 3
t : [int] = [4]

x = [1, ...[2, 3, 4], 5, ...[6, 7]]
x : [int] = [1, 2, 3, 4, 5, 6, 7]
```
-->
  
### Tuples

Another construction present in Liquidsoap is _tuples_\index{tuple} of values, which are
finite sequences of values which, contrarily to lists, might have different
types. For instance,

```{.liquidsoap}
(3, 4.2, "hello")
```

is a triple (a tuple with three elements) of type

```
int * float * string
```

which indicate that the first element is an integer, the second a float and the
third a string. In particular, a _pair_\index{pair} is a tuple with two elements. For those,
the first and second element can be retrieved with the functions `fst`\indexop{fst} and
`snd`\indexop{snd}:

```
# p = (3, "a");;
p : int * string = (3, "a")
# fst(p);;
- : int = 3
# snd(p);;
- : string = "a"
```

For general tuples, there is a special syntax in order to access
their elements. For instance, if `t` is the above tuple `(3, 4.2,
"hello")`{.liquidsoap}, we can write

```liquidsoap
let (n, x, s) = t
```

which will assign the first element to the variable `n`, the second element to
the variable `x` and the third element to the variable `s`:

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

### Association lists {#sec:association-list}

A quite useful combination of the two previous data structures is _association
lists_\index{association list}\index{list!association}, which are lists of pairs. Those can be thought of as some kind of
dictionary: each pair is an entry whose first component is its key and second
component is its value. These are the way metadata\index{metadata} are represented for instance:
they are lists of pairs of strings, the first string being the name of the
metadata, and the second its value. For instance, a metadata would be the
association list

```liquidsoap
m = [("artist", "Frank Sinatra"), ("title", "Fly me to the moon")]
```

indicating that the artist of the song is "Frank Sinatra" and the title is "Fly
me to the moon". For such an association list, one can obtain the value
associated to a given key using the `list.assoc` function:

```liquidsoap
list.assoc("title", m)
```

will return `"Fly me to the moon"`, i.e. the value associated to
`"title"`. Since this is so useful, we have a special notation for the above
function, and it is equivalent to write

```liquidsoap
m["title"]
```

to obtain the `"title"` metadata. Other useful functions are

- `list.assoc.mem`: determine whether there is an entry with a given key,
- `list.assoc.remove`: remove all entries with given key.

Apart from metadata, association lists are also used to store http headers
(e.g. in `http.get`).

In passing, you should note the importance of parenthesis when defining
pairs. For instance

```liquidsoap
["a", "b"]
```

is a list of strings, whereas

```liquidsoap
[("a", "b")]
```

is a list of pairs of strings, i.e. an association list.

Programming primitives
----------------------

### Variables

We have already seen many examples of uses of _variables_\index{variable}: we use

```liquidsoap
x = e
```

in order to assign the result of evaluating an expression `e` to a
variable `x`, which can later on be referred to as `x`. Variables can be masked:
we can define two variables with the same name, and at any point in the program the
last defined value for the variable is used:

```{.liquidsoap include="liq/masking.liq"}
```

will print `3` and `5`. Contrarily to most languages, the value for a variable
cannot be changed (unless we explicitly require this by using references, see
below), so the above program does not modify the value of `n`, it is simply that
a new `n` is defined.

There is an alternative syntax for declaring variables which is\indexop{def}

```liquidsoap
def x =
  e
end
```

It has the advantage that the expression `e` can spread over multiple lines and
thus consist of multiple expressions, in which case the value of the last one
will be assigned to `x`, see also [next section](#sec:functions). This is
particularly useful to use local variables when defining a value. For instance,
we can assign to `x` the square of sin(2) by

```{.liquidsoap include="liq/def1.liq" to=-1}
```

Note that we first compute sin(2) in a variable `y` and then multiply `y` by
itself, which avoids computing sin(2) twice. Also, the variable `y` is _local_:
it is defined only until the next `end`, so that

```{.liquidsoap include="liq/def2.liq" to=-1}
```

will print `5`: outside the definition of `x`, the definition of `y` one on the
first line is not affected by the local redefinition.

When we define a variable, it is generally to use its value: otherwise, why
bothering defining it? For this reason, Liquidsoap issues a warning when an
_unused_ variable\index{variable!unused} is found, since it is likely to be a bug. For instance, on

```{.liquidsoap include="liq/bad/unused.liq"}
```

Liquidsoap will output

```
Line 1, character 1:
Warning 4: Unused variable n
```

If this situation is really wanted, you should use `ignore`\indexop{ignore} in order to fake a
use of the variable `n` by writing

```liquidsoap
ignore(n)
```

Another possibility is to assign the special variable `_`\indexop{\_}, whose purpose is to
store results which are not going to be used afterwards:

```liquidsoap
_ = 2 + 2
```

### References {#sec:references}

As indicated above, by default, the value of a variable cannot be
changed. However, one can use a _reference_\index{reference} in order to be able to do this.
Those can be seen as memory cells, containing values of a given fixed type,
which can be modified during the execution of the program. They are created with
the `ref`\indexop{ref} function, with the initial value of the cell as argument. For instance,

```{.liquidsoap include="liq/ref1.liq" to=0}
```

declares that `r` is a reference which contains `5` as initial value. Since `5`
is an integer (of type `int`), the type of the reference `r` will be

```
(() -> int).{set : (int) -> unit}
```

It might be difficult for you to read right now (the syntax for curly brackets
will be explained in [functions' section](#sec:functions) and [records'
section](#sec:records) below), but all you need to know is that it indicates
that, on such a reference, two operations are available:

- one can obtain the value of the reference `r` by writing `r()`, for instance

  ```liquidsoap
  x = r() + 4
  ```
  
  declares the variable `x` as being 9 (which is 5+4),
  
- one can change the value of the reference by using the `:=`\indexop{:=}
  keyword, e.g.

  ```liquidsoap
  r := 2
  ```
  
  will assign the value 2 to `r`.

The behavior of references can be illustrated by the following simple
interactive session:

```
# r = ref(5);;
r : (() -> int).{set : (int) -> unit} = <fun>.{set=<fun>}
# r();;
- : int = 5
# r := 2;;
- : unit = ()
# r();;
- : int = 2
```

Note that the type of a reference is fixed: once `r` is declared to be a
reference to an integer, as above, one can only put integers into it, so that
the script

```{.liquidsoap include="liq/bad/ref.liq" from=1}
```

will raise the error

```
Error 5: this value has type string
but it should be a subtype of int
```

which can be explained as follows. On the first line, the declaration `r =
ref(5)`{.liquidsoap} implies that `r` is a reference to an `int` since it
initially contains `5` which is an integer. However, on the second line, we try
to assign a string to `r`, which would only be possible if `r` was a reference
to a string.

### Loops

The usual looping\index{loop} constructions are available in Liquidsoap. The `for`\indexop{for} loop
repeatedly executes a portion of code with an integer variable varying between
two bounds, being increased by one each time. For instance, the following code
will print the integers `1`, `2`, `3`, `4` and `5`, which are the values
successively taken by the variable `i`:

```{.liquidsoap include="liq/for-print.liq"}
```

In practice, such loops could be used to add a bunch of numbered files
(e.g. `music1.mp3`, `music2.mp3`, `music3.mp3`, etc.) in a request queue for
instance.

The `while`\indexop{while} loop repeatedly executes a portion of code, as long a condition is
satisfied. For instance, the following code doubles the contents of the
reference `n` as long as its value is below `10`:

```{.liquidsoap include="liq/while-sum.liq"}
```

The variable `n` will thus successively take the values `1`, `2`, `4`, `8` and
`16`, at which point the looping condition `n() < 10` is not satisfied anymore
and the loop is exited. The printed value is thus `16`.

Functions {#sec:functions}
---------

Liquidsoap is built around the notion of function\index{function}: most operations are performed
by those. For some reason, we sometimes call _operators_\index{operator} the functions acting on
sources. Liquidsoap includes a standard library which consists of functions
defined in the Liquidsoap language, including fairly complex operators such as
`playlist` which plays a playlist or `crossfade` which takes care of fading
between songs.

### Basics

A function is a construction which takes a bunch of arguments and produces a
result. For instance, we can define a function `f` taking two float arguments,
prints the first and returns the result of adding twice the first to the second:\indexop{def}

```{.liquidsoap include="liq/fun4.liq"}
```

This function can also be written on one line if we use semicolons (`;`) to
separate the instructions instead of changing line:

```{.liquidsoap include="liq/fun5.liq"}
```

The type of this function is

```
(int, int) -> int
```

The arrow `->`\indexop{->} means that it is a function, on the left are the types of the
arguments (here, two arguments of type `int`) and on the right is the type of
the returned value of the function (here, `int`). In order to use this function,
we have to apply it to arguments, as in

```
f (3, 4)
```

This will trigger the evaluation of the function, where the argument `x`
(resp. `y`) is replaced by `3` (resp. `4`), i.e., it will print `3` and return
the evaluation of `2*3+4`, which is `10`. Of course, generally, there is no
reason why all arguments and the result should have the same type as in the
above example, for instance:

```
# def f(s, x) = string.length(s) + int_of_float(x) end;;
f : (string, float) -> int = <fun>
```

As explained earlier, declarations of variables made inside the definition of a
function are _local_: they are only valid within this definition (i.e., until
the next `end`). For instance, in the definition

```{.liquidsoap include="liq/fun6.liq"}
```

the variable `y` is not available after the definition.

### Handlers

A typical use of functions in Liquidsoap is for _handlers_\index{handler}, which are functions
to be called when a particular event occurs, specifying the actions to be taken
when it occurs. For instance, the `source.on_metadata`\indexop{source.on\_metadata} operator allows
registering a handler when metadata occurs in a stream. Its type is

```
(source('a), (([string * string]) -> unit)) -> unit
```

and it thus takes two arguments:

- the source, of type `source('a)`, see [below](#sec:source-type), whose
  metadata are to be watched,
- the handler, which is a function of type

  ```
  ([string * string]) -> unit
  ```

  which takes as argument an association list (of type `[string * string]`)
  encoding the metadata and returns nothing meaningful (`unit`).

When some metadata occur in the source, the handler is called with the metadata
as argument. For instance, we can print the title of every song being played on
our radio (a source named `radio`) with

```{.liquidsoap include="liq/on_meta1.liq" from=2 to=-1}
```

The handler is here the function `handle_metadata`, which prints the field
associated to `"title"` in the association list given in the argument `m`.

Other useful operators allow the registration of handlers for the following
situations:

- `blank.detect`: when a source is streaming blank (no sound has been
  streamed for some period of time),
- `source.on_track`: when a new track is played,
- `source.on_end`: when a track is about to end,
- `on_start` and `on_shutdown`: when Liquidsoap is starting or stopping.

Many other operators also take more specific handlers as arguments. For
instance, the operator `input.harbor`, which allows users to connect to a
Liquidsoap instance and send streams, has `on_connect` and `on_disconnect`
arguments which allow the registration of handlers for the connection and
disconnection of users.

### Anonymous functions

For concision in scripts, it is possible define a function\indexop{fun}\indexop{->} without giving it a
name, using the syntax

```liquidsoap
fun (x) -> ...
```

This is called an _anonymous function_\index{function!anonymous}, and it is typically used in order to
specify short handlers in arguments. For instance, the above example for
printing the title in metadatas could equivalently be rewritten as

```{.liquidsoap include="liq/on_meta2.liq" from=2 to=-1}
```

where we define the function directly in the argument.

As a side note, this means that a definition of a function of the form

```liquidsoap
def f(x) =
  ...
end
```

could equivalently be written

```liquidsoap
f = fun (x) -> ...
```

<!--
Also, of course, the `fun`{.liquidsoap} syntax also supports labeled arguments
and default values as expected.
-->

When using this syntax, on the right hand of `->` Liquidsoap expects exactly one
expression. If you intend to use multiple ones (for instance, in order to
perform a sequence of actions), you can use the `begin ... end`{.liquidsoap}\indexop{begin}
syntax, which allows grouping multiple expressions as one. For instance,

```{.liquidsoap include="liq/on_meta3.liq" from=2 to=-1}
```

<!--
#### Anonymous function with no arguments

You will see that it is quite common to use anonymous functions with no
arguments. For this reason, we have introduced a special convenient syntax for
those and allow writing

```liquidsoap
{...}
```

instead of

```liquidsoap
fun () -> ...
```
-->

### Labeled arguments

\index{argument!labeled}

A function can have an arbitrary number of arguments, and when there are many of them it
becomes difficult to keep track of their order and their order matter! For
instance, the following function computes the sample rate given a number of
samples in a given period of time:

```{.liquidsoap include="liq/samplerate1.liq" from=0 to=0}
```

which is of type

```
(float, float) -> float
```

For instance, if you have 110250 samples over 2.5 seconds the samplerate will be
`samplerate(110250., 2.5)`{.liquidsoap} which is 44100. However, if you mix the
order of the arguments and type `samplerate(2.5, 110250.)`{.liquidsoap}, you
will get quite a different result (2.27×10^-5^) and this will not be detected by
the typing system because both arguments have the same type. Fortunately, we can
give _labels_ to arguments in order to prevent this, which forces explicitly
naming the arguments. This is indicated by prefixing the arguments with a tilde
"`~`":

```{.liquidsoap include="liq/samplerate2.liq" from=0 to=0}
```

The labels will be indicated as follows in the type:

```
(samples : float, duration : float) -> float
```

Namely, in the above type, we read that the argument labeled `samples` is a
float and similarly for the one labeled `duration`. For those arguments, we have
to give the name of the argument when calling the function:

```liquidsoap
samplerate(samples=110250., duration=2.5)
```

The nice byproduct is that the order of the arguments does not matter anymore, the
following will give the same result:

```liquidsoap
samplerate(duration=2.5, samples=110250.)
```
Of course, a function can have both labeled and non-labeled arguments.

### Optional arguments

Another useful feature is that we can give _default values_ to arguments, which
thus become _optional_\index{argument!optional}: if, when calling the function, a value is not specified
for such arguments, the default value will be used. For instance, if for some
reason we tend to generally measure samples over a period of 2.5 seconds, we can
make this become the value for the `duration` parameter:

```{.liquidsoap include="liq/samplerate3.liq" from=0 to=0}
```

In this way, if we do not specify a value for the duration, its value will
implicitly be assumed to be 2.5, so that the expression:

```liquidsoap
samplerate(samples=110250.)
```

will still evaluate to 44100. Of course, if we want to use another value for the
duration, we can still specify it, in which case the default value will be
ignored:

```liquidsoap
samplerate(samples=132300., duration=3.)
```

The presence of an optional argument is indicated in the type by prefixing the
corresponding label with "`?`"\indexop{?}, so that the type of the above function is

```
(samples : float, ?duration : float) -> float
```

<!--- \TODO{explain that non-optional arguments can have default values too} -->

#### Actual examples

As a more concrete example of labeled arguments, we can see that the
type of the operator `output.youtube.live`, which outputs a video stream to
YouTube\index{YouTube}, is

```
(?id : string, ?video_bitrate : int, ?audio_encoder : string, ?audio_bitrate : int, ?url : string, key : string, source) -> source
```

(we have only slightly simplified the type `source`, which will only be detailed
in [a next section](#sec:source-type)). Even if we have not read the
documentation of this function, we can still guess what it is doing:

- there are 5 optional arguments that we should be able to ignore because they
  have reasonable default values (although we can guess the use of most of them
  from the label, e.g. `video_bitrate` should specify the bitrate we want to
  encode video, etc.),
- there is 1 mandatory argument which is labeled `key` of type `string`: it must
  be the secret key we need in order to broadcast on our YouTube account,
- there is 1 mandatory argument, unlabeled, of type `source`: this is clearly
  the source that we are going to broadcast to YouTube.
  
As we can see the types and labels of arguments already provide us with much
information about the functions and prevent many mistakes.

If you want a more full-fledged example, have a look at the type of
`output.icecast`:

```
(?id : string, ?chunked : bool, ?connection_timeout : float, ?description : string, ?dumpfile : string, ?encoding : string, ?fallible : bool, ?format : string, ?genre : string, ?headers : [string * string], ?host : string, ?icy_id : int, ?icy_metadata : string, ?mount : string, ?name : string, ?on_connect : (() -> unit), ?on_disconnect : (() -> unit), ?on_error : ((string) -> float), ?on_start : (() -> unit), ?on_stop : (() -> unit), ?password : string, ?port : int, ?protocol : string, ?public : bool, ?start : bool, ?timeout : float, ?url : string, ?user : string, ?verb : string, format('a), source) -> source
```

Although the function has 31 arguments, it is still usable because most of them
are optional so that they are not usually specified. In passing, we recognize
some of the concepts introduced earlier: the headers (`header` parameter) are
coded as an association list, and there are quite few handlers (`on_connect`,
`on_disconnect`, etc.).

### Polymorphism

Some functions can operate on values of many possible types. For instance, the
function `list.tl`\indexop{list.tl}, which returns the tail of the list (the list without its
first element), works on lists of integers so that it can have the type

```
([int]) -> [int]
```

but it also works on lists of strings so that it can also have the type

```
([string]) -> [string]
```

and so on. In fact, this would work for any type, which is why in Liquidsoap the
function `list.tl` is actually given the type

```
(['a]) -> ['a]
```

which means: "for whichever type you replace `'a` with, the resulting type is a
valid type for the function". Such a function is called _polymorphic_\index{polymorphism}, in the
sense that it can be given multiple types: here, `'a` is not a type but rather a
"meta-type" (the proper terminology is a _type variable_) which can be replaced
by any regular type. Similarly, the empty list `[]` is of type `['a]`: it is a
valid list of whatever type. More interestingly, the function `fst` which returns the
first element of a pair has the type

```
('a * 'b) -> 'a
```

which means that it takes as argument a pair of a something (`'a`) and a
something else (`'b`) and returns a something (`'a`). For instance, the type

```
(string * int) -> string
```

is valid for `fst`. In general, a type can involve an arbitrary number of type
variables which are labeled `'a`, `'b`, `'c` and so on.

#### Constraints

In Liquidsoap, some type variables can also be constrained so that they cannot
be replaced by any type, but only specific types. A typical example is the
multiplication function `*`, which operates on both integers and floats, and can therefore
be given both the types

```
(int, int) -> int
```

and

```
(float, float) -> float
```

but not the type

```
(string, string) -> string
```

If you have a look at the type of `*` in Liquidsoap, it is

```
('a, 'a) -> 'a where 'a is a number type
```

which means that it has type `('a, 'a) -> 'a` where `'a` can only be replaced by
a type that represents a number (i.e., `int` or `float`). Similarly, the
comparison function `<=` has type

```
('a, 'a) -> bool where 'a is an orderable type
```

which means that it has the type `('a, 'a) -> bool` for any type `'a` on which
there is a canonical order (which is the case of all usual types, excepting for
function types and source types).

### Getters {#sec:getters}

We often want to be able to dynamically modify some parameters in a script. For
instance, consider the operator `amplify`\indexop{amplify}, which takes a float and an audio
source and returns the audio amplified by the given volume factor: we can expect
its type to be

```
(float, source('a)) -> source('a)
```

so that we can use it to have a radio consisting of a microphone input amplified
by a factor 1.2 by

```liquidsoap
mic   = input.alsa()
radio = amplify(1.2, mic)
```

In the above example, the volume 1.2 was supposedly chosen because the sound
delivered by the microphone is not loud enough, but this loudness can vary from
time to time, depending on the speaker for instance, and we would like to be
able to dynamically update it. The problem with the current operator is that the
volume is of type `float` and a float cannot change over time: it has a fixed
value.

In order for the volume to have the possibility to vary over time, instead of
having a `float` argument for `amplify`, we have decided to have instead an
argument of type

```
() -> float
```

This is a function which takes no argument and returns a float (remember that a
function can take an arbitrary number of arguments, which includes zero arguments). It is
very close to a float excepting that each time it is called the returned value
can change: we now have the possibility of having something like a float which
varies over time. We like to call such a function a _float getter_\index{getter}, since it can
be seen as some kind of object on which the only operation we can perform is get
the value. For instance, we can define a float getter by

```{.liquidsoap include="liq/getter.liq"}
```

Each time we call `f`, by writing `f()` in our script, the resulting float
will be increased by one compared to the previous one: if we try it in an
interactive session, we obtain

```
# f();;
- : float = 1.0
# f();;
- : float = 2.0
# f();;
- : float = 3.0
```

Since defining such arguments often involves expressions of the form

```liquidsoap
fun () -> e
```

which is somewhat heavy, we have introduced the alternative syntax

```liquidsoap
{e}
```

for it. It can be thought of as a variant of the expression `e` which will be
evaluated each time it is used instead of being evaluated once. Its use is
illustrated below.

Finally, we should mention an important fact. Since the value of a reference `r`
can be queried by writing `r()`, any reference can be considered as a getter:
this is the function which, when queried, will return the contents of the
reference!

#### Variations on a volume

The type of `amplify` is thus actually

```
(() -> float, source('a)) -> source('a)
```

and the operator will regularly call the volume function in order to have the
current value for the volume before applying it. To be precise, it is actually
called before each frame, which means roughly every 0.04 second. Let's see how
we can use this in scripts. We can, of course, still apply a constant factor
with

```liquidsoap
def volume () = 1.2 end
radio = amplify(volume, mic)
```

or, using anonymous functions,

```liquidsoap
radio = amplify(fun () -> 1.2, mic)
```

which we generally write, using the alternative syntax,

```liquidsoap
radio = amplify({1.2}, mic)
```

More interestingly, we can use the value of a float reference `v` for
amplification:

```liquidsoap
radio = amplify({v()}, mic)
```

when the value of the reference gets changed, the amplification will get changed
too. Moreover, since any reference can be considered as a getter, as mentioned
above, this can be written in an even simpler way:

```liquidsoap
radio = amplify(v, mic)
```

However, we need to use the above syntax if we want to manipulate the value of
the reference. For instance,

```liquidsoap
radio = amplify({2 * v()}, mic)
```

will amplify by twice the value of `v`.

In practice, float getters are often created using `interactive.float`\index{interactive variable}\index{variable!interactive} which
creates a float value which can be modified on the telnet server (this is an
internal server provided by Liquidsoap on which other applications can connect
to interact with it, as detailed in [a later section](#sec:telnet)), or
`osc.float` which reads a float value from an external controller using the OSC
library. For instance, with the script

```{.liquidsoap include="liq/interactive-float1.liq" from=1 to=-1}
```

the volume can be modified by issuing the telnet command

```
var.set volume = 0.5
```

You should remember that getters are regular functions. For instance, if we
expect that the volume on telnet to be expressed in decibels, we can convert it
to an actual amplification coefficient as follows:

```{.liquidsoap include="liq/interactive-float2.liq" from=1 to=-1}
```

<!--
There are some useful functions in Liquidsoap in order to create getters. The
first one is `ref.getter`, whose type is

```
(ref('a)) -> () -> 'a
```

and creates a 
-->

As a more elaborate variation on this, let's program a fade in: the volume
progressively increases from 0 to 1 in `fade_duration` seconds (here, 5
seconds). We recall that the volume function will be called before each frame,
which is a buffer whose duration is called here `frame_duration` and can be
obtained by querying the appropriate configuration parameter: in order to have
the volume raise from 0 to 1, we should increase it by `frame_duration /
fade_duration` at each call. If you execute the following script, you should
thus hear a sine which is getting louder and louder during the 5 first seconds:

```{.liquidsoap include="liq/getter-fade-in.liq" from=1}
```

Of course, this is for educational purposes only, and the actual way one would
usually perform a fade in Liquidsoap is detailed in [an ulterior
section](#sec:transitions).

Let us give another advanced example, which uses many of the above
constructions. The standard library defines a function
`metadata.getter.float`\index{metadata!getter}, whose type is

```
(float, string, source('a)) -> source('a) * (() -> float)
```

which creates a float getter with given initial value (the first argument),
which can be updated by reading a given metadata (the second argument) on a
given source (the third argument). Its code is

```{.liquidsoap include="liq/metadata-getter.liq"}
```

You can see that it create a reference `x`, which contains the current value,
and registers a handler for metadata, which updates the value when the metadata
is present, i.e. `m[metadata]` is different from the empty string `""`, which is
the default value. Given a `radio` source which contains metadata labeled
"`liq_amplify`", we can actually change the volume of the source according to the
metadata with

```{.liquidsoap include="liq/metadata-getter-ex.liq" from=2 to=-1}
```

<!--
If you are still afraid of the above code, you should be pleased to know that
the `amplify` operator is actually doing this by default (and the name of the
metadata can be changed with the optional parameter `override` that we have not
mentioned up to now).
-->

#### Constant or function

Finally, in order to simplify things a bit, you will see that the type of
amplify is actually

```
({float}, source('a)) -> source('a)
```

where the type `{float}` means that both `float` and `() -> float` are accepted,
so that you can still write constant floats where float getters are
expected. What we actually call a _getter_ is generally an element of such a
type, which is either a constant or a function with no argument.

In order to work with such types, the standard library often uses the following
functions:

- `getter`, of type `({'a}) -> {'a}`, creates a getter,
- `getter.get`, of type `({'a}) -> 'a`, retrieves the current value of a getter,
- `getter.function`, of type `({'a}) -> () -> 'a`, creates a function from a
  getter.

### Recursive functions

Liquidsoap supports functions which are _recursive_\index{recursive function}\index{function!recursive}, i.e., that can call
themselves. For instance, in mathematics, the factorial\index{factorial} function on natural
numbers is defined as fact(n)=1×2×3×...×n, but it can also be defined
recursively as the function such that fact(0)=1 and fact(n)=n×fact(n-1) when
n>0: you can easily check by hand that the two functions agree on small values
of n (and prove that they agree on all values of n). This last formulation has
the advantage of immediately translating to the following implementation of
factorial:

```{.liquidsoap include="liq/fact.liq"}
```

for which you can check that `fact(5)` gives 120, the expected result. As
another example, the `list.length` function, which computes the length of a
list, can be programmed in the following way in Liquidsoap:

```{.liquidsoap include="liq/list.length.liq"}
```

We do not detail much further this trait since it is unlikely to be used for
radios, but you can see a few occurrences of it in the standard library.

<!---
\TODO{give the example of some functions on lists instead of loops which are not implemented like this anymore} Of course
you are not here to compute factorials, but recursive functions are most useful
to implement what you would implement using _for_ or _while_ loops in
traditional languages: this is why those constructions are not available as
primitive constructions in Liquidsoap. For instance, the for loop is implemented
in the standard library as

```{.liquidsoap include="liq/for-loop.liq" to=-1}
```

This function successively calls the function `f` given as last argument, with
integers ranging from `first` to `last`. It thus implements, what you would
write as

```
for (i = first; i <= last; i++) {
  f(i);
}
```

in languages such as C or Java. As an illustration of its use, the program

```{.liquidsoap include="liq/for-loop.liq" from=-1}
```

will print

```
This is number 0.
This is number 1.
This is number 2.
This is number 3.
This is number 4.
```

In practice, such loops could be used to add a bunch of numbered files
(e.g. `music1.mp3`, `music2.mp3`, `music3.mp3`, etc.) in a request queue for
instance. A `while` function is implemented similarly for your
convenience. However, keep in mind that some functions are simpler to express
directly as recursive functions than by using `for` or `while`, although it
might take some time for you to get accustomed to those.
-->

<!--
### Partial evaluation

The final thing to know about functions in Liquidsoap is that they support
_partial evaluation_\index{function!partial evaluation} of functions. This means that if you call a function, but
do not provide all the arguments, it will return a new function expecting only
the remaining arguments. For instance, consider the multiplication function

```{.liquidsoap include="liq/mul.liq"}
```

which is of type

```
(float, float) -> float
```

taking two floats and returning their products. We can then define a function
which will compute the double of its input by

```liquidsoap
double = mul(2.)
```

which is of type

```
(float) -> float
```

Since we have provided only the first argument to `mul`, the `double` will
define is still a function waiting for a second argument `x` and returning
`mul(2., x)`, as we can see in the interactive mode:

```
# def mul(x, y) = x * y end;;
mul : (float, float) -> float = <fun>
# double = mul(2.);;
double : (float) -> float = <fun>
# double(5.);;
- : float = 10.0
```

A typical use of this is when providing arguments which are functions. For
instance, if we want to print all the elements of a list without new lines
between them, we can do

```{.liquidsoap include="liq/list-print1.liq" from=1}
```

Here, the function `print`\indexop{print} is of type

```
(?newline : bool, 'a) -> unit
```

and we only provide one argument (the one labeled `newline`) out of two. Without
partial evaluation, we would have had to write

```{.liquidsoap include="liq/list-print2.liq"}
```

which is somewhat more heavy.

-->

<!-- this is a source of errors (e.g. `list.hd([1,2,3])`) which are however
 easily detected by typing -->

Records and modules {#sec:records}
-------------------

### Records

Suppose that we want to store and manipulate structured data. For instance, a
list of songs together with their duration and tempo. One way to store each song
is as a tuple of type `string * float * float`, but there is a risk of confusion
between the duration and the length which are both floats, and the situation
would of course be worse if there were more fields. In order to overcome this,
one can use a _record_\index{record} which is basically the same as a tuple, excepting that
fields are named. In our case, we can store a song as

```{.liquidsoap include="liq/record-song.liq" to=-1}
```

which is a record with three fields respectively named `filename`, `duration`
and `bpm`. The type of such a record is

```
{filename : string, duration : float, bpm : float}
```

which indicates the fields and their respective type. In order to access a field
of a record, we can use the syntax `record.field`. For instance, we can print
the duration with

```liquidsoap
print("The duration of the song is #{song.duration} seconds")
```

### Modules

Records are heavily used in Liquidsoap in order to structure the functions of
the standard library. We tend to call _module_\index{module} a record with only functions, but
this is really the same as a record. For instance, all the functions related to
lists are in the `list` module and functions such as `list.hd` are fields of
this record. For this reason, the `def`{.liquidsoap}\indexop{def} construction allows adding
fields in record. For instance, the definition

```{.liquidsoap include="liq/list.last.liq"}
```

adds, in the module `list`, a new field named `last`, which is a function which
computes the last element of a list. Another shorter syntax to perform
definitions consists in using the `let`\indexop{let} keyword which allows assigning a value
to a field, so that the previous example can be rewritten as

```{.liquidsoap include="liq/list.last2.liq"}
```

If you often use the functions of a specific module, the `open`\indexop{open} keyword allows
using its fields without having to prefix them by the module name. For instance,
in the following example

```{.liquidsoap include="liq/list.last3.liq" from=1 to=-1}
```

the `open list` directive allows directly using the functions in this module: we
can simply write `nth` and `length` instead of `list.nth` and `list.length`.

<!-- \TODO{def replaces....} -->

### Values with fields

A unique feature of the Liquidsoap language is that it allows adding fields to
any value. We also call them _methods_\indexop{method} by analogy with object-oriented
programming. For instance, we can write

```{.liquidsoap include="liq/meth-song.liq" from=0 to=0}
```

which defines a string (`"test.mp3"`) with two methods (`duration` and
`bpm`). This value has type

```
string.{duration : float, bpm : float}
```

and behaves like a string, e.g. we can concatenate it with other strings:

```{.liquidsoap include="liq/meth-song.liq" from=1 to=1}
```

but we can also invoke its methods like a record or a module:

```{.liquidsoap include="liq/meth-song.liq" from=2 to=2}
```

The construction `def replaces`{.liquidsoap} allows changing the main value
while keeping the methods unchanged, so that

```{.liquidsoap include="liq/meth-song.liq" from=3 to=4}
```

will print

```
"newfile.mp3".{duration = 123., bpm = 120.}
```

(note that the string is modified but not the fields `duration` and `bpm`).

#### Examples

The `http.get`\indexop{http.get} function, which retrieves a webpage over http, has the type:

```
(?headers : [string * string], ?timeout : float, string) ->
string.{headers : [string * string],
        status_message : string,
        status_code : int,
        protocol_version : string}
```

It returns a string (the contents of the webpage) with fields specifying the
returned headers, the status message and the version used by the protocol. A
typical use is

```{.liquidsoap include="liq/http.get.liq" from=1}
```

Another typical example is the `rms`\index{RMS} operator, which takes a source as argument,
and returns the same source together with an added method named `rms` which
allows retrieving the current value for the RMS (which is a measure of sound
intensity). The RMS of a source can thus be logged every second in a file as
follows (functions concerning files and threads are explained in
[there](#sec:stdlib)):

```{.liquidsoap include="liq/metrics-file2.liq" from=1}
```

When the return type of a function has methods, the help of Liquidsoap displays
them in a dedicated section. For instance, every function returning a source,
also returns methods associated to this source, such as the `skip`\indexop{skip} function
which allows skipping the current track (those methods are detailed in [a
section below](#sec:source-methods)). If we ask for help about the `playlist`
operator by typing

```
$ liquidsoap -h playlist
```

we can observe this: the help displays, among other,

```
Methods:

 * reload : (?uri : string) -> unit
     Reload the playlist.

 * skip : () -> unit
     Skip to the next track.
```

This indicates that the returned source has a `reload` method, which allows
reloading the playlist, possibly specifying a new file, as well as the `skip`
method described above. If you try at home, you will see that they are actually
many more methods.

### References

You should now be able to fully understand the type given to references. We
recall for instance that the type of `ref(5)` is

```
(() -> int).{set : (int) -> unit}
```

This means that such a reference consists of a function of type `() -> int`,
taking no argument and returning an integer (the current value of the
reference), together with a method `set` of type `(int) -> unit`, which takes as
argument an integer (and, when called, modifies the value of the reference
according to the argument). Since a reference `r` can be considered as a
function, this explains why we have been writing `r()` to get its value. In
order to modify its value, say set it to 7, we can call the method `set` and
write `r.set(7)`{.liquidsoap}. In fact, the syntax `r := 7`{.liquidsoap} is
simply a shorthand for this.

Advanced values
---------------

In this section, we detail some more advanced values than the ones presented in
[previous sections](#sec:basic-values). You are not expected to be understanding
those in details for basic uses of Liquidsoap.

### Errors

In the case where a function does not have a sensible result to return, it can raise an
_error_\index{error}. Typically, if we try to take the head of the empty list without
specifying a default value (with the optional parameter `default`), an error will be raised.
By default, this error will stop the script, which is usually not a desirable
behavior. For instance, if you try to run a script containing

```{.liquidsoap include="liq/bad/list.hd-empty.liq" from=1}
```

the program will exit printing

```
Error 14: Uncaught runtime error:
type: not_found, message: "no default value for list.hd"
```

This means that the error named "`not_found`"\indexop{not\_found} was raised, with a message
explaining that the function did not have a reasonable default value of the head
to provide.

In order to avoid this, one can _catch_ exceptions with the syntax

```liquidsoap
try
  code
catch err do
  handler
end
```

This will execute the instructions `code`: if an error is raised at some point
during this, the code `handler` is executed, with `err` being the error. For
instance, instead of writing

```{.liquidsoap include="liq/list.hd-default.liq" to=-1}
```

we could equivalently write

```{.liquidsoap include="liq/list.hd-catch.liq" to=-1}
```

The name and message associated to an error can respectively be retrieved using
the functions `error.kind` and `error.message`, e.g. we can write

```liquidsoap
try
  ...
catch err do
  print("the error #{error.kind(err)} was raised")
  print("the error message is #{error.message(err)}")
end
```

Typically, when reading from or writing to a file, errors will be raised when a
problem occurs (such as reading from a non-existent file or writing a file in a
non-existent directory) and one should always check for those and log the
corresponding message:

```{.liquidsoap include="liq/file.write-bad.liq" from=2}
```

Specific errors can be catched with the syntax

```liquidsoap
try
  ...
catch err in l do
  ...
end
```

where `l` is a list of error names that we want to handle here.

Errors can be raised from Liquidsoap with the function `error.raise`, which
takes as arguments the error to raise and the error message. For instance:

```{.liquidsoap include="liq/bad/error.raise.liq"}
```

Finally, we should mention that all the errors should be declared in advance
with the function `error.register`, which takes as argument the name of the new
error to register:

```{.liquidsoap include="liq/bad/error.register.liq"}
```

### Nullable values

It is sometimes useful to have a default value for a type. In Liquidsoap, there
is a special value for this, which is called `null`\indexop{null}. Given a type `t`, we write
`t?` for the type of values which can be either of type `t` or be `null`: such a
value is said to be _nullable_. For instance, we could redefine the `list.hd`
function in order to return null (instead of raising an error) when the list is
empty:

```{.liquidsoap include="liq/list.hd-null.liq" from=0 to=2}
```

whose type would be

```
(['a]) -> 'a?
```

since it takes as argument a list whose elements are of type `'a` and returns a
list whose elements are `'a` or `null`. As it can be observed above, the null
value is created with `null()`.

In order to use a nullable value, one typically uses the construction `x ?? d`
which is the value `x` excepting when it is null, in which case it is the
default value `d`. For instance, with the above head function:

```{.liquidsoap include="liq/list.hd-null.liq" from=4 to=5}
```

Some other useful functions include

- `null.defined`: test whether a value is null or not,
- `null.get`: obtain the value of a nullable value supposed to be distinct from `null`,
- `null.case`: execute a function or another, depending on whether a value is
  null or not.

<!--
### Iterators

TODO: not including this for now, this is too experimental I feel

An _iterator_ on a type `t` is an element of the type `() -> t?`, i.e., a getter
of nullable `t`: it consists of a function taking no argument which, each time
it is called returns either an element of type `t` or `null`. We can think of
this as encoding a possibly finite enumeration of elements of type `t`: the
function will successively return all the elements, and then `null` when there
are no more elements. Given an iterator `iter`, we can use `for` notation in
order to .............................;

```{.liquidsoap}
for i = iter do
  e
end
```

For instance, the function `file.lines.iterator` constructs an iterator over the
lines of the file

TODO......

see #1252

```{.liquidsoap include="liq/file.iterator.liq" from=1}
```
-->

<!--
```{.liquidsoap include="liq/for-iterator.liq"}
```
-->

Configuration and preprocessor
------------------------------

Liquidsoap has a number of features (such as its preprocessor) which allow
useful operations on the scripts, but cannot really be considered as part of the
core language itself. Those are presented below.

### Configuration {#sec:configuration}

The main configuration\index{configuration} options are accessed through
functions whose name are prefixed by `settings`. These settings affect the
overall behavior of Liquidsoap. Each setting is a reference: this means that,
given a setting, we can obtain its value by applying it to `()` and we can
change its value by using the `:=` syntax. For instance, the samplerate used for
audio in Liquidsoap is controlled by the `settings.frame.audio.samplerate`
setting. We can thus display its current value with

```{.liquidsoap include="liq/samplerate-get-print.liq" from=1}
```

and change its value to 48kHz (the default being 44.1kHz) by adding the
following command at the beginning of our script:

```{.liquidsoap include="liq/set.liq" from=1}
```

Or we can increase the verbosity of the log messages with

```{.liquidsoap include="liq/set2.liq" from=1}
```

which sets the maximum level of shown log messages to 4, the default being 3. We
recall that the log levels are 1 for critical messages, 2 for severe issues, 3
for important messages, 4 for information and 5 for debug messages.

You can obtain the list of all available settings, as well as their default
value with the command

```
liquidsoap --list-settings
```

For instance, the documentation about the `frame.duration` setting is

```
### Tentative frame duration in seconds

Audio samplerate and video frame rate constrain the possible frame
durations.This setting is used as a hint for the duration, when
'frame.audio.size'is not provided.Tweaking frame duration is tricky but
needed when dealing with latencyor getting soundcard I/O correctly
synchronized with liquidsoap.

settings.frame.duration := 0.04
```

The value `0.04` at the bottom indicates the default value.

### Including other files

It is often useful to split your script over multiple files, either because it
has become quite large, or because you want to be able to reuse common functions
between different scripts. You can include a file `file.liq` in a script by
writing

```liquidsoap
%include "file.liq"
```

which will be evaluated as if you had pasted the contents of the file in place
of the command.

For instance, this is useful in order to store passwords out of the main file, in
order to avoid risking leaking those when handing the script to some other
people. Typically, one would have a file `passwords.liq` defining the passwords
in variables, e.g.

```liquidsoap
radio_pass = "secretpassword"
```

and would then use it by including it:

```liquidsoap
%include "passwords.liq"

radio = ...
output.icecast(%mp3, host="localhost", port=8000,
               password=radio_pass, mount="my-radio.mp3", radio)
```

so that passwords are not shown in the main script.

### Conditional execution

Liquidsoap embeds a preprocessor which allows including or not part of the code
depending on some conditions. For instance, the following script will print
something depending on whether the function `input.alsa` is defined or not:

```{.liquidsoap include="liq/ifdef.liq" from=1}
```

This is useful in order to have some code being executed depending on the
compilation options of Liquidsoap (the above code will be run only when
Liquidsoap has the support for the ALSA library) and is used intensively in the
standard library. The command `%ifndef` can similarly be used to execute code
when a function is not defined. We can also execute a portion of code whenever
an encoder is present using `%ifencoder` (or `%ifnencoder` when an encoder is
not present), the end of the code in question being delimited with `%endif` as
above. For instance, suppose that we want to encode a file in mp3, if Liquidsoap
was compiled with support for it, and otherwise default to wave. This can be
achieved with

```{.liquidsoap include="liq/ifencoder.liq" from=2}
```

Finally, the command `%ifversion` can be used to execute some code
conditionally, depending on the version of Liquidsoap:

```{.liquidsoap include="liq/ifversion.liq" from=1}
```

This is quite useful in order to provide a script which is compatible with
multiple versions of Liquidsoap (note that this functionality was only
introduced in version 2.0, and thus unfortunately cannot be used in order to
ensure backward compatibility with versions earlier than this).

Standard functions {#sec:stdlib}
------------------

In this section, we detail some of the most useful general purpose functions
present in the standard library. The functions related to sound and streaming
are mentioned in [next section](#sec:quick-streams) and detailed in subsequent
chapters.

### Type conversion

The string representation of any value can be obtained with the
`string`\indexop{string} function:

```liquidsoap
print(string([1,2,3]))
```

Most expected type conversion function are implemented with names of the form
`A_of_B`. For instance, we can convert a string to an integer with
`int_of_string`:

```liquidsoap
print(1 + int_of_string("2"))
```

### Files

The\index{file} whole contents of a file can be obtained with the function `file.contents`:

```{.liquidsoap include="liq/file.contents.liq"}
```

In the case where the file is big, it is advisable to use `file.read`, whose type is

```
(string) -> () -> string
```

and returns a function which successively reads chunks of the file until the
end, in which case the empty string is returned. The contents of a file can be
dumped using it by

```{.liquidsoap include="liq/file.read.liq"}
```

Other useful functions are

- `file.exists`: test whether a file exists,
- `file.write`: write in a file,
- `file.remove`: remove a file,
- `file.ls`: list the files present in a directory.

Also, convenient functions for working on paths\index{path} are present in the `file` and `path`
module:

- `file.extension`: get the extension of a file,
- `file.temp`: generate a fresh temporary filename,
- `path.dirname`: get the directory of a path,
- `path.basename`: get the file name without the directory from a path,
- `path.home`: home directory of user,

and so on.

### HTTP

\index{HTTP}

Distant files can be retrieved over http using `http.get`. For instance, the
following script will fetch and display the list of changes in Liquidsoap:

```{.liquidsoap include="liq/https.get.liq" from=1}
```

Other useful functions are

- `http.post`: to send data, typically on forms,
- `http.put`: to upload data,
- `http.delete`: to delete resources.

Liquidsoap also features an internal web server called _harbor_, which allows serving
web pages directly from Liquidsoap, which can be handy to present some
data related to your script or implement some form of advanced interaction. This
is described on details in [there](#sec:harbor).

### System

\index{argument!commandline}

The arguments passed on the command line to the current script can be retrieved
using the `argv`\indexop{argv} function. Its use is illustrated in
[there](#sec:offline-processing).

The current script can be stopped using the `shutdown`\indexop{shutdown} function which cleanly
stops all the sources, and so on. In case of emergency, the application can be
immediately stopped with the `exit`\indexop{exit} function, which allows specifying an exit
code (the convention is that a non-zero code means that an error occurred). The
current script can also be restarted using `restart`\indexop{restart}.

In order to execute other programs\index{process} from Liquidsoap, you can use the function
`process.read` which executes a command and returns the text it wrote in the
standard output. For instance, in the script

```{.liquidsoap include="liq/process.read.liq" from=1}
```

we use the `find` command to find files in the `~/Music` directory and pipe it
through `wc -l` which will count the number of printed lines, and thus the
number of files. In passing, in practice you would do this in pure Liquidsoap
with

```{.liquidsoap include="liq/process.read2.liq" from=1 to=1}
```

There is also the quite useful variant called `process.read.lines`, which
returns the list of lines written on the standard output. Typically, suppose
that we have a script `generate-playlist` which outputs a list of files to play,
one per line. We can play it by feeding it to `playlist.list` which plays a list
of files:

```{.liquidsoap include="liq/process.read.lines.liq" from=1}
```

The more elaborate variant `process.run` allows retrieving the return code of
the program, set a maximal time for the execution of the program and _sandbox_
its execution, i.e. restrict the directories it has access to in order to
improve security (remember that executing programs is dangerous, especially if
some user-contributed data is used). This is further detailed in
[there](#sec:run-external).

### Threads

\index{thread}


The function `thread.run`\indexop{thread.run} can be used to run a function asynchronously in a _thread_, meaning
that the function will be executed in parallel to the main program and will not
block other computations if it takes time. It takes two optional arguments:

- `delay`: if specified, the function will not be run immediately, but after the
specified number of seconds,
- `every`: if specified, the function will be run regularly, every given number
of seconds.

#### Phone ring

For instance, we can simulate the sound of a hanged phone by playing a sine and
switching the volume on and off every second. This is easily achieved as
follows:

```{.liquidsoap include="liq/hanged-phone.liq" from=1}
```

Here, we amplify the sine by the contents of a reference `volume` (or, more
precisely, by a getter which returns the value of the reference). Its value is
switched between `0.` and `1.` every second by the function `change`.

#### Auto-gain control

A perhaps more useful variant of this is _auto-gain control_\index{automatic gain control}. We want to adjust
the volume so that the output volume is always roughly -14 LUFS, which is a
standard sound loudness measure. One way to do this is to regularly check its
value and increase or lower the volume depending on whether we are below or above
the threshold:

```{.liquidsoap include="liq/agc.liq" from=1}
```

Here, we have a source `pre` which we amplify by the value of the reference
`volume` in order to define a source `post`. On both sources, the `lufs`
function instructs that we should measure the LUFS\index{LUFS}, which value can be obtained
by calling the `lufs` and `lufs_momentary` methods attached to the
sources. Regularly (10 times per second), we run the function `adjust` which
multiplies the volume by the coefficient needed to reach -14 LUFS (to be
precise, we actually divide the distance to -14 by 20 in order not to change the
volume too abruptly, and we constrain the volume in the interval [0.01,10] in
order to keep sane values).

Of course, in practice, you do not need to implement this by hand: the operator
`normalize`\indexop{normalize} does this for you, and more efficiently than in the above
example. But it is nice to see that you could if you needed, to experiment with
new strategies for managing the gain for instance.

#### Conditional execution


Another useful function is `thread.when`, which executes a function when a
Another useful function is `thread.when`\indexop{thread.when}, which executes a
predicate (a boolean getter, of type `{bool}`) becomes true. By default, the
function when a predicate (a boolean getter, of type `{bool}`) becomes true. By
value of the predicate is checked every second, this can be changed with the
default, the value of the predicate is checked every half second, this can be
`every` parameter. For instance, suppose that we have a file named "`song`"
changed with the `every` parameter. For instance, suppose that we have a file
containing the path to a song, and we want that each time we change the contents
named "`song`" containing the path to a song, and we want that each time we
of this file, the new song is played. This can be achieved as follows:
change the contents of this file, the new song is played. This can be achieved
as follows:

```{.liquidsoap include="liq/thread.when.liq" from=1}
```

We begin by creating `q` which is a request queue, i.e. some source on which we
can push new songs (those are detailed in [there](#sec:request.queue)) and
`song` which is a getter which returns the contents of the file. We then use
`thread.when` on the predicate `getter.changes(song)` (which is true when the
contents of `song` changes) in order to detect changes in `song` and, when this
is the case, actually push the song on the request queue.

As a variation on previous example, we can program a clock which will read the
time at the beginning of every hour as follows:

```{.liquidsoap include="liq/thread.when2.liq" from=2}
```

Namely, the condition `0m` is true when the minute of the current time is zero,
i.e. we are the beginning of the hour: when this is the case we push in the
queue a request to say the current time. Note that even though the condition is
checked very regularly, the function `read_time` is called only once at the
beginning of every hour: this is because, by default, `thread.when` waits for
the condition to become false before executing the function again (this can be
altered with the `changed` parameter of `thread.when`).

<!--
#### Mutexes

In the case where two concurrent threads access a common resource at the same
time (for instance, if they modify the same reference).

\TODO{speak about mutexes}

`thread.mutexify`
-->

### Time

In case you need it, the current time\index{time} can be retrieved using the
`time` function. This function returns the number of seconds since the 1st of
January 1970, which is mostly useful to measure duration by considering the
difference between two points in time. For instance, we can compute the time
taken by the execution of a function `f` with

```{.liquidsoap include="liq/time-duration.liq" from=2}
```

which stores the time before and after the execution of `f` and displays the
difference. As a useful variant, the function `time.up` returns the
_uptime_\index{uptime} of the script, i.e. the number of seconds since the
beginning of its execution.

In order to retrieve time in more usual notations, you can use the functions
`time.local` and `time.utc` which return a record containing the usual
information (year, month, day, hour, etc.), respectively according to the
current time zone and the Greenwich median time. For instance, we can print the
current date with

```{.liquidsoap include="liq/time.liq" from=1}
```

If you do not need to manipulate time components and only print time, this can
also be more conveniently done with the `time.string` function which takes a
string as argument and replaces `%Y` by the year, `%m` by the month and so on,
so that we can do

```{.liquidsoap include="liq/time2.liq" from=1}
```

Finally, we mention here that the time zone can be retrieved and changed with
the `time.zone` function:

```{.liquidsoap include="liq/time.zone.liq" from=1}
```

Streams in Liquidsoap {#sec:quick-streams}
---------------------

Apart from the general-purpose constructions of the language described above,
Liquidsoap also has constructions dedicated to building streams: after all this
is what we are all here for. Those are put to practice in [the next
chapter](#chap:workflow) and described in details in [the chapter
after](#chap:streaming). We however quickly recap here the main concepts and
operators.

### Sources

An operator producing a stream is called a _source_\index{source} and has a type of the form

```
source(audio=..., video=..., midi=...)
```

where the "`...`" indicate the _contents_\index{contents} that the source can generate, i.e. the
number of channels, and their nature, for audio, video and midi data, that the
source can generate. For instance, the `playlist` operator has (simplified) type

```
(?id : string, string) -> source(audio='a, video='b, midi='c)
```

we see that it takes as parameters an optional string labeled `id` (most
operators take such an argument which indicates its name, and is used in the
logs or the telnet) as well as a string (the playlist to play) and returns a
source (which plays the playlist...).

Some sources are _fallible_\index{fallibility}\index{source!fallible}, which means that they are not always available. For
instance, the sound input from a DJ over the internet is only available when the
DJ connects. We recall from [there](#sec:fallible) that a source can be made
infallible with the `mksafe` operator or by using a fallback to an infallible
source.

### Encoders

Some outputs need to send data encoded in some particular format. For instance,
the operator which records a stream into a file, `output.file`, needs to know in
which format we want to store the file in, such MP3, AAC, etc. This is
specified by passing special parameters called _encoders_\index{encoder}. For instance, the
(simplified) type of `output.file` is

```
(?id : string, format('a), string, source('a)) -> unit
```

We see that it takes the `id` parameter (a string identifying the operator), an
encoder (the type of encoders is `format(...)`), a string (the file where we
should save data) and a source. This means that we can play our playlist and
record it into an mp3 file as follows:

```{.liquidsoap include="liq/output.file.liq" from=1}
```

Here, `%mp3` is an encoder specifying that we want to encode into the mp3
formats. Encoders for most usual formats are available (`%wav` for wav,
`%fdkaac` for aac, `%opus` for opus, etc.) and are detailed [later
on](#sec:encoders).

### Requests

Internally, Liquidsoap does not directly deal with a file, but rather with an
abstraction of it called a _request_\index{request}. The reason is that some files require some
processing before being accessible. For instance, we cannot directly access a
distant mp3 file: we first need to download it and make sure that it has the
right format.

This is the reason why most low-level operators do not take files as arguments,
but requests. The main thing you need to know in practice is that you can create
a request from a file location, using the `request.create` function. For
instance, in the following example, we create a request queue `q`, on which we
can add requests to play in it using `q.push`. We define a function `play`,
which adds the file on the queue, by first creating a request from it. We then
use `list.iter` to apply this function `play` on all the mp3 files of the
current directory. The following script will thus play all the mp3 files in the
current directory:\indexop{request.queue}

```{.liquidsoap include="liq/request.queue-ls.liq" from=1}
```

### Main functions

The main functions in order to create and manipulate audio streams are

- `playlist`: plays a playlist,
- `fallback`: plays the first available source in a list,
- `switch`: plays a source depending on a condition,
- `crossfade`: fade successive tracks,
- `output.icecast`, `output.hls`, `output.file`: output on Icecast, an HLS
  playlist, or in a file,
- `request.queue`: create a queue that can be dynamically be fed with user's
  requests and will play them in the order they were received.

Their use is detailed in next chapter.
