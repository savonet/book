#!./liquidsoap
s = mksafe(playlist("~/Music")) output.file(
%ffmpeg(format="mp3",
        %audio(codec="libmp3lame", samplerate=44100, q=4))
, "/tmp/out", s)
