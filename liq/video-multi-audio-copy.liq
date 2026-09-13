#!./liquidsoap
s = single("movie.mkv")
# header
output.file(
  %ffmpeg(format="matroska", %audio.copy, %audio_2(codec="aac"), %video.copy),
  "output.mkv", s)
