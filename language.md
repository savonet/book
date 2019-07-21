The language
============

TODO (SM): je pense qu'il faudrait ne faire que le typage dans ce chapitre

Syntax of [language](https://www.liquidsoap.info/doc-dev/language.html)

The main ideas behind it are described in [@baelde2008webradio;
@baelde2011liquidsoap]. We focus here on the practical parts.

Typing system
-------------

This raises a typing error:

```
s = sine(500)
```

Expressions
-----------

string / int / float / lists / tuples
deconstructing tuples


Sources
-------

### What is a faillible source?

In practice, simply use `mksafe`{.liquidsoap}

The execution model
-------------------

Language execution vs stream production

Strings and logging
-------------------

String interpolation: `"my name is #{name}"`

Functions
---------

Partial evaluation

### Function ()->...

A nice example from https://github.com/savonet/liquidsoap/issues/536:
```liquidsoap
f = interactive.float("test", 0.0)
f = {lin_of_dB(f())}
s = amplify(f, in())
out(s)
```

References
----------

ref ! :=

Float getters

Exemple de `gstreamer.hls`

Requests
--------

Interaction
-----------

interactive floats
