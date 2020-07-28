#!/usr/bin/env liquidsoap
s = input.gstreamer.audio(pipeline='filesrc location="test.mp3"')
output(s)
