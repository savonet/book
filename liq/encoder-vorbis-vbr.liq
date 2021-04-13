#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%vorbis(samplerate=44100, channels=2, quality=0.3)
, "/tmp/out", s)
