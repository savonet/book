#!/usr/bin/env liquidsoap
log.level := 5
s = blank(id="BLANK")
s = normalize(id="NORMALIZE", s)
output(s)
