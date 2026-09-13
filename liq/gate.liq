#!./liquidsoap
# header
mic = buffer(input.pulseaudio())
mic = gate(threshold=-30., range=-80., mic)
# footer
output(mic)
