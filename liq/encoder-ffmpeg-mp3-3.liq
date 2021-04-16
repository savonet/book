#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%ffmpeg(format="mp3",
        %audio(codec="libmp3lame", b="160k", abr=1))
, "/tmp/out", s)
