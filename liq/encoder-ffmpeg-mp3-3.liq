#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%ffmpeg(format="mp3",
        %audio(codec="libmp3lame", b="160k", abr=1))
# footer
, "/tmp/out", s)
