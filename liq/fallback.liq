#!/usr/bin/env liquidsoap
stream    = buffer(input.http("http://..."))
emergency = playlist("~/Music")
s         = fallback([stream, emergency])
output(s)
