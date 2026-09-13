#!./liquidsoap
s = mksafe(single(fallible=true, "lf.mp4"))
output.file(
# header
%ffmpeg(format="avi",
        %audio(codec="libmp3lame", b="128k"),
        %video(codec="libx264",    b="2500k"))
# footer
, "/tmp/out.avi", s)
