#!./liquidsoap
log.level := 5
s = (single("test.mid"):source(audio=none,video=none))
s = mux_audio(audio=blank(), s)
s = midi.inspect(s)
s = synth.all.sine(s)
output(s)
