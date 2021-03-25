#!./liquidsoap
s = playlist("~/Music")
a = file.getter.float("volume")
s = amplify(a, s)
output(s)
