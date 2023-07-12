#!./liquidsoap
log.level := 5
s = single("test.mid")
s = source.mux.audio(audio=blank(), s)
s = midi.inspect(s)
s = synth.all.sine(s)
output(s)
