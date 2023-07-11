#!./liquidsoap
s = midi.inspect(single("test.mid"))
s = synth.all.saw(s)
output(s)
