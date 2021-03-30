#!./liquidsoap
s = playlist("~/Music")
freq = interactive.float("freq", min=0., max=20000., step=10., 1000.)
q = interactive.float("q", min=0., max=10., step=.1, 1.)
interactive.harbor()
s = filter.iir.eq.bandpass(frequency=freq, q=q, s)
output(s)
