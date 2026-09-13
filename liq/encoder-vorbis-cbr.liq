#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%vorbis.cbr(samplerate=44100, channels=2, bitrate=128)
# footer
, "/tmp/out", s)
