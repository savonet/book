Prologue {#chap:prologue epub:type=prologue}
========

What is Liquidsoap?
-------------------

<!-- ### The need for a flexible streaming tool -->

So, you want to make a webradio? At first, this looks like an easy task, we
simply need a program which takes a playlist of mp3 files, and broadcasts them
one by one over the internet. However, in practice, people want something much
more elaborate than just this.

For instance, we want to be able to switch between multiple playlists depending
on the current time, so that we can have different ambiances during the day
(soft music in the morning and techno at night). We also want to be able to
incorporate requests from users (for instance, they could ask for specific songs
on the website of the radio, or we could have guest DJ shows). Moreover, the
music does not necessarily come from files which are stored on a local harddisk:
we should be able to relay other audio streams, youtube videos, or a microphone
which is being recorded on the soundcard or on a distant computer.

When we start from music files, we rarely simply play one after the
other. Generally, we want to have some fading between songs, so that the
transition from a track to the next one is not too abrupt, and serious people
want to be able to specify the precise time at which this fading should be
performed on a per-song basis. We also want to add jingles between songs so that
people know and remember about our radio, and to use speech synthesis to give
the name of the song we just played. We should also maybe add commercials, so
that we can earn some money, and those should be played at a given fixed hour,
but should wait for the current song to be finished before launching the ad.

Also, we want to have some signal processing on our music in order to have a
nice and even sound. We should adjust the gain so that successive tracks roughly
have the same volume. We should also compress and equalize the sound in order to
have a warm sound and to give the radio a unique color.

Finally, the rule number one of a webradio is that _it should never fail_. We
want to ensure that if, for some reason, the stream we are usually relaying is
not available, or the external harddisk on which our mp3 files are stored is
disconnected, an emergency playlist will be played, so that we do not simply
kick off our beloved listeners. More difficult, if the microphone of the speaker
is unplugged, the soundcard will not be aware of it and will provide us with
silence: we should be able to detect that we are streaming blank and after some
time also fallback to the emergency playlist.

Once we have successfully generated the stream we had in mind, we need to encode
it in order to have data which is small enough to be sent in realtime through
the network. We actually often want to perform multiple simultaneous encodings
of the same stream: this is necessary to account for various qualities (so that
users can choose depending on their bandwidth) and various formats. We should
also be able to broadcast those encoded streams using the various usual
protocols that everybody uses nowadays.

As we can see, there is a wide variety of usages and technologies, and this is
only the tip of the iceberg. Even more complex setups can be looked for in
practice, especially if we have some form of interaction (through a website, a
chatbot, etc.). Most other software tools to generate webradios impose a fixed
workflow for webradios: they either consist in a graphical interface, which
generally offers the possibility of programming a grid with different broadcasts
on different timeslots, or a commandline program with more or less complex
configuration files. As soon as your setup does not fit within the predetermined
radio workflow, you are in trouble.

### A new programming language

Based on this observation, we decided to come up with a new _programming
language_, our beloved _Liquidsoap_, which would allow for describing how to
generate audio streams. The generation of the stream does not need to follow a
particular pattern here, it is instead implemented by the user in a script,
which combines the various building blocks of the language in an arbitrary way:
the possibilities are thus virtually unlimited. It does not impose a rigid
approach for designing your radio, it can cope with all the situations described
above, and much more.

Liquidsoap itself is programmed in the OCaml\index{OCaml} programming language, but the
language you will use is not OCaml (although it was somewhat inspired of it), it
is a new language, and it is quite different from a general-purpose programming
language, such as Java or C. It was designed from scratch, with stream
generation in mind, trying to follow the principle formulated by Allan Kay:
_simple things should be simple, complex things should be possible_. This means
that we had in mind that our users are not typically experienced programmers,
but rather people enthusiastic about music or willing to disseminate
information, and we wanted a language as accessible as possible, were a basic
script should be easy to write and simple to understand, where the functions
have reasonable default values, where the errors are clearly located and
explained. Yet, we provide most things needed for handling sound (in particular,
support for the wide variety of file formats, protocols, sound plugins, and so
on) as well as more advanced functions which ensure that one can cope up with
complex setups (e.g. through callbacks and references).

It is also designed to be very robust, since we want our radios to stream
forever and not have our stream crash after a few weeks because of a rare case
which is badly handled. For this reason, before running a script, the Liquidsoap
compiler performs many in-depth checks on it, in order to ensure that everything
will go on well. Most of this analysis is performed using _typing_, which
offer very strong guarantees.

- We ensure that the data passed to function is of the expected form. For
  instance, the user cannot pass a string to a function expecting an integer.
  Believe it or not, this simple kind of error is the source of an incredible
  number of bugs in everyday programs (ask Python or Javascript programmers).
- We ensure there is always something to stream: if there is a slight chance
  that a source of sound might fail (e.g. the server on which the files are
  stored gets disconnected), Liquidsoap imposes that there should be a fallback
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
production. In this book, we will mainly focus on applications and will not
detail much further the theory behind those features of the language. If you
want to know more about it, you can have a look at the two articles published on
the subject, which are referenced at the end of the book [@baelde2008webradio;
@baelde2011liquidsoap].

While we are insisting on webradios because this is the original purpose of
Liquidsoap, the language is now also able to handle video. In some sense, this
is quite logical since the production of a video stream is quite similar to the
one of an audio stream, if we abstract away from technical details. Moreover,
many radios are also streaming on Youtube, adding an image or a video, and maybe
some information text sliding at the bottom.

### Free software

The Liquidsoap language is a _free software_. This of course means that it is
available for free on the internet, see the [installation
chapter](#chap:installation), and more: this also means that the source code of
Liquidsoap is available for you to study, modify and redistribute. Thus, you are
not doomed if a specific feature is missing in the language: you can add it if
you have the competences for that, or hire someone who does. This is guaranteed
by the license of Liquidsoap, which is the _GNU General Public Licence 2_ (and
most of the libraries used by Liquidsoap are under the _GNU Lesser General
Public Licence 2.1_).

Liquidsoap will always be free, but this does not prevent companies from selling
products based on the language (and there are quite a number of those, be they
graphical interfaces, web interfaces, or providing webradio tools as part of
larger journalism tools) or services around the language (such as
consulting). The main constraint imposed by the license is that if you
distribute a modified version of Liquidsoap, say with some new features, you
have to provide the user with the source code containing your improvements,
under the same license as the original code.

The above does not apply to the current text which is covered by standard
copyright laws.

### A bit of history

The Liquidsoap language was initiated by David Baelde and Samuel Mimram, while
students at the École Normale Supérieure de Lyon, around 2004. They liked to
listen to music while coding and it was fun to listen to music together. This
motivated David to write a Perl script based on the IceS program in order to
stream their own radio on the campus: _geekradio_ was born.

They did not have that many music files, and at that time it was not so easy to
get online streams. But there were plenty of mp3s available on the internal
network of the campus, which were shared by the students. In order to have
access to those more easily, Samuel wrote a dirty campus indexer in OCaml
(called _strider_, later on replaced by _bubble_), and David made an ugly Perl
hack for adding user requests to the original system. It probably kind of worked
for a while. Then they wanted something more, and realized it was all too ugly.

So, they started to build the first audio streamer in pure OCaml, using
libshout. It had a simple telnet interface, so that a bot on IRC (this was the
chat at that time) could send user requests easily to it, as well as from the
website. There were two request queues, one for users, one for admins. But it
was still not so nicely designed, and they felt it when they needed more. They
wanted some scheduling, especially techno music at night to code better.

Around that time, students had to propose and realize a "large" software project
for one of their courses, with the whole class of around 30 students. David and
Samuel proposed to build a complete flexible webradio system called _savonet_\index{savonet}
(an acronym of something like _Samuel and David's OCaml network_). A complete
rewriting of every part of the streamer in OCaml was planned, with grand goals,
so that everybody would have something to do: a new website with so many
features, a new intelligent multilingual bot, new network libraries for glueing
that, etc. Most of those did not survive up to now. But still, _Liquidsoap_ was
born, and plenty of new libraries for handling sound in OCaml emerged, many of
which we are still using today. The name of the language was a play on word
around "savonet" which sounds like "savonette", a soap bar in French.

On the day when the project had to be presented to the teachers, the demo
miserably failed, but soon after that they were able to run a webradio with
several static (but periodically reloaded) playlists, scheduled on different
times, with a jingle added to the usual stream every hour, with the possibility
of live interventions, allowing for user requests via a bot on IRC which would
find songs on the database of the campus, which have priority over static
playlists but not live shows, and added speech-synthetized metadata information
at the end of requests.

Later on, the two main developers were joined by Romain Beauxis who was doing
his PhD at the same place as David, and was also a radio enthusiastic: he was
part of _Radio Pi_, the radio of École Centrale in Paris, which was soon
entirely revamped and enhanced thanks to Liquidsoap. Over the recent year, he
has become the main maintainer (taking care of the releases) and developer of
Liquidsoap (adding, among other, support for FFmpeg in the language).

About this book
---------------

### Prerequisites

We expect that the computer knowledge can vary much between Liquidsoap users,
who can range from music enthusiasts to experienced programmers, and we tried to
accommodate with all those backgrounds. Nevertheless, we have to suppose that
the reader of this book is familiar with some basic concepts and tools. In
particular, this book does not cover the basics of text file editing and Unix
shell scripting (how to use the command line, how to run a program, and so
on). Some knowledge in signal processing, streaming and programming can also be
useful.

### Liquidsoap version

The language has gone through some major changes since its beginning and
maintaining full backward-compatibility was impossible. In this book, we assume
that you have a version of Liquidsoap which is at least 2.0. Most examples
could easily be adapted to work with earlier versions though, at the cost of
making minor changes.

### How to read the book

This book is intended to be read mostly sequentially, excepting perhaps [this
chapter](#chap:language), where we present the whole language in details, which
can be skimmed trough at first. It is meant as a way of learning Liquidsoap, not
as a 500+ pages references manual: should you need details about the arguments
of a particular operator, you are advised to have a look at the online
documentation.

We explain the technological challenges that we have face in order to produce
multimedia streams in [this chapter](#chap:technology) and are addressed by
Liquidsoap. The means of installing the software are described in [this
chapter](#chap:installation). We then describe in [this
chapter](#chap:quickstart) what everybody wants to start with: setting up a
simple webradio station. Before, going to more advanced uses, we first need to
understand what we can do in this language, and this is the purpose of [this
chapter](#chap:language). We then detail the various ways to generate a webradio
in [there](#chap:workflow) and a video stream in [there](#chap:video). Finally,
for interested readers, we give details about the internals of the language and
the production of streams in [there](#chap:streaming).

<!--
The book ends with the list of frequently asked
questions of [this chapter](#chap:faq).
-->

### How to get help

You are reading the book and still have questions? There are many ways to get in
touch with the community and obtain help\index{help} to get your problem solved:

1. the [Liquidsoap website](https://liquidsoap.info/) contains an extensive
  up-to-date documentation and tutorials about specific points,
2. the [Liquidsoap slack workspace](https://liquidsoapworkspace.slack.com/)\index{slack} is a
  public chat on where you can have instantaneous discussions,
3. the [Liquidsoap mailing-list](savonet-users@lists.sf.net) is there if you
  would rather discuss by mail (how old are you?),
4. the [Liquidsoap github
  page](https://github.com/savonet/liquidsoap/issues)\index{github} is the place
  to report bugs,
5. there is also a [Liquidsoap discussion
   board](https://github.com/savonet/liquidsoap/discussions).

Please remember to be kind, most of the people there are doing this on their
free time!

### How to improve the book

We did our best to provide a progressive and illustrated introduction to
Liquidsoap, which covers almost all the language, including the most advanced
features. However, we are open to suggestions: if you find some error, some
unclear explanation, or some missing topic, please tell us! The best way is by
opening an issue on [the dedicated
bugtracker](https://github.com/savonet/book/issues), but you can also reach us
by mail at `sam@liquidsoap.info` and `romain@liquidsoap.info`. Please include
page numbers and text excerpts if your comment applies to a particular point of
the book (or, better, make pull requests). The version you are holding in your
hands was compiled on \today, you can expect frequent revisions to fix found
issues.

### The authors

The authors of the book you have in your hands are the two main current
developers of Liquidsoap.
*Samuel Mimram* obtained his PhD in computer science
2009 and is currently a Professor in computer science in École polytechnique,
France.
<!-- His main research topics are type theory, category theory and rewriting. -->
*Romain Beauxis* obtained his PhD in computer science in 2009 and is currently a
software engineer based in New Orleans.

### Thanks

The advent of Liquidsoap and this book would not have been possible without the
numerous contributors over the years, the first of them being David Baelde who
was a leading creator and designer of the language, but also the students of the
MIM1 (big up to Florent Bouchez, Julien Cristau, Stéphane Gimenez and Sattisvar
Tandabany), and our fellow users Gilles Pietri, Clément Renard and Vincent
Tabard (who also designed the logo), as well as all the regulars of slack and the
mailing-list. Many thanks also to the many people who helped to improve the
language by reporting bugs or suggesting ideas, and to the Radio France team who
where enthusiastic about the project and motivated some new developments (hello
Maxime Bugeia, Youenn Piolet and others).
