Video {#chap:video}
=====

Historically, Liquidsoap was dedicated to generating audio streams such as those
found in radios, even though it was conceived in order to be extensible with
other kinds of data, such as video. When it started in 2004, there was
absolutely no video support, then some work began to add that around 2009, but
it was still not much used, partly because it was quite inefficient. Starting
with the release of Liquidsoap 2.0 in 2021, the internal coding of video changed
to RGB to YUV420, which is much more compact and used by most video libraries:
Liquidsoap is now able to decently handle videos, as we will see in this
chapter.

Generating videos
-----------------

### Playing a video

Most sources accepting audio files (`single`, `playlist`, etc.) also accept
video files, so that generating a video stream is performed in the exact same
way you would generate an audio stream, excepting that you start from video
files instead of audio files. For instance, you can play a video file `test.mp4`
with

```{.liquidsoap include="liq/play-video.liq" from=1}
```

The operator `output.audio_video` plays both the audio and the video of the
source `s`, and you can use `output.video` to play the video only. These
operators chose a local output operator among the ones provided by
Liquidsoap. There are currently two of them:

- `output.sdl` which uses the SDL library to display the video, and
- `output.graphics` which uses the library provided by OCaml in order to display
  graphical data.

As another example, if we have a playlist `video.playlist` of video files, it
can be played with

```{.liquidsoap include="liq/play-video2.liq" from=1}
```

Generally, the video will be generated form a playlist using the `playlist`
operator or from user's request using `request.queue` operator. Those were
already presented in [there](#sec:inputs), nothing changes for video.

#### The webcam

Under Linux, it is possible to use our webcam as a source with the `input.v4l2`
operator which reads from the webcam:

```{.liquidsoap include="liq/v4l2.liq" from=1}
```

### Parameters of the video

The format used by Liquidsoap for videos can be changed by setting the following
configuration keys:

- `frame.video.width`: width of videos (in pixels),
- `frame.video.height`: height of videos (in pixels),
- `frame.video.framerate`: number of images per seconds.

The default format for images is 1280×720 pixels at 25 images per seconds which
corresponds to the 720p (or _HD ready_) format. You can switch to 1080p (or
_Full HD_) format with

```{.liquidsaop include="liq/full-hd.liq"}
```

Remember that processing video data in real time is very costly. Reducing the
resolution to 960×540 or even 640×360 will degrade the quality of images, but
can greatly improve the CPU consumption, in particular if your server is getting
a bit old: a low resolution video is better than a laggy or jumpy one...

For convenience the functions `video.frame.width`, `video.frame.height` and
`video.frame.rate` are also defined and return the corresponding configuration
parameters.

### Blank and colored frames

The operator `blank` can generate video (in addition to audio): it will generate
a blank image (transparent). In order to generate a video of a given color, you
can use the `video.fill` operator which fills the video of the source with the
color specified in the `color` argument. For instance, the script

```{.liquidsoap include="liq/video.fill.liq" from=1}
```

will play a red image. The color should be specified in hexadecimal, in the form
`0xrrggbb` where `rr` specifies the red intensity, `gg` the green and `bb` the
blue, each color ranges from `00` (color absent) to `ff` (color with maximum
intensity).

### Images

Images can be used as sources just as video video files: they are accepted by
operators such as `single`, `playlist`, etc. However, if you try the following
simple script

```{.liquidsoap include="liq/image.liq" from=1}
```

Liquidsoap will complain that it cannot decode the file `test.png`. This is
because, by default, Liquidsoap tries to decode the image with an audio track,
and this is not possible for an image. We can however force the source to have
no audio as follows, and you should then see the image:

```{.liquidsoap include="liq/image2.liq" from=1}
```

Here, `(x:source(audio=none))` is that we force `x` to be a source with no
audio: this mechanism is explained in details in [there](#sec:source-type). In
order for you to avoid thinking of those subtleties, the standard library
provides the `image` operator which does this for you and conveniently creates a
source from an image:

```{.liquidsoap include="liq/image3.liq" from=1}
```

You are advised to use this operator when dealing with images.

#### Specifying the dimensions

Decoders also take in account the following metadata when decoding images:

- `x`, `y`: offset of the decoded image (in pixels),
- `width`, `height`: dimensions of the decoded image (in pixels),
- `duration`: how long the image is made available.

This means that the script

```{.liquidsoap include="liq/image4.liq" from=1}
```

will show a small image of 50×50 pixels.

#### Cover art

Most recent audio formats (such as mp3 or ogg) allow embedding the cover of the
album into metadata. Liquidsoap has support for extracting this and provides the
`video.cover` operator in order to extract the cover from an audio stream and
generate a video stream from it. The script

```{.liquidsoap include="liq/cover.liq" from=1 to=-1}
```

generates a source `a` from our music library, generates a video track from its
covers with `video.cover`, adds it to the sound track `a` (with `mux_video`,
detailed below) and plays the result. It is important here that we use `mksafe`
around `video.cover` in order to play black by default: the source will not be
available when the track has no cover!

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

```{.liquidsoap include="liq/image-playlist.liq" from=1 to=-1}
```

will display for 2 seconds the images of the playlist `image.playlist`.

#### Changing images

The `image` operator produces a source with a method `set` which takes as
argument the new path to the image to stream. For instance, the following script
shows a random image in the current directory every 2 seconds:

```{.liquidsoap include="liq/image-set.liq" from=1 to=-1}
```

In more details, the `file.ls(".")` function returns a list of functions in the
current directory. We then use `list.filter` to extract all the files which end
with `.png` or `.jpg` (the `string.match` function looks at whether the strings
match the regular expression `.*\\.png|.*\\.jpg` which means: "anything followed
by `.png` or anything followed by `.jpg`). We define an `image` source `s` of
which we change the image every 2 second using the `set` method, with
`list.pick(files)` which picks a random element of the list `files`.

This mechanism can also be used to change the displayed image depending on some
metadata. For instance, consider the script

```{.liquidsoap include="liq/image-metadata.liq" from=1 to=-1}
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

### Adding videos

Our beloved `add` operator also works with videos. For instance, we can add a
logo on top of our video source `s` by adding a scaled down version of our
`logo.png` image:

```{.liquidsoap include="liq/add-videos.liq" from=1}
```

When taking a list of sources with video as argument, the `add` operator draws
the rightmost last: it is therefore important that the `logo` source is second
so that it is drawn on top of the other one.

Because one often does this, Liquidsoap provides the function `video.add_image`,
which allows adding an image on top of another source, and the previous script
can be more concisely written as

```{.liquidsoap include="liq/add-videos2.liq" from=1}
```

The function `video.add_image` moreover has the advantage of allowing getters
for the parameters, so that we can program a moving logo as follows:

```{.liquidsoap include="liq/add-videos3.liq" from=1}
```

#### Picture in picture

Instead of adding a small image on top of a big one, we can also add a small
video on top of a big one. In order to reduce the size of a video, we can either use

- `video.scale`: which scales a video according to a given factor `scale`,
- `video.resize`: which resizes a video to a given size specified by its `width`
  and `height`.

Both functions also allow translating the video so that the upper-left corner is
at a given position (`x`, `y`). 

For instance, the following script adds a small webcam capture on top of the
main video:

```{.liquidsoap include="liq/add-scale.liq" from=1}
```

Here, the main source `s` is a playlist of videos and `w` is the capture of the
webcam. Since it does not have audio (only video), we add to it a blank audio
track so that it has the same type as the source `s` and can be added with
it. We scale down the webcam image with `video.scale` and finally add it on top
of the main video with `add`.

### Combining audio and video sources

Given an audio source `a` and a video source `v`, one can combine them in order
to make a source `s` with both audio and video with the `mux_audio` and
`mux_video` operators, which respectively add audio and video to a source, by

```{.liquidsoap include="liq/mux_audio.liq" from=2 to=-1}
```

or

```{.liquidsoap include="liq/mux_video.liq" from=2 to=-1}
```

For instance, we can generate a stream from a playlist of audio files and a
playlist of image files with

```{.liquidsoap include="liq/audio-video-playlists.liq" from=1 to=-1}
```

The "opposite" of the muxing functions are the functions `drop_audio` and
`drop_video` which respectively remove the audio and video channels from a video
track. For instance, if we have two sources `s1` and `s2` with both audio and
video, we can create a source `s` with the audio from `s1` and the video from
`s2` by

```{.liquidsoap include="liq/mix-av.liq" from=3 to=-1}
```

### (Cross)fading

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

```{.liquidsoap include="liq/video.fade.in.liq" from=2 to=-1}
```

\TODO{crossfading with cross when it will work see bug 1603}

### Test sources

In case you do not have any video at hand to play, the sources
`video.testsrc.ffmpeg` and `video.testsrc.gstreamer` can be used to generate
test videos such as

![Test video](img/testsrc.png)\

### Text

In order to add text on videos, we provide the `video.add_text` operator which,
in addition to the text to print and the source on which it should add the text
takes the following optional arguments:

- `color`: color of the text, in the format `0xrrggbb` as explained above for
  `video.fill`,
- `font`: the path to the font file (usually in ttf format),
- `metadata`: metadata on which the text should be changed,
- `size`: the font size,
- `speed`: the speed at which it should scroll horizontally to have a "news
  flash" effect (in pixels per seconds, set to `0` to disable),
- `x` and `y`: the position of the text.

This function uses one of the various implementation we provide. You should try
them in order to reach what you want, they have various quality and
functionalities, and unfortunately we have not found the silver bullet yet. The
implementations are:

- `video.add_text.native`: the native implementation. It always works and does
  not rely on any external library, but uses a hand-made, hard-coded, low-fi
  font.
- `video.add_text.sdl` / `video.add_text.gd` / `video.add_text.gstreamer` /
  `video.add_text.ffmpeg`: synthesize the text using SDL, GD, GStreamer and
  FFmpeg libraries.
  
For instance,

```{.liquidsoap include="liq/video.add_text.liq" from=2 to=-1}
```

The text is a getter which means that it can vary over times. For instance, the
following prints the current volume and BPM of a song:

```{.liquidsoap include="liq/video.add_text-volume-bpm.liq" from=1}
```

and here is the output:

![Volume and BPM](img/vol-bpm.png)\

Other parameters are getters, so that the position of the text can also be
customized over time...

Encoders
--------

### FFmpeg {#sec:ffmpeg-video}

TODO: explain the specificities of video

* **AC3 audio and H264 video encapsulated in a MPEG-TS stream**
```liquidsoap
%ffmpeg(format="mpegts",
        %audio(codec="ac3",channel_coupling=0),
        %video(codec="libx264",b="2600k",
               "x264-params"="scenecut=0:open_gop=0:min-keyint=150:keyint=150",
               preset="ultrafast"))
```

* **AC3 audio and H264 video encapsulated in a MPEG-TS stream using ffmpeg raw frames**
```liquidsoap
%ffmpeg(format="mpegts",
        %audio.raw(codec="ac3",channel_coupling=0),
        %video.raw(codec="libx264",b="2600k",
                   "x264-params"="scenecut=0:open_gop=0:min-keyint=150:keyint=150",
                   preset="ultrafast"))
```


### Ogg/theora

```liquidsoap
%theora(quality=40,width=640,height=480,
        picture_width=255,picture_height=255,
        picture_x=0, picture_y=0,
        aspect_numerator=1, aspect_denominator=1,
        keyframe_frequency=64, vp3_compatible=false,
        soft_target=false, buffer_delay=5,
        speed=0)
```

You can also pass `bitrate=x` explicitly instead of a quality.
The default dimensions are liquidsoap's default,
from the settings `frame.video.height/width`.

### AVI

TODO

### Saving frames

`video.still_frame`

Streaming to youtube {#sec:youtube}
--------------------

(this is apparently the thing everybody wants to do)

Got to the url <https://www.youtube.com/live_dashboard>

RTMP: <https://github.com/savonet/liquidsoap/issues/1008>

explain the implementation with `output.url`

parameters can be found here: <https://gist.github.com/olasd/9841772>

Video filters
-------------

### Builtin filters

### Fades

### Frei0r

### FFmpeg filters

GStreamer
---------

RTMP input (see #1020)

```liquidsoap
uri = "rtmp://fms.105.net/live/rmc1"
s = input.gstreamer.audio_video(pipeline="rtmpsrc location=#{uri} ! tee name=t", audio_pipeline="t. ! queue", video_pipeline="t. ! queue")
s = mksafe(s)
output.graphics(s)
out(s)
```

