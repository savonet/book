#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%ffmpeg(format="mpegts",
        %audio(codec="libfdk_aac", vbr=4))
, "/tmp/out", s)
