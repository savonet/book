#!./liquidsoap
s = single("lf.mp4") output.file(
%ffmpeg(format="mp4",
        %audio(codec="libmp3lame", q=4),
        %video(codec="libx264", preset="fast", crf=20))
, "/tmp/out.mp4", s) output.audio_video(s)
