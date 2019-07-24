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

Streaming to youtube
--------------------

(this is apparently the thing everybody wants to do)

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

