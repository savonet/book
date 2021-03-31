#!./liquidsoap
s = normalize(playlist("~/Music"))
interactive.harbor()
f = interactive.float("f", description="Frequency", min=0., max=1000.,
                      unit="Hz", 200.)
g = interactive.float("g", description="Gain", min=0., max=20.,
                      unit="dB", 8.)
b = bass_boost(frequency=f, gain=g, s)
s = add([s, b])
output(s)
interactive.persistent("bb.params")
