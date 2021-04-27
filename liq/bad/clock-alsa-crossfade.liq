#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.alsa(s)
output.alsa(crossfade(s))
