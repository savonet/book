#!./liquidsoap
s = mksafe(playlist("~/Music"))
enc =
# header
%ffmpeg(format="mp3", %audio(codec="libmp3lame"))
# footer
output.file(enc, "/tmp/out", s)
