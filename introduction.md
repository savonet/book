Prologue {#chap:prologue epub:type=prologue}
========

What is Liquidsoap?
-------------------

### The need for a flexible streaming tool

So, you want to make a webradio? At first, this looks like an easy task, we
simply need a program which takes a playlist of MP3 files and broadcasts them
one by one over the internet. But in practice, most people want something much
more elaborate than just this.

For instance, we want to be able to switch between multiple playlists depending
on the time, so that we can have different ambiances during the day (soft music
in the morning and techno at night). We also want to be able to incorporate
requests from users (for instance, they could requests songs on the website of
the radio, or we could have guest DJ shows). Moreover, the music does not
necessarily comes from files which are stored on a local harddisk: we should be
able to relay other audio streams, youtube videos, or a microphone which is
being recorded on the soundcard (to have live shows).

The music files are rarely simply played one after the other. Generally, we want
to have some fading between songs, so that the transition is not too abrupt, and
serious people want to be able to describe the time at which this fading should
be performed on a per-song basis. We also want to add jingles between songs so
that people know and remember about our radio, to use speech synthesis to give
the name of the song we just played, and maybe add commercials so that we can
earn some money, which should be played at a given hour, but should wait for the
current song to be finished before launching the ad.

Also, we want to have some signal processing on our music in order to have a
nice and even sound. We should adjust the gain so that songs roughly have the
same volume. We should also compress and equalize the sound in order to have a
warm sound or to give the radio a unique color.

Finally, the rule number one of a webradio is that _it should never fail_! We
want to ensure that if, for some reason, the stream we are usually relaying is
not available, or the external harddisk on which our MP3 files are stored is
disconnected, an emergency playlist will be played. More difficult, if the
microphone is unplugged the soundcard will not be aware of it and will provide
us with silence: we should be able to detect that we are streaming blank and
after some time fallback on the emergency playlist.

Once we have successfully generated the stream we had in mind, we want to encode
it multiple times simultaneously: this is necessary to account for various
qualities (so that users can choose depending on their bandwidth) and various
formats. We should also be able to broadcast those encoded streams using various
protocols.

As we can see, there is a wide variety of usages and this is only the tip of the
iceberg. Even more complex setups can be looked for in practice, especially if
we have some form of interaction (through a website, a chatbot, etc.). However,
most software tools to generate webradios impose a fixed workflow for webradios:
they either consist in a graphical interface, which generally offers the
possibility of programming a grid with different broadcasts on different
timeslots, or a commandline program with more or less complex configuration
files. As soon as your setup does not fit within the predetermined radio
workflow, you are in trouble.

### A new programming language

Based on this observation, we decided to come up with a new _programming
language_, our beloved _Liquidsoap_, which would allow for describing how to
generate audio streams. The generation of the stream does not follow a
predetermined shape, it is instead described by the user in a script, which
combines the various building blocks of the language in an arbitrary way: the
possibilities are thus virtually unlimited. It does not impose a particular
approach for designing your radio; it can cope with all the situations described
above, and much more.

Liquidsoap itself is programmed in OCaml, but the language you will use is not
OCaml, it is a new language, and it is quite different from a general-purpose
programming languages, such as Java or C. It was designed from scratch,
dedicated to stream generation, where we tried to follow the principle
formulated by Allan Kay: _simple things should be simple, complex things should
be possible_. This means that we had in mind that our users are not typically
experienced programmers, but rather people enthusiastic about music or willing
to disseminate information, and we wanted a language as accessible as possible,
were a basic script should be simple and easy to understand, where the functions
have reasonable default values, where the errors are clearly located and
explained. Yet, we provide most things needed for handling sound (in particular,
support for the wide variety of file formats, protocols, sound plugins, and so
on) as well as more advanced functions which ensure that one can cope up with
complex setups (e.g. through callbacks and references).

It is also designed to be very robust, since we want our radios to stream
forever and our stream crash after a few weeks because of a rare case which is
badly handled. For this reason, the Liquidsoap compiler, before running a script
performs many in-depth checks on it in order to ensure that everything will go
on well. Most of those analysis are performed using _typing_, which offer very
strong guarantees.

- We ensure that the data passed to function is of the expected form. For
  instance, the user cannot pass a string to a function expecting an integer.
  Believe it or not, this simple kind of error is the source of an incredible
  number of bugs in everyday programs.
- We ensure there is always something to stream: if there is a slight chance
  that a source of sound might fail (e.g. the server on which the files are
  stored get disconnected), Liquidsoap imposes that there should be a fallback
  source of sound.
- We ensure that we correctly handle [synchronization issues](#clocks). Two
  sources of sound (such as two soundcards) generally produce the sound at
  slightly different rates (the promised 44100 samples per seconds might
  actually be 44100.003 for one and 44099.99 for the other). While slightly
  imprecise timing cannot be heard, the difference between the two sources
  accumulates on the long run and can lead to blanks (or worse) in the resulting
  sound. Liquidsoap imposes that a script will be able to cope with such
  situations (typically by using buffers).

Again, these potential errors are not detected while running the script, but
before, and the experience shows that this results in quite robust sound
production.

Actually, while we are insisting on webradios because this is the original
purpose of Liquidsoap, the language is now able to also handle video. In some
sense this is quite logical since, if we abstract away from technical details,
the production of an audio stream or of a video stream is quite
similar. Typically, many radios are also streaming on youtube, adding an image
or a video, and maybe some information text sliding at the bottom.

In this book, we will mainly focus on applications. More details about the
language and underlying ideas behind Liquidsoap can be found in the two articles
[@baelde2008webradio; @baelde2011liquidsoap].

### Free software

The Liquidsoap language is a _free software_. This of course means that it is
available for free on the internet, see the [installation
chapter](#chap:installation), but also much more: this also means that the
source code of Liquidsoap is available for you to study, modify and
redistribute. Thus, you are not doomed if a specific feature is missing in the
language: you can add it if you have the competences for that, or hire someone
who does. This is guaranteed by the license of Liquidsoap, which is the _GNU
General Public Licence 2_ (and most of the libraries used by Liquidsoap are
under the _GNU Lesser General Public Licence 2.1_).

Liquidsoap will always be free, but this does not prevent companies from selling
products based on the language (and there are quite a number of those, be they
graphical interfaces, web interfaces, or providing webradio tools as part of
larger journalism tools) or services around the language (such as
consulting). The main constraint imposed by the license is that if you
distribute a modified version of Liquidsoap, say with some new features, you
have to provide the user with the source code containing your improvements.

### A bit of history

The Liquidsoap language was initiated by David Baelde and Samuel Mimram, while
students at the École Normale Supérieure de Lyon, around 2004. They liked to
listen to music while coding and it was fun to listen to music together, which
motivated David to write a Perl script based on the IceS program in order to
stream a radio on the campus: _geekradio_ was born.

They did not have that many music files, and at that time it was not so easy to
get online streams. But there were plenty of MP3s available on the internal
network of the campus, which were shared by the students. In order to have
access to those more easily, Samuel wrote a dirty campus indexer in OCaml
(called _strider_, later on replaced by _bubble_), and David made an ugly Perl
hack for adding user requests to the original system. It probably kind of worked
for a while. Then they wanted something more, and realized it was all too ugly.

So they started to built the first audio streamer in pure OCaml, using
libshout. It had a simple telnet interface, so that a bot on IRC (this was the
chat at that time) could send user requests easily to it, same for the
website. There were two request queues, one for users, one for admins. But it
was still not so nicely designed, and they felt it when they needed more. They
wanted scheduling, especially techno music at night.

Around that time, students had to propose and realize a "large" software project
for one of their courses, with the whole class of around 30 students. David and
Samuel proposed to build a complete flexible webradio system called _savonet_
(for something like "Samuel and David's OCaml network"). A complete rewriting of
every part of the streamer in OCaml was planned, with grand goals, so that
everybody would have something to do: a new website with so many features, a new
intelligent multilingual bot, a new network libraries for glueing that,
etc. Most of those died. But still, _Liquidsoap_ was born and plenty of new
libraries for handling sound in OCaml emerged, many of which we are still using
today. The name of the language was a play on word around "savonet" which sounds
like "savonette", a soap bar in French.

On the day where the project had to be presented to the teachers, the demo
miserably failed, but soon after that they ware able to run a webradio with
several static (but periodically reloaded) playlists, scheduled on different
times, with a jingle added to the usual stream every hour, with the possibility
of live interventions, allowing for user requests via a bot on IRC which would
find songs on the database of the campus, which have priority over static
playlists but not live shows, and added speech-synthetized metadata information
at the end of requests.

Later on, the two main developers were joined by Romain Beauxis\TODO{détailler
et mentionner Radio Pi}

About this book
---------------

### Prerequisites

We expect that the computer knowledge can vary much between Liquidsoap users,
who can range between music enthusiasts and experienced programmers, and we try
to accommodate with all those backgrounds. Nevertheless, we have to suppose that
the reader of this book is familiar with some basic concepts and tools. In
particular, this book does not cover the basics of text file editing and unix
shell scripting (how to use the command line, how to run a program and so
on). Some knowledge in signal processing, streaming and programming can also be
useful.

### How to read the book

TODO: explain that this is not a 500+ pages reference manual, but a way to
really learn Liquidsoap, without necessarily giving all the details about the
functions, which can be found in the online documentation

TODO: plan of the book

### How to get help

You have read the book and still have questions? There are many ways to get in
touch with the community and obtain help to get your problem solved:

1. the [Liquidsoap website](https://www.liquidsoap.info/) contains an extensive
  up-to-date documentation and tutorial about specific points,
2. the [Liquidsoap slack workspace](https://liquidsoapworkspace.slack.com/) is a
  public chat on which you can have instantaneous discussions,
3. the [Liquidsoap mailing-list](savonet-users@lists.sf.net) is there if you'd
  rather discuss by mail,
4. the [Liquidsoap github page](https://github.com/savonet/liquidsoap/issues) is
  the place to report bugs and get some help.

Please remember to be kind, most of the people there are doing this on their
free time!

\TODO{explain how to report bugs about this book}

### The authors

The authors of the book are the two main current developers of Liquidsoap.

*Romain Beauxis* is ...

*Samuel Mimram* obtained his PhD in 2009 and is now professor in École
polytechnique in France. His main research topics are concurrency, type theory
and category theory.

### Thanks

The advent of Liquidsoap and this book could not have been possible without the
numerous contributors over the years among whom David Baelde who stood at the
starting point, the students of the MIM1 (big up to Florent Bouchez, Julien
Cristau, Stéphane Gimenez and Sattisvar Tandabany), Clément Renard and Vincent
Tabard (who also designed the logo). Many thanks also to the many people who
helped improving the language by reporting bugs or suggesting ideas!
