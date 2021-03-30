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
HLS (see below), it tends to be more and more replaced by a traditional web
server.

A _media player_, which connects to the server and plays the stream for the
client, it can either be a software (such as iTunes), an Android application, or
a website.

After general considerations about compressed audio streams ([this
section](#sec:audio-streams)), we detail the technical challenges and tools at
our disposal for streaming media systems ([this section](#sec:audio-streaming))
and stream generators ([this section](#sec:audio-sources), [this
section](#sec:audio-processing) and [this section](#sec:audio-interaction)). In
particular, we will see in later chapters that all the desirable features
described here for stream generators can be achieved with Liquidsoap. Finally,
in [the last section](#sec:video-streams), we discuss the generation of video
streams.

Audio streams {#sec:audio-streams}
-------------

### Digital audio

Sound consists in regular vibrations of the ambient air, going back and forth,
which you perceive through the displacements of the tympanic membrane they
induce in your ear. In order to be represented in a computer, such a sound is
usually captured by a microphone, which also has a membrane, and is represented
by samples, corresponding to the successive positions of the membrane of the
microphone. In general, sound is sampled at 44.1 kHz, which means that samples
are captured 44100 times per second, and indicate the position of the membrane,
which is represented by a floating point number, conventionally between -1
and 1. In the figure below, the position of the membrane is represented by the
continuous black curve and the successive samples correspond to the grayed
rectangles:

![Sampling](fig/sampling)\

The way this data is represented is a matter of convention and many of those can
be found in "nature":

- the sampling rate is typically 44.1 kHz (this is for instance the case in
  audio CDs), but the movie industry likes more 48 kHz, and recent equipment and
  studios use higher rates for better precision (e.g. DVDs are sampled at 92
  kHz),
- the representation of samples varies: Liquidsoap internally uses floats
  between -1 and 1 (stored in double precision with 64 bits), but other
  conventions exist (e.g. CDs use 16 bits integers ranging from -32768 to 32767,
  and 24 bits integers are also common).

In any case, this means lots of data. For instance, an audio sample in CD
quality takes 2 bytes (= 16 bits, remember that a byte is 8 bits) for each of
the 2 channels and 1 minute of sound is 44100×2×2×60 bytes, which is roughly
10 MB per minute.

### Compression

Because of the large quantities of data involved, sound is typically compressed,
especially if you want to send it over the internet where the bandwidth,
i.e. the quantity of information you can send in a given period of time,
matters: it is not unlimited and it costs money. To give you an idea, a typical
fiber connection nowadays has an upload rate of 100 megabits per second, with
which you can send CD quality audio to roughly 70 listeners only.

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
instance, the ears are much more sensitive in the 1 to 5 kHz range so that we
can be more rough outside this range, some low intensity signals can be masked
by high intensity signals (i.e., we do not hear them anymore in presence of
other loud sound sources), they do not generally perceive phase difference under
a certain frequency so that all audio data below that threshold can be encoded
in mono, and so on. Most compression formats are _destructive_: they remove some
information in the original signal in order for it to be smaller. The most
well-known are mp3, opus and aac: the one you want to use is a matter of taste
and support on the user-end. For instance, mp3 is the most widespread, opus has
the advantage of being open-source, patent-free, has a good quality/bandwidth
radio and is reasonably supported by modern browsers although hardware support
is almost nonexistent, aac is proprietary so that good free encoders are more
difficult to find (because they are subject to licensing fees) but achieves good
sounding at high compression rates and is quite well supported, etc. A typical
mp3 is encoded at a bitrate of 128 kbps (kilobits per second, although rates of
192 kbps and higher are recommended if you favor sound quality), meaning that 1
minute will weight roughly 1 MB, which is 10% of the original sound in CD
quality.

Most of these formats also support _variable bitrates_ meaning that the bitrate
can be adapted within the file: complex parts of the audio will be encoded at
higher rates and simpler ones at low rates. For those, the resulting stream size
will heavily depend on the actual audio and is thus more difficult to predict,
by the perceived quality is higher.

As a side note, we were a bit imprecise above when speaking of a "file format"
and we should distinguish between two things: the _codec_ is the algorithm we
used to compress the audio data, and the _container_ is the file format used to
store the compressed data. This is why one generally speaks of ogg/opus: ogg is
the container and opus is the codec. A container can usually embed streams
encoded with various codecs (e.g. ogg can also contain flac or vorbis streams),
and a given codec can be embedded in various containers (e.g. flac and vorbis
streams can also be embedded into Matroska containers). In particular, for video
streams, the container typically contains multiple streams (one for video and
one for audio), each encoded with a different codec, as well as other
information (metadata, subtitles, etc.).

### Metadata

Most audio streams are equipped with _metadata_ which are textual information
describing the contents of the audio. A typical music file will contain, as
metadata, the title, the artist, the album name, the year of recording, and so
on. Custom metadata are also useful to indicate the loudness of the file, the
desired cue points, and so on (see below).

Streaming {#sec:audio-streaming}
---------

<!--
- buffering
- we want one machine to broadcast streams from other (possibly multiple) sources
- it needs to know a bit of the protocol in order to split data into reasonable packets (+ replay an modify metadata, etc)
- multiple bitrates
- caching
-->

Once properly encoded, the streaming of audio data is generally not performed
directly by the stream generator (such as Liquidsoap) to the client, a streaming
server generally takes care of this. One reason to want separate tools is for
reliability: if the streaming server gets down at some point because too many
auditors connect simultaneously at some point, we still want the stream
generator to work so that the physical radio or the archiving are still
operational.

Another reason is that this is a quite technical task. In order to be
transported, the streams have to be split in small packets in such a way that a
listener can easily start listening to a stream in the middle and can cope with
the loss of some of them. Moreover, the time the data takes from the server to
the client can vary over time (depending on the load of the network or the route
taken): in order to cope with this the clients, do not play the received data
immediately, but store some of it in advance, so that they still have something
to play if next part of the stream comes late, this is called
_buffering_. Finally, one machine is never enough to face the whole internet, so
we should have the possibility of distributing the workload over multiple
servers in order to handle large amounts of simultaneous connections.

### Icecast

Historically, Icecast was the main open-source server used in order to serve
streams over the internet. On a first connection, the client starts by buffering
audio (in order to be able to cope with possible slowdowns of the network):
Icecast therefore begins by feeding it up as fast as possible and then sends the
data at a peaceful rate. It also takes care of handling multiple stream
generators (which are called _mountpoints_ in its terminology), multiple
clients, replaying metadata (so that we have the title of the current song even
if we started listening to it in the middle), recording statistics, enforcing
limits (on clients or bandwidth), and so on. Icecast servers support relaying
streams from other servers, which is useful in order to distribute listening
clients across multiple physical machines, when many of them are expected to
connect simultaneously.

### HLS {#sec:HLS}

Until recently, the streaming model as offered by Icecast was predominant, but
it suffers from two main drawbacks. Firstly, the connection has to be kept
between the client and the server for the whole duration of the stream, which
cannot be guaranteed in mobile contexts: when you connect with your smartphone,
you frequently change networks or switch between wifi and 4G and the connection
cannot be held during such events. In this case, the client has to make a new
connection to the Icecast server, which in practice induces blanks and glitches
in the audio for the listener. Another issue is that the data cannot be cached
as it is done for web traffic, because each connection can induce a different
response, where it helps lowering the latencies and bandwidth-related costs.

For these reasons, new standards such as HLS (for _HTTP Live Stream_) or
MPEG-DASH (for _Dynamic Adaptive Streaming over HTTP_) have emerged, where the
stream is provided as a rolling playlist of small files called segments: a
playlist typically contains the last minute of audio split into segments of 2
seconds. Moreover, the playlist can indicate multiple versions of the stream
with various formats and encoding qualities, so that the client can switch to a
lower bitrate if the connection becomes bad and back to higher bitrates when it
is better again, without interrupting the stream: this is called _adaptative_
streaming. Here, the files are downloaded one by one, and are served by an usual
HTTP server. This means that we can reuse all the technology developed for those
to scale up and improve the speed, such as load balancing and caching techniques
typically provided by content delivery networks. It seems that such formats will
take over audio distribution in the near future, and Liquidsoap already has
support for them. Their only drawback is that they are more recent and thus less
well supported on old clients, although this tends to be less and less the case.

### RTMP

Finally, we would like to mention that, nowadays, streaming is more and more
being delegated to big online platforms, such as Youtube or Twitch, because of
their ease of use, both in terms of setup and of user experience. Those
generally use another protocol, called RTMP (_Real-Time Messaging Protocol_),
which is more suited to transmitting live streams, where it is more important to
keep the latency low (i.e. transmit the information as close as possible to the
instant where it happened) than keep its integrity (dropping small parts of the
audio or video is considered acceptable).

Audio sources {#sec:audio-sources}
-------------

In order to make a radio, one has to start with a primary source of audio. We
give examples of such below.

### Audio files

A typical radio starts with one or more _playlists_, which are lists of audio
files. These can be stored in various places: they can either be on a local hard
drive, or on some distant server, in which case they have to be downloaded
beforehand, in order to make sure that we will not suffer from disturbances in
the network.\SM{say what an uri "Uniform Resource Identifier" is} There is a
slight difference between the two: in the case of local files, we have pretty
good confidence that they will always be available (or at least we can check
that this is the case), whereas for distant files the server might be
unavailable, or just very slow, so that we have to take care of downloading the
file in advance enough and be prepared to have fallback option in case the file
is not ready in time. Finally, audio files can be in various formats (as
described in [the above section](#sec:audio-streams)) and have to be decoded,
which is why Liquidsoap depends on many libraries, in order to support as many
formats as possible.

Even in the case of local files, the playlist might be _dynamic_: instead of
knowing in advance the list of all the files, the playlist can consist of a
queue of _requests_ made by users (e.g., via a website or a chatbot); we can
even call a script which will return the next song to be played, depending on
whichever parameters (for instance taking in account votes on a website).

### Live inputs

A radio often features live shows. As in the old days, the speaker can be in the
same room as in the server, in which case the sound is directly captured by a
sound card. But now, live shows are made more and more from home, where the
speaker will stream its voice to the radio itself, which should be able to
interrupt its contents and relay the stream. More generally, a radio should be
able to relay other streams along with their metadata (e.g. when a program is
shared between multiple radios) or other sources (e.g. a live youtube channel).

As for distant files, we should be able to cleanly handle failures due to
network. Another issue specific to live streams is that we do not have control
over time: this is an issue for operations such as crossfading (see below) which
requires shifting time and thus cannot be performed on realtime sources.

### Synchronization

In order to provide samples at a regular pace a source has an _internal clock_
which will tick regularly: each soundcard has a clock, your computer has a
clock, the live streams are generated by things which have clocks. Now, suppose
that you have two soundcards generating sound at 44100 Hz, meaning that their
internal clocks both tick at 44100 Hz. Those are not infinitely precise and it
might be the case that there is a slight difference if 1 Hz between the two
(maybe one it ticking at 44099.6 Hz and the other one at 44100.6 Hz in
reality). Usually, this is not a problem, but on the long run it is: this 1 Hz
difference means that one will be 1 second in advance to the other after a
month. For a radio which is supposed to be running for years (say that you
update it once a year), this will be an issue and the stream generator has to
take care of that, typically by using buffers. This is not a theoretical issue:
first versions of Liquidsoap did not carefully handle this and we did experience
quite a few problems related to it.

Audio processing {#sec:audio-processing}
----------------

### Resampling

As explained in [the above section](#sec:audio-streams), various files have
various sampling rates. For instance, suppose that your radio is streaming at 48
kHz and that you want to play a file at 44.1 kHz. You will have to _resample_
your file (change its sampling rate) which, in the present case, means that you
will have to come up with new samples. There are various simple strategies for
this such as copying the sample closest to a missing one, or doing a linear
interpolation between the two closest. This is what Liquidsoap is doing if you
don't have the libsamplerate library enabled and, believe it or not (or better try
it!), it sounds quite bad. Resampling is a complicated task to get right, and
can be costly in terms of CPU if you want to achieve good quality.

### Normalization

The next thing you want to do is to _normalize_ the sound, meaning that you want
to have roughly the same audio loudness between tracks. If they come from
different sources (such as two different albums by two different artists) this
is generally not the case.

A strategy to fix that is to use _automatic gain control_: the program can
regularly measure the current audio loudness based, say, on the previous second
of sound, and increase or decrease the volume depending on how it is with
respect to a target volume. This has the advantage of being easy to set up and
providing an homogeneous sound. It is quite efficient when having voice over the
radio, but is quite unnatural for music: if a song has a quiet introduction for
instance, its volume will be pushed up and the song as a whole will not sound as
usual.

Another strategy for music consists in pre-computing the loudness of each
file. It can be performed each time a song is about to be played, but the most
efficient way of proceeding consists in computing this in advance and store it
as a metadata; the stream generator can then adjust the volume on a per-song
basis. The standard for this is _ReplayGain_ and there are a few efficient tools
to achieve this task. It is also more natural than basic gain control, because
it takes in account the way our ears perceive sound in order to compute
loudness.

At this point, we should also indicate that there is a subtlety in the way we
measure amplification. They are either measured _linearly_, i.e. we indicate the
amplification coefficient by which we should multiply the sound, or in
_decibels_. The relationship between linear _l_ and decibel _d_ measurements is
not easy, the formulas relating the two are _d_=20 log~10~(_l_) and
_l_=10^_d_/20^. If your math classes are too far away, you should only remember
that 0 dB means no amplification (we multiply by the amplification coefficient
1), adding 6 dB corresponds to multiplying by 2, and removing 6dB corresponds to
dividing by 2:

------------- ---- --- -- -- -- --
decibels      -12  -6  0  6  12 18
amplification 0.25 0.5 1  2  4  8
------------- ---- --- -- -- -- --

This means that an amplification of -12 dB corresponds to multiplying all the
samples of the sound by 0.25, which amounts to dividing them by 4.

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
awkward to the listener: it does not feel like a proper radio, but rather like a
simple playlist.

### Equalization

The final thing you want to do is to give your radio an appreciable and
recognizable sound. This can be achieved by applying a series of sound effects
such as a

- _compressor_: gives a more uniform sound by amplifying quiet sounds,
- _equalizer_: gives a signature to your radio by amplifying differently
  different frequency ranges (typically, simplifying a bit, you want to insist
  on bass if you play mostly lounge music in order to have a warm sound, or on
  treble if you have voices in order for them to be easy to understand),
- _limiter_: lowers the sound when there are high-intensity peaks (we want to
  avoid clipping),
- _gate_: reduce very low level sound in order for silence to be really silence
  and not low noise (in particular if you capture a microphone).

These descriptions are very rough and we urge the reader not accustomed with
those basic components of signal processing to learn more about them. You will
need those at some point of you want to make a professional sounding webradio.

### The processing loop

Because we generally want to perform all those operations on audio signals, the
typical processing loop will consist in

1. decoding audio files,
2. processing the audio (fading, equalizing, etc.),
3. encoding the audio,
4. streaming encoded audio.

If for some reason we do not want to perform any audio processing (for instance,
if this processing was done offline, or if we are relaying some already
processed audio stream), the second phase is empty and if the encoding format is
the same as the source format there is no need to decode and then reencode in
the same format, and we can directly stream the original encoded files. By
default, Liquidsoap will always reencode files but this can be avoided since
recent versions (see [there](#sec:...)).

Interaction {#sec:audio-interaction}
-----------

What we have described so far is more or less the direct adaptation of
traditional radio techniques to the digital world. But with new tools come new
usages, and a webradio generally requires more than the above features. In
particular, we should be able to interact with other programs and services.

### Interacting with other programs

Whichever tool you are going to use in order to generate your webradio, it is
never going to support all the features that a user will require. At some point,
the use of an obscure hardware interface, database, or whatsoever will be
required by a client, which will not be supported out of the shelf by the
tool. Or maybe you simply want to be able to reuse parts of the scripts that you
spent years to write in your favorite language.

For this reason, a stream generator should be able to interact with other tools,
by calling external programs or scripts, written in whichever language. For
instance, we should be able handle _dynamic playlists_, which are playlists
where the list of songs is not determined in advance, but the next song to play
is rather determined each time the previous one has ended. In order to obtain
the name of the next song, we should be able to call an external script.

We should also be able to easily import data generated by other programs, the
usual mechanism being by reading the standard plain text output of the executed
program. This means that we should also have tools to parse and manipulate this
standard output. Typically, structured data such as the result of a query on a
database can be output in standard formats such as JSON, for which we should
have support.

Finally, we should be able to interact with some more specific external
programs, such as for monitoring scripts (in order to understand its state and
be quickly notified in case of a problem).

### Interacting with other services

The above way of interacting works in _pull mode_: the stream generators asks an
external program for information, such as the next song to be played. Another
desirable workflow is in _push mode_, where the program adds information
whenever it feels like. This is typically the case for _request queues_ which
are, again, a variant of playlists, where an external programs can add songs
whenever it feels like: those will be played one, in the order where they where
inserted. This is typically used for interactive websites: whenever a user asks
for a song, it gets added to the request queue.

Push mode interaction is also commonly used for controllers, which are physical
or virtual devices consisting of push buttons and sliders, that one can use in
order to switch between audio sources, change the volume of a stream, and so
on. The device generally notifies the stream generator when some control gets
changed, which should then react accordingly. The commonly used standard
nowadays for communicating with controllers is called OSC (_Open Sound
Control_).

Video streams {#sec:video-streams}
-------------

The workflow for generating video streams is not fundamentally different to what
we have described above, so that one can expect that an audio stream generator
can also be used to generate video. In practice, this is rarely the case because
manipulating video is an order of magnitude harder to implement. Since the main
focus of this book is for audio streams, we only briefly explain the main
technological issues related to video.

### Video data

The first thing to notice is that if processing and transmitting audio requires
handling large amounts of data, video requires processing *huge* amounts of
data. A video in a decent resolution has 25 images per second at a resolution of
720p, which means 1280×720 pixels, each pixels consisting of three channels
(generally, red, green and blue, or _RGB_ for short) each of which is usually
coded on one byte. This means that one second of uncompressed video data weights
65 MB (which is worth more than 6 minutes of CD audio)! And these are only the
minimal requirements for a video to be called HD (_High Definition_), which is
the kind of video which is being watched everyday on the internet: in practice,
even low-end devices can produce much higher resolutions than this.

This volume of data means that manipulation of video, such as combining videos
or applying effects, should be coded very efficiently (by which we mean down to
fine-tuning the assembly code for some parts), otherwise the stream generator
will not be able to apply them in realtime on a standard recent computer. It
also means that even copying of data should be avoided, the speed of memory is
also a problem at such rates.

An usual video actually consists of two streams: one for the video and one for
the audio. We want to be able to handle them separately, so that we can apply
all the operations specific to audio described in previous sections to videos,
but the video and audio stream should be kept in perfect sync (even a very small
delay between audio is video can be noticed).

As a side note, in practice, video pixels are not represented by red, green and
blue channels as we learn in school, but in another base often called _YUV_
consisting of one _luma_ channel Y (roughly, the black and white component of
the image) and two _chroma_ channels U and V (roughly, the color part of the
image represented as blueness and redness). Moreover, because the eye is much
more sensitive to the variations in luma than in chroma components, we can use
one Y byte for each pixel and one U byte and one V byte for every four pixels,
thus using 1.5 byte per pixel instead of 3 for traditional RGB
representation. The conversion between YUV and RGB is not entirely trivial and
costs in terms of computations, so it is generally better to code video
manipulations directly on the YUV representation.

### File formats

We have seen that there is quite a few compressed formats available for audio
and the situation is the same for video, but the video codecs generally involve
many configuration options exploiting specificities of video, such as the fact
two consecutive images in a video are usually quite similar. Fortunately, most
of the common formats are handled by high-level libraries such as _FFmpeg_. This
solves the problem for decoding, but for encoding we are still left with many
parameters to specify, which can have a large impact on the quality of the
encoded video and on the speed of the compression (finding the good balance is
somewhat of an art).

### Video effects

As for audio, many manipulation of video files are expected to be present in a
typical workflow.

- _Fading_: as for audio tracks, we should be able to fade between successive
  videos, this can be a smooth fade, or one video slides on top of the other,
  and so on.
- _Visual identity_: we should be able to add the logo of our channel, add a
  sliding text at the bottom displaying the news or listing the shows to come.
- _Color grading_: as for audio tracks, we should be able to give a particular
  ambiance by having uniform colors and intensities between tracks.
