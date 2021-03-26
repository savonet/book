#!/usr/bin/env liquidsoap
s = replaygain(playlist(prefix="replaygain:", "~/Music"))
output(s)
