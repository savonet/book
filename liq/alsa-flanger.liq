#!./liquidsoap
s = input.alsa()
output.alsa(fallible=true, flanger(s))
