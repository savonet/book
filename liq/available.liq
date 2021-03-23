#!./liquidsoap
s1 = sine(880.)
s2 = sine(440.)
s1 = available(track_sensitive=false, {time() mod 2. < 1.}, s1)
s  = fallback(track_sensitive=false, [s1, s2])
output(s)