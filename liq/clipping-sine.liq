#!./liquidsoap
# header
s = sine(440.)
s = amplify(s.time, s)
output(s)
