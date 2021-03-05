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
works internally. Beware, this chapter is a bit more technical than others.

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
those are always quite useless (they are blank). The reason is mainly because of
the following pattern. Suppose that you want to generate a blue screen with a
sine wave as sound. You would immediately write something like this

```{.liquidsoap include="liq/blue-sine.liq" from=1}
```

We create the source `a` which is the sine wave, the source `b` which is the
blue screen (obtained by taking the output of `blank`, which is black and mute,
and filling it in blue), we add them and finally play the resulting source
`s`. The thing is that we can only add sources of the same type: `add` being of type

```
([source(audio=internal('a), video=internal('b), midi=internal('c))]) -> source(audio=internal('a),video=internal('b),midi=internal('c))
```

it takes a list of sources to add, and lists cannot contain heterogeneous
elements. Therefore, in order to produce a source with both audio and video, the
elements of the list given as argument to `add` must all be sources with audio
and video.

If you insist of adding a video channel to a source which does not have one, you
should use the dedicated function `mux_video`, whose type is

```
(video : source(audio=none, video='a, midi=none), source(audio='b, video=none, midi='c)) -> source(audio='b, video='a, midi='c)

```

(and the function `mux_audio` can similarly be used to add audio to a source
which does not have that). However, since this function is much less well-known
than `add`, we like leaving the possibility to the user of using both most of
the time, as explained above. Note that the following variant of the above
script

```{.liquidsoap include="liq/blue-sine2.liq" from=1}
```

is slightly more efficient since the source `a` does not need to generate video
and the source `b` does not need generate audio.

Dually, in order to remove the audio of a source, the operator `drop_audio` of
type

```
(source(audio='a, video='b, midi='c)) -> source(audio=none, video='b, midi='c)
```

can be used, and similarly the operator `drop_video` can remove the video.

### Type annotations

If you want to constraint the contents of a source, the Liquidsoap language
offers the construction `(e : t)` which allows constraining an expression `e` to
have type `t` (technically, this is called a type _cast_). It works for
arbitrary expressions and types, but is mostly useful for sources. For instance,
in the following example, we play the source `s` in mono, even though the
default number of channels is two:

```{.liquidsoap include="liq/mono-output.liq" from=2}
```

Namely, in the second line, we constrain the type of `s` to be
`source(audio=pcm(mono))`, i.e. a source with mono audio.

### Encoding formats {#sec:encoders-intro}

In order to specify the format in which a stream is encoded, Liquidsoap uses
particular annotations called _encoders_. For instance, consider the
`output.file` operator which stores a stream into a file: this operator needs to
know what kind of file we want to produce. The (simplified) type of this
operator is

```
(format('a), string, source('a)) -> active_source('a)
```

We see that the second argument is the name of the file and the third argument
is the source we want to dump. The first argument is the encoding format, of
type `format('a)`. Observe that it takes a type variable `'a` as argument, which
is the same variable as the parameters of the source taken as third argument
(and the returned source): the format required by the source will depend on the
chosen format.

