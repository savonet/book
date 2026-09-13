#!./liquidsoap
s = playlist("~/Music")
# header
a = file.getter.float("volume")
s = amplify(a, s)
# footer
output(s)
