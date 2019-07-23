The technology behind streams {#chap:technology}
=============================

Before getting our hands on Liquidsoap, let us quickly describe the typical
toolchain involved in a webradio, in case the reader is not familiar with it. It
typically consists of the following three elements.

The _stream generator_ is a program which generates an audio stream, generally
in compressed form such as mp3 or aac, be it from playlists, live sources,
etc. Liquidsoap is one of those and we will be most exclusively concerned with
it, but there are other competitors ranging from
[Ezstream](http://icecast.org/ezstream/), [IceS](http://icecast.org/ices/) or
[DarkIce](http://www.darkice.org/) which are simple command-line free software
that can stream a live input or a playlist to an Icecast server (see below), to
[Rivendell](http://www.rivendellaudio.org/) or [SAM
Broadcaster](https://spacial.com/) which are graphical interfaces to describe
the scheduling of your radio. Nowadays, websites are also proposing to do this
online on the cloud; these include [AzuraCast](https://www.azuracast.com/),
[Centova](https://centova.com/) and [Radionomy](https://www.radionomy.com/)
which are all powered by Liquidsoap!

A _streaming media system_, which is generally
[Icecast](http://www.icecast.org/). Its role is to relay the stream from the
generator to the listeners, of which there can be thousands. With the advent of
HLS, it tends to be more and more replaced by a traditional web server.

A _media player_, which connects to the server and plays the stream for the
client, it can either be a software (such as iTunes), an Android application, or
a website.

Below, we enter the details of the first two, explaining the technical choices
you have to face when setting up a webradio.

Audio streams {#sec:audio-streams}
-------------

### Digital audio

Sound consists in regular vibrations of the ambient air, which goes back and
forth, which you perceive through the displacements of the membrane it induces
in your ear. In order to be represented in a computer, such a sound is usually
captured by a microphone, which also has a membrane, and is represented by
samples, corresponding to the successive positions of the membrane of the
microphone. In general, sound is sampled as 44.1 kHz, which means that samples
are captured 44100 times per second, and indicate the position of the membrane,
which is represented by a floating point number, conventionally between -1 and
1.\TODO{maybe do we want something like
\href{https://upload.wikimedia.org/wikipedia/commons/5/50/Signal_Sampling.png}{the
usual picture} about sampling?} But this is a matter of convention and many of
those can be found in "nature":

- the sampling rate is typically 44.1 kHz (this is for instance the case in
  audio CDs), but the movie industry likes more 48 kHz, and recent equipment and
  studios use higher rates for better precision (e.g. DVDs are sampled at 92
  kHz),
- the representation of samples varies: Liquidsoap internally uses floats
  between -1 and 1 (stored in double precision with 64 bits), but other
  conventions exist (e.g. CDs use 16 bits integers ranging from -32768 to 32767,
  and 24 bits integers are also common).

This means lots of data. For instance, an audio sample in CD quality takes 2
bytes (= 16 bits, remember that a byte is 8 bits) for each of the 2 channels and
1 minute of sound is 44100×2×2×60 bytes, which is roughly 10 MB per minute.

### Compression

Because of the above, sound is typically compressed, especially if you want to
send it over the internet where the bandwidth, i.e. the quantity of information
you can send in a given period of time, matters: it is not unlimited and it
costs money. To give you an idea, a connection of 1 gigabits per second is
roughly $10000, with which you can send CD quality audio to roughly 10 listeners
only (provided that their bandwidth is large enough to download that).

One way to compress audio consists in using the standard tools from coding and
information theory: if something occurs often then encode it with a small
sequence of bytes (this is how formats such as zip work for instance). The
_flac_ format uses this principle and generally achieves compression to around
65% of the original size. This compression format is _lossless_, which means
that if you compress and then decompress an audio file, you will get back to the
exact same file you started with.

In order to achieve more compression, we should be prepared to loose some data
in the compression process. Most compressed audio formats are based, in addition
to the previous ideas, on psychoacoustic models which take in account the way
sound is perceived by the human hear and processed by the human brain. For
instance, the ear does not generally perceive sounds about 20 kHz, so that we
can remove those, the ear is much more sensitive in the 1 to 5 kHz range so that
we can be more rough outside this range, some low intensity signals can be
masked by high intensity signals (i.e., we do not hear them anymore in presence
of other loud sound sources), and so on. Most compression formats are
_destructive_: they remove some information in the original signal in order for
it to be smaller. The most well-known are mp3, ogg/vorbis and aac: the one you
want to use is a matter of taste and support on the user-end. For instance, mp3
is the most widespread, ogg/vorbis has the advantage of being open-source,
patent-free and has a good quality/bandwidth radio but not many users have good
support for that (e.g. on smartphones), aac is proprietary so that good free
encoders are more difficult to find but achieves better sounding at high
compression rates, etc. A typical mp3 is encoded at a bitrate of 128 kbps
(kilobits per second, although rates of 192 kbps and higher are recommended if
you favor sound quality), meaning that 1 minute will weight roughly 1 MB, which
is 10% of the original sound in CD quality.

Most of these formats also support _variable bitrates_ meaning that the bitrate
can be adapted within the file: complex parts of the audio will be encoded at
higher rates and simpler ones at low rates. For those, the resulting stream size
will heavily depend on the actual audio and is thus more difficult to predict,
by the perceived quality is higher.

As a side note we were a bit imprecise above when speaking of a "file
format. TOOD: explain the difference between containers and codecs..............

### Metadata

Most audio streams are equipped with _metadata_ which are textual information
describing the contents of the audio. A typical music file will contain, as
metadata, the title, the artist, the album name, the year of recording, and so
on. Custom metadata are also useful to indicate the loudness of the file, the
desired cue points, and so on (see below).

### Streaming

Once properly encoded, the streaming of audio data is not performed directly by
the stream generator (such as Liquidsoap) to client. The reason is that this is
quite a technical task, which is already handled quite well by tools such as
Icecast, which takes care of distributing the stream. On a first connection, the
client starts by buffering audio (in order to be able to cope with possible
slowdowns of the network) and Icecast therefore has to feed it up at first and
then sends the data at a peaceful rate, apart from such buffering issues, it
also takes care of various connections by clients, recording statistics,
enforcing limits (on clients or bandwidth), and so on. It also handles multiple
mount points (i.e., different radios).

Until recently, the streaming model as offered by Icecast was predominant, but
suffers from two main drawbacks. Firstly, the connection has to be kept between
the client and the server which cannot be achieved in mobile contexts: when you
connect with your smartphone, you frequently change networks or switch between
wifi and 4G and the connection cannot be held during such events. Another issue
is that the data cannot be cached as it is for web traffic, where it helps
lowering the latencies and bandwidth-related costs. For this reason, new
standards such as HLS (for HTTP Live Stream) or MPEG-DASH (for Dynamic Adaptive
Streaming over HTTP) have emerged where the stream is provided as a rolling
playlist of small files called segments: a playlist typically contains the last
minute of audio split into segments of 2 seconds. Moreover, the playlist can
indicate, multiple versions of the stream with various formats and encoding
qualities, so that the client can switch to a lower bitrate if the connection
becomes bad (this is called _adaptative_ streaming). Here, the files are
downloaded one by one, and are served by an usual HTTP server, so that it is
more robust and scales better than Icecast serving. Our guess is that such
formats will take over audio distribution in the near future, and Liquidsoap
already has support for HLS.

Finally, we would like to mention that, nowadays, streaming is more and more
being delegated to big online platforms, such as Youtube, because of their ease
of use (both in terms of setup and of user experience), for which Liquidsoap
also has support.

Audio sources
-------------

In order to make a radio, one has to start with a primary source of audio. We
give examples of such below.

### Audio files

A typical radio starts with one or more _playlists_, which are lists of audio
files. These can be stored in various places: they can either be on a local hard
drive, or on some distant server, in which case they have to be downloaded
beforehand. There is a slight difference between the two: in the case of local
files, we have pretty good confidence that they will always be available (or at
least we can check that this is the case), whereas for distant files the server
might be unavailable, or just very slow, so that we have to take care of
downloading the file in advance enough and be prepared to have fallback option
in case the file is not ready in time. Finally, audio files can be in various
formats (as described in [the above section](#sec:audio-streams)) and have to be
decoded, which is why Liquidsoap depends on many libraries, in order to support
as many formats as possible.

Even in the case of local files, the playlist might be _dynamic_: instead of
knowing in advance the list of all the files, it can be a queue of _requests_
made by users (e.g., via a website or a chatbot) ; we can even call a script
which will return the next song to be played, depending on whichever parameters
(for instance taking in account votes on a website).

### Live inputs

A radio often features live shows. As in the old days, the speaker can be in the
same room as in the server, in which case the sound is directly captured by a
sound card. But now, live shows are made more and more from home, where the
speaker will stream its voice to the radio itself, which should be able to
interrupt its contents and relay the stream. More generally, a radio should be
able to relay other streams together with their metadata (e.g. when a program is
shared between multiple radios) or other sources (e.g. a live youtube channel).

As for distant files, we should be able to cleanly handle failures due to
network. Another issue specific to live streams is that we do not have control
over time: this is an issue for operations such as crossfading (see below) which
require shifting time and thus cannot be performed on realtime sources.

### Synchronization

In order to provide samples at a regular pace a source has an _internal clock_
which will tick regularly: each soundcard has a clock, your computer has a
clock, the live streams are generated by things which have clocks. Now, suppose
that you have two soundcards generating sound at 44100 Hz, meaning that their
internal clock both tick at 44100 Hz. Those are not infinitely precise and it
might be the case that there is a slight difference if 1 Hz between the two
(maybe one it ticking at 44099.6 Hz and the other one at 44100.6 Hz in
reality). Usually it is not a problem, but on the long run it is: this 1 Hz
difference means that one will be 1 second in advance to the other after a
month. For a radio which is supposed to be running for years (say that you
update it once a year), this will be an issue and the stream generator has to
take care of that, typically by using buffers. This is not a theoretical issue:
first versions of Liquidsoap did not handle this and we experienced the
problems.

Audio processing
----------------

### Resampling

As explained in [the above section](#sec:audio-streams), various files have
various sampling rates. For instance, suppose that your radio is streaming at 48
kHz and that you want to play a file at 44.1 kHz. You will have to _resample_
your file (change its sampling rate) which, in the present case, means that you
will have to come up with new samples. There are various simple strategies for
this such as copying the sample closest to a missing one, or doing a linear
interpolation between the two closest. This is what Liquidsoap is doing if you
don't have the samplerate library enabled and, believe it or not (or better try
it!), it sounds quite bad. Resampling is a complicated task to get right, and
can be costly in terms of CPU if you want to achieve good quality.

### Normalization

The next thing you want to do is to _normalize_ the sound, meaning that you want
to have roughly the same audio intensity between tracks. If they come from
different sources (such as two different albums by two different artists) this
is generally not the case.

A strategy to fix that is to use _automatic gain control_: the program can
regularly measure the current audio intensity based, say, on the previous second
of sound, and increase or decrease the volume depending on how it is with
respect to a target volume. This has the advantage of being easy to set up and
providing an homogeneous sound. It is quite efficient when having voice over the
radio, but is quite unnatural for music: if a song has a quiet introduction for
instance, its volume will be pushed up and the song as a whole will not sound as
usual.

Another strategy for music consists in pre-computing the sound intensity of each
file. It can be performed each time a song is about to be played, but the most
efficient way of proceeding consists in computing this in advance and store it
as a metadata; the stream generator can then adjust the volume on a per-song
basis. The standard for this is ReplayGain and there are a few efficient tools
to achieve this task.

### Fading

In order to ease the transition between songs, one generally uses _crossfading_
which consists in fading out one song while fading in the next one. A simple
approach can be to crossfade for say 3 seconds between the end of a song and a
beginning of the next one, but serious people want to have _cue points_, which
are metadata indicating where to start a song (not necessarily right at the
beginning of the file), where to end it, the length and type of fading to apply
and so on.

Another approach to mark the transitions between the tracks consists in adding
_jingles_ between songs: those are short audio tracks generally saying the name
of the radio and perhaps the current show. In any way, people avoid simply
playing one track after another (unless it is an album) because it sounds
awkward to the listener: it does not feel like a radio, but rather a simple
playlist.

### Equalization

The final thing you want to do is to give your radio an appreciable and
recognizable sound. This can be achieved by applying a series of sound effects.

- _compressor_: gives a more uniform sound by amplifying quiet sounds,
- _equalizing_: gives a signature to your radio by amplifying differently
  different frequency ranges (typically, simplifying a bit, you want to insist
  on bass if you play mostly lounge music in order to have a warm sound, or on
  treble if you have voices in order for them to be easy to understand),
- _limiter_: lowers the sound when there are high-intensity peaks,
- _gate_: reduce very low level sound in order for silence to be really silence
  and not low noise (in particular if you capture a microphone).

\TODO{veut-on faire une partie "technique" où l'on explique les unités courantes
comme le RMS ?}

More features
-------------

### Interacting with the world

websites, osc

### Video
