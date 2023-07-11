#!/usr/bin/env liquidsoap
log.level := 5
low = sine(id="low", duration=2., 220.)
med = sine(id="med", duration=2., 440.)
hi  = sine(id="hi",  duration=2., 880.)
s   = sequence([low, med, hi])
output(s)
