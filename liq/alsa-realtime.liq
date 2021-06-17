#!./liquidsoap
s = input.alsa(bufferize=false)
output.alsa(bufferize=false, flanger(s))
