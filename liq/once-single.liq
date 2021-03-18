#!/usr/bin/env liquidsoap
s = once(single("test.mp3"))
t = fallback([s, sine()])
output(s)
