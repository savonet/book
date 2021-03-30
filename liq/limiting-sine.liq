#!./liquidsoap
s = sine(440.)
s = amplify(s.time, s)
s = limit(s)
output(s)