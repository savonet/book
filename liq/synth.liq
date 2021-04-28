#!/usr/bin/env liquidsoap
s = midimeter(single("test.mid"))
s = synth.all.saw(s)
s = drop_midi(s)
output(s)
