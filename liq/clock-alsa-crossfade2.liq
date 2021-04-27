#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.alsa(clock_safe=false, s)
output.alsa(mksafe(crossfade(s)))
