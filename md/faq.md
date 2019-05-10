Frequently asked questions
==========================

reprendre la [FAQ DU SITE](https://www.liquidsoap.info/doc-dev/faq.html)

Type errors
-----------

might reject a script with a series of errors of the form . Usually the
last error tells you what the problem is, but the previous errors might
provide a better information as to where the error comes from.

For example, the error might indicate that a value of type has been
passed where a float was expected, in which case you should use a
conversion, or more likely change an integer value such as into a float
.

A type error can also show that you're trying to use a source of a
certain content type (e.g., audio) in a place where another content type
(e.g., pure video) is required. In that case the last error in the list
is not the most useful one, but you will read something like this above:

    At ...:
      this value has type
        source(audio=?A+1,video=0,midi=0)
        where ?A is a fixed arity type
      but it should be a subtype of
        source(audio=0,video=1,midi=0)

Sometimes, the type error actually indicates a mistake in the order or
labels of arguments. For example, given liquidsoap will complain that
the second argument is a source () but should be a format (): indeed,
the first unlabelled argument is expected to be the encoding format,
e.g., , and the source comes only second.

Finally, a type error can indicate that you have forgotten to pass a
mandatory parameter to some function. For example, on the code ,
liquidsoap will complain as follows:

    At line ...:
      this value has type
        (?id:string, ~start_next:float, ~fade_in:float,
         ~fade_out:float)->source(audio=?A,video=?B,midi=0)
        where ?B, ?A is a fixed arity type
      but it should be a subtype of
        source(audio=?A,video=?B,midi=0)
        where ?B, ?A is a fixed arity type

Indeed, expects a source, but is still a function expecting the
parameters , and .

Unable to decode "file" as 
---------------------------

That source is fallible!
------------------------

Clock errors
------------

We must catchup
---------------

Exceptions
----------

Files cannot be decoded
-----------------------

Use
```
set("decoder.file_extensions.ffmpeg",["mp3","mp4","m4a","wav","flac","ogg", "osb"])
```

