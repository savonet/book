#!./liquidsoap
s = normalize(playlist("~/Music")) interactive.harbor()
s2 = compress(threshold=-10., ratio=5., gain=4., s)
w = interactive.float("wetness", min=0., max=1., 1.)
s = dry_wet(w, s, s2)
output(s)
