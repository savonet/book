#!./liquidsoap
interactive.harbor() s = normalize(playlist("~/Music")) a = interactive.float("a", min=0., max=20., 8.) freq = interactive.float("freq", min=0., max=1000., 200.)
b = limit(pre_gain=8., filter.iir.eq.low(frequency=freq, s))
s = add([s, b])
output(s)
