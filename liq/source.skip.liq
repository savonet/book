#!/usr/bin/env liquidsoap
s = playlist("~/Music")
# header
thread.run(every=5., {s.skip()})
output(s)
