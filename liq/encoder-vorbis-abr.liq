#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%vorbis.abr(samplerate=44100, channels=2, bitrate=128,
            min_bitrate=64, max_bitrate=192)
# footer
, "/tmp/out", s)
