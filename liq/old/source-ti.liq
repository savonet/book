#!./liquidsoap -i
s = fail()
output.alsa(fallible=true, s)
output.sdl(fallible=true, s)
