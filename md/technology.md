The technology behind a webradio
================================

This chapter does not give code, but presents the general components you
have to set up in order to build a webradio.

Before starting with the proper Liquidsoap tutorial let's describe quickly the components of the internet radio toolchain, in case the reader is not familiar with it.

The chain is made of:

* the stream generator (Liquidsoap, [ices](http://www.icecast.org/ices.php), or for example a DJ-software running on your local PC) which creates an audio stream (Ogg Vorbis or MP3);
* the streaming media server ([Icecast](http://www.icecast.org), [Shoutcast](http://www.shoutcast.com), ...) which relays several streams from their sources to their listeners;
* the media player (iTunes, Winamp, ...) which gets the audio stream from the streaming media server and plays it to the listener's speakers.

![Internet radio toolchain](images/schema-webradio-inkscape.png)

The stream is always passed from the stream generator to the server, whether or not there are listeners. It is then sent by the server to every listener. The more listeners you have, the more bandwidth you need.

If you use Icecast, you can broadcast more than one audio feed using the same
server. Each audio feed or stream is identified by its "mount point" on the
server. If you connect to the `foo.ogg` mount point, the URL of your stream will
be [http://localhost:8000/foo.ogg](`http://localhost:8000/foo.ogg`) -- assuming
that your Icecast is on localhost on port 8000. If you need further information
on this you might want to read Icecast's
[documentation](http://www.icecast.org). A proper setup of a streaming server is
required for running Liquidsoap.

Audio streams
-------------

### Encoding

Encoding (mp3, etc.)

### Streaming

Icecast, buffering, connections, packets

### Metadata

Audio sources
-------------

### Playlists

### Dynamic playlists

### Other sources

microphone

Audio processing
----------------

### Fading

### Normalization

Replaygain

### Equalization

More features
-------------

### Video
