#!./liquidsoap
s1 = playlist("~/Music") s2 = playlist("~/Music")
s2 = source.run(s2, every=10., {s2.skip()})
s = fallback([s1, s2])
output(s)
