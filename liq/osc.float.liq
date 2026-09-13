#!./liquidsoap
s = playlist("~/Music")
# header
v = osc.float("/volume", 1.)
s = amplify(v, s)
# footer
output(s)
