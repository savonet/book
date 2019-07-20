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

### Encoding

Encoding (mp3, ogg, flac, HE-AAC, etc.)

bandwidth, audio quality (flac is lossless), proprietary or not

### Metadata

### Streaming

Icecast, buffering, connections, packets

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
