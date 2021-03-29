#!./liquidsoap
s = playlist("~/Music")
s = gate(s)
output(s)
