#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.alsa(mksafe(buffer(s)))
output.pulseaudio(s)
