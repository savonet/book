#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%external(process="lame - -")
, "/tmp/out", s)
