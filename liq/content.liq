#!/usr/bin/env liquidsoap
log.level.set(5)
s = blank(id="BLANK")
s = normalize(id="NORMALIZE", s)
output(s)
