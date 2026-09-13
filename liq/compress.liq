#!./liquidsoap
s = playlist("~/Music")
# header
s = compress(threshold=-10., ratio=5., s)
# footer
output(s)
