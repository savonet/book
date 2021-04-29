#!./liquidsoap
a = playlist("~/Music")
v = crossfade(playlist(prefix="annotate:duration=10:", "image.playlist"))
s = mux_video(video=v, a)
output.audio_video(s)
