#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%opus
# footer
, "/tmp/out", s)
