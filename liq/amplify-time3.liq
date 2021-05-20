#!./liquidsoap
s = playlist("~/Music")
s  = amplify(time.up, s)
output(s)
