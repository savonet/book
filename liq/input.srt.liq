#!./liquidsoap
s = input.srt()
output.pulseaudio(fallible=true, buffer(fallible=true, s))
