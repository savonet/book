#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%mp3.abr(bitrate=128, max_bitrate=192, id3v2=true)
, "/tmp/out", s)
