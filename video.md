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

Decoders also take in account the following metadata when decoding images:

- `x`, `y`: offset of the decoded image (in pixels),
- `width`, `height`: dimensions of the decoded image (in pixels),
- `duration`: how long the image is made available.

This means that the script

```{.liquidsoap include="liq/image4.liq" from=1}
```

will show a small image of 50×50 pixels.

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
can be more concisely written

```{.liquidsoap include="liq/add-videos2.liq" from=1}
```

The function `video.add_image` also has the advantage


TODO: explain the implementation of `video.add_image` (in particular,
explain the parameters for the request)

```{.liquidsoap include="liq/logo.liq"}
```

We can extract cover art, e.g.

```{.liquidsoap include="liq/cover.liq"}
```

### Size and superposition

`add` `video.scale` `video.resize`

### Text

`video.add_text`

explain how to display the volume and bpm of the currently playing song.

### Audio

`mux_audio` / `mux_video`

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

