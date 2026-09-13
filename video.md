Video {#chap:video}
=====

Historically, Liquidsoap was dedicated to generating audio streams such as those
found in radios, even though it was conceived from the beginning in order to be
extensible with other kinds of data, such as video. When it started in 2004,
there was absolutely no video support, then some work began to add that around
2009, but it was still not much used, partly because it was quite
inefficient. Starting with the release of Liquidsoap 2.0 in 2021, the internal
coding of video changed to RGB to YUV420, which is much more compact and used by
most video libraries: Liquidsoap is now able to decently handle videos, as we
will see in this chapter.

Generating videos
-----------------

### Playing a video

Most sources accepting audio files (`single`, `playlist`, etc.) also accept
video files, so that generating a video stream is performed in the exact same
way you would generate an audio stream, excepting that you start from video
files instead of audio files. For instance, you can play a video file `test.mp4`
with\indexop{single}

```{.liquidsoap include="liq/play-video.liq" from=header}
```

The operator `output.audio_video`\indexop{output.audio\_video} plays both the audio and the video of the
source `s`, and you can use `output.video` to play the video only. These
operators chose a local output operator among the ones provided by
Liquidsoap. There are currently two of them:

- `output.sdl` which uses the SDL library to display the video, and
- `output.graphics` which uses the library provided by OCaml in order to display
  graphical data.

The videos can even be directly pulled from YouTube with the `youtube-dl`\indexop{youtube-dl}
protocol, which requires that you have installed the
[`yt-dlp`](https://github.com/yt-dlp/yt-dlp) program:

```{.liquidsoap include="liq/play-video-yt.liq" from=header}
```

Since the whole video has to be downloaded beforehand, it can take quite some
time, which is why we specify a "large" `timeout` parameter (10 minutes instead
of the default 30 seconds).

As another example, if we have a playlist `video.playlist` of video files, it
can be played with\indexop{playlist}

```{.liquidsoap include="liq/play-video2.liq" from=header}
```

Generally, the video will be generated from a playlist using the `playlist`
operator or from user's request using `request.queue` operator. Those were
already presented in [there](#sec:inputs), nothing changes for video.

#### The webcam

\index{webcam}

Under Linux, it is possible to use our webcam as a source with the `input.v4l2`\indexop{input.v4l2}
operator which reads from the webcam:

```{.liquidsoap include="liq/v4l2.liq" from=header}
```

### Parameters of the video

The format used by Liquidsoap for videos is governed by the following
configuration keys:

- `settings.frame.video.width`: width of videos (in pixels),
- `settings.frame.video.height`: height of videos (in pixels),
- `settings.frame.video.framerate`: number of images per seconds.

Most of the time you do not have to touch them. Liquidsoap reads the dimensions\index{dimensions}
of the first video file it decodes and uses them for the whole stream. A 1080p
file is thus streamed in 1080p, and not downscaled to some other format. The
setting `settings.frame.video.detect_dimensions` controls this behaviour and is
enabled by default. The logs say so when the stream starts:

```
[frame:3] Default video frame size: 1280x720 (auto-detection enabled).
```

The detection requires a file decoded before the streaming begins. There is not
always one: the images can be synthesized by an operator, or captured from the
webcam. You also sometimes want to impose a format, typically because the
platform you stream to expects one. Setting the width or the height explicitly
disables the detection, so that with

```{.liquidsoap include="liq/full-hd.liq"}
```

everything is produced in 1080p (or _Full HD_) whatever the files contain. With
no file to inspect and no setting, the stream is 1280×720 pixels at 25 images
per seconds, which corresponds to the 720p (or _HD ready_) format.

Remember that processing video data in realtime is very costly. Reducing the
resolution to 854×480 (called 480p) or even 640×360 (called 360p) will degrade
the quality of images, but can greatly improve the CPU consumption, in
particular if your server is getting a bit old: a low resolution video is better
than a laggy or jumpy one...

For convenience the functions `video.frame.width`, `video.frame.height` and
`video.frame.rate` are also defined and return the corresponding configuration
parameters.

By the way, a source only carries video when some operator of your script
requires it. An `output.dummy(noise())` contains no image and costs nothing. Set
`settings.frame.video.default` to `true` to force a video track where no
operator requires one. Incidentally, error messages name the contents of a video
track `yuv420p`, which is the name of the pixel format we use to store images:
`yuv420p` in an error message means "video".

#### A canvas to position things on

\index{canvas}

Changing the resolution has an annoying consequence. The positions and the sizes
of your logo, of your titles and of your picture in picture are given in pixels.
A logo 20 pixels away from the corner of a 720p frame is 20 pixels away from the
corner of a 4k frame too, which is three times closer in proportion. Rather than
recomputing every value by hand, we can express them on a _virtual canvas_ much
larger than the actual frame, and let Liquidsoap scale them down. We provide one
canvas per usual resolution, all in 16:9 and 10 000 virtual pixels wide:

```{.liquidsoap include="liq/video-canvas.liq" from=header}
```

The record returned by `video.canvas.virtual_10k.actual_720p`\indexop{video.canvas} has the `width` and
the `height` of the actual frame, and four functions which translate a value
into actual pixels: `px` for a length in virtual pixels, `vw` and `vh` for a
fraction (between 0 and 1) of the width and of the height of the frame, and
`rem` for a multiple of the font size of the canvas. They are more readable when
written with the infix operator `@`, which is nothing else than application:
`120 @ px` is `px(120)`. Changing `actual_720p` to `actual_4k` on the first line
is the only edit needed to render the same scene in 4k. For another aspect ratio
or another virtual width, `video.canvas.make`\indexop{video.canvas.make} builds a canvas from a
`virtual_width`, an `actual_size` and a `font_size`.

### Blank and colored frames

The operator `blank`\indexop{blank} can generate video (in addition to audio): it will generate
an image which is _blank_, i.e. fully transparent. In order to generate a video
of a given color, you can use the `video.fill`\indexop{video.fill} operator which fills the video of
the source with the color specified in the `color` argument. For instance, the
script

```{.liquidsoap include="liq/video.fill.liq" from=header}
```

will play a red image. The color should be specified in hexadecimal, in the form
`0xrrggbb` where `rr` specifies the red intensity, `gg` the green and `bb` the
blue, each color ranges from `00` (color absent) to `ff` (color with maximum
intensity) in hexadecimal. The operator also takes an `alpha` argument, between
0 (fully transparent) and 1 (fully opaque, the default). Adding a black
`video.fill` with `alpha=0.3` on top of a video darkens it, which is what
television channels do behind a title. Both `color` and `alpha` are getters, so
that the darkening can be switched on and off during the stream.

### Images

Images can be used as sources just as video files: they are accepted by
operators such as `single`, `playlist`, etc. For instance,

```{.liquidsoap include="liq/image.liq" from=header}
```

and you should see `test.png`. The image decoder also produces a silent audio
track, so that the source has the same tracks as a video file.

Two things are missing. The image keeps its own dimensions and is drawn at the
center of a black frame, and the script cannot change either. The image also has
no duration, so the source shows it forever. The standard library therefore
provides the `image`\indexop{image} operator, which creates a source from an image and takes
the position and the size of the image as arguments:

```{.liquidsoap include="liq/image3.liq" from=header}
```

You are advised to use this operator when dealing with images. We pass
`fallible=true` to the output because the source is unavailable when the file
cannot be read.

#### Specifying the dimensions

The operator takes four arguments to place the image in the frame: `x` and `y`
for the position of its upper-left corner, `width` and `height` for its size,
the image being scaled to fit. For instance,

```{.liquidsoap include="liq/image-dimensions.liq" from=header}
```

shows a small image of 50×50 pixels, ten pixels away from the upper-left corner
of the frame. The four arguments are getters, so that their value can change
over time, as we will see when [adding a moving logo](#sec:video-add) to a
video.

The same can be specified with metadata, which is convenient when the images
come from a playlist and each entry needs its own size. Decoders take in account
the following metadata:

- `x`, `y`: offset of the decoded image (in pixels),
- `width`, `height`: dimensions of the decoded image (in pixels),
- `duration`: how long the image is made available.

The `annotate:`\indexop{annotate} protocol is the usual way of attaching them to a file, so
that the script

```{.liquidsoap include="liq/image4.liq" from=header}
```

shows a small image of 50×50 pixels too.

#### Cover art

\index{cover}

Most recent audio formats (such as mp3 or ogg) allow embedding the cover of the
album into metadata. Liquidsoap has support for extracting this and provides the
`video.cover`\indexop{video.cover} operator in order to extract the cover from an audio stream and
generate a video stream from it. The script

```{.liquidsoap include="liq/cover.liq" from=header to=footer}
```

defines an audio source `a` from our music library, generates a video track `v`
from its covers with `video.cover`, adds it to the sound track `a` (with
`source.mux.vide`\indexop{source.mux.video}, detailed below) and plays the
result. It is important here that we use `mksafe` around `video.cover` in order
to play black by default: the source will not be available when the track has no
cover!

#### Playlists

If you want to rotate between images, you can use playlists containing
images. However, remember that images have infinite duration by default, and
therefore a `duration` metadata should be added for each image in order to
specify how long it should last. The most simple way of performing this is to
have entries of the form

```
annotate:duration=5:/path/toimage.jpg
```

Alternatively, if the playlist contains only the paths to the images, the
`duration` metadata can be added by using the `prefix` argument of the playlist
operator. For instance, the script

```{.liquidsoap include="liq/image-playlist.liq" from=header to=footer}
```

will display for 2 seconds the images of the playlist `image.playlist`.

#### Changing images

The path given to `image` is a getter. When the getter returns a new path, the
source switches to the corresponding image. For instance, the following script
shows a random image of the current directory every 2 seconds:

```{.liquidsoap include="liq/image-set.liq" from=header to=footer}
```

In more details, the `file.ls(".")` function returns a list of files in the
current directory. We then use `list.filter` to extract all the files which end
with the `.png` or `.jpg` extension (the `string.match` function looks at whether the strings
match the regular expression `.*\\.png|.*\\.jpg` which means: "anything followed
by `.png` or anything followed by `.jpg`"). We define a reference `img_path`
holding the path of the image to show, hand it over to `image` as the path to
stream, and change it every 2 seconds with `list.pick(files)` which picks a
random element of the list `files`.

Incidentally, showing a series of pictures one after the other is common enough
that the standard library provides the `video.slideshow`\indexop{video.slideshow} operator. It takes
the list of files and displays them in turn, changing every `advance` seconds.
After the last file it returns to the first one, unless you pass
`cyclic=false`. The `current` method returns the file being displayed, and the
`append` and `clear` methods modify the list while the source is streaming.

This mechanism can also be used to change the displayed image depending on some
metadata. For instance, consider the script

```{.liquidsoap include="liq/image-metadata.liq" from=header to=footer}
```

It creates a source `a` from a playlist `playlist-with-image` which contains
audio songs with a metadata `image` indicating the image to display with the
song. Typically, a line of this playlist would look like

```
annotate:image="myimage.png":mysong.mp3
```

(or the metadata `image` could also be hardcoded in the audio files). It also
creates an `image` source `v`, whose image is set to the contents of the `image`
metadata of each new track in `a`. Finally, we show the source `s` obtained by
combining the audio source `a` and the video source `v`.

### Adding videos {#sec:video-add}

Our beloved `add`\indexop{add} operator also works with videos. For instance, we can add a
logo on top of our video source `s` by adding a scaled down version of our
`logo.png` image:

```{.liquidsoap include="liq/add-videos.liq" from=header}
```

When taking a list of sources with video as argument, the `add` operator draws
the rightmost last: it is therefore important that the `logo` source is second
so that it is drawn on top of the other one. Two other behaviours of `add` are
worth knowing here. The `add` operator relays the metadata of all the sources it
is given, and it drops the track marks of all of them. Dropping the track marks
is what we want with a logo: the logo should not end the tracks of the video
below it. Remember that `add` drops the track marks when both sources produce
track marks you care about.

Because one often does this, Liquidsoap provides the function `video.add_image`,
which allows adding an image on top of another source, and the previous script
can be more concisely written as

```{.liquidsoap include="liq/add-videos2.liq" from=header}
```

The function `video.add_image` moreover has the advantage of allowing getters
for the parameters, so that we can program a moving logo as follows:

```{.liquidsoap include="liq/add-videos3.liq" from=header}
```

#### Picture in picture

\index{scale}
\index{resize}

Instead of adding a small image on top of a big one, we can also add a small
video on top of a big one. In order to reduce the size of a video, we can either use

- `video.scale`: which scales a video according to a given factor `scale`,
- `video.resize`: which resizes a video to a given size specified by its `width`
  and `height`.

Both functions also allow translating the video so that the upper-left corner is
at a given position (`x`, `y`). By default, `video.resize` keeps the proportions
of the original image and fits it inside the requested `width` and `height`. A
16:9 capture resized into a square thus keeps its shape instead of being
squashed. Pass `proportional=false` to stretch the image to the requested size.


For instance, the following script adds a small webcam capture on top of the
main video:

```{.liquidsoap include="liq/add-scale.liq" from=header}
```

Here, the main source `s` is a playlist of videos and `w` is the capture of the
webcam. Since it does not have audio (only video), we add to it a blank audio
track so that it has the same type as the source `s` and can be added with
it. We scale down the webcam image with `video.scale` and finally add it on top
of the main video with `add`.

#### Alpha channels

\index{alpha channel}

A defining feature of video in Liquidsoap is that _alpha channels_ are supported
for video: this means that images in videos can have more or less transparent
regions, which allows to see the "video behind" whenever adding videos. The
overall opacity of a video can be changed with the `video.opacity` operator,
which takes a coefficient between 0 (transparent) and 1 (fully opaque) in
addition to the source. For instance, with

```{.liquidsoap include="liq/video.opacity.liq" from=header to=footer}
```

we are adding the source `s1` with the source `s2` made opaque at 75%: this
means that we are going to see 75% of `s2`, and the remaining 25% are from `s1`
behind.

Transparent regions are also supported from usual picture formats such as
png. In particular, when you add a logo to a video stream, it does not have to
be a square!

### Combining audio and video sources

\index{mux}

Given an audio source `a` and a video source `v`, one can combine them in order
to make a source `s` with both audio and video with the `source.mux.audio` and
`source.mux.video` operators. Namely, in

```{.liquidsoap include="liq/mux_audio.liq" from=header to=footer}
```

the `source.mux.audio` replaces the audio channel of the source `v` by the one of
the source `a`. And we can similarly replace the video channel with

```{.liquidsoap include="liq/mux_video.liq" from=header to=footer}
```

For instance, we can generate a stream from a playlist of audio files and a
playlist of image files with

```{.liquidsoap include="liq/audio-video-playlists.liq" from=header to=footer}
```

The "opposite" of the muxing functions are the functions `source.drop.audio` and
`source.drop.video`, which respectively remove the audio and video channels from
a source. For instance, we can remove the video channel of a an audio+video
source `s` with

```{.liquidsoap include="liq/source.drop.video.liq" from=header to=footer}
```

### Multitrack: demuxing and remuxing tracks {#sec:multitrack}

\index{multitrack}\index{tracks}

Suppose that you have filmed your last concert. The sound taken by the camera
is, as always, dreadful, but you also have the recording of the mixing desk. You
want the images of one file with the sound of the other one, so we have to take
both sources apart.

A stream is made of _tracks_\index{track}, which are named components carried
together: an `audio` track, a `video` track, and the two we have been using
since the beginning without naming them. The `metadata` track carries the
metadata and the `track_marks` track carries the marks separating one track from
the next one. The `source.tracks`\indexop{source.tracks} function returns them
as a record:

```{.liquidsoap include="liq/video-source-tracks.liq" from=header}
```

and the `source`\indexop{source} function does the converse, assembling a source from a record
of tracks:

```{.liquidsoap include="liq/video-source-rebuild.liq" from=header}
```

so that `s2` streams exactly what `s` streams, after having been taken apart and
put back together. Our concert is then a matter of taking the record of tracks
of one source and overriding one of its fields:

```{.liquidsoap include="liq/video-replace-audio.liq" from=header}
```

The syntax `r.{field = value}` extends a record with a new field or replaces an
existing one. The last line thus reads "all the tracks of `v`, but with the
audio of `music`". The `source.mux.audio` and `source.mux.video` operators we
have seen above are shorthands for this construction.

Dropping a track works the same way, by destructuring the record instead of
extending it:

```{.liquidsoap include="liq/video-remove-track.liq" from=header}
```

where `track_marks=_` discards that field and `...tracks` captures all the
others. The source `s2` is thus `s` without its track marks. The source `s2`
never signals the end of a track, which is what you want when it feeds a longer
montage whose cuts are decided elsewhere.

#### Several tracks of the same kind

A movie in MKV with its original soundtrack and two dubbings contains three
audio tracks. Liquidsoap names them `audio`, `audio_2` and `audio_3`, and does
the same for video and subtitles. An `%ffmpeg` encoder writes them all at once:

```{.liquidsoap include="liq/video-multi-audio-copy.liq" from=header}
```

Beware that the encoder also determines what the decoder looks for. Requesting
`audio_2` requests a second audio track from every file of the source. The
decoder rejects a file which does not have one, and the source skips it. This is
generally what you want, since a playlist of dubbed movies should only contain
dubbed movies. It is worth remembering on the day a playlist skips every file in
it.

You can also name the streams yourself, which is more readable than counting
them, for instance `%audio_en` for the English and `%audio_fr` for the French:

```{.liquidsoap include="liq/video-multi-audio.liq" from=header}
```

Liquidsoap then determines the kind of content of such a stream, in this order.
A `%foo.copy` stream is a passthrough copy and needs no determination. An
explicit `audio_content`, `video_content` or `subtitle_content` parameter gives
the kind. Otherwise the name of the stream is searched for `audio`, `video` or
`subtitle`. Failing all this, a hardcoded codec such as `codec="aac"` gives the
kind. These names are internal to your script: the FFmpeg encoder identifies
streams by their position in the file, so that reading the result back gives
`audio`, `audio_2` and `video` again, in the order in which they were declared.

#### Working on a track alone

Some operators take a track rather than a source, and they are all named
`track.something`. For instance, `track.audio.mean`\indexop{track.audio.mean} mixes a stereo track down
to mono:

```{.liquidsoap include="liq/video-track-audio-mean.liq" from=header}
```

Encoding is one of those operators. The
`track.ffmpeg.encode.audio`\indexop{track.ffmpeg.encode.audio} operator encodes
an audio track in the middle of a script, without going through an output.
FFmpeg encoding is not synchronous with the streaming loop, so the encoded track
runs on a clock of its own. The `metadata` and `track_marks` tracks of the
original source remain on the original clock. Combining them with the encoded
track, as in

```{.liquidsoap include="liq/video-inline-encode-conflict.liq" from=header}
```

earns you a clock conflict of the kind described in [there](#sec:clocks-ex).
Take them from the encoded track instead, with `track.metadata` and
`track.track_marks`:

```{.liquidsoap include="liq/video-inline-encode.liq" from=header}
```

Incidentally, reading and writing several tracks at once requires the FFmpeg
bindings. Without them, decoders and outputs are limited to one `audio` track
and one `video` track. The `source.tracks` and `source` functions still work,
there are simply fewer tracks to work with.

### Subtitles {#sec:subtitles}

\index{subtitles}

A movie usually comes with the words which are being said in it, and we would
rather keep them. Subtitles are therefore a kind of track of their own, on a par
with audio and video. Everything we have just done with `source.tracks` and
`source` applies to subtitle tracks.

The simplest case is a standalone SubRip file, which Liquidsoap decodes without
the help of FFmpeg:

```{.liquidsoap include="liq/subtitles-decode-srt.liq" from=header}
```

The subtitles contained in a container, such as an MKV file holding the images,
the sound and five languages, are decoded by FFmpeg:

```{.liquidsoap include="liq/subtitles-decode-ffmpeg.liq" from=header}
```

FFmpeg decodes the text-based codecs, which are SubRip, ASS/SSA, WebVTT and MOV
text. The DVD, Blu-ray and DVB formats store subtitles as images rather than as
text. Liquidsoap cannot decode those into text, and can only copy them to
another file or draw them onto the video, both of which are described below.

In the two scripts above, `subtitles` is a track like any other. A source can
carry several subtitle tracks, named `subtitles`, `subtitles_2` and so on, using
the same convention as audio and video tracks:

```{.liquidsoap include="liq/subtitles-multiple.liq" from=header to=footer}
```

Each entry of a subtitle track is a record of eight fields. The `text` field
holds the text and the `format` field says how to read it, `"text"` for a plain
line and `"ass"` for a line written as an ASS dialogue. The `forced` field marks
the subtitles which a player should display even when the viewer asked for none.
The `position`, `start_time` and `end_time` fields give the timing in the
internal unit of the stream, and `absolute_start_time` and `absolute_end_time`
give it in seconds, which are the two fields you will use in practice. Times are
stored relatively to the position, so that subtitle tracks can be concatenated
with `sequence`\indexop{sequence}:

```{.liquidsoap include="liq/subtitles-sequence.liq" from=header to=footer}
```

The `on_subtitle`\indexop{on\_subtitle} function calls a function of yours each time a subtitle is
about to be displayed, which is how you log the captions, send them to a
translation service, or trigger anything else in sync with them:

```{.liquidsoap include="liq/subtitles-on_subtitle.liq" from=header to=footer}
```

The `subtitles.map`\indexop{subtitles.map} function goes further and changes the subtitles on their
way through the source. Its function receives the same record, and returns a
record of the fields to update, an empty record `{}` to leave the subtitle
unchanged, or `null` to remove it. Removing a subtitle is a decent way of
implementing a broadcast delay on your least favourite word:

```{.liquidsoap include="liq/subtitles-map.liq" from=header to=footer}
```

Finally, `subtitles.insert`\indexop{subtitles.insert} adds subtitles to a source, creating the subtitle
track when the source has none. The operator adds an `insert_subtitle` method to
the source, which takes the `text`, its `duration` in seconds, its `format` and
its `forced` flag:

```{.liquidsoap include="liq/subtitles-insert.liq" from=header to=footer}
```

This is how you inject the captions produced by a speech recognition engine into
a live stream.

#### Encoding subtitles

Writing subtitles back to a file is the job of the `%subtitles` encoder, whose
`codec` must be one the container accepts: `subrip` and `ass` for Matroska,
`webvtt` for WebM, `mov_text` for mp4.

```{.liquidsoap include="liq/subtitles-encode.liq" from=header}
```

Text subtitles are converted to the ASS dialogue format before being encoded.
The `text_to_ass` argument of `%subtitles` replaces that conversion. It takes a
function receiving the index of the subtitle and its text, and returning the ASS
dialogue line to write.

When you only move subtitles from one container to another, there is no reason
to decode and re-encode them. The `%subtitles.copy` encoder passes the encoded
data through as it is, which costs no CPU and loses no quality. It is also the
only way to handle the image-based formats mentioned above:

```{.liquidsoap include="liq/subtitles-copy.liq" from=header}
```

Note that the name of the encoded stream, `%subtitles`, is also the name of the
track it takes from the source. An encoder written `%subtitle` requires a track
named `subtitle`, which is not the name the decoders produce.

#### Burning subtitles into the video

HLS players, old set-top boxes and several streaming platforms ignore a separate
subtitle track. The only way to have the words displayed is then to draw them
onto the images. The `track.video.add`\indexop{track.video.add} operator does it, given a video track
and a subtitle track:

```{.liquidsoap include="liq/subtitles-burn.liq" from=header}
```

The script takes the `audio`, `video` and `subtitles` tracks of the movie with
`source.tracks`, composites the video and the subtitles into a single video
track with `track.video.add`, and encodes the result with no subtitle stream at
all, since the words are part of the images. The operation is irreversible: the
text cannot be recovered from the output. It also requires re-encoding the
video, which costs more CPU than copying it.

### (Cross)fading

\index{crossfading}

In order to have nice endings for video, one can use the `video.fade.out`
operator which will fade out to black (or actually rather to transparent) the
video. The time it takes to perform this is controlled by the `duration`
parameter (3 seconds by default), the kind of transition can be controlled by
the `transition` parameter whose values can be

- `fade`: perform a fade to blank,
- `slide_left`, `slide_right`, `slide_up`, `slide_down`: make the video slide
  left, right, up or down,
- `grow`: makes the image get smaller and smaller,
- `disc`: have a black disc covering the image,
- `random`: randomly choose among the previous transitions.

Similarly, the operator `video.fade.in` add fade effects at the beginning of
tracks:

```{.liquidsoap include="liq/video.fade.in.liq" from=header to=footer}
```

Since the `add` and `cross` operators also work with video sources, this means
that we can nicely crossfade the tracks of a video playlist as follows:

```{.liquidsoap include="liq/video-cross.liq" from=header}
```

We apply fading at the beginning and the end of the videos, and then use the
`cross`\indexop{cross} operator to add the end of each track with the beginning of the next one
during 1.5 seconds. The duration is the `duration` argument, 5 seconds by
default. It is a getter, so that it can depend on the time of the day. The
transition function receives one record per side: `a` for the track which ends
and `b` for the track which starts. Each record has three fields: the `source`
we use here, the `db_level` of that side and its `metadata`. The `metadata`
field is the only place where the metadata of the two tracks is available during
a transition. The `cross` operator does not replay it into the transition
source, so read the `metadata` field rather than adding a metadata handler on
`a.source` or `b.source`. As a variant, slided transitions can be achieved with

```{.liquidsoap include="liq/video-cross2.liq" from=header}
```

### Test sources

\indexop{video.testsrc}

In order to generate test videos, the operator `video.testsrc` can be used. For
instance,

```{.liquidsoap include="liq/video.testsrc.liq" from=header to=footer}
```

will generate a video such as

![](img/testsrc.png){width=300px}

The operator takes an optional `width` and `height`, and nothing else. When you
need a particular test pattern, use `video.testsrc.ffmpeg`\indexop{video.testsrc.ffmpeg} instead: its
`pattern` argument accepts `"testsrc"` (the default one), `"testsrc2"`,
`"smptebars"`, `"smptehdbars"`, `"pal75bars"`, `"pal100bars"`, `"yuvtestsrc"`,
`"rgbtestsrc"`, and any other pattern supported by your FFmpeg. The
`video.testsrc.ffmpeg` operator also takes a `duration`, after which the source
becomes unavailable.

### Text

\index{text}
\indexop{video.add\_text}

In order to add text on videos, we provide the `video.add_text` operator which,
in addition to the text to print and the source on which it should add the text,
takes the following optional arguments:

- `color`: color of the text, in the format `0xrrggbb` as explained above for
  `video.fill`,
- `font`: the path to the font file (usually in ttf format),
- `metadata`: metadata on which the text should be changed,
- `size`: the font size,
- `speed`: the speed at which it should scroll horizontally to have a "news
  flash" effect (in pixels per seconds, set to `0` to disable),
- `x` and `y`: the position of the text,
- `duration`: how long the text stays on screen (it stays forever by default),
- `cycle`: whether a scrolling text comes back from the right once it has left
  the frame on the left (it does by default, set it to `false` for a one-shot
  announcement), together with `on_cycle` which is called each time it wraps
  around, and is the place to pick the next headline.

This function uses one of the various basic implementations we provide, the
first one available among camlimages, SDL, FFmpeg, gd and the native one. You
should actually try them in order to reach what you want: they have various
quality and functionalities, and unfortunately we have not found the silver
bullet yet. Those implementations are

- `video.add_text.camlimages`: renders with the camlimages library, which is the
  one picked first when it is there,
- `video.add_text.sdl` / `video.add_text.ffmpeg` / `video.add_text.gd`:
  synthesize the text using the SDL, FFmpeg or GD libraries,
- `video.add_text.native`: the native implementation. It always works and does
  not rely on any external library, but uses a hand-made, hard-coded, low-fi
  font.

For instance,

```{.liquidsoap include="liq/video.add_text.liq" from=header to=footer}
```

The text is a getter which means that it can vary over times. For instance, the
following prints the current volume\index{RMS} and BPM\index{BPM} of a song:

```{.liquidsoap include="liq/video.add_text-volume-bpm.liq" from=header}
```

and here is the output:

![](img/vol-bpm.png){width=300px}

The position parameters are also getters, so that the position of the text can
also be customized over time. For instance, the following will add a text moving
along the diagonal at the speed of 10 pixels per second in each direction:

```{.liquidsoap include="liq/video.add_text2.liq" from=header to=footer}
```

By the way, a frequent use of text over video is captioning, and the
`video.add_subtitle`\indexop{video.add\_subtitle} operator does it from metadata. The operator reads the
`subtitle` metadata, or the one named by the `override` argument, and prints its
contents `offset` pixels above the lower edge of the image. Subtitles as a kind
of track, decoded from a file and encoded back into one, are described in [a
section below](#sec:subtitles).

Filters and effects
-------------------

In order to change the appearance of your videos Liquidsoap offers video
effects. These are not as well developed as for audio processing, but this is
expected to improve in the future, and we support generic libraries which
provide a large amount of effects.

### Builtin filters

\index{filter!video}

By default, Liquidsoap only offers some very basic builtin video filters such as

- `video.greyscale`: convert the video to black and white,
- `video.opacity`: change the opacity of the video,
- `video.fill`: fill the video with given color,
- `video.scale` / `video.resize`: change the size of the video.

### Frei0r

\index{frei0r}

Liquidsoap has native support for [frei0r plugins](https://frei0r.dyne.org/),
which are based on the frei0r API for video effects. When those are installed on your system, they
are automatically detected and corresponding operators are added in the
language. Those have names of the form `video.frei0r.*` where `*` is the name of the
plugin. For instance, the following adds a "plasma effect" to the video:

```{.liquidsoap include="liq/frei0r.liq" from=header to=footer}
```

Each operator (there are hundreds of them) of course has specific parameters
which allow modifying its effect, you are advised to have a look at their
documentation, as usual.

### FFmpeg filters {#sec:ffmpeg-filters}

\index{FFmpeg}

Another great provider of video (and audio) effects is FFmpeg: we have access to
[hundreds of those](https://ffmpeg.org/ffmpeg-filters.html)! Its filters are a bit more
involved to use because FFmpeg expects that you create a _graph_ of filters (by
formally connecting multiple filters one to each other) before being able to use
this graph for processing data, and because it operates on data in FFmpeg's
internal format. Those filters can process both audio and video data, we chose
to present it here and not in [previous chapter](#chap:workflow) because it is
more likely to be used for video processing.

The basic function we are going to use for creating filters is
`ffmpeg.filter.create`. Its argument is a function `mkfilter` which takes as
argument the graph of filters we are going to build, attaches filters to it, and
returns the resulting stream. Usually this function

- uses the operators

  - `ffmpeg.filter.audio.input`
  - `ffmpeg.filter.video.input`

  to input from some stream (note that those function operate on audio / video
  tracks, not sources),
- processes the stream using one or more `ffmpeg.filter.*` functions,
- outputs the result using one of the operators

  - `ffmpeg.filter.audio.output`
  - `ffmpeg.filter.video.output`
  - `ffmpeg.filter.audio_video.output`

In this way, we can define the following function `myfilter` which inputs the
audio track and add a flanger effect to it, inputs the video track, flips its
images horizontally and inverts the colors of the video, and finally outputs
both audio and video:

<!-- \TODO{could be simplified with audio + video output, see bug 1612} -->

```{.liquidsoap include="liq/ffmpeg-effect3.liq"}
```

The function can then be used on a source `s` as follows:

```{.liquidsoap include="liq/ffmpeg-effect4.liq" from=header}
```

If you look at the type of the function `myfilter`, you will see that it is

```
(source(audio=ffmpeg.audio.raw('a), video=ffmpeg.video.raw('b), midi=none)) -> source(audio=ffmpeg.audio.raw('d), video=ffmpeg.video.raw('e), midi=none)
```

which means that it operates on streams where both audio and video are in
FFmpeg's internal raw format (`ffmpeg.audio.raw` and `ffmpeg.video.raw`). In the
above example this is working well because

- sources which decode audio from files such as `single` (or `playlist`) can
  generate streams in most formats, including FFmpeg's raw,
- the encoder we have chosen operates directly on streams in FFmpeg's raw format
  (because we use an `%ffmpeg` encoder with `%audio.raw` and `%video.raw`
  streams).

Two properties of filter graphs are worth knowing before building a complicated
one. Firstly, a graph is a single source, whatever the number of outputs you
take out of it. All the outputs are produced together and share one buffer, one
set of track marks and one availability. A track mark reaching any output
therefore ends every output of that graph. This is why we pass the audio through
`myfilter` above instead of leaving it aside. This is also why the outputs must
be consumed at roughly the same rate: the data of the fastest output accumulates
while Liquidsoap waits on the slowest one. Past
`settings.ffmpeg.filter_max_buffer`, 10 seconds by default, Liquidsoap raises an
error rather than let the buffer grow without bound.

Secondly, a graph lives as long as its inputs produce data. When an input
becomes unavailable, Liquidsoap flushes the data held by the filters and
destroys the graph. A new graph is created from scratch when the input comes
back. A short gap thus costs nothing but the internal state of the filters,
which starts again from zero: a `loudnorm` filter measures the loudness of the
new graph as it would on a fresh stream. Filters with a long settling time are
therefore a poor match for a source which often becomes unavailable. Give such a
graph an input which is always available, using `mksafe`\indexop{mksafe} for instance.

<!--

The first problem is that the resulting source has no audio, because the filter
is only processing video. It is easy to preserve the audio of the original
source by changing the penultimate line

```liquidsoap
ffmpeg.filter.create(mkfilter)
```

to

NOTE: this is ffmpeg-effect2.liq
```liquidsoap
mux_audio(audio=drop_video(s), ffmpeg.filter.create(mkfilter))
```

which adds back the audio of the source `s` to the result.

TODO: this is bad because it involves unnecessary encoding of audio

Alternatively, we can process both audio and video in the filter by performing
both audio and video input in the filtered and use
`ffmpeg.filter.audio_video.output` to output both:

```{.liquidsoap include="liq/ffmpeg-effect3.liq"}
```
-->
<!--
This is fine if your effect applies on a decoding
source (such as `single` or `playlist`) because those know how to decode directly in FFmpeg's internal format.
-->

If you want to operate on a source `s` which is in the usual Liquidsoap's
internal format, you can use

- `ffmpeg.raw.encode.audio_video` to convert from Liquidsoap's internal to
  FFmpeg's raw format,
- `ffmpeg.raw.decode.audio_video` to decode FFmpeg's raw format into
  Liquidsoap's internal format.

For instance, from the above `myfilter` function, we can define a function
`myfilter'` which operates on usual streams as follows:

```{.liquidsoap include="liq/ffmpeg-effect5.liq" from=header}
```

by encoding before applying the filter and decoding afterward.

Encoders
--------

The usual outputs described in [there](#sec:outputs) support streams with video,
which includes

- `output.file`: for recording in a file,
- `output.icecast`: for streaming using Icecast,
- `output.hls`: for generating HLS playlists streams,
- `output.dummy`: for discarding a source.

We do not explain them here again: the only difference with audio is the choice
of the encoder\index{encoder} which indicates that we want to use sources with video.

### FFmpeg {#sec:ffmpeg-video}

The encoder of choice for video is FFmpeg\index{FFmpeg}, that we have already seen in
[here](#sec:ffmpeg-encoder). The general syntax is

```liquisoap
%ffmpeg(format="...", %audio(...), %video(...))
```

where the omitted parameters specify the format of the container, the audio
codec and the video codec.

#### Formats

The full list of supported formats can be obtained by running `ffmpeg
-formats`. Popular formats\index{container} for

- encoding in files:
  - `mp4` is the most widely supported, (its main drawback is that index tables
    are located at the end of the file, so that partially downloaded files
    cannot reliably be played, and the format is not suitable for streaming),
  - `matroska` corresponds to `.mkv` files, supports slightly more codecs than
  mp4 and it license-free, but is less widely supported,
  - `webm` is well supported by modern browsers (in combination with the VP9
    codec),
  - `avi` is getting old and should be avoided,
- streaming:
  - `mpegts` is the standard container for streaming, this is the one you should
    use for HLS for instance,
  - `webm` is a modern container adapted to streaming with Icecast,
  - `flv` is used by some old streaming protocols such as RTMP, still widely in
    use to stream video to platforms such as YouTube.

Many [other formats](https://ffmpeg.org/ffmpeg-formats.html) are also
supported.

#### Codecs

The codec\index{codec} can be set by passing the `codec` argument to `%video`.
The codecs all take `width` and `height` parameters, which allow setting the
dimensions of the encoded video. Remember that smaller images have lower
quality, but require smaller bitrates and encode faster. Common resolutions for
16:9 aspect ratio are

 360p     480p    720p     1080p
-------  ------- -------- ---------
640×360  854x480 1280×720 1920×1080

the "default reasonable value" being 720p nowadays. By default, the videos are
encoded at the dimensions of internal frames in Liquidsoap, which can be set via
`video.frame.width` and `video.frame.height`. If you only need to encode a video
to "small" dimensions, it is a better idea to lower these values than specifying
the codec parameters, in order to avoid computing large images which will be
encoded to small ones.

While we are talking about CPU, the FFmpeg encoder chooses by itself the number
of threads it uses. Pass `threads=1` to restrict it to a single thread, for
instance when several encoders share the same machine. Scaling images is a
separate matter: it is done on one thread, and the setting
`settings.ffmpeg.scaling_threads` changes that number, `0` meaning one thread
per core. Raising it rarely helps a stream running in realtime, so measure
before you do.

You generally also want to set the bitrate by passing the `b` argument in bits
per second (e.g. `b="2000k"`). Typical bitrates for streaming, depending on the
resolution, at 25 frames per second, are

 Resolution   Bitrate
-----------  --------
640×360       700k
1280×720      2500k
1920×1080     4000k

Alternatively, many encoders allow specifying a "quality" parameter instead of a
bitrate: in this case, it tries to reach a target quality instead of bitrate, by
increasing the bitrate on complex scenes. This is not advised for videos
intended for streaming since it can lead to unexpected bandwidth problems on
those scenes.

Another useful parameter is the GOP (group of picture) which can be set by
passing the argument `g` and controls how often keyframes are inserted (we
insert one keyframe every `g` frames). A typical default value is 12, which
allows easy seeking in videos, but for video streams this value can be increased
in order to decrease the size of the video. The habit for streaming is to have a
keyframe every 2 seconds or less, which means setting `g=50` at most for the
default framerate of 25 images per second.

We now detail the two most popular codecs H.264 (aka AVC) and VP9, but there are [many other ones](https://ffmpeg.org/ffmpeg-codecs.html). Also note that there are alternative versions of those codecs, namely H.265 (aka HEVC) and AV1, which are better but less widely supported, with which you might also want to experiment with. Also note that VP9 and AV1 are completely royalty-free, but H.264 used to be the de facto standard which has more support (in particular on low-end devices such as smartphones, although this is less and less true).

#### H.264

The most widely used codec for encoding video is `libx264` which encodes in
H.264\index{H.264}. This format has hardware support in many devices such as smartphones (for
decoding). The most important parameter is `preset`, which controls how fast the
encoder is, and whose possible values are

> `ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`,
> `slower`, `veryslow`

with the obvious meaning. Of course, the faster the setting is the lower the
quality of the video will be, so that you have to find a balance between CPU
consumption and quality.

Instead of imposing a bitrate, one can also choose to encode in order to reach a
target quality, which is measured in _CRF_ (for Constant Rate Factor) and can be
passed in the `crf` parameter. It is an integer ranging from 0 ( the best quality) to
51 (the worse quality). In order to give you ideas,

- 0 is lossless,
- 17 is with nearly unnoticeable compression,
- 23 is the default value,
- 28 is the worse acceptable value.

Additional parameters can be passed in the `x264-params` parameter, e.g.

```
"x264-params"="scenecut=0:open_gop=0:min-keyint=150:keyint=150"
```

use this if you need very fine tuning for your encoding (you need to put quotes
around the parameter name `x264-params` because it contains a dash).

A typical setting for encoding in a file for backup would be

```{.liquidsoap include="liq/encoder-ffmpeg-h264-file.liq" from=header to=footer}
```

and for streaming in HLS it would be

```{.liquidsoap include="liq/encoder-ffmpeg-h264-streaming.liq" from=header to=footer}
```

<!-- See: https://obsproject.com/blog/streaming-with-x264 -->

The successor of H.264 is called H.265 (how imaginative) or HEVC and is
available through FFmpeg codec `libx265`. The parameters are roughly the same as
those for `libx264` described above.

#### VP9 and AV1

VP9\index{VP9} is a recently developed codec, which is generally more efficient than H.264
and can achieve lower bitrates at comparable quality, and is royalty-free. It is
supported by most modern browsers and is for instance the used by the YouTube
streaming platform. It is generally encapsulated in the WebM container although
it is supported by most modern containers.

The encoder in FFmpeg is called `libvpx-vp9`, some of its [useful
parameters](https://developers.google.com/media/vp9) are

- `quality` can be `good` (the decent default), `best` (takes much time) or
  `realtime` (which should be used in your scripts since we usually want fast
  encoding),
- `speed` goes from -8 (slow and high quality) to 8 (fast but low quality),
  for realtime encoding you typically want to set this to 5 or 6,
- `crf` controls quality-based encoding, as for H.264.

A typical WebM encoding would look like this:

```{.liquidsoap include="liq/encoder-ffmpeg-vp9-file.liq" from=header to=footer}
```

and if you are on budget with respect to CPU and bandwidth:

```{.liquidsoap include="liq/encoder-ffmpeg-vp9-streaming.liq" from=header to=footer}
```

The successor of VP9 is AV1\index{AV1}, which is more efficient, and is now gaining popularity. It can
be used through the FFmpeg codec `libaom-av1` which essentially takes the same
parameters as `libvpx-vp9`.

### Ogg/Theora

We have support for the Theora\index{Theora} video codec encapsulated in ogg container,
already presented in [there](#sec:ogg). The encoder is named `%theora` whose
main parameters are

- `bitrate`: bitrate of the video (for fixed bitrate encoding, in bits per second),
- `quality`: quality of the encoding (for quality-based encoding, between 0 and 63),
- `width` / `height`: dimensions of the image,
- `speed`: speed of the encoder,
- `keyframe_frequency`: how often keyframes should be inserted.

For instance, we can encode a video in ogg with opus for the audio and Theora
for the video with

```{.liquidsoap include="liq/encoder-theora.liq" from=header to=footer}
```

### AVI

Liquidsoap has native (without any external library) builtin support for
generating AVI\index{AVI} files with the `%avi` encoder. The resulting files contain raw
data (no compression is performed on frames), which means that we need to compute
almost nothing but also that it will not be compressed. This format should thus
be favored for machines which are tight on CPU but not on hard disk, for backup
purposes:

```{.liquidsoap include="liq/encoder-avi.liq" from=header}
```

You can expect the resulting files to be huge and you will typically want to
re-encode the resulting files afterward.

If you want to generate AVI files with usual codecs, you should use the FFmpeg
encoder presented above. For instance,

```{.liquidsoap include="liq/encoder-ffmpeg-avi.liq" from=header to=footer}
```

Specific inputs and outputs
---------------------------

### Standard streaming methods

The two standard methods for streaming video are the same as those which have
already been presented for audio in [there](#sec:outputs): they are Icecast
(with `output.icecast`) and HLS (with `output.hls`). The only difference is that
the encoder should be one which has support for video.

### Streaming platforms

Another very popular way of streaming video is by going through streaming
platforms such as YouTube, Twitch or Facebook. All the three basically use the
same method for streaming. You first need to obtain a secret key associated to
your account on the website. Then you should send your video, using the RTMP
protocol, to some standard url followed by your secret key, using the
`output.url` operator, and that's it. Because of limitations of the RTMP
protocol, videos should be encoded using the FLV container with H.264 for video
and mp3 or aac for audio.

#### YouTube {#sec:youtube}

\index{YouTube}

The streaming key can be obtained from the [YouTube streaming
platform](https://youtube.com/live_dashboard). The
`output.youtube.live.rtmp`\indexop{output.youtube.live.rtmp} operator already contains the url and takes only the
key. If we suppose that we have stored our key in the file `youtube-key`, we can
stream a video source `s` to YouTube by

```{.liquidsoap include="liq/video-youtube.liq" from=header to=footer}
```

These settings are for quite low quality encoding. You should try to increase
them depending on how powerful your computer and internet connection are. For
the HLS ingest, `output.youtube.live.hls`\indexop{output.youtube.live.hls} takes the same key plus the usual HLS
arguments `segment_duration` and `segments`. Both operators also take a `url`
argument, should YouTube change the address of its servers.

#### Twitch

\index{Twitch}

The streaming key can be obtained from the [Twitch
dashboard](https://dashboard.twitch.tv/settings/stream) and a [list of
_ingesting servers_](https://stream.twitch.tv/ingests/) is provided (the url you
should send your stream to is obtained by appending your key to one of those
servers). For instance:

```{.liquidsoap include="liq/video-twitch.liq" from=header to=footer}
```

#### Facebook

\index{Facebook}

The url and streaming key can be obtained from the [Facebook Live
Producer](https://facebook.com/live/producer/). According to
[recommendations](https://facebook.com/help/1534561009906955), your video
resolution should not exceed 1280×720 at 30 frames per second, video should be
encoded in H.264 at at most 4000 kbps and audio in AAC in 96 or
128 kbps. Keyframes should be sent at most every two second (the `g` parameter
of the video codec should be at most twice the framerate). For instance,

```{.liquidsoap include="liq/video-facebook.liq" from=header}
```

### Saving frames

In case you need it, it is possible to save frames of the video with the
`video.still_frame`\indexop{video.still\_frame} operator: this operator adds to a source a method `save`
which, when called with a filename as argument, saves the current image of the
video stream to the file. Currently, only bitmap files are supported and the
filename should have a `.bmp` extension. For instance, the following script will
save a "screenshot" of the source `s` every 10 seconds:

```{.liquidsoap include="liq/screenshot.liq" from=header}
```
