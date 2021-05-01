#!./liquidsoap
s = mksafe(single(fallible=true, "lf.mp4")) output.file(
%ffmpeg(format="avi",
        %audio(codec="libmp3lame", b="128k"),
        %video(codec="libx264",    b="2500k"))
, "/tmp/out.avi", s)
