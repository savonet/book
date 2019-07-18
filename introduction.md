Prologue
========

What is Liquidsoap?
-------------------

### The need for a flexible streaming tool

So, you want to make a webradio? At first, this looks like an easy task, we
simply need a program which takes a playlist of mp3 files and broadcasts them
one by one over the internet. But in practice, most people want something much
more elaborate than just this.

For instance, we want to be able to switch between multiple playlists depending
on the time, so that we can have different ambiances during the day. We also
want to be able to incorporate requests from users (for instance, they could
requests songs on the website of the radio, or we could have DJ shows). The
sound itself is not necessarily always stored in local files: we should be able
to relay other audio streams, youtube videos, or a microphone which is being
recorded on the soundcard (to have live shows).

The different music files are rarely simply played one after the
other. Generally, we want to have some fading between songs, so that the
transition is not too abrupt, and serious people want to be able to describe the
time at which this fading should be performed on a per-song basis. We also want
to add jingles between songs so that people know and remember about our radio,
to use speech synthesis to give the name of the song we just played, and maybe
add commercials so that we can earn some money, which should be played at a
given hour, but should wait for the song to be finished before starting.

Also, we want to have some signal processing on our music in order to have a
nice and even sound. We should adjust the gain so that songs roughly have the
same volume. We should also compress and equalize the sound in order to have a
warm sound or to give the radio a unique color.

Finally, the rule number one of a webradio is that _it should never fail_! We
want to ensure that if, for some reason, the stream we are usually relaying is
not available, or the external harddisk on which our mp3 files are stored is
disconnected, an emergency playlist will be played. More difficult, if the
microphone is unplugged the soundcard will not be aware of it and will provide
us silence: we should be able to detect that we are streaming blank and after
some time fallback on the emergency playlist.

Once we are successfully generated the stream we had in mind, we want to encode
it multiple times. This is necessary to account for various qualities (so that
users can choose depending on their bandwidth) and various formats. We should
also be able to broadcast them using various protocols.

As you can see, there is a wide variety of usages and this is only the tip of
the iceberg. Even more complex setups can be looked for in practice, especially
if we have some form of interaction (through a website, a chatbot,
etc.). However, most software tools to generate webradios impose a fixed
workflow for webradios: they either consist in a graphical interface, which
generally offers the possibility of programming a grid with different broadcasts
on different timeslots, or a commandline program with more or less complex
configuration files. As soon as your setup does not fit within the predetermined
radio workflow, you are in trouble.

### What is Liquidsoap?

Based on this observation, we decided to design a _programming language_, our
beloved _Liquidsoap_, which would allow for describing how to generate audio
streams.

Since 2004.

free software

Liquidsoap is a programming language, it is programmed in OCaml but the language
is _not_ OCaml (see [@realworldocaml]).

Designed to be very simple so that non programmers can use it.

It should be robust/safe (=> typing, etc.)

What is _not_ liquidsoap: streaming (icecast), gui


### A bit of history

How it all started

The radio at ENS Lyon, radio pi, etc

Even two publications [@baelde2008webradio] [@baelde2011liquidsoap].

About the authors

*David Baelde* is \...

*Romain Beauxis* is \...

*Samuel Mimram* is \...

Other main developers of Liquidsoap

TODO: thanks Balbinus for the logo

TODO: origin of the name Liquidsoap


Prerequisites
-------------

We suppose the reader familiar with

-   text file editing and unix shell

-   basics of signal processing

-   basics of audio streaming (e.g. Icecast is not covered in details)


About this book
---------------

### The authors

*Romain Beauxis* is \...

*Samuel Mimram* is \...

### How to read the book



### How to get help

online, etc.
