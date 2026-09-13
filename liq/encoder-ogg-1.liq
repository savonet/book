#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%ogg(%opus)
# footer
, "/tmp/out", s)
