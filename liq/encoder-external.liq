#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%external(process="lame - -")
# footer
, "/tmp/out", s)
