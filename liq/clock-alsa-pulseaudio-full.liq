#!./liquidsoap
# header
s = mksafe(playlist("~/Music"))
output.alsa(s)
output.pulseaudio(s)
