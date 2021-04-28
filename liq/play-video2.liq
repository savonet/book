#!./liquidsoap
s = mksafe(playlist("videos.playlist"))
output.graphics(s)
output.pulseaudio(s)