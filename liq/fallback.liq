#!/usr/bin/env liquidsoap
stream    = input.http("http://...")
emergency = playlist("~/Music")
s         = fallback([stream, emergency])
output(s)
