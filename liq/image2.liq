#!./liquidsoap
s = (single("test.png"):source(audio=none))
output.video(s)
