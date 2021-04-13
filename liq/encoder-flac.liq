#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%flac(samplerate=44100, channels=2, compression=5, bits_per_sample=16)
, "/tmp/out", s)