The encoding formats are given by encoders, whose name always begin with the
"`%`" character and can take parameters: their exhaustive list is given in
[there](#sec:encoders). For instance, if we want to encode a source `s` in mp3
format, we are going to use the encoder `%mp3` and thus write something like

```{.liquidsoap include="liq/format-mp3.liq" from=2}
```

If we have a look at the type of the encoder `%mp3`, we see that its type is

```
format(audio=pcm(stereo), video=none, midi=none)
```

which means that, in the above example, the source `s` will be of type

```
source(audio=pcm(stereo), video=none, midi=none)
```

and thus have to contain stereo pcm audio, no video and no midi. The encoders
take various parameters. For instance, if we want to encode mp3 in mono, at a
bitrate of 192 kbps, we can pass the parameters `mono` and `bitrate=192` as
follows:

```{.liquidsoap include="liq/format-mp3-mono.liq" from=2}
```

Note that this will have an influence on the type of the stream: if we pass
`mono` as parameter, the type of the encoder becomes

```
format(audio=pcm(mono), video=none, midi=none)
```

and thus imposes that `s` should have mono audio.

Because they have such an influence on types, an encoder is not a value as any
other in Liquidsoap, and specific restrictions have to be imposed. In
particular, you cannot use variables or complex expressions in the parameters
for the encoders. For instance, the following will not be accepted


```{.liquidsoap include="liq/bad/format-mp3-mono.liq" from=2}
```

because we are trying to use a variable as value for the bitrate. This might
change in the future though.

As another example, suppose that we want to encode our whole music library as a
long mp3. We would proceed in this way:


```{.liquidsoap include="liq/encoded-concat.liq" from=1}
```

The first line creates a `playlist` source which will read all our music files
once, the second line ensures that we try to encode the files as fast as
possible instead of performing this in real time (the use of clocks is detailed
in [there](...)\TODO{reference}) and the third line requires the encoding in mp3
of the resulting source, calling the `shutdown` function once the source is
over, which will terminate the script. If you try this at home, you will see
that it takes quite some time, because the `playlist` operator has to decode all
the files of the library into internal raw contents, and the `output.file`
operator has to encode the stream in mp3, which is quite CPU-hungry. If our
music library already consists of mp3 files, it is much more efficient to avoid
decoding and then reencoding the files. In order to do so, we can use the
FFmpeg encoder, by replacing the last line with

```{.liquidsoap include="liq/encoded-concat2.liq" from=3}
```

Here, the encoder `fmt` states that we want to use the FFmpeg library, in order
to create mp3, from already encoded audio (`%audio.copy`). In this case, the
source `s` will have the type

```
source(audio=ffmpeg.audio.copy, video=none, midi=none)
```

where the contents of the audio is already encoded. Because of this, the
`playlist` operator will not try to decode the mp3 files, it will simply pass
their data on, and the encoder in `output.file` will simply copy them in the
output file, thus resulting in a much more efficient script.

The format of most encoded output operators (`output.icecast`,
`output.file.hls`, `output.srt`, etc.) is determined by an encoder argument in
the same way.

The streaming model
-------------------

At this point, we think that it is important to explain a bit how streams are
handled "under the hood", even though you should never have to explicitly deal
with this in practice. After parsing a script, liquidsoap starts one or more
streaming loop. Each streaming loop is responsible for creating audio data from
the inputs, pass it through the various operators and, finally, send it to the
outputs. Each loop is attached to a _clock_, which is in charge of controlling
the latency during the streaming (in most cases, the clock follows the
computer's CPU clock, in order to stream data in real time to your
listeners). This way of functioning is detailed below.

### Frames

For performance reasons, the data contained in streams is generated by small
chunks, that we call _frames_ in Liquidsoap. The default size of a frame is
controlled by the setting `frame.duration` whose default value is 0.04 second,
i.e. 1/25 th of a second, which corresponds to 1764 audio samples and 1 video
image with default settings. The actual duration is detailed at the beginning of
the logs:

```
Frames last 0.04s = 1764 audio samples = 1 video samples = 1764 ticks.
```

Note that if you request a duration of 0.06 second, by

```{.liquidsoap include="liq/frame-duration.liq" from=1 to=1}
```

you will see that Liquidsoap actually selects a frame duration of 0.08 seconds:

```
Frames last 0.08s = 3528 audio samples = 2 video samples = 3528 ticks.
```

this is because the requested size is rounded up so that we can fit an integer
number of samples and images (0.06 would have amounted to 1.5 image per frame).

In a typical script, such as

```{.liquidsoap include="liq/streaming1.liq"}
```

The active source is `output.pulseaudio`, and is thus responsible for
synchronization. In practice, it waits for the soundcard to say: "hey, my
internal buffer is almost empty, now is a good time to fill me in!". Each time
this happens, and this occurs 25 times per second, the active source generates a
_frame_, which is a buffer for audio (or video) data waiting to be filled in,
and passes it to the `amplify` source asking it to fill it in. In turn, it will
pass it to the `sine` source, which will fill it with a sine, then the `amplify`
source will modify its volume, and then the `output.pulseaudio` source will send
it to the soundcard.

### Frame raw contents {#sec:liquidsoap-raw}

Let us provide some more details about the way data is usually stored in those
frames, when using raw internal contents. Each frame has room for audio, video
and midi data.

The raw audio contents is called `pcm` for _pulse-code modulation_. The signal
is represented by a sequence of _samples_, one for each channel, which represent
the amplitude of the signal at a given instant. Each sample is represented by
floating point number, between -1 and 1, stored in double precision (using 64
bits, or 8 bytes). The samples are given regularly for each channel of the
signal, by default 44100 times per seconds: this value is called the _sample
rate_ of the signal and is stored globally in the `frame.audio.samplerate`
setting. This means that we can retrieve the value of the samplerate with

```{.liquidsoap include="liq/samplerate-get.liq" from=1 to=1}
```

and set it to another value such as 48000 with

```{.liquidsoap include="liq/samplerate-set.liq" from=1 to=1}
```

although default samplerate of 44100 Hz is largely the most commonly in use.

A video consists of a sequence images given regularly. By default, these images
are presented at the _frame rate_ of 25 images per second, but this can be
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
together with the time (in ticks, relative to the beginning of the frame) they
occur and the channel on which they occur. Each event can be "such note is
starting to play at such velocity", "such note is stopping to play", "the value
of such controller changed", etc.

### Ticks

The time at which something occurs in a frame is measured in a unit called
_ticks_. To avoid errors due to rounding, which tend to accumulate when
performing computations with float numbers, we want to measure time with
integers. The first natural choice would thus be to measure time in audio
samples, since they have the highest rate, and in fact this is what is done with
default settings: 1 tick = 1 audio sample = 1/44100 second. In this case, an
image lasts 1/25 second = 44100/25 ticks = 1764 ticks.

However, if we change the video framerate to 24 images per second with

```{.liquidsoap include="liq/frame-ticks.liq" from=1 to=1}
```

we have difficulties measuring time with integers because an image now lasts
44100/24 samples = 1837.5 samples, which is not an integral number. In this
case, Liquidsoap conventionally decides that 1 sample = 2 ticks, so that an
image lasts 3675 ticks. Indeed, if you try the above, you will see in the logs

```
Using 44100Hz audio, 24Hz video, 88200Hz main.
```

which means that there are 44100 audio samples, 24 images and 88200 ticks per
second, as well as

```
Frames last 0.08s = 3675 audio samples = 2 video samples = 7350 ticks.
```

which means that a frame lasts 0.8 seconds and contains 8675 audio samples and 2
video samples, which corresponds to 7350 ticks.

### The stream generation workflow {#sec:stream-generation}

wake up

content kind / content type setting

TODO: explain that channels are re-computed at wake up time, therefore we should
not for the evaluation of `self#ctype` before that (e.g. by initializing an
array with the number of channels)

source which are available or not (failability)

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

### Additional data in frames

Sampling units are used to for position markers within the frame. Each
frame has two arrays of markers: an array of **breaks** and
an array of **metadata**.

Breaks are added each time the frame is filled. A break represent the last
position after a filling operation. Each filling operation is required to
add exactly one break.

In a typically execution, a filling operation with no track mark has only one
break, located right at the end of the frame. Otherwise, breaks located before the
frame's end represent markers for end of tracks.

Metadata are attached with their position within the frame and a list of pairs of
`(label, value)` metadata. Labels can be any string. However, metadata labels are filtered
before being exported, in order to prevent internal information leak. This is 
controlled by the `"encoder.encoder.export"` setting. 

TODO: explain that there are boundary conditions: a source can be fetched twice
with different track boundaries

TODO: source functions take an `id` parameter which is mostly useful for the
logs and the telnet

TODO: explain that switch does not advance the non-selected sources

TODO: tracks, metadata

### Fallible sources

What is a faillible source? (source available or not)

In practice, simply use `mksafe`{.liquidsoap}

explain `fail` and give the example of `once` which is implemented with `sequence`

### Clocks

Ticks represent the internal sampling unit. They are defined as the smaller
sampling unit across all data types. For instance, wth `audio`
and `video` data, the sampling unit will be the audio sample rate,
since it is usually lower than the video sample rate.

TODO: the CPU clock

TODO: the `clock` operator

TODO: we briefly explain the principle of clocks here and give the practice in
[a later section](#sec:clocks)

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
     seeked). Seeking is implement whenever possible. A `input.harbor` source,
     for instance, cannot seek its data while a `playlist` source can. Also,
     seeking to the exact request position might not be possible, instead
     seeking to a nearby position. For these reasons, `source.seek` returns a
     floating point number. If this number is negative, seeking failed.  If this
     number is positive, it represents the position that was effectively seeked
     to.
- `shutdown`: Deactivate a source.
- `skip`: Skip to the next track.
- `time`: Get a source's time, based on its assigned clock.




### Requests

explain that we need to resolve requests, which is why queues take request in account, we want to be able to play them immediately

persistent or not

main functions:

- `request.create`
- `request.resolve`
- `request.duration`
- `request.filename` and `request.uri`
- `request.metadata`

TODO: what are _indicators_ (used as parameters for create for instance)?

The purpose of a request is to get a valid file. The file can contain media in
which case validity implies finding a working decoder, or can be something
arbitrary, like a playlist. This file is fetched using protocols. For example
the fetching can involve querying a mysql database, receiving a list of new
URIS, using http to download the first URI, check it, fail, using smb to
download the second, success, have the file played, finish the request, erase
the temporary downloaded file. This process involve a tree of URIs, represented
by a list of lists.  Metadata is attached to every file in the tree, and the
view of the metadata from outside is the merging of all the metadata on the path
from the current active URI to the root.  At the end of the previous example,
the tree looks like:

```
[ [ "/tmp/localfile_from_smb" ] ;
  [
    (* Some http://something was there but was removed without producing
     * anything. *)
    "smb://something" ; (* The successfully downloaded URI *)
    "ftp://another/uri" ;
    (* maybe some more URIs are here, ready in case of more failures *)
  ] ;
  [ "mydb://myrequest" ] (* And this is the initial URI *)
]
```

Romain's writings
--------

TODO: integrate this in the above

The elements that are filled during a clock cycle are called **frames**. They contain
the amount of data (audio, video) to be filled and sent to the outputs during each cycle. The 
frame size is calculated when starting liquidsoap and should be the smallest
size that can fit an interval of samples of each data type. Typically, a frame
for an audio rate of `44.1kHz` and video rate of `25Hz` fits `0.04s` of data. To
check this, look for the following lines in your liquidsoap logs:

```
[frame:3] Using 44100Hz audio, 25Hz video, 44100Hz master.
[frame:3] Frame size must be a multiple of 1764 ticks = 1764 audio samples = 1 video samples.
[frame:3] Targetting 'frame.duration': 0.04s = 1764 audio samples = 1764 ticks.
[frame:3] Frames last 0.04s = 1764 audio samples = 1 video samples = 1764 ticks.
```

The streaming algorithm works as follows: during one clock cycle, each output is 
given a frame to fill. In turn, the outputs pass their frame down to their connected
sources. For instance, if an output is connected to a `switch` operator, the
operator selects which source is  ready and, in turn, passes the frame to be filled
down to that source. All the data is filled in-place, to avoid data copy.

If a source is connected to multiple operators, it keeps a memoized
frame in order to generate its audio data only once during a single clock cycle,
sharing the result with all the operators it is connected to.

This operation goes on until the call returns. At this point, the frame is filled with
data and metadata. Most calls will fill up the entire frame at once. If the
frame is only partially filled after one call, we consider that the current
track has ended. This defines a track mark, used in many operators such as
`on_track`.

After one such filling loop, if the frame is partially filled and 
the source connected to the output is still available, another call
to to fill up the frame is issued, still within the same clock cycle.
When a source is considered `infallible`, we assume that this source will 
_always_ be able to fill up the current frame.

Once a frame is fully filled, the outputs proceed with the output procedure
they are designed to perform. For instance, a `output.icecast` encodes the data
and sends it to the connected icecast server.

### Clocks

As mentioned earlier, clocks control the latency associated with each streaming
cycle. The default clock tries to run this streaming loop in real-time,
speeding up when filling the frame takes more time than the frame's duration.
When this happens, you will see the infamous `catchup` log messages:

```
[clock.wallclock_main:2] We must catchup 2.82 seconds!
```

However, in some cases such as a `input.alsa`, the sound card already has its own
clock. In this case, it is assumed that the source (or output) controls the latency,
blocking each filling call until it has enough data to return. For these situation,
the clock assigned by liquidsoap does _not_ try to control the latency and, instead,
runs the streaming loop as fast as possible, delegating latency control to the underlying
sources. In these situation, you will not see any `catchup` log messages.

There also are situations where the clock may switch from controlling the latency to delegating
it to the underlying sources or vice-versa. Consider for instance the following script:
```liquidsoap
s = fallback(track_sensitive=false,[
  input.harbor("foo"), input.alsa()
])
```
When `input.harbor` is available, the latency is controlled by liquidsoap however,
as soon as the `fallback` switches to `input.alsa`, latency is delegated to this source.
This can be seen in the logs as follows:
```
2019/12/14 15:20:39 [clock.main:3] Streaming loop starts in auto-sync mode
2019/12/14 15:20:39 [clock.main:3] Delegating synchronisation to CPU clock
...
2019/12/14 15:21:30 [clock.main:3] Delegating synchronisation to active sources
``` 

Clock cycles and frame duration define the I/O delay that you can expect when working
with liquidsoap. If you aim for a shorter delay, specially when working with only
audio, try to lower the video rate.\RB{Man we need to detect that and not use
video when computing the frame size!}. This also means that streaming happens by
increment of a frame's length. Thus, `source.time` for instance is precise down to
the frame's duration. The same goes for scripted fade operators. 

### Clocks & Time Discrepancies


Clocks in liquidsoap can be confusing. They are, however, central to the functioning of
the internals while streaming data. Let's try to explain why they had to be introducted
and how they are aasigned and used. For more details, the reader
is invited to checkout our initial research paper, entitled
[Liquidsoap: a High-Level Programming Language for Multimedia Streaming](https://www.liquidsoap.info/assets/docs/bbm10.pdf)

#### What's the big deal?

To understand the need for clocks, we should first remember that all data in a digital
system is _sampled_. The sampling operation relies on a clock to tick at the frequency
that is used for sampling. For instance, for `44.1kHz` audio, the sampling operation relies
on a clock ticking every `1/44.100` seconds.

But, what happens if this clock, in fact, ticks at a slightly different rate, for instance 
`1/44.100+0.001` seconds? Even worst, and not to be pedantic here but, relativity theory actually tells us
that two clocks following different motions do not agree on time. A famous example being the fact
that the atomic clocks over the globe have to be mindful of their respective elevation, in order
to keep track of time discrepancies due to the earth's rotation..

But, anyways, let's go down to earth and consider a much more practical case: two computer's internal
clocks are _very_ likely to tick at slightly different rates. It can be that these two rates cancel out
statistically over time or, in the worst case, it can be that these two rates drift appart over time.

Consider now what happens when a listener receives a stream encoded by another computer. Locally, the listener
takes the sequence of data samples and re-assembles them to created an analog signal for human's consumption.
However, if the listener's and the encoder's clock do not agree, the might be some issues down the road.

When playing a recorded file, clock discrepancies between the encoder and decoder usually do not matter.
Eventually, for instance, a movie's playback time on the viewer's computer ends up being a slighly different
which does not really impact the viewer's experience. However, with a continuous, real-time stream, things
can be slightly more annoying. For instance, if the drift is constant over time, the listener's buffers might run out
of data or be overrun with data, leading to loss of data while playing the stream.

#### How does it matter?

In liquidsoap, clock and time discrepancies matter on the following cases:

1. Reading or writing data to a sound card
2. Sending or receiving data over the network
3. Accelerating or slowing down a source's rate

The first case is the most straight forward: computer's sound card have their own
local clock, used for sampling and rendering audio data. This clock is different than
the computer's clock and, hopefully, more accurate. When accessing the sound card, either
to read (record) or write (play) data, the sound card's driver will block until enough 
data has been read or writen based on the sound card's clock. In such a case, liquidsoap
needs to be aware of the situation and delegate time synchronizatin to the sound card.

The second case is usually transient. Network operations can have slow down and blocking
if, for instance, the network is down. This can happen with `output.icecast`. Also, some
network operators such as `input.srt` have their own notion of time, similar to the sound
card's local clock, and will block to control the latency over which network data is being
delivered.

The third case is specific to our needs. Consider a source with track crossfades. Originally,
the source contains two track adjacent to each other: `<track1>, <track2>`. After applying a
crossdade, a portion of the ending and starting tracks overlap: 
`<track1 ...>, <end of track 1 + beginning of track 2>, <... track2>`\RB{Add figure}
After this operation, the stream's playback time is shortened by the amount of time used to
mix the two tracks.

In order to achieve this in a real-time stream, liquidsoap needs to briefly accelerate
the source in order to bufferize the beginning of `<track2>` and compute the crossfade transition.
This, in turn, requires that the source can actually be accelerated, which is possible if 
the source, for instance, is a playlist of files, but won't work if it is a live source from
the sound card. 

Lastly, there is still, of course, the chance that a listener's clock drifts
away from the clock used to synchronize liquidsoap. However, there isn't much that
we can do from a sender's perspective. In this case, we expect the listener's playback
software to be able to mitigate, for instance by using an adaptative resampler. One such
example is The VLC player.
