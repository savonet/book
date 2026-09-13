#!/usr/bin/env liquidsoap
# header-a
s = once(single("test.mp3"))
# footer-a
# header-b
t = fallback([s, sine()])
# footer-b
output(t)
