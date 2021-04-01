#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(%mp3, "out.mp3", s)
