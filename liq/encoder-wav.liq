#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%wav(stereo=true, channels=2, samplesize=16, header=true, duration=10.)
, "/tmp/out", s)
