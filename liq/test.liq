#!./liquidsoap
log.level.set(5)
s = playlist("~/Music")
output.file(fallible=true,
%ffmpeg(format="ogg", %audio(codec="libopus", samplerate=48000, b="128k")), "/tmp/out.ogg", s)
output(s)
