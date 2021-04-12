#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%mp3.vbr(quality=7, samplerate=22050)
, "/tmp/out", s)
