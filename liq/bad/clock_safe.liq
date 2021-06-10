#!./liquidsoap
s = input.alsa()
output.pulseaudio(s)