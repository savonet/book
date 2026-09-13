#!/usr/bin/env liquidsoap
s = playlist("~/Music")
# header
s = fade.in(duration=4., type="sin", s)
s = fade.out(s)
# footer
output(s)
