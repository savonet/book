#!/usr/bin/env liquidsoap
s = replaygain(playlist("~/Music"))
output(s)
