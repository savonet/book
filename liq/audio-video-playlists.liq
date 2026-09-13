#!./liquidsoap
# header
a = playlist("~/Music")
v = playlist(prefix="annotate:duration=10:", "image.playlist")
s = source.mux.video(video=v, a)
# footer
output.audio_video(s)
