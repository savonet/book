#!./liquidsoap
s = playlist(prefix="annotate:duration=2:", "image.playlist")
output.video((s:source(audio=none)))
