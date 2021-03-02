A streaming language {#chap:streaming}
====================

The previous chapter should have convinced you that Liquidsoap is a pretty
decent general-purpose scripting language. But what makes it unique is the
features dedicated to streaming. In this chapter, we present the general
concepts behind those, they will be put in use in subsequent chapters.

Sources {#sec:lang-sources}
-------

The main purpose of Liquidsoap is to manipulate functions which will generate
streams and are called _sources_ in Liquidsoap. Typically, the `playlist`
operator is a source, which generates streams by sequentially reading files. The
way sources generate audio or video data is handled abstractly: you almost never
get down to the point where you need to understand how or in what format this
data is actually generated, you usually simply combine sources in order to get
elaborate ones. It is however useful to have a general idea of how Liquidsoap
works internally.

### Typing

Each source has a number of channels of

- _audio_ data: containing sound,
- _video_ data: containing animated videos,
- _midi_ data: containing notes to be played.

Moreover, each of those channels can either contain

- _raw_ data: this data is in an internal format (usually obtained by decoding
  compressed files), suitable for manipulation by operators within Liquidsoap,
  or
- _encoded_ data: which Liquidsoap is not able to modify, such as audio data in
  mp3 format.

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

Contents of the form `internal('a)` only impose that the format is one supported
internally


The parameters of `source` indicate the number of
channels: here, as for polymorphic functions, `'a`, `'b` and `'c` mean "any
number of channels": depending on what is required, this source can generate as
many channels as we want: it will generate the same sine on all audio channels
and the video and midi channels are always going to be empty. Similarly, the
type of the `amplify` operator, which modifies the ..................
\TODO{why don't we enforce the type of audio to be pcm???}

```
({float}, source(audio='a, video='b, midi='c)) -> source(audio='a, video='b, midi='c)
```

.............


Another example of an operator is the operator `mean` which takes an audio
stream as input and changes audio to mono, by taking the mean of all the audio
channels. Its type is

```
(source(audio=pcm('a), video='b, midi='c)) -> source(audio=pcm(mono), video='b, midi='c)
```

We see that the type of the input source is `pcm('a)` which means any number of
channels of raw audio, and the corresponding type for audio in the output is
`pcm(mono)`, which means mono raw audio, as expected. We can also see that the
video and midi channels are preserved since their names (`'b` and `'c`) are the
same in the input and the output.

Currently, the raw types are

|raw audio | raw video  | raw midi |
|:--------:|:----------:|:--------:|
| `pcm`    | `yuva420p` | `midi`   |

as well as the type `none` which indicates that no data is available in the
channel. The supported numbers of channels for audio are `mono`, `stereo` and
`dolby 5.1`.

TODO: we can have constraints, for instance the type of `mksafe`

```
(?id : string, source(audio='a, video='b, midi=none)) -> source(audio='a, video='b, midi=none)
where
  'a, 'b is an internal media type (none, pcm, yuva420p or midi)
```

The type of `drop_audio` is

```
?id : string, source(audio='a, video='b, midi='c)) -> source(audio=none, video='b, midi='c)
```

TODO: sum up possible contents

- `'a`
- `internal('a)`
- `pcm('a)`

### Why we are not very strict

TODO: expliquer qu'on a besoin de générer des pistes "vides" pour satisfaire les
exigeances du typage de `add`: tous doivent avoir le même nombre de canaux audio
et vidéo

```{.liquidsoap include="liq/encoded-amplify.liq"}
```

### Internal formats

Detail the internal formats PCM / yuv420

Explain that blank video is transparent

Conf settings for the samplerate, size of video, etc.

### Passive and active sources

Most of the sources are _passive_ which means that they are simply waiting to be
asked for some data, they are not responsible for when the data is going to be
produced. The ones that ask for the production of data are called _active
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

### Type inference

The contents of a source (raw or encoded, and the number of channels) is
determined at startup and is fixed during the whole execution of the script.

Explain how the type of data is determined by inference, give examples.

TODO: on ne devrait pas pouvoir amplifier du mp3:

```{.liquidsoap include="liq/blue-sine.liq"}
```

TODO: example of an encoded source which is shared with a non-encoded one

TODO: say that we default to two audio channels when there is no constraint
(actually, this is determined by a configuration setting)


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

Formats
-------

Concatenating mp3 without reencoding:

```{.liquidsoap include="liq/encoded-concat.liq"}
```

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

Decoders
--------

Example of a log of decoder

MIME is used to guess
