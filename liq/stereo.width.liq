#!./liquidsoap
s = normalize(playlist("~/Music"))
a = interactive.float("a", min=-1., max=1., 0.)
interactive.harbor()
s = stereo.width(a, s)
output(s)
