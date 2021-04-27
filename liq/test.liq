#!./liquidsoap
s = playlist("~/Music")
ignore(s.seek(-10.))
output(s)
