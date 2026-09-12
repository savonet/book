#!/usr/bin/env liquidsoap
s = sleeper(delay=1.1, sine())
s = buffer(s)
output(s)
