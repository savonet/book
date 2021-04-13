#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%vorbis.cbr(samplerate=44100, channels=2, bitrate=128)
, "/tmp/out", s)
