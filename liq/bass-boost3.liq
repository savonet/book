#!./liquidsoap
interactive.harbor() s = normalize(playlist("~/Music")) a = interactive.float("a", min=0., max=20., 10.)
s = bass_boost(gain=8., s)
output(s)
