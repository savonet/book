#!./liquidsoap
s = single("test.mp4")
# header
s = source.drop.video(s)
# footer
output(s)
