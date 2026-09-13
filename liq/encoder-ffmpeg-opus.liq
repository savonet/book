#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%ffmpeg(format="ogg", %audio(codec="libopus", samplerate=48000))
# footer
, "/tmp/out", s)
