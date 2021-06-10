#!./liquidsoap
s = buffer(input.alsa())
output.pulseaudio(s)