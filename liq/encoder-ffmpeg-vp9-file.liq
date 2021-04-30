#!./liquidsoap
log.level.set(5) s = single("lf.mp4") output.file(
%ffmpeg(format="webm",
        %audio(codec="libopus", samplerate=48000, b="128k"),
        %video(codec="libvpx-vp9", quality="realtime", speed=6,
               b="2500k"))
, "/tmp/out.webm", s) output.audio_video(s)
