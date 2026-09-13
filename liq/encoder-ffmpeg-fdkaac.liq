#!./liquidsoap
s = mksafe(playlist("~/Music"))
output.file(
# header
%ffmpeg(format="mpegts",
        %audio(codec="libfdk_aac", samplerate=22050, b="32k",
               afterburner=1, profile="aac_he_v2"))
# footer
, "/tmp/out", s)
