#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%opus(bytes_per_page=1024)
, "/tmp/out", s)
