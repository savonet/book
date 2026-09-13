#!./liquidsoap
s = playlist("~/Music")
enc =
# header
%ffmpeg(format="mp3", %audio.copy)
# footer
output.file(fallible=true, enc, "/tmp/out", s)
