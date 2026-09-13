#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%vorbis(samplerate=44100, channels=2, quality=0.3)
# footer
, "/tmp/out", s)
