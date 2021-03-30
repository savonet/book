#!./liquidsoap
# s = playlist("~/Music")
s = buffer.adaptative(input.pulseaudio())
s = rms(s)
rms = s.rms
s = gate(threshold=-30., range=-80., s)
s = source.run(s, every=.5, {print("rms: #{dB_of_lin(rms())}\tgate: #{s.gate()}")})
output(s)
