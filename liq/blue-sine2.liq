#!./liquidsoap -i
a = sine()
b = video.fill(color=0x0000ff, blank())
s = mux_video(video=b, a)
output.audio_video(mksafe(s))
