#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%mp3(bitrate=128)
# footer
, "/tmp/out", s)
