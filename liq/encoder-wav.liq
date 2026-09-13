#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%wav(stereo=true, channels=2, samplesize=16, header=true, duration=10.)
# footer
, "/tmp/out", s)
