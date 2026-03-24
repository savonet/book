#!./liquidsoap
s = mksafe(playlist("videos.playlist"))
output.sdl(s)
output.pulseaudio(s)
