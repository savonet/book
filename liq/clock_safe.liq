#!./liquidsoap
s = buffer(input.alsa())
output.pulseaudio(fallible=true, s)