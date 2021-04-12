#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%mp3.fxp(channels=2, samplerate=44100, bitrate=128)
, "/tmp/out", s)
