#!./liquidsoap
interactive.harbor() s = normalize(playlist("~/Music"))
a = interactive.float("a", description="Gain", min=0., max=20., unit="dB", 8.)
f = interactive.float("f", description="Frequency", min=0., max=1000., unit="Hz", 200.)
b = limit(pre_gain=a, filter.iir.eq.low(frequency=f, s))
s = add([s, b])
output(s)
