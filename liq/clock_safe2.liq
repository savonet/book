#!./liquidsoap
s = input.alsa(self_sync=false)
output.pulseaudio(s)
