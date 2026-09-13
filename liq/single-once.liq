#!./liquidsoap
# header
s = once(single("http://server/file.mp3"))
# footer
output(s)
