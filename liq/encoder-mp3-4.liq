#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%mp3.fxp(channels=2, samplerate=44100, bitrate=128)
# footer
, "/tmp/out", s)
