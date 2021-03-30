#!./liquidsoap
interactive.harbor() s = normalize(playlist("~/Music")) a = interactive.float("a", min=0., max=20., 3.)
b = amplify(lin_of_dB(6.), filter.iir.eq.low(frequency=200., s))
s = add([s, b])
output(s)
