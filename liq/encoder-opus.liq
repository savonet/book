#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%opus(samplerate=48000, bitrate=192, vbr="none", application="audio",
      channels=2, signal="music", max_bandwidth="full_band")
# footer
, "/tmp/out", s)
