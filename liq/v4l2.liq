#!./liquidsoap
# header
s = input.v4l2()
output.video(s)
