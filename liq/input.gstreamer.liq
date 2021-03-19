#!/usr/bin/env liquidsoap
s = input.gstreamer.audio(pipeline=
      "audiotestsrc ! audioamplify amplification=1.5")
output(s)
