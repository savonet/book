#!/usr/bin/env liquidsoap
s = sleeper(delay=1.1, sine())
# header
s = buffer(s)
# footer
output(s)
