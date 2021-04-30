#!./liquidsoap
s = single("lf.mp4") output.file(
%ffmpeg(format="mpegts",
        %audio(codec="aac", b="96k"),
        %video(codec="libx264", preset="ultrafast", b="2500k"))
, "/tmp/out.mpegts", s) output.audio_video(s)
