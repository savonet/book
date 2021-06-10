#!./liquidsoap
s = input.alsa(clock_safe=false)
output.pulseaudio(s)