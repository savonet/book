#!./liquidsoap
s = once(single("http://server/file.mp3"))
output(s)
