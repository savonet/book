#!./liquidsoap
s = playlist("~/Music")
s = normalize(s)
output(s)
