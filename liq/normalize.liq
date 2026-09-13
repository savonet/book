#!./liquidsoap
s = playlist("~/Music")
# header
s = normalize(s)
# footer
output(s)
