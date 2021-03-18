#!/usr/bin/env liquidsoap
s = input.http("http://...")
output.pulseaudio(s)
