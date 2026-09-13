#!./liquidsoap
s = single("lf.mp4")
output.file(
# header
%ffmpeg(format="mpegts",
        %audio(codec="aac", b="96k"),
        %video(codec="libx264", preset="ultrafast", b="2500k"))
# footer
, "/tmp/out.mpegts", s)
output.audio_video(s)
