#!./liquidsoap
log.level := 5; s = single("lf.mp4") output.file(
%ffmpeg(format="webm",
        %audio(codec="libopus", samplerate=48000, b="128k"),
        %video(codec="libvpx-vp9", width=854, height=480, g=75,
               quality="realtime", speed=7, b="500k"))
, "/tmp/out.webm", s) output.audio_video(s)
