#!./liquidsoap
s1 = single("test.mp4")
s2 = single("test.mp4")
s = source.mux.audio(audio=source.drop.video(s1), source.drop.audio(s2))
output(s)