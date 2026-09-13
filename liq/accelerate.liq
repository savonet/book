#!./liquidsoap
s = playlist("~/Music")
# header
s = accelerate(ratio=10., s)
# footer
output(s)
