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

Audio streams
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
1. But this is a matter of convention and many of those can be found in
"nature":

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
is the most widespread, ogg/vorbis has the advantage of being open-source
patent-free and more efficient but not many users have good support for that
(e.g. on smartphones), aac is proprietary so that good free encoders are more
difficult to find but achieves better sounding at high compression rates, etc. A
typical mp3 is encoded at a bitrate of 128 kbps (kilobits per second, although
rates of 192 kbps and higher are recommended if you favor sound quality),
meaning that 1 minute will weight roughly 1 MB, which is 10% of the original
sound in CD quality.

Most of these formats also support _variable bitrates_ meaning that the bitrate
can be adapted within the file: complex parts of the audio will be encoded at
higher rates and simpler ones at low rates. For those, the resulting stream size
will heavily depend on the actual audio and is thus more difficult to predict,
by the perceived quality is higher.

TOOD: explain the difference between containers and codecs..............

### Metadata

Most audio streams are equipped with _metadata_ which are textual information
describing the contents of the audio. A typical music file will contain, as
metadata, the title, the artist, the album name, the year of recording, and so
on. Custom metadata are also useful to indicate the loudness of the file, the
desired cue points, and so on (see below).

### Streaming



Icecast, buffering, connections, packets, limit, stats

If you use Icecast, you can broadcast more than one audio feed using the same
server. Each audio feed or stream is identified by its "mount point" on the
server. If you connect to the `foo.ogg` mount point, the URL of your stream will
be [http://localhost:8000/foo.ogg](`http://localhost:8000/foo.ogg`) -- assuming
that your Icecast is on localhost on port 8000. If you need further information
on this you might want to read Icecast's
[documentation](http://www.icecast.org). A proper setup of a streaming server is
required for running Liquidsoap.

HLS, better: we can disconnect, the files can be cached (thus cheaper bandwidth)

RTMP

platforms such as youtube

see

- https://stackoverflow.com/questions/30184520/whats-the-best-protocol-for-live-audio-radio-streaming-for-mobile-and-web

Audio sources
-------------

### Playlists

### Dynamic playlists

### Other sources

microphone

TODO: difference between files and live sources (e.g. we cannot fade)

Audio processing
----------------

### Resampling

The fist thing we want to do, not easy

### Fading

### Normalization

Replaygain

### Equalization

More features
-------------

### Video
