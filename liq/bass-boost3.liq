#!./liquidsoap
s = normalize(playlist("~/Music"))
s = bass_boost(frequency=200., gain=8., s)
output(s)
