#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%mp3.vbr(quality=7, samplerate=22050)
# footer
, "/tmp/out", s)
