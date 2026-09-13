#!./liquidsoap
s = playlist("~/Music")
# header
thread.run(every=3., {s.skip()})
# footer
output(s)
