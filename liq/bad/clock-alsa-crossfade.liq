#!./liquidsoap
s = mksafe(input.srt())
output.pulseaudio(crossfade(s))
