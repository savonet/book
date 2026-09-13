#!./liquidsoap
a = single("test.mp3")
v = single("test.mp4")
# header
s = source.mux.video(video=v, a)
# footer
output.audio_video(s)
