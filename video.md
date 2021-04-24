Video {#chap:video}
=====

Playing locally
---------------
something like

```
output.graphics(s)
```
will for `s` not to have audio, use `drop_audio`

Images
------

TODO: explain the implementation of `video.add_image` (in particular,
explain the parameters for the request)

```{.liquidsoap include="liq/logo.liq"}
```

We can extract cover art, e.g.

```{.liquidsoap include="liq/cover.liq"}
```

Text
----

`video.add_text`

explain how to display the volume and bpm of the currently playing song.

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

Streaming to youtube
--------------------

(this is apparently the thing everybody wants to do)

Got to the url <https://www.youtube.com/live_dashboard>

RTMP: <https://github.com/savonet/liquidsoap/issues/1008>

explain the implementation with `output.url`

parameters can be found here: <https://gist.github.com/olasd/9841772>

Parameters
----------

```liquidsoap
set("frame.video.width",320)
set("frame.video.height",240)
set("frame.video.samplerate",24)
```
Explain (recall) how to use in external encoders...

Frei0r
------

FFmpeg filters
--------------

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

