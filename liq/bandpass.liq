#!./liquidsoap
s = playlist("~/Music")
low = interactive.float("low", min=0., max=20000., step=10., 1000.)
high = interactive.float("high", min=0., max=20000., step=10., 2000.)
interactive.harbor()
s = filter.iir.eq.bandpass(low=low, high=high, s)
output(s)
