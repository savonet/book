#!./liquidsoap
interactive.harbor()
s = normalize(playlist("~/Music"))
# header
b = limit(pre_gain=8., filter.iir.eq.low(frequency=200., s))
s = add([s, b])
# footer
output(s)
