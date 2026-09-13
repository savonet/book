#!./liquidsoap
# header
s = mksafe(buffer(input.srt()))
output.pulseaudio(crossfade(s))
