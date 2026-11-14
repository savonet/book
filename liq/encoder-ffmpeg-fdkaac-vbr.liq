#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%ffmpeg(format="mpegts", %audio(codec="libfdk_aac", vbr=3))
# footer
, "/tmp/out", s)
