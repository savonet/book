#!./liquidsoap
s = playlist("~/Music")
s = compress(threshold=-10., ratio=5., s)
output(s)
