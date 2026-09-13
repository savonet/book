#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%flac(samplerate=44100, channels=2, compression=5, bits_per_sample=16)
# footer
, "/tmp/out", s)
