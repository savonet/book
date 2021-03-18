Video
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

