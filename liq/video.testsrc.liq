#!./liquidsoap
# header
s = video.testsrc()
# footer
output.sdl(fallible=true, s)
