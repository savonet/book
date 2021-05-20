#!./liquidsoap
s = playlist("~/Music")
v = osc.float("/volume", 1.)
s = amplify(v, s)
output(s)
