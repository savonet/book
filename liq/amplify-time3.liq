#!./liquidsoap
s = playlist("~/Music")
# header
s  = amplify(time.up, s)
# footer
output(s)
