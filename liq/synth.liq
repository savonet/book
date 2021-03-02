#!/usr/bin/env liquidsoap
s = single("test.mid")
s = synth.all.saw(s)
s = drop_midi(s)
output(s)
