#!/usr/bin/env liquidsoap
enable_replaygain_metadata()
s = replaygain(playlist("~/Music"))
output(s)
