#!./liquidsoap
s = single("movie.mkv")
output.file(
  %ffmpeg(format="matroska", %audio.copy, %audio_2(codec="aac"), %video.copy),
  "output.mkv", s)
