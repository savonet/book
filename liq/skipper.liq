#!./liquidsoap
s = playlist("~/Music")
thread.run(every=3., {s.skip()})
output(s)
