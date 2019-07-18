The language
============

Syntax of [language](https://www.liquidsoap.info/doc-dev/language.html)

The typing system
-----------------

Sources
-------

### What is a faillible source?

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
```
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