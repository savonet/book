#!./liquidsoap
s = playlist("~/Music")
s = accelerate(ratio=10, s)
output(s)
