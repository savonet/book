#!./liquidsoap
# header
radio = playlist("http://www.some-server.com/playlist")
# footer
output(mksafe(radio))
