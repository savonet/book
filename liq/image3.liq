#!./liquidsoap
# header
s = image("test.png")
output.video(fallible=true, s)
