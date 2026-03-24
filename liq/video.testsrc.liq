#!./liquidsoap
s = video.testsrc()
output.sdl(fallible=true, s)
