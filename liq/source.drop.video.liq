#!./liquidsoap
s = single("test.mp4")
s = source.drop.video(s)
output(s)
