#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%mp3(bitrate=128)
, "/tmp/out", s)
