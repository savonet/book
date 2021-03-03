A streaming language {#chap:streaming}
====================

The previous chapter should have convinced you that Liquidsoap is a pretty
decent general-purpose scripting language. But what makes it unique is the
features dedicated to streaming. In this chapter, we present the general
concepts behind those, they will be put in use in subsequent chapters.

The main purpose of Liquidsoap is to manipulate functions which will generate
streams and are called _sources_ in Liquidsoap. Typically, the `playlist`
operator is a source, which generates streams by sequentially reading files. The
way sources generate audio or video data is handled abstractly: you almost never
get down to the point where you need to understand how or in what format this
data is actually generated, you usually simply combine sources in order to get
elaborate ones. It is however useful to have a general idea of how Liquidsoap
works internally. This chapter is a bit more technical than others: at a first
reading, it might be a good idea to go though it quickly, and come back later to
it when a deeper knowledge about a specific point is required.

Sources and content types {#sec:source-type}
-------------------------

Each source has a number of channels of

- _audio_ data: containing sound,
- _video_ data: containing animated videos,
- _midi_ data: containing notes to be played (typically, by a synthesizer).

The last kind of data is much less used in practice in Liquidsoap, so that we
will insist less on it. Moreover, each of those channels can either contain

- _raw_ data: this data is in an internal format (usually obtained by decoding
  compressed files), suitable for manipulation by operators within Liquidsoap,
  or
- _encoded_ data: this is compressed data which Liquidsoap is not able to
  modify, such as audio data in mp3 format.

In practice, users manipulate sources handling raw data most of the time since
most operations are not available on encoded data, even very basic ones such as
changing the volume or performing transitions between tracks. Encoded data was
introduced starting from version 2.0 of Liquidsoap and is however useful for
avoiding to have to encode a stream multiple times in the same format, e.g. when
sending the same encoded stream to multiple icecast instances, or both to
icecast and in HLS, etc.

The type of sources is of the form

```
source(audio=..., video=..., midi=...)
```

where the "`...`" indicate the _contents_ that the source can generate, i.e. the
number of channels, and their nature, for audio, video and midi data, that the
source can generate. For instance, the type of `sine` is

```
(?amplitude : {float}, ?duration : float, ?{float}) -> source(audio=internal('a), video=internal('b), midi=internal('c))
```

We see see that it takes 3 optional arguments (the amplitude, the duration and
the frequency) and returns a source as indicated by the type of the returned
value: `source(...)`. The parameters of `source` indicate the nature and number
of channels: here we see that audio is generated in some internal format (call
it `'a`), video is generated in some internal data format (call it `'b`) and
similarly for midi. The contents `internal` does not specify any number of
channels, which means that any number of channels can be generated. Of course,
only the audio channels are going to be meaningful:

- if multiple audio channels are requested, they will all contain the same audio
  consisting of a sine waveform, with specified frequency and amplitude,
- if video channels are requested they are all going to be blank,
- if midi channels are requested, the are not going to contain any note.

As another example, consider the type of the operator `drop_audio` which removes
audio from a source:

```
(source(audio='a, video='b, midi='c)) -> source(audio=none, video='b, midi='c)
```

We see that it takes a source as argument and returns another source. We also
see that that is accepts any audio, video and midi contents for the input
source, be they in internal format or not, calling them respectively `'a`, `'b`
and `'c`. The output source has `none` as audio contents, meaning that it will
have no audio at all, and that the video content is the same as the content for
the input (`'b`), and similarly for midi content (`'c`).

### Internal contents

Contents of the form `internal('a)` only impose that the format is one supported
internally. If we want to be more specific, we can specify the actual
contents. For instance, the internal contents are:

- for raw audio: `pcm`
- for raw video: `yuva420p`
- for midi: `midi`

The arguments of `pcm` is the number of channels which can either be `none` (0
audio channel), `mono` (1 audio channel), `stereo` (2 audio channels) or `5.1`
(6 channels for surround sound: front left, front right, front center,
subwoofer, surround left and surround right, in this order). For instance, the
operator `mean` takes an audio stream and returns a mono stream, obtained by
taking the mean over all the channels. Its type is

```
(source(audio=pcm('a), video='b, midi='c)) -> source(audio=pcm(mono), video='b, midi='c)
```

We see that the audio contents of the input source is `pcm('a)` which means any
number of channels of raw audio, and the corresponding type for audio in the
output is `pcm(mono)`, which means mono raw audio, as expected. We can also see
that the video and midi channels are preserved since their names (`'b` and `'c`)
are the same in the input and the output.

Note that the contents `none` and `pcm(none)` are not exactly the same: for the
first we know that there is no audio whereas for the second we now that there is
no audio and that this is encoded in `pcm` format (if you have troubles grasping
the subtlety don't worry, this is never useful in practice). For this reason
`internal('a)` and `pcm('a)` express almost the same content but not
exactly. Every content valid for the second, such as `pcm(stereo)`, is also
valid for the first, but the content `none` is only accepted by the first
(again, this subtle difference can be ignored in practice).

For now, `yuva420p` does not take any argument. The only argument of `midi` is
of the form `channels=n` where `n` is the number of midi channels of the
stream. For instance, the operator `synth.all.sine` which generates sound for
all midi channels using sine waves has type

```
(source(audio=pcm(mono), video='a, midi=midi(channels=16))) -> source(audio=pcm(mono), video='a, midi=midi(channels=16))
```

We see that it takes a stream with mono audio and 16 midi channels as argument
and returns a stream of the same type.

### Encoded contents

Liquidsoap has support for the wonderful
[FFmpeg](https://ffmpeg.org/)\index{FFmpeg} library which allow for manipulating
audio and video data in most common (and uncommon) video formats: it can be used
to convert between different formats, apply effects, etc. By the way, if
converting files is the only thing you want to do, you don't need to use
Liquidsoap: you can directly use the `ffmpeg` commandline program, which is a
frontend for the library. This is implemented by having native support for

- the raw FFmpeg formats: `ffmpeg.audio.raw` and `ffmpeg.video.raw`,
- the encoded FFmpeg formats: `ffmpeg.audio.copy` and `ffmpeg.video.copy`.

Typically, the raw formats used in order to input from or output data to FFmpeg
filters, whose use is detailed in [there](...)\TODO{reference}: as for
Liquidsoap, FFmpeg can only process decoded raw data. The encoded formats are
used to handled encoded data, such as sound in mp3, typically in order to encode
the stream once in mp3 and output the result both in a file and to Icecast, this
is detailed in [there](...)\TODO{reference}. Their name come from the fact that
when using those, Liquidsoap simply copies and passes on data generated by
FFmpeg without having a look into it.

Conversion from FFmpeg raw contents to internal Liquidsoap contents can be
performed with the function `ffmpeg.raw.decode.audio`, which _decodes_ FFmpeg
contents into Liquidsoap contents. Its type is

```
(?buffer : float, ?max : float, source(audio=ffmpeg.audio.raw('a), video=none, midi=none)) -> source(audio=pcm('b), video=none, midi=none)
```

Ignoring the two optional arguments `buffer` and `max`, which control the
buffering used by the function, we see that this function takes a source whose
audio has `ffmpeg.audio.raw` contents and output a source whose audio has `pcm`
contents. The functions `ffmpeg.raw.decode.video` and
`ffmpeg.raw.decode.audio_video` work similarly with streams containing video and
both audio and video respectively. The functions `ffmpeg.decode.audio`,
`ffmpeg.decode.video` and `ffmpeg.decode.audio_video` have similar effect to
decode FFmpeg encoded contents to Liquidsoap contents, for instance the type of
the last one is

```
(?buffer : float, ?max : float, source(audio=ffmpeg.audio.copy('a), video=ffmpeg.video.copy('b), midi=none)) -> source(audio=pcm('c), video=yuva420p('d), midi=none)
```

Conversely, the functions `ffmpeg.raw.encode.audio`, `ffmpeg.raw.encode.video`
and `ffmpeg.raw.encode.audio_video` can be used to encode Liquidsoap contents
into FFmpeg raw contents, and the functions `ffmpeg.encode.audio`,
`ffmpeg.encode.video` and `ffmpeg.encode.audio_video` can encode into FFmpeg
encoded contents.

The parameters for the FFmpeg contents are as follows (those should be compared
with the description of the raw contents used in Liquidsoap, described in
[there](#sec:liquidsoap-raw)):

- `ffmpeg.audio.raw`
  - `channel_layout`: number of channels and their ordering (it can be `mono`,
    `stereo` or `5.1` as for Liquidsoap contents, but many more are supported
    such as `7.1` or `hexagonal`, the full list can be obtained by running the
    command `ffmpeg -layouts`)
  - `sample_format`: encoding of each sample (`dbl` is double precision float,
     which is the same as used in Liquidsoap, but many more are supported such
     as `s16` and `s32` for signed 16- and 32-bits integers, see
     `ffmpeg -sample_fmts` for the full list),
  - `sample_rate`: number of samples per second (typically, 44100),
- `ffmpeg.video.raw`
  - `width` and `height`: dimensions in pixels of the images,
  - `pixel_format`: the way each pixel is encoded (such as `rgba` for
    red/green/blue/alpha or `yuva420p` as used in Liquidsoap, see `ffmpeg
    -pix_fmts`),
  - `pixel_aspect`: the aspect ratio of the image (typically `16:9` or `4:3`)
- `ffmpeg.audio.copy`: parameters are `codec` (the algorithm used to encode
  audio such as `mp3` or `aac`, see `ffmpeg -codecs` for a full list),
  `channel_layout`, `sample_format` and `sample_rate`,
- `ffmpeg.video.copy`: parameters are `codec`, `width`, `height`, `aspect_ratio`
  and `pixel_format`.

### Passive and active sources

Most of the sources are _passive_ which means that they are simply waiting to be
asked for some data, they are not responsible for when the data is going to be
produced. For instance, a playlist is a passive source: we can decode the files
of the playlist at the rate we want. However, some sources are _active_ which
means that we do not have control over the rate at which the data is
produced. This is typically the case with a soundcard which regularly produces
data, at a rate which is controlled by the hardware, and this is indicated in
the type. For instance, the type of the `input.alsa` function (which inputs from
a soundcard) is

```
(...) -> active_source(audio=pcm('a), video='b, midi='c)
```

We see that the returned type is `active_source` instead of `souce`, which
indicates that it is active. Any active source is a particular case of a source,
so that we can feed the result of `input.alsa` to an operator requiring a
source, such as `amplify` whose type is

```
({float}, source(audio=pcm('a), video='b, midi='c)) -> source(audio=pcm('a), video='b, midi='c)
```

as in the script

```{.liquidsoap include="liq/alsa-amplify.liq" from=1}
```

(namely, `mic` is of type `active_source` and `amplify` requires an argument of
type `source`, which does not cause any problem). Outputs to soundcard (such as
`output.alsa` or `output.pulseaudio`) are also active because the rate of the
output is controlled by the soundcard. The reason for distinguishing active
sources is further explained in [there](#sec:stream-generation).

### Type inference

In order to determine the type of the sources, Liquidsoap looks where they are
used and deduces constraints on their type. For instance, consider a script of
the following form:

<!-- See source-ti.liq -->
```liquidsoap
s = ...
output.alsa(s)
output.sdl(s)
```

In the first line, suppose that we do not know yet what the type of the source
`s` should be. On the second line, we see that it is used as an argument of
`output.alsa` and should therefore have a type of the form
`source(audio=pcm('a), video='b, midi='c)`, i.e. the audio should be in `pcm`
format. Similarly, on the second line, we see that it is used as an argument of
`output.sdl` (which displays the video of the stream) and should therefore have
a type of the form `source(audio='a, video=yuva420p('b), midi='c))`, i.e. the
video should be in `yuva420p` format. Combining the two constraints, we deduce
that the type of the source should be of the form `source(audio=pcm('a),
video=yuva420p('b), midi='c)`.

In the end, the parameters of the stream which are not fixed will be taken to be
default values. For instance, the number of audio channels will take the default
value 2 (stereo), which is specified in the configuration option
`frame.audio.channels`. So that if we want streams to be mono by default, we can
type, at the beginning of the script,

```{.liquidsoap include="liq/set-channels.liq" from=1}
```

Similarly, the default number of midi channels is 0, since it is expected to be
useless for most users, and can be changed in the configuration option
`frame.midi.channels`. Once determined at startup, the contents of the streams
(such as number of audio channels) are fixed during the whole execution of the
script. Earlier versions of Liquidsoap somehow supported sources with varying
contents, but this was removed because it turned out to be error-prone and not
used much in practice.

During the type checking phase, it can happen that two constraints are not
compatible for a stream, in which case an error is returned before the script is
executed. For instance, suppose that we have a source `s` and we execute the
following script:

```{.liquidsoap include="liq/bad/encoded-amplify.liq" from=2}
```

We recall that the type of `amplify` is essentially

```
(float, source(audio=pcm('a), video='b, midi='c)) -> source(audio=pcm('a), video='b, midi='c)
```

and the one of `ffmpeg.decode.audio` is essentially

```
(source(audio=ffmpeg.audio.copy('a), video=none, midi=none)) -> source(audio=pcm('b), video=none, midi=none)

```

On the first line of the script above, we are using `amplify` on `s` which means
that `s` should be of the form `source(audio=pcm('a), video='b, midi='c)`,
i.e. the audio should be in `pcm` format, because `amplify` can only work on
internal data. Moreover, the type of `t` should be the same as the one of `s`
because the type of the output of `amplify` is the same as the source given as
argument. However, on the second line, we use `u` as argument for
`ffmpeg.decode.audio`, which means that it should have a type of the form
`source(audio=ffmpeg.audio.copy('a), video=none, midi=none)` and now we have a
problem: the audio of the source `u` should both be encoded in `pcm` and in
`ffmpeg.audio.copy` formats, which is impossible. This explains why Liquidsoap
raises the following error

```
At line 2, char 24:
Error 5: this value has type
  source(audio=pcm(_),...) (inferred at line 1, char 4-18)
but it should be a subtype of
  source(audio=ffmpeg.audio.copy(_),...)
```

which is precisely a way to state the above.

### Adding and removing channels

As a final remark on the design of our typing system, one could wonder why the
type of the source returned by the `sine` operator is

```
source(audio=internal('a), video=internal('b), midi=internal('c))
```

and not

```
source(audio=internal('a), video=none, midi=none)
```

i.e. why allow the `sine` operator to generate video and midi data, whereas
those are always useless (they are blank). The reason is that 

we state that the `sine` operator can generate video (and midi) data,

TODO: expliquer qu'on a besoin de générer des pistes "vides" pour satisfaire les
exigeances du typage de `add`: tous doivent avoir le même nombre de canaux audio
et vidéo

```{.liquidsoap include="liq/blue-sine.liq"}
```

expliquer qu'on peut enlever l'audio et la video avec drop et rajouter avec mux

### Type annotations


If necessary we can constraint the type of a source


Example of outputing in mono

TODO: explain that we can enforce the type, eg to force mono output

```{.liquidsoap include="liq/mono-output.liq" from=1}
```

Formats
-------

Concatenating mp3 without reencoding:

```{.liquidsoap include="liq/encoded-concat.liq"}
```

They are used by file encoding, streaming functions, and FFmpeg functions

The streaming model
-------------------

At this point, we think that it is important to explain a bit how streams are
handled "under the hood", even though you should never have to explicitly deal
with this in practice.

### Frames

In a script such as

```{.liquidsoap include="liq/streaming1.liq"}
```

the active source is the one on the third line (`output.pulseaudio`), and is
thus responsible for synchronization. In practice, it waits for the soundcard to
say: "hey, my internal buffer is almost empty, now is a good time to fill me
in!". Each time this happens, the active source generates a _frame_, which is a
buffer for audio (or video) data waiting to be filled in, and passes it to the
`amplify` source asking it to fill it in. In turn, it will pass it to the `sine`
source, which will fill it with a sine, then the `amplify` source will modify
its volume, and then the `output.pulseaudio` source will send it to the
soundcard.

Although you do not usually want to change it, the default duration of a frame
can be modified with the configuration option `frame.duration` (see
[above](#sec:configuration)), which indicates the duration of a frame in
seconds. The default value is 0.04, meaning that frames are filled 25 times each
second, each frame containing 41100×0.04=1764 samples.

### Frame raw contents detailed {#sec:liquidsoap-raw}

For those whose are interested, let us provide some details about the internal
contents currently in use in Liquidsoap (don't hesitate to skip this section if
your head is starting to hurt). The raw audio contents is called `pcm` for
_pulse-code modulation_. The signal is represented by a sequence of _samples_,
one for each channel, which represent the amplitude of the signal at a given
instant. Each sample is represented by float number, between -1 and 1, stored in
double precision (using 64 bits, or 8 bytes). The samples are given regularly
for each channel of the signal, by default 44100 times per seconds: this value
is called the _sample rate_ of the signal and is stored globally in the
`frame.audio.samplerate` setting. This means that we can retrieve the value of
the samplerate with

```{.liquidsoap include="liq/samplerate-get.liq" from=1 to=1}
```

and set it to another value such as 48000 with

```{.liquidsoap include="liq/samplerate-set.liq" from=1 to=1}
```

although default samplerate of 44100 Hz is largely the most commonly in use.

A video consists of a sequence images given regularly. By default, these images
are presented at the _frame rate_ of 25 images by seconds, but this can be
changed using the setting `frame.video.framerate` similarly as above. Each image
consists of a rectangle of pixels: its default width and height are 1280 and 720
respectively (this corresponds to the resolution called 720p or _HD ready_,
which features an aspect ratio of 16:9 as commonly found on television or
computer screens), and those values can be changed through the settings
`frame.video.width` and `frame.video.height`. For instance, _full HD_ or _1080p_
format would be achieved with

```{.liquidsoap include="liq/fullhd.liq" from=1}
```

Each pixel has a color and a transparency (also sometimes called an _alpha
channel_): this last parameter controls how opaque the pixels is and is used
when superimposing two images (the less opaque a pixel of the above image is,
the more you will see the pixels below it). Traditionally, the color would be
coded in RGB, consisting of the values for the intensity of the red, green and
blue for each pixel. However, if we did things in this way, a pixel would take 4
bytes (1 byte for each color and 1 for transparency), which means 4×1280×720×25
bytes (= 87 Mb) of video per seconds, which is too much to handle in realtime
for a standard computer. For this reason, instead using the RGB representation,
we use the YUV representation (Y, U and V respectively being the _luma_, _blue
chroma_ and _red chroma components_): human eye is not very sensitive to chroma
variations, we can take the same U and V values for 4 neighboring pixels. This
means that each pixel is now encoded by 2.5 bytes (1 for Y, ¼ for U, ¼ for V and
1 for alpha) and 1 second of typical video is down to a more reasonable 54 Mb
per second.

MIDI stands for _Musical Instrument Digital Interface_ and is a (or, rather,
the) standard for communicating between various digital instruments and
devices. Liquidsoap mostly follows it and encodes data as lists of _events_
together with the time they occur and the channel on which they occur, each
event being "such note is starting to play at such velocity", "such note is
stopping to play", "the value of such controller changed", etc.

### The stream generation workflow {#sec:stream-generation}

wake up

content kind / content type setting

The ones that ask for the production of data are called _active
sources_. For instance, the function `output.pulseaudio` plays the contents of a
source on the soundcard (using the pulseaudio library). Its type is

```
(..., source(audio=pcm('a), video='b, midi='c)) ->
   active_source(audio=pcm('a), video='b, midi='c)
```

which means that it takes any source producing raw audio as input and returns an
active source: the returned type `active_source(...)` means that this operator
is active and will be responsible for asking audio to the input source. As
expected, every active source is in particular a source.

This way of functioning means that if a source is not connected to an active
source, it stream will not

```{.liquidsoap include="liq/passive.liq"}
```

TODO: expliquer le flux des sources: par exemple, si on fait un on_metadata mais
qu'on ne lit pas la sortie, la fonction n'est pas appelée...

### Decoding compressed data

Example of a log of decoder

MIME is used to guess

We also have metadata resolvers

Explain samplerate conversion, channel layout conversion, pixel format
conversion (gavl), etc.

Sometimes it will fail, for instance if test.mp3 is stereo, the following script will output an error

```{.liquidsoap include="liq/surround.liq"}
```

because we cannot implicitly convert a stereo file into 5.1

### Ticks

### Tracks

TODO: .....


### Metadata

### Catching up

We have indicated that, by default, a frame is computed every 0.04 second. In
some situations, the generation of the frame could take more than this: for
instance, we might fetch the stream over the internet and there might be a
problem in the connection, or we are using very cpu-intensive audio effects, and
so on. What happens in this case? If this is for a very short period of time,
nothing: there are buffers at various places, which store the stream in advance
in order to cope with this kind of problems. If the situation persists, those
buffer will empty and we will run into trouble: there is not enough audio data
to play and we will regularly hear no sound.

This can be tested with the `sleeper` operator, which can be used to simulate
various audio delays. Namely, the following script simulates a source
which takes roughly 1.1 second to generate 1 second of sound:

```{.liquidsoap include="liq/sleeper.liq"}
```

When playing it you should hear regular glitches and see messages such as

```
2020/07/29 11:13:05 [clock.pulseaudio:2] We must catchup 0.86 seconds!
```

This means Liquidsoap took _n_+0.86 seconds to produce _n_ seconds of audio, and
is thus "late". In such a situation, it will try to produce audio faster than
realtime in order to "catch up" the delay.

How can we cope with this kind of situations? As explained above, buffers are a
solution to handle temporary disturbances in production of streams for
sources. You can explicitly add some in you script by using the `buffer`
operator: for instance, in the above script, we would add before the output, the
line

```liquidsoap
s = buffer(s)
```

which make the source store 1 second of audio (this duration can be configured
with the `buffer` parameter) and thus bear with delays of less than 1 second.

### Caching

An important optimization of Liquidsoap is _caching_, which allows sharing the
frame computed by a source between two sources. For instance, consider the
following script:

```{.liquidsoap include="liq/streaming2.liq"}
```

Here, the source `s` is used twice: once by the pulseaudio output and once by
the icecast output. Liquidsoap is smart enough to detect this kind of situation:
when the first active source (say, `output.pulseaudio`) asks `amplify` to fill
in a frame, Liquidsoap will temporarily store the result -- we that that it
"caches" it -- so that when the second active sources asks `amplify` to fill in
the frame, the stored one will be reused, thus avoiding to compute twice the
same frame.

TODO: explain that there are boundary conditions: a source can be fetched twice
with different track boundaries

TODO: source functions take an `id` parameter which is mostly useful for the
logs and the telnet

### Clocks

TODO: we briefly explain the principle of clocks here and give the practice in
[a later section](#sec:clocks)

### Fallible sources

What is a faillible source? (source available or not)

In practice, simply use `mksafe`{.liquidsoap}

explain `fail` and give the example of `once` which is implemented with `sequence`

### Startup and shutdown

Explain what is going up at startup an shutdown of sources (ready / etc.)

### Methods for sources {#sec:source-methods}

TODO: detail the methods present for every source....

- `fallible`: Indicate if a source may fail, i.e. may not be ready to stream.
- `id`: Identifier of the source.
- `is_ready`: Indicate if a source is ready to stream, or currently streaming.
- `is_up`: Check whether a source is up.
- `on_metadata`: Call a given handler on metadata packets.
- `on_shutdown`: Register a function to be called when source shuts down.
- `on_track`: Call a given handler on new tracks.
- `remaining`: Estimation of remaining time in the current track.
- `seek`: Seek forward, in seconds (returns the amount of time effectively
     seeked).
- `shutdown`: Deactivate a source.
- `skip`: Skip to the next track.
- `time`: Get a source's time, based on its assigned clock.

Requests
--------

explain that we need to resolve requests, which is why queues take request in account, we want to be able to play them immediately

persistent or not

main functions:

- `request.create`
- `request.resolve`
- `request.duration`
- `request.filename` and `request.uri`
- `request.metadata`

TODO: what are _indicators_ (used as parameters for create for instance)?
