#!./liquidsoap
s = normalize(playlist("~/Music"))
# header
s = bass_boost(frequency=200., gain=8., s)
# footer
output(s)
