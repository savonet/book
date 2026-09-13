#!./liquidsoap
s = playlist("~/Music")
# header
s = limit(normalize(s))
# footer
output(s)
