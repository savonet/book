#!./liquidsoap
s = playlist("~/Music")
s = skipper(every=3., s)
output(s)
