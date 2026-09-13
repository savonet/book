#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%ffmpeg(format="mp3",
        %audio(codec="libmp3lame", samplerate=44100, q=4))
# footer
, "/tmp/out", s)
