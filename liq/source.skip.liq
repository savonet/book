#!/usr/bin/env liquidsoap
s = playlist("~/Music")
thread.run(every=5., {s.skip()})
output(s)
