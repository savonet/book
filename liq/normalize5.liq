#!./liquidsoap
s = playlist("~/Music")
s = limit(normalize(s))
output(s)
