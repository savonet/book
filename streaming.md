The streaming language {#chap:streaming}
======================

You should now be convinced that Liquidsoap is a pretty decent general-purpose
scripting language. But of course, it also has features dedicated to
streaming. In this section, we present the general concepts behind those. The
operators useful to construct streams in practice will be presented in details
in subsequent chapters.

Sources {#sec:lang-sources}
-------

What makes Liquidsoap unique is that it has dedicated functions in order to
produce and manipulate streams, which are called _sources_ in Liquidsoap.

### Typing

Each source has a number of channels of audio, video and midi data, and each of
which can either contain

- _raw data_: this data is decoded in an internal format, suitable for
  manipulation by operators within Liquidsoap, or
- _encoded data_: which Liquidsoap is not able to modify, e.g. audio data in mp3
  format.

In practice, you will manipulate sources handling raw data most of the
time. Encoded data is mostly useful for avoiding to have to encode a stream
multiple times in the same format, e.g. when sending the same encoded stream to
multiple icecast instances.

The contents of each channel is indicated in the type of the values. For
instance, we have seen that the type of `sine` is

```
(?amplitude : {float}, ?duration : float, ?{float}) ->
    source(audio='a, video='b, midi='c)
```

We see see that it takes 3 optional arguments (the amplitude, the duration and
the frequency) and returns a source as indicated by the type of the returned
value: `source(...)`. The parameters of `source` indicate the number of
channels: here, as for polymorphic functions, `'a`, `'b` and `'c` mean "any
number of channels": depending on what is required, this source can generate as
many channels as we want: it will generate the same sine on all audio channels
and the video and midi channels are always going to be empty. Another example of
an operator is the operator `mean` which takes an audio stream as input and
changes audio to mono, by taking the mean of all the audio channels. Its type is

```
(source(audio=pcm('a), video='b, midi='c)) ->
    source(audio=pcm(mono), video='b, midi='c)
```

We see that the type of the input source is `pcm('a)` which means any number of
channels of raw audio, and the corresponding type for audio in the output is
`pcm(mono)`, which means mono raw audio, as expected. We can also see that the
video and midi channels are preserved since their names (`'b` and `'c`) are the
same in the input and the output.

Currently, the raw types are

|raw audio | raw video | raw midi |
|:--------:|:---------:|:--------:|
| `pcm`    | `yuv420p` | `midi`   |

as well as the type `none` which indicates that no data is available in the
channel. The supported numbers of channels for audio are `mono`, `stereo` and
`dolby 5.1`.

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



TODO: source functions take an `id` parameter which is mostly useful for the
logs and the telnet

### Clocks

TODO: we briefly explain the principle of clocks here and give the practice in
[a later section](#sec:clocks)

### Fallible sources

What is a faillible source? (source available or not)

In practice, simply use `mksafe`{.liquidsoap}


Requests
--------

explain that we need to resolve requests

persistent or not

main functions:

- `request.create`
- `request.resolve`
- `request.duration`
- `request.filename` and `request.uri`
- `request.metadata`
