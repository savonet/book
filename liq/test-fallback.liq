#!./liquidsoap
s1 = sine(duration=2., 880.)
s2 = sine(440.)
s  = fallback([s1, s2])
output(s)