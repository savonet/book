#!/usr/bin/env liquidsoap
s = sine(duration=3.)
s = fade.in(s)
output(s)
output.file(fallible=true, %mp3, "/tmp/out.mp3", s)
