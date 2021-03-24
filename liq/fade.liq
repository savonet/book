#!/usr/bin/env liquidsoap
s = playlist("~/Music")
s = fade.in(duration=4., type="sin", s)
s = fade.out(s)
output(s)
