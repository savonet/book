#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%ffmpeg(format="ogg", %audio(codec="libopus", samplerate=48000))
, "/tmp/out", s)
