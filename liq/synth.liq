#!/usr/bin/env liquidsoap
s = midi.inspect(single("test.mid"))
s = synth.all.saw(s)
s = drop_midi(s)
output(s)
