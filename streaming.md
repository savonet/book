A streaming language {#chap:streaming}
====================

After reading [this chapter](#chap:language), you should have been convinced you
that Liquidsoap is a pretty decent general-purpose scripting language. But what
makes it unique is the features dedicated to audio and video streaming, which
were put to use in previous chapters. We now present the general concepts behind
the streaming features of the language, for those who want to understand in
depth how the streaming parts of the language work. The main purpose of
Liquidsoap is to manipulate functions which will generate streams and are called
_sources_ in Liquidsoap. The way those generate audio or video data is handled
abstractly: you almost never get down to the point where you need to understand
how or in what format this data is actually generated, you usually simply
combine sources in order to get elaborate ones. It is however useful to have a
general idea of how Liquidsoap works internally. Beware, this chapter is a bit
more technical than previous ones.

Sources and content types {#sec:source-type}
-------------------------

Each source\index{source} carries a number of _tracks_:

- _audio_ data: containing sound,
- _video_ data: containing animated videos,
- _subtitle_ data: containing the lines of text to display over the video,
- _midi_ data: containing notes to be played (typically, by a synthesizer),
- _metadata_: containing information about the current track (typically, title,
  artist, etc.),
- _track marks_: indicating when a track is ending.

The midi data is much less used in practice in Liquidsoap, so that we will
mostly forget about it. Subtitles get a section of their own in [the video
chapter](#chap:video). The audio and video tracks can either contain

- _raw_ data: this data is in an internal format (usually obtained by decoding
  compressed files), suitable for manipulation by operators within Liquidsoap,
  or
- _encoded_ data: this is compressed data which Liquidsoap is not able to
  modify, such as audio data in mp3 format.

In practice, users manipulate sources handling raw data most of the time since
most operations are not available on encoded data, even very basic ones such as
changing the volume or performing transitions between tracks. Support for
encoded data was introduced starting from version 2.0 of Liquidsoap and we have
seen in [an earlier section](#sec:encoded-streams) that it is mostly useful to
avoid encoding a stream multiple times in the same format, e.g. when sending the
same encoded stream to multiple icecast instances, or both to icecast and in
HLS, etc.

The type of sources is of the form

```
source(audio=..., video=..., midi=...)
```

where the "`...`" indicate the _contents_\index{contents} of each track: the
nature of the data, and the number of channels. A source type only lists the
tracks the operator constrains. For instance, the type of `sine` is

```
(?id : string?, ?amplitude : {float}, ?duration : float?, ?{float}) ->
source(audio=pcm*)
```

We see that it takes 4 optional arguments (the identifier, the amplitude, the
duration and the frequency) and returns a source, as indicated by the type of
the returned value: `source(...)`. Every source operator takes an `id`
argument, which names the source in the logs, and we will not comment on it
again. The returned source has one track, `audio`, whose contents is written
`pcm*`\indexop{pcm}: raw audio, in any of the supported sample formats, with
any number of channels. Video and midi do not appear in the type, which means
that `sine` produces neither of them.

An operator which passes a track through without looking at it uses a _row
variable_\index{type!row variable} for the tracks it does not name. For
instance, the type of `amplify` is

```
(?id : string?, ?override : {string?}, {float}, source(audio='a, 'b)) ->
source(audio='a, 'b)
where 'b is a set of tracks to be muxed into a source,
  'a is a track and a track of type: pcm, pcm_s16 or pcm_f32
```

The two lines after `where` read the two variables aloud for us. The variable
`'a` is the audio track. Since `amplify` multiplies samples, `'a` has to be raw
audio, in one of the three sample formats `pcm`, `pcm_s16` or `pcm_f32`. The
variable `'b` is announced as "a set of tracks to be muxed into a source", and
`'b` is the row variable: `'b` stands for every other track of the source,
video and subtitles and midi and metadata, whatever those happen to be. Both
variables appear unchanged in the result, which says that `amplify` changes the
volume of the audio track and relays every other track untouched.

When Liquidsoap has no constraint to report on a track, it prints `_` instead of
a variable. A type such as

```
source(audio=pcm(stereo), _)
```

therefore reads "a source with two channels of raw audio, plus any other
tracks". You will meet `source(_)` on its own in error messages: that is a
source about which nothing has been decided yet.

As another example, consider the type of the operator
`source.drop.audio`\indexop{source.drop.audio}, which removes the audio track of
a source:

```
(?id : string?, source(audio='a, 'b)) -> source(audio='a, 'b)
where 'b is a set of tracks to be muxed into a source
```

The type of `source.drop.audio` says little, and the standard library
definition says more:

```{.liquidsoap include="liq/source-drop-audio.liq" from=header}
```

The function `source.tracks`\indexop{source.tracks} turns a source into a
record of its tracks, the pattern `{audio = _, ...tracks}` binds every track
but the audio one to `tracks`, and `source`\indexop{source} builds a source
back from a record of tracks. The operator `source.drop.video` removes the
video track in the same way, and `source.drop.midi`, `source.drop.metadata`
and `source.drop.track_marks` remove the remaining ones.

### Internal contents

The contents written `pcm*` above only imposes that the format is one of those
Liquidsoap handles internally. If we want to be more specific, we can name the
actual contents. The internal contents are currently:

- for raw audio: `pcm`\indexop{pcm}, `pcm_s16`\indexop{pcm\_s16} and
  `pcm_f32`\indexop{pcm\_f32},
- for raw video: `yuv420p`\indexop{yuv420p},
- for midi: `midi`.

The three audio contents differ by the size of a sample: `pcm` stores each
sample as a 64-bits float, `pcm_f32` as a 32-bits float and `pcm_s16` as a
16-bits integer. The default is `pcm`. The two others use less memory, at the
cost of a conversion every time an audio operator such as `amplify` touches the
samples.

The argument of `pcm` is the number of channels which can either be `none` (0
audio channel), `mono` (1 audio channel), `stereo` (2 audio channels) or `5.1`
(6 channels for surround sound: front left, front right, front center,
subwoofer, surround left and surround right, in this order). For instance, the
operator `mean` takes an audio stream and returns a mono stream, obtained by
taking the mean over all the channels. Its type is

```
(?id : string?, ?normalize : bool, source(audio=pcm('a), 'b)) ->
source(audio=pcm(mono), 'b)
where 'b is a set of tracks to be muxed into a source
```

We see that the audio contents of the input source is `pcm('a)` which means any
number of channels of raw audio, and the corresponding type for audio in the
output is `pcm(mono)`, which means mono raw audio, as expected. We can also see
that the other tracks are preserved, since the row variable `'b` is the same in
the input and the output.

The raw video format `yuv420p` does not take any argument. The only argument of
`midi` is of the form `channels=n` where `n` is the number of midi channels of
the stream. For instance, the operator `synth.all.sine` which generates sound
for all midi channels using sine waves has type

```
(?id : string?, ?attack : float, ?decay : float, ?envelope : bool,
 ?release : float, ?sustain : float, source(midi=midi(channels=16), 'a)) ->
source(midi=midi(channels=16), 'a)
```

We see that it takes a stream with 16 midi channels as argument and returns a
stream of the same type.

### Encoded contents

\index{encoded stream}

Liquidsoap has support for the wonderful
[FFmpeg](https://ffmpeg.org/)\index{FFmpeg} library which allows for
manipulating audio and video data in most common (and uncommon) video formats:
it can be used to convert between different formats, apply effects, etc. This is
implemented by having native support for

- the raw FFmpeg formats: `ffmpeg.audio.raw` and `ffmpeg.video.raw`,
- the encoded FFmpeg format: `ffmpeg.copy`, which covers both audio and video.

Typically, the raw formats used in order to input from or output data to FFmpeg
filters, whose use is detailed in [there](#sec:ffmpeg-filters): as for
Liquidsoap, FFmpeg can only process decoded raw data. The encoded format is
used to handled encoded data, such as sound in mp3, typically in order to encode
the stream once in mp3 and output the result both in a file and to Icecast, this
is detailed in [there](#sec:encoded-streams). The name `ffmpeg.copy` comes from
the fact that Liquidsoap simply copies and passes on data generated by FFmpeg
without having a look into it.

Conversion from FFmpeg raw contents to internal Liquidsoap contents can be
performed with the function `ffmpeg.raw.decode.audio`, which _decodes_ FFmpeg
contents into Liquidsoap contents. Its type is

```
(?id : string?, source(audio=ffmpeg.audio.raw('a), 'b)) ->
source(audio=pcm('c))
```

We see that this function takes a source whose audio has `ffmpeg.audio.raw`
contents and outputs a source whose audio has `pcm` contents. The functions
`ffmpeg.raw.decode.video` and `ffmpeg.raw.decode.audio_video` work similarly
with streams containing video and both audio and video respectively. The
functions `ffmpeg.decode.audio`, `ffmpeg.decode.video` and
`ffmpeg.decode.audio_video` have similar effect to decode FFmpeg encoded
contents to Liquidsoap contents, for instance the type of the last one is

```
(?id : string?, source(audio=ffmpeg.copy('a), video=ffmpeg.copy('b), 'c)) ->
source(audio=pcm('d), video=yuv420p('e))
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
    red/green/blue/alpha or `yuv420p` as used in Liquidsoap, see `ffmpeg
    -pix_fmts`),
  - `pixel_aspect`: the aspect ratio of the image (typically `16:9` or `4:3`)
- `ffmpeg.copy` on an audio track: parameters are `codec` (the algorithm used to
  encode audio such as `mp3` or `aac`, see `ffmpeg -codecs` for a full list),
  `channel_layout`, `sample_format` and `sample_rate`,
- `ffmpeg.copy` on a video track: parameters are `codec`, `width`, `height`,
  `aspect_ratio` and `pixel_format`.

### Passive and active sources

Most of the sources are _passive_ which means that they are simply waiting to be
asked for some data, they are not responsible for when the data is going to be
produced. For instance, a playlist is a passive source: we can decode the files
of the playlist at the rate we want, and will actually not decode any of those
if we are not asked to. Similarly, the amplification operator `amplify(a, s)` is
passive: it waits to be asked for data, then in turn asks the source `s` for
data, and finally it returns the given data amplified by the
coefficient `a`.

\index{source!active}

However, some sources are _active_ which means that they are responsible for
asking data. This is typically the case for outputs such as to a soundcard
(e.g. `output.alsa`) or to a file (e.g. `output.file`). Perhaps surprisingly,
some inputs are also active: for instance, in the `input.alsa` source, we do not
have control over the rate at which the data is produced, the soundcard
regularly sends us audio data, and is responsible for the synchronization.

This way of functioning means that if a source is not connected to an active
source, its stream will not be produced. For instance, consider the following
script:

```{.liquidsoap include="liq/passive.liq" from=header}
```

Here, the only active source is `output` which is playing the `blank`
source. The source `s` is not connected to an active source, and its contents
will never be computed. This can be observed because we are printing a message
for each new track: here, no stream is produced, thus no new track is produced,
thus we will never see the message.

<!--
Some operators also do not ask for frames from all their input sources:
typically, the `switch` operator will only ask a frame from the currently active
source.
-->

The above story is entirely not precise on one point. We will see in [a section
below](#sec:clocks) that it is not the exactly the active sources themselves
which are responsible for initiating computation of data, but rather the
associated clocks.

### Type inference

\index{type}

In order to determine the type of the sources, Liquidsoap looks where they are
used and deduces constraints on their type. For instance, consider a script of
the following form:

```{.liquidsoap include="liq/source-ti.liq" from=header}
```

In the first line, suppose that we do not know yet what the type of the source
`s` should be. On the second line, we see that `s` is used as an argument of
`output.alsa` and should therefore have a type of the form
`source(audio=pcm('a), 'b)`, i.e. the audio should be in `pcm` format.
Similarly, on the third line, we see that `s` is used as an argument of
`output.sdl` (which displays the video of the stream) and should therefore have
a type of the form `source(video=yuv420p('a), 'b)`, i.e. the video should be in
`yuv420p` format. Combining the two constraints, we deduce that the type of the
source should be of the form `source(audio=pcm('a), video=yuv420p('b), 'c)`.

In the end, the parameters of the stream which are not fixed will be taken to be
default values. For instance, the number of audio channels will take the default
value 2 (stereo), which is specified in the setting
`settings.frame.audio.channels`. If we want streams to be mono by default, we
should type, at the beginning of the script,

```{.liquidsoap include="liq/set-channels.liq" from=header}
```

The default number of midi channels is 0, and can be changed in the setting
`settings.frame.midi.channels`. Once determined at startup, the contents of the
streams (such as number of audio channels) is fixed during the whole execution
of the script. Earlier versions of Liquidsoap somehow supported sources with
varying contents, but this was removed because it turned out to be error-prone
and not used much in practice.

During the type checking phase, it can happen that two constraints are not
compatible for a given stream. In this case, an error is returned before the script is
executed. For instance, suppose that we have a source `s` and we execute the
following script:

```{.liquidsoap include="liq/bad/encoded-amplify.liq" from=header}
```

We recall that the type of `amplify` is essentially

```
({float}, source(audio='a, 'b)) -> source(audio='a, 'b)
where 'a is a track of type: pcm, pcm_s16 or pcm_f32
```

and the one of `ffmpeg.decode.audio` is essentially

```
(source(audio=ffmpeg.copy('a), 'b)) -> source(audio=pcm('c))
```

On the first line of the script above, we are using `amplify` on `s`, which
means that the audio track of `s` has to be one of the three raw audio formats,
because `amplify` can only work on internal data. The type of `t` is then the
same as the type of `s`, because `amplify` returns the same audio track it was
given. On the second line, however, we use `t` as argument for
`ffmpeg.decode.audio`, which requires the audio track to be `ffmpeg.copy`. The
audio track of `t` would have to be raw audio and encoded FFmpeg data at the
same time, which is impossible. Liquidsoap therefore raises the following error

```
At bad/encoded-amplify.liq, line 4, char 24:
u = ffmpeg.decode.audio(t)

Error 5: this value has type
  source(audio='A, _)
  where 'A is a track and a track of type: pcm, pcm_s16 or pcm_f32 (inferred at bad/encoded-amplify.liq, line 3, char 4-18)
but it should be a subtype of
  source(audio=ffmpeg.copy('A), _)
```

which is a formal way of stating the above explanation. The error quotes the
offending line, `u = ffmpeg.decode.audio(t)`, and it also says where the type it
complains about came from: line 3, characters 4 to 18, which is the call to
`amplify`.

### Muxing tracks

A source type lists the tracks the source produces, and nothing else: `sine`
produces an audio track and no video track. Suppose that you want to generate a
blue screen with a sine wave as sound. You would immediately write something
like this\indexop{add}

```{.liquidsoap include="liq/bad/blue-sine.liq" from=header}
```

We create the source `a` which is the sine wave, the source `b` which is the
blue screen (obtained by taking the output of `blank`, which is black and mute,
and filling it in blue), we add them and finally play the resulting source `s`.
Well, this does not work. The operator `add` takes a list of sources, lists
cannot contain heterogeneous elements, and `a` and `b` do not have the same
tracks: `a` has audio only and `b` has video only. Liquidsoap says

```
At bad/blue-sine.liq, line 4, char 12:
s = add([a, b])

Error 5: this value has type
  _.{composition_type : _, on_select : (...) -> source(audio=_)} (inferred at bad/blue-sine.liq, line 3, char 4-39)
but it should be a subtype of the type of the value at bad/blue-sine.liq, line 4, char 8-14
  _.{composition_type : _, on_select : (...) -> source(audio=_, video=_, _)} (inferred at bad/blue-sine.liq, line 2, char 4-10)
```

The part to read is the `source(...)` at the end of each of the two types: one
element of the list has an audio track only, and the other one has an audio
track and a video track. The `composition_type` and `on_select` around them are
the composition methods we met [there](#sec:composition), which `add` carries
along; they are not the cause of the error.

Adding a video track to a source which does not have one is the job of
`source.mux.video`\index{mux}, whose type is

```
(?id : string?, video : source(video='a, 'b), source('c)) ->
source(video='a, 'c)
where 'c is a set of tracks to be muxed into a source, 'a is a track
```

It takes the source to decorate as its last argument, the source to take the
video track from as its `video` argument, and returns the first source with the
video track of the second grafted onto it. The correct script is therefore

```{.liquidsoap include="liq/blue-sine2.liq" from=header}
```

and the function `source.mux.audio` can similarly be used to add audio to a
source which does not have that. Dually, `source.drop.video` removes the video
track of a source, as we have seen [above](#sec:source-type).

### Type annotations

\index{type!annotation}

If you want to constrain the contents of a source, the Liquidsoap language
offers the construction `(e : t)` which allows constraining an expression `e` to
have type `t` (technically, this is called a type _cast_). It works for
arbitrary expressions and types, but is mostly useful for sources. For instance,
in the following example, we play the source `s` in mono, even though the
default number of channels is two:

```{.liquidsoap include="liq/mono-output.liq" from=header}
```

Namely, in the second line, we constrain the type of `s` to be
`source(audio=pcm(mono))`, i.e. a source with mono audio.

### Encoding formats {#sec:encoders-intro}

In order to specify the format in which a stream is encoded, Liquidsoap uses
particular annotations called _encoders_\index{encoder}, already presented in
[there](#sec:encoders). For instance, consider the `output.file` operator which
stores a stream into a file: this operator needs to know the kind of file we
want to produce. The (simplified) type of this operator is

```
(format('a), {string}, source('a)) -> unit
```

We see that the second argument is the name of the file and the third argument
is the source we want to dump. The file name is a getter, `{string}` rather
than `string`, so that a new name can be computed every time the file is
reopened. The first argument is the encoding format, of type `format('a)`.
Observe that `format` takes a type variable `'a` as argument, and `'a` is also
the argument of the source taken as argument: the tracks required from the
input source depend on the chosen format.

#### Encoders

The encoding formats are given by _encoders_, whose name always begin with the
"`%`" character and can take parameters: their exhaustive list is given in
[there](#sec:encoders). For instance, if we want to encode a source `s` in mp3
format, we are going to use the encoder `%mp3` and thus write something like

```{.liquidsoap include="liq/format-mp3.liq" from=header}
```

If we have a look at the type of the encoder `%mp3`, we see that its type is

```
format(audio=pcm(stereo))
```

which means that, in the above example, the source `s` will be of type

```
source(audio=pcm(stereo))
```

and thus have to contain stereo pcm audio, and nothing else. The encoders take
various parameters. For instance, if we want to encode mp3 in mono, at a
bitrate of 192 kbps, we can pass the parameters `mono` and `bitrate=192` as
follows:

```{.liquidsoap include="liq/format-mp3-mono.liq" from=header}
```

Some of those parameters will have an influence on the type of the stream. For
instance, if we pass `mono` as parameter, the type of the encoder becomes

```
format(audio=pcm(mono))
```

and thus imposes that `s` should have mono audio.

The parameters which have such an influence on types are fixed once and for
all, at the time the script is loaded, and cannot be read from a variable. For
instance, the following will not be accepted


```{.liquidsoap include="liq/bad/format-mp3-mono.liq" from=header}
```

because the number of channels is taken from the variable `c`. Liquidsoap says

```
Error 14: Uncaught runtime error:
type: encoder,
message: "Invalid value c for channels mode. Only static numbers are allowed.",
stack: at bad/format-mp3-mono.liq, line 4, char 26
```

The parameters which do not change the type, such as `bitrate`, do accept
variables and arbitrary expressions.

#### Encoded sources

\index{encoded stream}

As another example of the influence of encoders, suppose that we want to encode
our whole music library as a long mp3. We would proceed in this way:


```{.liquidsoap include="liq/encoded-concat.liq" from=header}
```

The first line creates a `playlist` source which will read all our music files
once, the second line ensures that we try to encode the files as fast as
possible instead of performing this in realtime as explained in
[there](#sec:clocks-ex), and the third line requires the encoding in mp3 of the
resulting source, calling the `shutdown` function once the source is over, which
will terminate the script.

If you try this at home, you will see that it takes quite some time, because the
`playlist` operator has to decode all the files of the library into internal raw
contents, and the `output.file` operator has to encode the stream in mp3, which
is quite CPU hungry. If our music library already consists of mp3 files, it is
much more efficient to avoid decoding and then reencoding the files. In order to
do so, we can use the FFmpeg encoder, by replacing the last line with

```{.liquidsoap include="liq/encoded-concat2.liq" from=header}
```

Here, the encoder `fmt` states that we want to use the FFmpeg library, in order
to create mp3, from already encoded audio (`%audio.copy`). In this case, the
source `s` will have the type

```
source(audio=ffmpeg.copy('a))
```

where the contents of the audio is already encoded. Because of this, the
`playlist` operator will not try to decode the mp3 files, it will simply pass
their data on, and the encoder in `output.file` will simply copy them in the
output file, thus resulting in a much more efficient script. More details can be
found in [there](#sec:encoded-streams).

<!--
The format of most encoded output operators (`output.icecast`,
`output.file.hls`, `output.srt`, etc.) is determined by an encoder argument in
the same way.
-->

Frames
------

At this point, we think that it is important to explain a bit how streams are
handled "under the hood", even though you should never have to explicitly deal
with this in practice. After parsing a script, liquidsoap starts one or more
streaming loops. Each streaming loop is responsible for creating audio data from
the inputs, pass it through the various operators and, finally, send it to the
outputs. Those streaming loops are animated by _clocks_: each operator is
attached to such a clock, which ensures that data is produced regularly. This
section details this way of functioning.

### Frames

\index{frame}

For performance reasons, the data contained in streams is generated in small
chunks, that we call _frames_ in Liquidsoap. The duration of a frame is
controlled by the `settings.frame.duration` setting whose default value is 0.02
second, i.e. 1/50 th of a second. With the default samplerate, this corresponds
to 882 audio samples. The rates in use and the duration finally retained are
reported at the beginning of the logs:

```
[frame:3] Using 44100Hz audio, 25Hz video, 44100Hz main.
[frame:3] Default video frame size: 1280x720 (auto-detection enabled).
[frame:3] Targeting 'frame.duration': 0.02s = 882 ticks.
```

The unit called a _tick_ is explained [below](#sec:ticks): with the default
settings one tick is one audio sample, so 0.02 second is 882 ticks. A frame is
shorter than one video image, which lasts 1/25 th of a second, and that is
allowed: a frame carries the video data of the interval it covers, and an image
is completed over two frames.

#### Changing the size

The size of frames can be changed by instructions such as

```{.liquidsoap include="liq/frame-duration.liq" from=header to=footer}
```

and Liquidsoap takes the requested duration as is, as long as it amounts to an
integer number of ticks. A duration of 0.06 second, requested by

```{.liquidsoap include="liq/frame-duration2.liq" from=header to=footer}
```

gives

```
[frame:3] Targeting 'frame.duration': 0.06s = 2646 ticks.
```

The duration can also be given in audio samples, with the setting
`settings.frame.audio.size`, which overrides `settings.frame.duration`. Asking
for 1024 samples is the natural thing to do when Liquidsoap has to line up with
a soundcard buffer of that size.

#### Pulling frames

In a typical script, such as

```{.liquidsoap include="liq/streaming1.liq"}
```

the active source is `output.pulseaudio`, and `output.pulseaudio` is
responsible for the generation of frames. The soundcard signals that its
internal buffer is running low, which happens 50 times per second with the
default frame duration, and `output.pulseaudio` then asks `amplify` for a
frame. In turn, `amplify` asks `sine` for a frame, `sine` returns a frame
filled with a sine wave, `amplify` returns that frame with the volume changed,
and `output.pulseaudio` sends the result to the soundcard.

Each operator returns a new frame rather than writing into the frame of its
source. A frame, once produced, is never modified again, and two operators
reading the same source therefore read the same immutable value. This costs
memory, and it buys the guarantee that an operator can hold on to a frame and
read it later without another operator having overwritten it in the meantime.

#### Assumptions on frame size

The frame duration is always supposed to be "small" so that values can be
considered to be constant over a frame. For this reason, and in order to gain
performance, expressions are evaluated only once at the beginning of each
frame. For instance, the following script plays music at a random volume:

```{.liquidsoap include="liq/random-volume.liq" from=header-b}
```

In fact, the random number for the volume is only generated once for the whole
frame. This can be heard if you try to run the above script by setting the frame
duration to a "large" number such as 1 second:

```{.liquidsoap include="liq/random-volume.liq" from=header-a to=footer-a}
```

You should be able to clearly hear that volume changes only once every
second. In practice, with the default duration of a frame, this cannot be
noticed. It can be sometimes useful to increase it a bit (but not as much as 1
second) in order to improve the performance of scripts, at the cost of
decreasing the precision of computed values.

#### Triggering computations on frames

It is possible to trigger a computation on every frame, with the `on_frame`
method\indexop{on\_frame} that every source has. The method takes a function
which is called every time a new frame is computed, and a mandatory
`synchronous` argument which says whether the function runs in the streaming
thread (`true`) or in a separate thread (`false`). For instance, the following
script will increase the volume of the source `s` by 0.01 on every frame:

```{.liquidsoap include="liq/source.on_frame.liq" from=header to=footer}
```

The duration of a frame being 0.02 s, volume will progressively be increased by
0.5 each second.

### Frame raw contents {#sec:liquidsoap-raw}

Let us provide some more details about the way data is usually stored in those
frames, when using raw internal contents, which is the case most of the
time. Each frame has room for audio, video and midi data, the format of this
data we now describe.

#### Audio

The raw audio contents is called `pcm`\indexop{pcm} for _pulse-code modulation_. The signal
is represented by a sequence of _samples_, one for each channel, which represent
the amplitude of the signal at a given instant. Each sample is represented by
floating point number, between -1 and 1, stored in double precision (using 64
bits, or 8 bytes). The samples are given regularly for each channel of the
signal, by default 44100 times per seconds: this value is called the _sample
rate_ of the signal and is stored globally in the
`settings.frame.audio.samplerate` setting. This means that we can retrieve the
value of the samplerate with

```{.liquidsoap include="liq/samplerate-get.liq" from=header to=footer}
```

and set it to another value such as 48000 with

```{.liquidsoap include="liq/samplerate-set.liq" from=header}
```

although default samplerate of 44100 Hz is largely the most commonly in use.

#### Video

A video consists of a sequence images provided at regular interval. By default,
these images are presented at the _frame rate_ of 25 images per second, but this
can be changed using the setting `settings.frame.video.framerate` similarly as
above. Each image consists of a rectangle of pixels. Liquidsoap reads the width
and the height of the first video file it decodes and uses those for the whole
run, and the setting `settings.frame.video.detect_dimensions` turns that
detection off. When no video file is decoded, or when detection is off, the
dimensions are the ones given by the settings
`settings.frame.video.width` and `settings.frame.video.height`, 1280 and 720
respectively (this corresponds to the resolution called 720p or _HD ready_,
which features an aspect ratio of 16:9 as commonly found on television or
computer screens). For instance, _full HD_ or _1080p_ format would be achieved
with

```{.liquidsoap include="liq/fullhd.liq" from=header}
```

Setting either dimension explicitly, as above, also turns the detection off. By
the way, a script which uses no video at all pays nothing for any of this: video
is disabled unless the script asks for it, and the setting
`settings.frame.video.default` forces video on when set to `true`.

Each pixel has a color and a transparency, also sometimes called an _alpha
channel_: this last parameter specifies how opaque the pixels is and is used
when superimposing two images (the less opaque a pixel of the above image is,
the more you will see the pixels below it). Traditionally, the color would be
coded in RGB, consisting of the values for the intensity of the red, green and
blue for each pixel. However, if we did things in this way, every pixel would
take 4 bytes (1 byte for each color and 1 for transparency), which means
4×1280×720×25 bytes (= 87 Mb) of video per seconds, which is too much to handle
in realtime for a standard computer. For this reason, instead using the RGB
representation, we use the YUV representation consisting of one _luma_ channel Y
(roughly, the black and white component of the image) and two _chroma_ channels
U and V (roughly, the color part of the image represented as blueness and
redness). Moreover, since the human eye is not very sensitive to chroma
variations, we can be less precise for those and take the same U and V values
for 4 neighboring pixels. This means that each pixel is now encoded by 1.5 bytes
on average (1 for Y, ¼ for U and ¼ for V) and 1 second of typical video is down
to a more reasonable 32 Mb per second. You should now understand why the
internal contents for video is called `yuv420p`\indexop{yuv420p} in source
types: Y, U and V for the three channels, and 420 for the way the chroma
channels are shared between neighbors.

The transparency is not part of `yuv420p`, and this is why the name carries no
final "a". A video track holds a _canvas_\index{canvas}: a stack of layers,
each one a `yuv420p` image placed at a given position, each one with its own
alpha channel. Superimposing a logo over a video adds a layer to the canvas
instead of rewriting the image below it, which is what makes operators such as
`video.add_image` cheap.

#### MIDI

MIDI\index{MIDI} stands for _Musical Instrument Digital Interface_ and is a (or, rather,
_the_) standard for communicating between various digital instruments and
devices. Liquidsoap mostly follows it and encodes data as lists of _events_
together with the time (in ticks, relative to the beginning of the frame) they
occur and the channel on which they occur. Each event can be "such note is
starting to play at such velocity", "such note is stopping to play", "the value
of such controller changed", etc.

#### Encoded contents

As indicated in [there](#sec:encoded-streams), the data present in frames is not
always in the above format. Namely, Liquidsoap also has support for frames whose
contents is stored either in a format supported by the FFmpeg library, which can
consist of encoded streams (e.g. audio in the mp3 format).

<!--
#### Presentation time

Lastly, each frame also contains a pts (for _presentation timestamp_) which
indicates how this frame should be ordered with respect to other frames. This is
generally irrelevant in traditional applications, but is required 

TODO: explain why we need to have pts (_presentation timestamp_) in
frames\SM{Romain, I need your help on this!}
-->

### Ticks {#sec:ticks}

The time at which something occurs in a frame is measured in a custom unit which
we call _ticks_\index{tick}. To avoid errors due to rounding, which tend to accumulate when
performing computations with float numbers, we want to measure time with
integers. The first natural choice would thus be to measure time in audio
samples, since they have the highest rate, and in fact this is what is done with
default settings: 1 tick = 1 audio sample = 1/44100 second. In this case, an
image lasts 1/25 second = 44100/25 ticks = 1764 ticks.

However, if we change the video framerate to 24 images per second with

```{.liquidsoap include="liq/frame-ticks.liq" from=header to=footer}
```

we have difficulties measuring time with integers because an image now lasts
44100/24 samples = 1837.5 samples, which is not an integral number. In this
case, Liquidsoap conventionally decides that 1 sample = 2 ticks, so that an
image lasts 3675 ticks. Indeed, if you try the above, you will see in the logs

```
Using 44100Hz audio, 24Hz video, 88200Hz main.
```

which means that there are 44100 audio samples, 24 images and 88200 ticks per
second. You will also see in the logs

```
[frame:3] Targeting 'frame.duration': 0.02s = 1764 ticks.
```

which means that the default frame of 0.02 second is 1764 ticks long at this
rate, less than the 3675 ticks of a video image. More generally, the number of
ticks per second is the smallest number such that both an audio and a video
sample last for an integer number of ticks.

### Tracks and metadata

Each frame contains two additional arrays of data which are timed, in ticks
relative to the beginning of the frame: breaks and metadata.

#### Tracks

\index{track}

It might happen that a source cannot entirely fill the current frame. For
instance, in the case of a source playing one file once (e.g. using the operator
`once`), where there are only 0.01 seconds of audio left whereas the frame lasts
0.02 seconds. We could have simply ignored this and filled the last 0.01 seconds
with silence, but we are not like this at Liquidsoap, especially since even such
a short period of a silence can clearly be heard. Don't believe us? You can try
the following script which silences the audio for one frame every second:

```{.liquidsoap include="liq/glitch.liq" from=header}
```

You should clearly be able to hear a tick every second if the played music files
are loud enough. For this reason, if a source cannot fill the frame entirely, it
indicates it by adding a _break_, which marks the position until where the frame
has been filled. If the frame is not complete, it will try to fill the rest on
the next iteration of filling frames.

Each filling operation is required to add exactly one break. In a typical
execution, the break will be at the end of the frame. If this is not the case,
this means that the source could not entirely fill the frame, and this is thus
considered as a _track_ boundary. In Liquidsoap, tracks are encoded as breaks in
frames which are not at the end: this mechanism is typically used to mark the
limit between two successive songs in a stream. In scripts, you can detect when
a track occurs using the `on_track` method that all sources have, and you can
insert track by using the method provided by the `insert_metadata` function.

#### Metadata

\index{metadata}

A frame can also contain _metadata_ which are pairs of strings (e.g. `"artist"`,
`"Alizée"` or `"title"`, `"Moi... Lolita"`, etc.) together with the position in
the frame where they should be attached. Typically, this information is
present in files (e.g. mp3 files contain metadata encoded in ID3 format) and are
passed on into Liquidsoap streams (e.g. when using the `playlist`
operator). They are also used by output operators such as `output.icecast` to
provide information about the currently playing song to the listener. In
scripts, you can trigger a function when metadata is present with `on_metadata`,
transform the metadata with `metadata.map` and add new metadata with
`insert_metadata`. For instance, you can print the metadata contained in tracks:

```{.liquidsoap include="liq/print-metadata.liq" from=header}
```

If you have a look at a typical stream, you will recognize the usual information
you would expect (artist, title, album, year, etc.). But you should also notice
that Liquidsoap adds internal information such as

- `filename`: the name of the file being played,
- `temporary`: whether the file is temporary, i.e. has been downloaded from the
  internet and should be deleted after having been played,
- `source`: the name of the source which has produced the stream,
- `initial_uri`: the URI the request was created from,
- `rid`: the identifier of the request, as explained [below](#sec:requests),
- `status`: where the request stands in its lifecycle.

These are added when resolving requests, as detailed below. There used to be an
`on_air` metadata giving the time at which a track was first played, and the
setting `settings.request.deprecated_on_air_metadata` brings it back for scripts
which still read it.

In order to prevent internal information leaks (we do not want our listeners to
know about our filenames for instance), the metadata are filtered before being
sent to outputs: this is controlled by the `settings.encoder.metadata.export`
setting, which contains the list of metadata which will be exported, and whose
default value is

```
["artist", "title", "album", "genre", "date", "tracknumber", "comment",
 "track", "year", "dj", "next", "apic", "pic", "metadata_url",
 "metadata_block_picture", "coverart"]
```

The last five of those carry cover art rather than text. The setting
`settings.encoder.metadata.cover` lists the metadata which encoders treat as
cover art, and its default value is

```
["pic", "apic", "metadata_block_picture", "cover"]
```

The streaming model
-------------------

### The stream generation workflow {#sec:stream-generation}

When starting the script, Liquidsoap begins with a _creation phase_ which
instantiates each source and computes its parameters by propagating information
from the sources it uses. The two main characteristics determined for each
source are

- _fallibility_: we determine whether the source is fallible, i.e. might be
  unable to produce its stream at some point (this is detailed below),
- _clocks_: we determine whether the source is synchronized by using the cpu or
  has its own way of keeping synced, e.g. using the internal clock of a
  soundcard (this is also detailed below).

#### Lifecycle of a source

The standard lifecycle of a source is the following one:

- we first inform the source that we are going to use it (we also say that we
  _activate_ it) by asking it to _get ready_, which triggers its initialization,
- then we repeatedly ask it for _frames_,
- and finally, when the script shuts down, we _leave_ the source, indicating
  that we are not going to need it anymore.

The information always flows from outputs to inputs. For instance, in a simple
script such as

```{.liquidsoap include="liq/amplify-playlist.liq" from=header}
```

at beginning Liquidsoap will ask the output to get ready, in turn the output
will ask the amplification operator to get ready, which will in turn ask the
playlist to get ready (and leaving would be performed similarly, as well as the
computation of frames as explained above). Note that a given source might be
asked multiple times to get ready, for instance if it is used by two outputs
(typically, an icecast output and an HLS output). The first time it is asked to
get ready, the source _wakes up_ at which point it sets up what it needs (and
dually, the last time it is asked to leave, the source goes to _sleep_ where it
cleans up everything). Typically, an `input.http` source, will start polling the
distant stream at wake up time, and stop at sleep time.

You can observe this in the logs (you need to set your log level to at least 4):
when a source wakes up it emits a message of the form

```
[source:4] Source sine gets up from output.dummy with content type: {audio=pcm(stereo)} and frame type: {audio : pcm(stereo)}.
```

and when it goes to sleep it emits

```
[source:4] Source sine gets down.
```

where `sine` is the identifier of the source (which can be changed by passing an
argument labeled `id` when creating the source), and `output.dummy` is the clock
the source was woken up from. You can also determine whether a source has been
woken up, by using the method `is_up` which is present for any source `s`:
calling `s.is_up()` will return a boolean indicating whether the source `s` is up
or not. For instance,

```{.liquidsoap include="liq/is_up.liq" from=header to=footer}
```

will print, after 1 second, whether the playlist source is up or not (in this
example it will always be the case).

#### Computing the content type, again

\index{contents}

The wake-up message above carries two pieces of information which look like the
same thing. The _frame type_ is what the typechecker inferred, and the frame
type may still contain variables. The _content type_ is what the source will
actually produce, with every parameter fixed: `{audio=pcm(stereo)}` says two
channels of raw audio and nothing else. Liquidsoap drops types during execution
for efficiency reasons, so the content type is computed again at wake up, from
the frame type and from the default settings for whatever the frame type left
open. The computation happens once per source at startup and costs nothing
noticeable.

Scripts can read the content type of a source with
`source.content`\indexop{source.content}, which returns the list of the tracks
of the source paired with their format, and
`format.description`\indexop{format.description}, which turns a format into a
record we can print:

```{.liquidsoap include="liq/source-content.liq" from=header}
```

On our machine this prints

```
audio: {pcm={channel_layout="stereo", channels=2}}
video: {yuv420p={alpha=null, height=720, width=1280}}
```

The same information is available track by track with
`track.format`\indexop{track.format}, which takes one track out of
`source.tracks` and returns its format.

#### The streaming loop

As explained above, once the initialization phase is over, the outputs regularly
ask the sources they should play to fill in frames: this is called the
_streaming loop_. Typically, in a script of the form

```{.liquidsoap include="liq/streaming3.liq" from=header}
```

the Icecast output asks the amplification operator for a frame, the
amplification operator asks the switch for a frame, and the switch asks either
the `morning` or the `default` source depending on the time. Each operator
returns a new frame. The amplification operator reads the frame the switch
returned and produces a second frame with the volume changed, and the frame the
switch returned is left untouched.

Since the computation of frames is triggered by outputs, when a source is shared
by two outputs, at each round it will be asked twice for a frame (once by each
output). For instance, consider the following script:

```{.liquidsoap include="liq/streaming2.liq"}
```

Here, the source `s` is used twice: once by the pulseaudio output and once by
the icecast output. Each source produces at most one frame per streaming cycle
and keeps the result until the end of the cycle: `amplify` computes its frame
when `output.pulseaudio` asks for it, and hands the very same frame to
`output.icecast` a moment later. Computing it twice would be disastrous, since
each output would then get one frame out of every two.

The two outputs do not have to consume the same amount of that frame. Each one
reports how much it read, and whatever is left over is kept for the next cycle.
This keeps two outputs in step when one of them stops at a track mark and the
other one does not.

### Fallibility

\index{fallibility}
\index{source!fallible}

Some sources can _fail_, which means that they do not have a sensible stream to
produce at some point. This typically happens after ending a track when there is
no more track to play. For instance, the following source `s` will play the file
`test.mp3` once:

```{.liquidsoap include="liq/once-single.liq" from=header-a to=footer-a}
```

After the file has been played, there is nothing to play and the source
fails. Internally, each source has a method to indicate whether it _is ready_,
i.e. whether it has something to play. Typically, this information is used by
the `fallback` operator in order to play the first source which is ready. For
instance, the following source will try to play the source `s`, or a sine if `s`
is not ready:

```{.liquidsoap include="liq/once-single.liq" from=header-b to=footer-b}
```

In Liquidsoap scripts, every source has a method `is_ready` which can be used to
determined whether it has something to play.

On startup, Liquidsoap ensures that the sources used in outputs never fail
(unless the parameter `fallible=true` is passed to the output). This is done by
propagating fallibility information from sources to sources. For instance, we know that a
`blank` source or a `single` source will never fail (for the latter, this is
because we download the requested file at startup), `input.http` is always
fallible because the network might go down, a source `amplify(s)` has the same
fallibility as `s`, and so on. Typically, if you try to execute the script

```{.liquidsoap include="liq/fallible1.liq" from=header}
```

Liquidsoap will issue the error

```
Error 7: Invalid value:
That source is fallible.
This value was passed through the following call stack:
at fallible1.liq, line 3, char 0-20
```

indicating that it has determined that we are trying to play the source `s`,
which might fail, and pointing at the `output.pulseaudio` call which does it.
The way to fix this is to use the `fallback`\indexop{fallback} operator in order
to play a file which is always going to be available in case `s` falls down:

```{.liquidsoap include="liq/fallible2.liq" from=header}
```

Or to use `mksafe`\indexop{mksafe} which is defined by

```{.liquidsoap include="liq/mksafe.liq" from=header}
```

and will play blank in case the input source is down. The `track_sensitive =
false` method tells the fallback to switch back to `s` as soon as `s` is ready
again, without waiting for the end of the blank track, and the `on_select`
methods keep the two sources switching without a fade, as explained in
[there](#sec:composition).

The "worse" source with respect to fallibility is given by the operator `source.fail`\indexop{source.fail}, which creates a source which
is never ready. This is sometimes useful in order to code elaborate
operators. For instance, the operator `once`\indexop{once} is defined from the `sequence`
operator (which plays one track from each source in a list) by

```{.liquidsoap include="liq/once.liq"}
```

Another operator which is related to fallibility is `max_duration`\indexop{max\_duration} which makes a
source unavailable after some fixed amount of time.

### Clocks {#sec:clocks}

Every source is attached to a particular a _clock_\index{clock}, which is fixed during the
whole execution of the script, and is responsible for determining when the next
frame should be computed: at regular intervals, the clock will ask active
sources it controls to generate frames. We have said that a frame lasts for 0.02
seconds by default, which means that a new frame should be computed every 0.02
seconds, or 50 times per second. The clock is responsible for measuring the time
so that this happens at the right rate.

#### Multiple clocks

The first reason why there can be multiple clocks is _external_: there is simply
no such thing as a canonical notion of time in the real world. Your computer has
an internal clock which indicates a slightly different time than your watch or
another computer's clock. Moreover, when communicating with a remote computer,
network latency causes extra time distortions. Even within a single computer
there are several clocks: notably, each soundcard has its own clock, which will
tick at a slightly different rate than the main clock of the computer, and each
sound library makes a different use of the soundcard. For applications such as
radios, which are supposed to run for a very long time, this is a problem. A
discrepancy of 1 millisecond every second will accumulate to a difference of 43
minutes after a month: this means that at some point in the month we will have
to insert 43 minutes of silence or cut 43 minutes of music in order to
synchronize back the two clocks! The use of clocks allows Liquidsoap to detect
such situations and require the user to deal with them. In practice, this means
that each library (ALSA, Pulseaudio, etc.) has to be attached to its own clock, as well
as network libraries taking care of synchronization by themselves (SRT).

There are also some reasons that are purely _internal_ to Liquidsoap: in order
to produce a stream at a given rate, a source might need to obtain data from
another source at a different rate. This is obvious for an operator that speeds
up or slows down audio, such as `stretch`. But it also holds more subtly for
operators such as `cross`, which is responsible for crossfading successive
tracks in a source: during the lapse of time where the operator combines data
from an end of track with the beginning of the next one, the crossing
operator needs twice as much stream data. After ten tracks, with a crossing
duration of six seconds, one more minute will have passed for the source
compared to the time of the crossing operator.

An operator of this kind puts its input in a _child clock_\index{clock!child}
and pulls from that child clock faster than its own clock advances. The data
pulled ahead has to be kept somewhere, and the setting
`settings.clock.child.max_buffer` caps how much of it Liquidsoap is willing to
hold (10 seconds by default). Raise it if you ask `cross` for transitions longer
than that.

The use of clocks in Liquidsoap ensures that a given source will not be pulled
at two different rates by two operators. This guarantees that each source will
only have to sequentially produce data and never simultaneously produce data for
two different logical instants, which would be a nightmare to implement
correctly.

<!--
Some operators impose the use of a particular clock, because they have their own
way of synchronizing or use time. For instance, for most soundcard-related inputs and
outputs the synchronization is taken care of directly by the soundcard (which
has its own physical clock and buffers, and is able to signal us when a data
refill is needed). Also, some operators need to play source at a different
timing than global time: this is the case for the `stretch` operator which
changes the speed at which a source is played, or of the `crossfade` operator
which needs to compute the next track in advance in order to be able to perform
transitions between tracks. When such an operator is present its clock will be
used, otherwise the "default" clock based on CPU time is used (this clock is
called `main`). It is perfectly possible that two distinct parts of the script
use different clocks, although each operator should have one unambiguously
assigned clock.
-->

#### Observing clocks

Consider the following script:

```{.liquidsoap include="liq/clock-alsa-file.liq" from=header}
```

At startup, Liquidsoap creates a top-level clock named after the output
operator, and logs every source that clock controls along with its role:

```
[clock:3] Starting top-level clock output.file with sources: output.file (output), amplify (passive), track_audio_amplify (passive), input.alsa (active) and sync: auto
```

A source marked `active` is animated at every streaming cycle, whether or not
anything downstream is pulling from it. The source `input.alsa` is active
because `input.alsa` has to keep reading the soundcard, and audio that nobody
reads is audio that is lost. A source marked `passive` is animated only when
something downstream asks it for a frame. Each operator also logs which clock
it belongs to:

```
[amplify:5] Clock is output.file.
```

The `sync: auto` at the end of the first message is the clock's sync mode. In
`auto` mode, the clock waits to see whether one of its sources controls its own
latency. Here `input.alsa` does, because ALSA blocks until the soundcard has
audio to hand over. The clock therefore hands timing over to `input.alsa` and
logs:

```
[clock.output.file:3] Switching to self-sync mode (alsa)
```

If we now consider a script where no source enforces synchronization, such as

```{.liquidsoap include="liq/clock-sine-file.liq" from=header}
```

the clock is led by the CPU: no `active` source appears in the startup message,
and the clock sleeps between ticks to keep real time. You will also see the
following message whenever a clock loses its synchronization source and goes
back to being led by the CPU:

```
[clock.output.file:3] Switching to non-self-sync mode
```

A clock can be created explicitly with `clock.create`\indexop{clock.create},
whose `sync` argument takes the four modes: `"auto"` is the one we have just
described, `"cpu"` always keeps real time whatever the sources say, `"none"`
runs the streaming loop as fast as it can (which is what we used
[there](#sec:clocks-ex) to encode a library faster than realtime), and
`"passive"` never ticks on its own and waits for the script to tick it.

Rather than reading the logs, you can ask Liquidsoap to describe the clocks it
built and then quit, with the `--describe-clocks` option. On a script which
crossfades a source, this gives

```
Clocks dump: output.dummy (ticks: 64, time: 1.28s, self_sync: false)
  |-- outputs: output.dummy [output.dummy]
  |-- active sources:
  |-- passive sources: cross [cross, cross], crossfade [crossfade],
  |                    crossfade.1 [crossfade.1, crossfade.1],
  |                    track_metadata_deduplicate [track_metadata_deduplicate],
  |                    metadata_deduplicate [metadata_deduplicate],
  |                    cross.pre_buffer [cross.pre_buffer]
  `-- cross (ticks: 313, time: 6.26s, self_sync: false)
      |-- outputs: mksafe.child [mksafe.child, mksafe.child]
      |-- active sources:
      `-- passive sources: safe_blank [safe_blank], sine [sine, sine], mksafe [mksafe, mksafe],
                           sine.proxy [sine.proxy]
```

We see the two clocks, one nested inside the other, and we can check that the
child clock of `cross` has ticked 313 times where the top-level clock has ticked
64 times: the child clock is running ahead, which is exactly what `cross` needs
it for. The companion option `--describe-sources` prints the same tree from the
point of view of the sources. Both options run your script for a second before
printing, which you can change with `--dump-delay`, and both are experimental.

#### Graphical representation

In case it helps to visualize clocks, a script can be drawn as some sort of graph
whose vertices are the operators and there is an arrow from a vertex `op` to a
vertex `op'` when the operator `op'` uses the stream produced by the operator
`op`. For instance, a script such as

```{.liquidsoap include="liq/two-clocks.liq" from=header}
```

can be represented as the following graph:

![](fig/two-clocks.pdf)

The dotted boxes on this graph represent clocks: all the nodes in a box are
operators which belong to the same clock. Here, we see that the `playlist`
operator has to be in its own clock `clock₂`, because the `crossfade` operator
pulls from `playlist` ahead of time in order to compute transitions, whereas all
other operators belong the same clock `clock₁` and will produce their stream at
the same rate.

#### Errors with clocks

At most one source per clock may be a synchronization source at any given
moment\index{clock!synchronization source}. Two of them in the same clock is
allowed as long as only one of the two is producing data at a time, which is why
`fallback([input.srt(), input.alsa()])` is a perfectly good script. Two of them
producing at the same time is the conflict, and Liquidsoap reports it. For
instance, the script

```{.liquidsoap include="liq/clock-alsa-pulseaudio.liq" from=header}
```

will raise the error

```
Error 17: clock output.alsa has multiple synchronization sources. Do you need to set self_sync=false?

Sync sources:
 alsa from source output.alsa
 pulseaudio from source output.pulseaudio

Stack traces:
...
```

followed by the place in the script where each of the two sources was created.
Both ALSA and PulseAudio control their own timing, and the clock cannot honor
two different paces at once. The question in the error message is worth taking
literally: every operator which can be a synchronization source takes a
`self_sync` argument, and `self_sync=false` drops that role. We do not recommend
`self_sync=false` for a radio which runs for months, because the two paces then
drift apart with nothing to correct them. The buffer operators are the sound
answer, and we cover them [there](#sec:clocks-ex).

A different kind of conflict occurs with the operators which use a child clock,
such as `stretch` and `cross`. The script

```{.liquidsoap include="liq/clock-add-stretch.liq" from=header to=footer}
```

asks for the source `s` inside the child clock of `stretch` and for the same
source `s` in the clock of `add`. The source `s` would have to produce data at
normal speed and at half speed at the same time, so Liquidsoap refuses to start:

```
Error 11: Cannot unify two nested clocks
(clock(id=stretch,sync=stopped,pending=auto),
clock(id=stretch,sync=stopped,pending=passive)). Do you need to set
`settings.output.use_default_clock := false`?
```

An operator with a child clock also needs a child it can accelerate, and a
synchronization source cannot be accelerated: the soundcard delivers audio at
the pace the soundcard chooses. Feeding one to `stretch`, as in

```{.liquidsoap include="liq/clock-srt-stretch.liq" from=header}
```

gives

```
Error 7: Invalid value:
This source may control its own latency and cannot be used with this operator.
```

and the fix is to put a `buffer` between the two, which we detail just below.

<!--

#### Ensuring clock consistency

At the initialization phase, Liquidsoap assigns a clock to each operator by
taking the one enforced by some source if any (such as `alsa`, as explained
above), or defaulting the CPU clock `main`. If two distinct clocks are to be
used, Liquidsoap issues an error and refuses to start. For instance, if we try
to run

```{.liquidsoap include="liq/clock-alsa-pulseaudio-full.liq" from=header}
```

we have a clock inconsistency because `output.pulseaudio` enforces the use of
the `pulseaudio` clock and `input.alsa` enforces the use of the `alsa`
clock. Liquidsoap detects this and displays the error

```
Error 10: A source cannot belong to two clocks (alsa[], pulseaudio[]).
```

which indicates it. Some network protocols such as SRT also have their own
notion of logical time, so that the script

```{.liquidsoap include="liq/bad/clock-srt-pulseaudio.liq" from=header}
```

will also fail for exactly the same reasons.

Why is it the case? After all, it seems that the time measured by any library
based on the soundcard or the CPU should be the same. Well, in practice, no: two
internal clocks in a computer (e.g. from the CPU and from the soundcard) are very
likely to tick at slightly different rates, which means that the relative time
measured by those will drift apart over time. For applications such as radios,
which are supposed to run for a very long time, this is a problem. A discrepancy
of 1 millisecond every second will accumulate to a difference of 43 minutes
after a month: this means that at some point in the month we will have to insert
43 minutes of silence or cut 43 minutes of music in order to synchronize back
the two clocks! This is clearly that we do not want to be silently handled, so
that, when it detects that it might be the case Liquidsoap simply refuses to
start.

-->

<!--

As mentioned earlier, clocks control the latency associated with each streaming
cycle. The default clock tries to run this streaming loop in real-time, speeding
up when filling the frame takes more time than the frame's duration.  When this
happens, you will see the infamous `catchup` log messages:

```
[clock.wallclock_main:2] We must catchup 2.82 seconds!
```

However, in some cases such as a `input.alsa`, the sound card already has its
own clock. In this case, it is assumed that the source (or output) controls the
latency, blocking each filling call until it has enough data to return. For
these situations, the clock assigned by liquidsoap does _not_ try to control the
latency and, instead, runs the streaming loop as fast as possible, delegating
latency control to the underlying sources. In these situations, you will not see
any `catchup` log messages.

There also are situations where the clock may switch from controlling the
latency to delegating it to the underlying sources or vice-versa. Consider for
instance the following script:

```liquidsoap
s = fallback([
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

Clock cycles and frame duration define the I/O delay that you can expect when
working with liquidsoap. If you aim for a shorter delay, specially when working
with only audio, try to lower the video rate.\RB{Man we need to detect that and
not use video when computing the frame size!}. This also means that streaming
happens by increment of a frame's length. Thus, `source.time` for instance is
precise down to the frame's duration. The same goes for scripted fade operators.

### Clocks & Time Discrepancies

Clocks in liquidsoap can be confusing. They are, however, central to the
functioning of the internals while streaming data. Let's try to explain why they
had to be introducted and how they are aasigned and used. For more details, the
reader is invited to check out our initial research paper, entitled [Liquidsoap:
a High-Level Programming Language for Multimedia
Streaming](https://www.liquidsoap.info/assets/docs/bbm10.pdf)

#### What's the big deal?

To understand the need for clocks, we should first remember that all data in a
digital system is _sampled_. The sampling operation relies on a clock to tick at
the frequency that is used for sampling. For instance, for `44.1kHz` audio, the
sampling operation relies on a clock ticking every `1/44.100` seconds.

But, what happens if this clock, in fact, ticks at a slightly different rate,
for instance `1/44.100+0.001` seconds? Even worst, and not to be pedantic here
but, relativity theory actually tells us that two clocks following different
motions do not agree on time. A famous example being the fact that the atomic
clocks over the globe have to be mindful of their respective elevation, in order
to keep track of time discrepancies due to the earth's rotation...

But, anyways, let's go down to earth and consider a much more practical case:
two internal clocks in a computer are _very_ likely to tick at slightly different
rates. It can be that these two rates cancel out statistically over time or, in
the worst case, it can be that these two rates drift appart over time.

Consider now what happens when a listener receives a stream encoded by another
computer. Locally, the listener takes the sequence of data samples and
re-assembles them to create an analog signal for human's consumption.  However,
if the listener's and the encoder's clock do not agree, the might be some issues
down the road.

When playing a recorded file, clock discrepancies between the encoder and
decoder usually do not matter.  Eventually, for instance, a movie's playback
time on the viewer's computer ends up being a slighly different which does not
really impact the viewer's experience. However, with a continuous, real-time
stream, things can be slightly more annoying. For instance, if the drift is
constant over time, the listener's buffers might run out of data or be overrun
with data, leading to loss of data while playing the stream.

#### How does it matter?

In liquidsoap, clock and time discrepancies matter on the following cases:

1. Reading or writing data to a sound card
2. Sending or receiving data over the network
3. Accelerating or slowing down a source's rate

The first case is the most straight forward: computer's sound card have their
own local clock, used for sampling and rendering audio data. This clock is
different than the computer's clock and, hopefully, more accurate. When
accessing the sound card, either to read (record) or write (play) data, the
sound card's driver will block until enough data has been read or writen based
on the sound card's clock. In such a case, liquidsoap needs to be aware of the
situation and delegate time synchronizatin to the sound card.

The second case is usually transient. Network operations can have slow down and
blocking if, for instance, the network is down. This can happen with
`output.icecast`. Also, some network operators such as `input.srt` have their
own notion of time, similar to the sound card's local clock, and will block to
control the latency over which network data is being delivered.

The third case is specific to our needs. Consider a source with track
crossfades. Originally, the source contains two tracks adjacent to each other:
`<track1>, <track2>`. After applying a crossdade, a portion of the ending and
starting tracks overlap: `<track1 ...>, <end of track 1 + beginning of track 2>,
<... track2>`\RB{Add figure} After this operation, the stream's playback time is
shortened by the amount of time used to mix the two tracks.

In order to achieve this in a real-time stream, liquidsoap needs to briefly
accelerate the source in order to bufferize the beginning of `<track2>` and
compute the crossfade transition.  This, in turn, requires that the source can
actually be accelerated, which is possible if the source, for instance, is a
playlist of files, but won't work if it is a live source from the sound card.

Lastly, there is still, of course, the chance that a listener's clock drifts
away from the clock used to synchronize liquidsoap. However, there isn't much
that we can do from a sender's perspective. In this case, we expect the
listener's playback software to be able to mitigate, for instance by using an
adaptative resampler. One such example is The VLC player.
-->

#### Mediating between clocks: buffers

As we have seen in [there](#sec:clocks-ex), the usual way to handle clock
problems is to use buffer operators (either `buffer`\indexop{buffer} or
`buffer.adaptative`\indexop{buffer.adaptative}):
they record in a buffer some of their input source before outputting it (1 second by
default), so that it can easily cope with small time discrepancies. Because of
this, we allow that the clock of their argument and their clocks are different.

For instance, we have seen that the script

```{.liquidsoap include="liq/clock-alsa-pulseaudio.liq" from=header}
```

is not allowed because it would require `s` to belong to two distinct
clocks. Graphically,

![](fig/clock-alsa-pulseaudio.pdf)

The easy way to solve this is to insert a `buffer` operator before one of the
two outputs, say `output.alsa`:

```{.liquidsoap include="liq/clock-alsa-pulseaudio2.liq" from=header}
```

which allows having two distinct clocks at the input and the output of `buffer`
and thus two distinct clocks for the whole script:

![](fig/clock-alsa-pulseaudio2.pdf)

#### Catching up

\index{catchup}

We have indicated that, by default, a frame is computed every 0.02 second. In
some situations, the generation of the frame could take more than this: for
instance, we might fetch the stream over the internet and there might be a
problem with the connection, or we are using very cpu intensive audio effects, and
so on. What happens in this case? If this is for a very short period of time,
nothing: there are buffers at various places, which store the stream in advance
in order to cope with this kind of problems. If the situation persists, those
buffer will empty and we will run into trouble: there is not enough audio data
to play and we will regularly hear no sound.

This can be tested with the `sleeper`\indexop{sleeper} operator, which can be used to simulate
various audio delays. Namely, the following script simulates a source
which takes roughly 1.1 second to generate 1 second of sound:

```{.liquidsoap include="liq/sleeper.liq" from=header}
```

When playing it you should hear regular glitches and see messages such as

```
[clock.pulseaudio:2] Latency is too high: we must catchup 0.86 seconds! Check if your system can process your stream fast enough (CPU usage, disk access, etc) or if your stream should be self-sync (can happen when using `input.ffmpeg`). Refer to the latency control section of the documentation for more info.
```

This means Liquidsoap took _n_+0.86 seconds to produce _n_ seconds of audio, and
is thus "late". In such a situation, it will try to produce audio faster than
realtime in order to "catch up" the delay.

Two settings decide when that message appears. The clock stays quiet until the
delay reaches `settings.clock.log_delay_threshold` (0.2 second by default), and
it then repeats the message at most once every `settings.clock.log_delay`
(1 second by default). Beyond `settings.clock.max_latency` (60 seconds by
default) the clock gives up on catching up, resets its active sources, and logs

```
[clock.pulseaudio:2] Too much latency! Resetting active sources...
```

#### Coping with catch up errors

How can we cope with this kind of situations? Again, buffers are a solution to
handle temporary disturbances in production of streams for sources. You can
explicitly add some in you script by using the `buffer` operator: for instance,
in the above script, we would add before the output, the line

```{.liquidsoap include="liq/buffer-catchup.liq" from=header to=footer}
```

which make the source store 1 second of audio (this duration can be configured
with the `buffer` parameter) and thus bear with delays of less than 1 second.

A more satisfactory way to fix this consists in identifying the cause of the
delay, but we cannot provide a general answer for this, since it largely depends
on your particular script. The only general comment we can make is that
something is taking time to compute at some point. It could be that your cpu is
overloaded and you should reduce the number of effects, streams or simultaneous
encodings. It could also come from the fact that you are performing operations
such as requests over the internet, which typically take time. For instance, we
have seen in [an earlier section](#sec:harbor) that we can send the metadata of
each track to a website with a script such as

```{.liquidsoap include="liq/post-metadata.liq" from="# header" to="# footer"}
```

which uses `http.post` to POST the metadata of each track to a distant
server. The argument `synchronous=true` asks for `handle_metadata` to be called
by the streaming loop itself, which means that the next frame waits for the
website to answer. Passing `synchronous=false` instead hands `handle_metadata`
to the scheduler, which runs it on one of its own threads while the streaming
loop carries on:

```{.liquidsoap include="liq/post-metadata2.liq" from=header to=footer}
```

Every handler which can take time should be registered this way. The scheduler
keeps `settings.scheduler.blocking_tasks` threads (8 by default) for the
handlers which block on something, and raising that number is the answer if you
register a lot of them and see them queue up behind each other.

Clocks themselves run as scheduler tasks rather than as threads of their own, so
a clock which is ahead of real time parks and lets the scheduler wake it up
instead of holding a thread asleep. The setting `settings.clock.task` turns that
off, and `settings.scheduler.legacy` restores the single-core scheduler of the
older versions if a script of yours misbehaves on several cores. A `jack` input
or output keeps a thread of its own whatever `settings.clock.task` says, because
the JACK library requires calls from the thread which set it up.

A last way of dealing with the situation is by simply ignoring it. If the only
thing which is disturbing you is the error messages that pollute your log and
not the error itself, you can have fewer messages by changing the
`settings.clock.log_delay` setting which controls how often the "catchup" error
message is displayed. For instance, with

```{.liquidsoap include="liq/clock.log_delay.liq" from=header to=footer}
```

you will only see one every minute.

<!--
#### The `clock` operator

TODO: the `clock` operator

TODO: we briefly explain the principle of clocks here and give the practice in
[a later section](#sec:clocks)

#### Local time for sources

explain `source.time`, say that this is often used in conjunction with the
`on_frame` method (for instance, `source.run`)
-->

Requests
--------

When passing something to play to an operator, such as `test.mp3` to the
operator `single`,

```{.liquidsoap include="liq/single-file.liq" from=header to=footer}
```

it seems that the operator can simply open the file and play it on the
go. However, things are a bit more complicated in practice. Firstly, we have to
actually get the file:

- the file might be a distant file (e.g. `http://some.server/file.mp3` or
  `ftp://some.server/file.mp3`), in which case we want to download it beforehand
  in order to ensure that we have a valid file and that we will not be affected
  by the network,
- the "file" might actually be more like a recipe to produce the file (for instance
  `say:Hello you`, means that we should take some text-to-speech program to
  generate a sound file with the text `Hello you`).

Secondly, we have to find a way to decode the file

- we have to guess what format it is, based on the header of the file and its
  extension,
- we have to make sure that the file is valid and find a _decoder_, i.e. some
  library that we support which is able to decode it,
- we have to read the metadata of the file
<!-- - we have to compute an estimation of the duration of the file when
possible. -->

Finally, we have to perform some cleanup after the file has been played:

- the decoder should be cleanly stopped,
- temporary files (such as downloaded files) have to be removed.

Also note that the decoder depends on the kind of source we want to produce: for
instance, an mp3 file will not be acceptable if we are trying to generate video,
but will of course be if we are trying to produce audio only.

For those reasons, most operators (such as `single`, `playlist`, etc.) do not
directly deal with files, but rather with _requests_. Namely, a request is an
abstraction which allows manipulating files but also performing the above
operations.

### Requests {#sec:requests}

A _request_\index{request} is something from which we can eventually produce a file.

#### URI

It starts with an URI\index{URI} (_Uniform Resource Identifier_), such as

- `/path/to/file.mp3`
- `http://some.server/file.mp3`
- `annotate:title="My song",artist="The artist":~/myfile.mp3`
- `replaygain:/some/file.mp3`
- `say:This is my song`
- `synth:shape=sine,frequency=440.,duration=10.`
- ...

As you can see the URI is far from always being the path to a file. The part
before the first colons (`:`) is the _protocol_ and is used to determine how to
fetch or produce the file. A local file is assumed when no protocol is
specified. Some protocols such as `annotate` or `replaygain` operate on URI,
which means that they allow chaining of protocols so that

```
replaygain:annotate:title="Welcome":say:Hello everybody!
```

is a valid request.

#### The status of a request

When a request is created it is assigned a _RID_\index{RID}, for _request identifier_,
which is a number which uniquely identifies it (in practice the first request
has RID 0, the second one RID 1, and so on). Each request also has a _status_
which indicate where it is in its lifecycle:

1. _idle_: this is the initial status of a request which was just created,
2. _resolving_: we are generating an actual file for the request,
3. _ready_: the request resolved to a file and can be played,
4. _failed_: the resolution did not produce anything we can play,
5. _destroyed_: the request has been played and destroyed (it should not be used
   anymore).

#### Resolution

\index{resolution}
\index{request!resolution}

The process of generating a file from a request is called _resolving_ the
request. The _protocol_ specifies the details of this process, which is done in
two steps:

1. some computations are performed (e.g. sound in produced by a text-to-speech
   library for `say`),
2. a list of URI, called _indicators_\index{indicator}, is returned.

Generally, only one URI is returned: for instance, the `say` protocol generates
audio in a temporary file and returns the path to the file it produced. When
multiple URI are returned, Liquidsoap is free to pick any of them and will
actually pick the first working one. Typically, a "database" protocol could
return multiple locations of a given file on multiple servers for increased
resiliency.

When a request is indicated as _persistent_ is can be played multiple times
(this is typically the case for local files). Otherwise, a request should only be
used once. Internally, with every indicator is also associated the information
of whether it is _temporary_ or not. If it is, the file is removed when the
request is destroyed. For instance, the `say` protocol generates the text in a
temporary file, which we do not need after it has been played.

When resolving the request, after a file has been generated, Liquidsoap also
ensures basic checks on data and computes associated information:

- we read the metadata in the file (and convert those to the standard UTF-8
  encoding for characters),
<!-- - we compute its duration if possible, -->
- we find a library to decode the file (a decoder).

The resolution of a request may _fail_ if the protocol did not manage to
successfully generate a file (for instance, a database protocol used with a
query which did not return any result) or if no decoder could be found (either
the data is invalid or the format is not supported).

#### Manipulating requests

Requests can be manipulated within the language with the following functions.

- `request.create` creates a request from an URI. It can be specified to be
  persistent or temporary with the associated arguments. Beware that temporary
  files are removed after they have been played so that you should use this with
  care.
- `request.resolve` forces the resolution of a request. This function returns a
  boolean indicating whether the resolution succeeded or not. The `timeout`
  argument specifies how much time we should wait before aborting (resolution
  can take long, for instance when downloading a large file from a distant
  server). The `content_type` argument indicates a source with the same content
  type (number and kind of audio and video channels) as the source for which we
  would like to play the request: the resolution depends on it (for instance, we
  cannot decode an mp3 file to produce video...). Resolving twice does not hurt:
  resolution will simply not do anything the second time.
- `request.destroy` indicates that the request will not be used anymore and
  associated resources can be freed (typically, we remove temporary files).
- `request.id` returns the RID of the request.
- `request.status` returns the current status of a request (idle, resolving,
  ready, failed or destroyed) and `request.resolved` indicates whether a request
  is ready to play.
- `request.uri` returns the initial URI which was used to create the request and
  `request.filename` returns the file to which the request resolved.
- `request.duration` returns the (estimated) duration of the request in seconds.
- `request.metadata` returns the metadata associated to request. This metadata
  is read when resolving the file, and passing `resolve_metadata=false` to
  `request.create` skips that reading for a request we only want to hand over to
  another program.
- `request.log` returns the log associated to a particular request. It is useful
  in order to understand why a request failed to resolve and can also be
  obtained by using the `request.trace` telnet command.

Requests can be played using operators such as

- `request.queue` which plays a dynamic queue of requests,
- `request.dynamic` which plays a sequence of dynamically generated requests,
- `request.once` which plays a request once.

Those operators take care of resolving the requests before using them and
destroying them afterward. By the way, `source.dynamic`\indexop{source.dynamic}
does the same thing one level up: it plays a source which a function of yours
returns, and swaps that source for another one whenever you ask it to.

A request does not have to be played to be useful. The function
`request.dump`\indexop{request.dump} encodes the whole contents of a request
into a file as fast as the machine allows, which is how you transcode a file
without setting up an output and a clock by hand, and
`request.process`\indexop{request.process} does the same while letting you
insert operators between the request and the encoder through its `process`
argument. Both take a `ratio` argument saying how much faster than realtime to
run (50 times by default).

#### Metadata {#sec:requests-metadata}

When resolving requests, Liquidsoap inserts metadata\index{metadata} in addition to the metadata
already contained in the files. This can be observed with the following script:

```{.liquidsoap include="liq/request-metadata.liq" from=header}
```

Here, we are creating a request from a file path `test.mp3`. Since we did not
resolve the request, the metadata of the file has not been read yet. However,
the request still contains metadata indicating internal information about it. Namely, the
script prints:

```
[("initial_uri", "test.mp3"), ("rid", "0"), ("status", "idle"),
 ("temporary", "false")]
```

The meaning of the metadata should be obvious:

- `rid` is the identifier of the request,
- `status` is the status of the request,
- `initial_uri` is the uri we used to create the request,
- `temporary` indicates whether the file is temporary or not.

Once the request is resolved, a `filename` metadata appears as well, holding the
file the request resolved to.

#### Protocols

\index{protocol}

The list of protocols available in Liquidsoap for resolving requests can be
obtained by typing the command

```
liquidsoap --list-protocols-md
```

on [on the website](https://www.liquidsoap.info/doc-dev/protocols.html). The
documentation also indicates which protocol are _static_: for those, the same
URI should always produce the same result, and Liquidsoap can use this
information in order to optimize the resolution.

Some of those protocols are built in the language such as

- `http` and `https` to download distant files over HTTP,
- `annotate` to add metadata.

Some other protocols are defined in the standard library (in the file `protocols.liq`)
using the `protocol.add` function which registers a new protocol. This function
takes as argument a function `proto` of type

```
(rlog : ((string) -> unit), maxtime : float, string) -> [string]
```

which indicates how to perform the resolution: this function takes as arguments

- `rlog` a function to write in the request's log,
- `maxtime` the maximal duration resolution should take,
- the URI to resolve,

and returns a list of URI it resolves to. Additionally, the function
`protocol.add` takes arguments to document the function (`syntax` describes the
URI accepted by this protocol and `doc` is freeform description of the protocol)
as well as indicate whether the protocol is `static` or not and whether the
files it produces are `temporary` or not.

#### Request leaks

At any time, a given script should only have a few requests alive. For instance,
a `playlist` operator has a request for the currently playing file and perhaps
for a few files in advance, but certainly not for the whole playlist: if the
playlist contained distant files, this would mean that we would have to download
them all before starting to play. Because of this, Liquidsoap warns you when
there are hundreds of requests alive: this either mean that you are constantly
creating requests, or that they are not properly destroyed (what we call a
_request leak_). For instance, the following script creates 250 requests at
once:

```{.liquidsoap include="liq/request-loop.liq" from=header to=footer}
```

Consequently, you will therefore see in the logs messages such as

```
[request:2] There are currently 100 RIDs, possible request leak! Please check that you don't have a loop on empty/unavailable requests.
[request:2] There are currently 200 RIDs, possible request leak! Please check that you don't have a loop on empty/unavailable requests.
```

The warning is emitted every `settings.request.leak_warning` requests, 100 by
default.

<!-- https://github.com/savonet/liquidsoap/issues/309 -->

### Decoders

As mentioned above, the process of resolving requests involves finding an
appropriate decoder\index{decoder}.

#### Configuration

The list of available decoders can be obtained with the script

```{.liquidsoap include="liq/decoders.liq" from=header}
```

which prints here

```
["wav", "aiff", "pcm/basic", "srt", "raw audio", "midi", "image", "aac", "mp4", "ffmpeg", "flac", "ogg", "mad"]
```

indicating the available decoders. The choice of the decoder is performed on the
MIME type (i.e. the detected type for the file) and the file extension. For each
of the decoders the setting

- `settings.decoder.mime_types.*` specifies the list of MIME types the decoder
  accepts,
- `settings.decoder.file_extensions.*` specifies the list of file extensions the
  decoder accepts,
- `settings.decoder.priorities.*` specifies the priority of the decoder.

For instance, for the mad decoder (mad is a library to decode mp3 files) we have

```{.liquidsoap include="liq/decoder-mad-settings.liq" from=header}
```

The decoders with higher priorities are tried first, and the first decoder which
accepts a file is chosen. For mp3 files, this means that the FFmpeg decoder is
very likely to be used over mad, because it also accepts mp3 files but has
priority 10 by default.

#### Custom decoders

It is possible to add your custom decoders using the
`decoder.add`\indexop{decoder.add} function, which registers an external program
as a step of the request resolution. The program receives the path of a local
file and returns the path of another local file, in a format Liquidsoap can
decode. The returned path can carry annotations, and the recommended shape of a
return value is therefore `annotate:metadata="value":/path/to/file.wav`.

#### The log of a resolution

\index{resolution}
\index{request!resolution}

The choice of a decoder can be observed when setting log level to debug. For
instance, consider the simple script

```{.liquidsoap include="liq/decoder-accept.liq" from=header}
```

We see the following steps in the logs:

- the source `single` computes the content type it needs and asks for the
  request `test.mp3` to be resolved:

  ```
  [single_actual:5] Content type: {audio=pcm(stereo)}
  [request:5] Resolving request [test.mp3].
  [request:5] Resolved to [test.mp3].
  ```

- some decoders are discarded because the extension or the MIME are not among
  those they support:

  ```
  [decoder.ogg:4] Unsupported file extension for "test.mp3"!
  [decoder.ogg:4] Unsupported MIME type for "test.mp3": audio/mpeg!
  [decoder.wav:4] Unsupported file extension for "test.mp3"!
  [decoder.wav:4] Unsupported MIME type for "test.mp3": audio/mpeg!
  [decoder.aiff:4] Unsupported file extension for "test.mp3"!
  [decoder.aiff:4] Unsupported MIME type for "test.mp3": audio/mpeg!
  ```

- three possible decoders are left, ffmpeg, image and mad, the first one having
  priority 10 and the two others priority 1:

  ```
  [decoder:4] Available decoders: ffmpeg (priority: 10), image (priority: 1), mad (priority: 1)
  ```

- the one with the highest priority is tried first, accepts the file, and is thus
  selected:

  ```
  [decoder:4] Trying decoder "ffmpeg"
  [decoder.ffmpeg.description:3] Analyzing container for format: "mp3", uri: "test.mp3"
  [decoder.ffmpeg:3] FFmpeg recognizes "test.mp3" as audio: {codec: mp3, 48000Hz, 2 channel(s)}
  [decoder.ffmpeg.description:3] Requested content-type: {audio=pcm(stereo)}
  [decoder.ffmpeg.description:3] Decoded content-type: {audio=pcm(stereo)}
  [decoder:4] Selected decoder ffmpeg for file "test.mp3" with expected kind {audio=pcm(stereo)} and detected content {audio=pcm(stereo)}
  ```

- the file is handed to the source:

  ```
  [single_actual:3] Prepared "test.mp3" (RID 0).
  ```

#### The log of a failed resolution

For comparison, consider the following variant of the script

```{.liquidsoap include="liq/decoder-reject.liq" from=header}
```

Here, the resolution will fail because we are trying to play the source with
`output.video`: this implies that the source should have video, which an mp3
does not. The logs of the resolution process are as follows:

- the source `single` asks for a source with video and initiates the resolution
  of `test.mp3`:

  ```
  [single_actual:5] Content type: {video=yuv420p}
  [request:5] Resolving request [test.mp3].
  [request:5] Resolved to [test.mp3].
  ```

- the ffmpeg decoder is tried first, detects that the file has no video track at
  all, and refuses it:

  ```
  [decoder:4] Available decoders: ffmpeg (priority: 10), image (priority: 1), mad (priority: 1)
  [decoder:4] Trying decoder "ffmpeg"
  [decoder.ffmpeg:3] FFmpeg recognizes "test.mp3" as audio: {codec: mp3, 48000Hz, 2 channel(s)}
  [decoder.ffmpeg.description:3] Requested content-type: {video=yuv420p}
  [decoder.ffmpeg.description:3] Decoded content-type: {}
  [decoder:4] Cannot decode file "test.mp3" with decoder ffmpeg as {video=yuv420p}. Detected content: {}
  ```

- the image decoder is tried, since an image would give us video, and none of
  the image decoders recognizes the file:

  ```
  [decoder:4] Trying decoder "image"
  [decoder:4] Available image decoders: ffmpeg (priority: 10), sdl (priority: 5), ppm (priority: 1)
  [decoder:4] Trying image decoder "ffmpeg" (priority: 10)
  [decoder:4] Trying image decoder "sdl" (priority: 5)
  [decoder:4] Trying image decoder "ppm" (priority: 1)
  ```

- mad is tried last, recognizes the file as mp3 audio, and refuses it for the
  same reason as ffmpeg:

  ```
  [decoder:4] Trying decoder "mad"
  [decoder.mad:3] Libmad recognizes "test.mp3" as mpeg audio (layer III, 64kbps, 48000Hz, 2 channels).
  [decoder:4] Cannot decode file "test.mp3" with decoder mad as {video=yuv420p}. Detected content: {audio=pcm(stereo)}
  ```

- no decoder was found for the file at the given content type, so the resolution
  fails and the `single` operator, which was declared infallible, raises an
  error which stops the script:

  ```
  [decoder:3] Available decoders cannot decode "test.mp3" as {video=yuv420p}
  [single:2] Error while starting source single: Lang.Runtime_error { kind: "failure", msg: "Infallible source.dynamic single was not able to prepare source single_actual in time! Make sure to either define infallible sources in the source's dynamic function or mark the source as fallible..", pos: [] }!
  ```

#### Other libraries involved in the decoding of files

Apart from decoders, the following additional libraries are involved when
resolving and decoding requests.

- _Metadata decoders_: some decoders are dedicated to decoding the metadata of
  the files.
- _Duration decoders_: some decoders are dedicated to computing the duration of
  the files. Those are not enabled by default and can be by setting the
  dedicated setting

  ```{.liquidsoap include="liq/decoder-duration.liq" from=header}
  ```

  The reason they are not enabled is that they can take quite some time to
  compute the duration of a file. If you need this, it is rather advised to
  precompute it and store the result in the `duration` metadata.
- _Samplerate converters_: those are libraries used to change the samplerate of
  audio files when needed (e.g. converting files sampled at 48 kHz to default
  44.1 kHz). The following setting gives the list of converters, in the order in
  which they are tried:

  ```{.liquidsoap include="liq/samplerate-converters.liq" from=header}
  ```

  The first supported one is chosen. The `native` converter is fast and always
  available, but its quality it not very good (correctly resampling audio is a
  quite involved process), so that we recommend that you compile Liquidsoap with
  FFmpeg or libsamplerate support.
- _Channel layout converters_: those convert between the supported audio channel
  layouts (currently supported are mono, stereo and 5.1). Their order can be
  changed with the `settings.audio.converter.channel_layout.converters` setting.
- _Video converters_: those convert between various video formats. The converter
  to use can be changed by setting the `settings.video.converter.preferred`
  setting, which is `"ffmpeg"` by default.

<!--
Sometimes it will fail, for instance if test.mp3 is stereo, the following script will output an error

```{.liquidsoap include="liq/surround.liq"}
```

because we cannot implicitly convert a stereo file into 5.1
-->

Custom metadata decoders can be added with the function `decoder.metadata.add`.

Reading the source code
-----------------------

\index{source code}

As indicated in [there](#sec:further-workflow), a great way of learning about
Liquidsoap, and adding features to it, is to read (and modify) the standard
library, which is written in the Liquidsoap language detailed in [the dedicated
chapter](#chap:language). However, in the case you need to modify the internal
behavior of Liquidsoap or chase an intricate bug you might have to read (and
modify) the code of Liquidsoap itself, which is written in the [OCaml
language](https://ocaml.org/)\index{OCaml}. This can be a bit intimidating at first, but it
is perfectly doable with some motivation, and it might be reassuring to learn
that some other people have gone through this before you!

In order to guide you through the source, let us briefly describe the main
folders and files. All the files referred to here are in the `src` directory of
the source, where all the code lies. The code is split in two halves: `src/lang/`
holds the language, which knows nothing about audio, and `src/core/` holds
everything which streams. The main folders of `src/lang/` are

- `parser/`: the lexer and the grammar,
- `ast/`: the abstract syntax tree, that is the internal representation of
  programs,
- `reducer/`: the pass which turns the parsed tree into the term the rest of the
  language works on,
- `types/`: the types of the language and the operations on them,
- `values/`: the values computed by programs, and the errors they raise,
- `runtime/`: typechecking, evaluation, and the builtins which do not need a
  stream (lists, strings, JSON, and so on),
- `cache/`: the on-disk cache which lets a script skip typechecking the standard
  library on every start.

And the main folders of `src/core/` are

- `stream/`: frames and their contents,
- `source/`: the definition of sources and tracks,
- `clock/`: the definition of clocks,
- `request/`: requests and playlist parsers,
- `builtins/`: the builtins which do need a stream,
- `operators/`: where most operators such as sound processing are,
- `sources/`: input sources, and `outputs/`: outputs,
- `media/`: decoders, samplerate converters and image converters,
- `decoders/`: the decoders which need no external library,
- `encoder/`: the encoders, and the support in the language for the `%` syntax,
- `protocols/`: the protocols which need no external library,
- `net/` and `utils/`: the plumbing,
- `optionals/`: one folder per optional library, from `alsa/` to `xmlplaylist/`,
  each one holding the inputs, outputs, decoders and encoders that library
  provides.

The most important files are the following ones:

File | Description
-----|------------
`lang/parser/parser.mly` | Syntax of the language
`lang/ast/term.ml` | Internal representation of programs
`lang/values/value.ml` | Values computed by programs
`lang/types/type.ml` | Types of the language
`lang/types/typing.ml` | Operations on types
`lang/runtime/typechecking.ml` | Typechecking of programs
`lang/runtime/evaluation.ml` | Execution of programs
`lang/runtime/runtime.ml` | Handling of errors
`lang/runtime/lang.ml` | High-level operations on the language
`core/stream/frame.ml` | Definition of frames for streams
`core/stream/content.ml` | Internal contents of frames
`core/stream/frame_settings.ml` | Samplerate, frame duration and ticks
`core/source/source.ml` | Definition of sources
`core/clock/clock.ml` | Definition of clocks
`core/request/request.ml` | Definition of requests
`core/media/decoder.ml` | Choice of a decoder for a file

Happy hacking, and remember that the community is here to help you!
