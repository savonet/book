#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%opus
, "/tmp/out", s)
