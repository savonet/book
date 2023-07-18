#!./liquidsoap
s1 = single("test.mp4")
s2 = single("test.mp4")
s = source.mux.audio(audio=s1, s2)
output(s)