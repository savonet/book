#!./liquidsoap
v = video.fill(color=0xff0000, blank())
a = sine()
s = source.mux.video(video=v, a)
output.audio_video(s)