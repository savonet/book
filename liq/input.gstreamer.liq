#!/usr/bin/env liquidsoap
s = input.gstreamer.audio(pipeline="audiotestsrc")
out(s)
