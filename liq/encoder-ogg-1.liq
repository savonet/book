#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%ogg(%opus)
, "/tmp/out", s)
