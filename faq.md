Frequently asked questions {#chap:faq}
==========================

TODO: this chapter still has to be written

Errors
------

TODO: common errors => link to corresponding section

#### That source is fallible

#### We must catchup

Too much CPU is used

Check the samplerate conversion settings

encoding blank

This error means that a clock is getting late in liquidsoap. This can be caused
by an overloaded CPU, if your script is doing too much encoding or processing:
in that case, you should reduce the load on your machine or simplify your
liquidsoap script. The latency may also be caused by some lag, for example a
network lag will cause the icecast output to hang, making the clock late.

The first kind of latency is problematic because it tends to accumulate,
eventually leading to the restarting of outputs:

```
Too much latency!
Resetting active source...
```


The second kind of latency can often be ignored: if you are streaming to an
icecast server, there are several buffers between you and your listeners which
make this problem invisible to them. But in more realtime applications, even
small lags will result in glitches.

In some situations, it is possible to isolate some parts of a script from the
latency caused by other parts. For example, it is possible to produce a clean
script and back it up into a file, independently of its output to icecast (which
again is sensitive to network lags).  For more details on those techniques, read
about [clocks](clocks.html).

#### Cannot decode "file" as

This log message informs you that liquidsoap failed to decode a file, not
necessarily because it cannot handle the file, but also possibly because the
file does not contain the expected media type. For example, if video is
expected, an audio file will be rejected.

The case of mono files is often surprising. Since liquidsoap does not implicitly
convert between media formats, input files must be stereo if the output expects
stereo data. As a result, people often get this error message on files which
they expected to play correctly. The simple way to fix this is to use the
`audio_to_stereo()` operator to allow any kind of audio on its input, and
produce stereo as expected on its output.

#### Clock errors

Read about [clocks](clocks.html) for the errors `a source cannot belong to two
clocks` and `cannot unify two nested clocks`.


#### Example of a type error due to contents mismatch

where we have to drop audio or something

#### A type error with () when accessing a non-existent field


Warnings
--------

#### Unused sources

#### This expression should have type unit

This one is explained in [there](#sec:unit):

```
Warning 3: This expression should have type unit.
```

Runtime errors
--------------

#### not_found

example of a `list.hd([])`

#### internal errors

examples of an `http.get` on an non-existent url
