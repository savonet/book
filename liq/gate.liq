#!./liquidsoap
mic = buffer(input.pulseaudio())
mic = gate(threshold=-30., range=-80., mic)
output(mic)
