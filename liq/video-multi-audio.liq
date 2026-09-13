#!./liquidsoap
s = single("movie.mkv")
# header
output.file(
  %ffmpeg(%audio_en(codec="aac"), %audio_fr(codec="aac"), %video.copy),
  "output.mkv", s)
